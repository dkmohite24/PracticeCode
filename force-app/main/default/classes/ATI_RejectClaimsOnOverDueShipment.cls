/*
Class Name  :   ATI_RejectClaimsOnOverDueShipment
Description :   Batch apex class to reject the claims when shipment is not generated after x days(configured in BU) from shipment overdue date
Create On   :   March 12th 2021
*/
global with sharing class ATI_RejectClaimsOnOverDueShipment implements database.Batchable<sObject>, database.stateful {
    global Integer days = 0;
    global String claimStatus = 'Reopened';
    global database.QueryLocator start(database.BatchableContext bc){
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c 
                                                                            FROM WOD_2__Business_Category_Configuration_Setting__c 
                                                                            WHERE Name = 'Shipment Overdue Additional days' OR 
                                                                            Name = 'Claim Status On Shipment Over Due']; 
        for(WOD_2__Business_Category_Configuration_Setting__c bccsObj : bccsList){
            if(bccsObj.Name == 'Shipment Overdue Additional days'){
                days =  Integer.valueOf(bccsObj.WOD_2__Value__c);
            }
            if(bccsObj.Name == 'Claim Status On Shipment Over Due'){
                claimStatus = String.valueOf(bccsObj.WOD_2__Value__c);
            }
        }
        
        string query = 'SELECT Id,WOD_2__Shipment_Detail__r.WOD_2__Status__c,WOD_2__Removed_Claim_Part__r.WOD_2__Shipment_Due_Date__c,'
            +'WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c FROM WOD_2__Claim_Shipment__c '
            +'WHERE WOD_2__Shipment_Detail__r.WOD_2__Status__c=\'Draft\' AND WOD_2__Removed_Claim_Part__r.WOD_2__Shipment_Due_Date__c < today'
            +' AND WOD_2__Removed_Claim_Part__r.WOD_2__Shipment_Due_Date__c!=NULL AND WOD_2__Removed_Claim_Part__r.WOD_2__Claim__r.WOD_2__Claim_Status__c = \'Approved\'';
        System.debug('>> query :'+query);
        return database.getQueryLocator(query); 
    }   
    global void execute(database.BatchableContext bc, List<WOD_2__Claim_Shipment__c> claimShipmentLst){
        List<WOD_2__Claim__c> claimsToUpdateLst = new List<WOD_2__Claim__c>();
        List<ATI_CommentWrapper> wrapList = new List<ATI_CommentWrapper>();
        List<WOD_2__Removed_Claim_Part__c> rcpToUpdate = new List<WOD_2__Removed_Claim_Part__c>();
        for(WOD_2__Claim_Shipment__c claimShipmentObj : claimShipmentLst)
        {
            if(claimShipmentObj.WOD_2__Removed_Claim_Part__r.WOD_2__Shipment_Due_Date__c.daysBetween(system.today())>=days){
                WOD_2__Claim__c claimObj = new WOD_2__Claim__c();
                claimObj.id = claimShipmentObj.WOD_2__Removed_Claim_Part__r.WOD_2__Claim__c;
                claimObj.WOD_2__Claim_Status__c = claimStatus;
                claimObj.Shipment_Status__c = 'Partial Shipment';
                claimsToUpdateLst.add(claimObj);
                System.debug('clmlst'+claimsToUpdateLst);
                WOD_2__Removed_Claim_Part__c rcpObj = new WOD_2__Removed_Claim_Part__c(Id=claimShipmentObj.WOD_2__Removed_Claim_Part__c);
                rcpObj.ATI_is_OverDue__c = true;
                rcpObj.WOD_2__Inspection_Status__c = 'Rejected';
                rcpToUpdate.add(rcpObj);
                
                // Alsn - 145  ***update external comments on the conversation history of all the claims in list***
                List<WOD_2__Claim__c> clm=[SELECT Id,Name,WOD_2__Chatter_Comments__c FROM WOD_2__Claim__c WHERE Id in:claimsToUpdateLst];
                System.debug('clmm'+clm);
                for(WOD_2__Claim__c clmObj: clm){
                    WOD_2__Shipment_Detail__c clmShp = [Select Id,Name,WOD_2__Claim__c,WOD_2__Status__c from WOD_2__Shipment_Detail__c where WOD_2__Claim__c in:clm];
                    ATI_CommentWrapper wrap = new ATI_CommentWrapper();
                    wrap.u=userinfo.getUserId();
                    wrap.t='C';
                    wrap.ind='EC';
                    wrap.i='2224';
                    wrap.d=date.today();
                    wrap.c=Label.Shipment+' '+clmShp.Name +' '+Label.ATI_ShipmentMessage;
                    wrapList.add(wrap);
                    clmShp.WOD_2__Status__c = 'Rejected';
                    update clmShp;
                }
                String finalStr;
                String test = JSON.serialize(wrapList);
                WOD_2__Claim__c claim= [SELECT Id,Name,CreatedById,WOD_2__Chatter_Comments__c FROM WOD_2__Claim__c WHERE Id in:clm];
                String oldComment = String.valueof(claim.WOD_2__Chatter_Comments__c);
                if(oldComment != null){
                    String oldStr=oldComment;
                    String trimOldStr = oldStr.Substring(0,oldStr.length()-1);
                    String newStr = test;
                    String finalComment = newStr.Substring(1,newStr.length()-1);
                    finalStr = trimOldStr + ',' + finalComment +']';
                }else{
                    finalStr =  test;
                }
                claim.WOD_2__Chatter_Comments__c=finalStr;
                update claim;
                
                
                // end of Alsn-145
            }
        }        
        if(claimsToUpdateLst.size() > 0){
            TriggerHandler.bypass('ATI_ClaimTriggerHandler');
            TriggerHandler.bypass('ATI_RemovedClaimPartTriggerHandler');
            update claimsToUpdateLst;
            System.debug('updated');
            update rcpToUpdate;
            TriggerHandler.clearAllBypasses();
        }
        // Alsn - 145...
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(WOD_2__Claim__c workItem : claimsToUpdateLst){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(workItem.Id);
            requests.add(req);
        } 
        Approval.ProcessResult[] processResults = Approval.process(requests);
        // end of Alsn -145
    }
    
    global void finish(database.BatchableContext bc){
        
    }
}