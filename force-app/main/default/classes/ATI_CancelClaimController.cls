/*  
Class Name   : ATI_CancelClaimController
Description  : Ability to cancel a claim
Created Date : Dec 13th, 2022 ( ALSN-86)
*/
public class ATI_CancelClaimController {      
    @AuraEnabled    
    public static ResponseWrapper cancelClaim(Id claimId){
        try{
            Integer pending=0;
            Integer paid=0;
            WOD_2__Claim__c clm= [select id,WOD_2__Claim_Status__c,ATI_Tracking_Number__c from WOD_2__Claim__c where Id=:claimId];
            List<WOD_2__Transaction_Memo_History__c> tmh =[Select Id,WOD_2__Claim__c,WOD_2__Transaction_Status__c from WOD_2__Transaction_Memo_History__c where WOD_2__Claim__c=:claimId];
            List<WOD_2__Shipment_Detail__c> shpLst =[Select Id,WOD_2__Claim__c,WOD_2__Claim__r.WOD_2__Claim_Status__c from WOD_2__Shipment_Detail__c where WOD_2__Claim__c=:claimId];
            List<twodcms__Member_Template_Association__c> cmpgnMemLst =[Select Id,twodcms__Claim__c from twodcms__Member_Template_Association__c where twodcms__Claim__c=:claimId];
            List<WOD_2__Shipment_Detail__c> updateShp = new List<WOD_2__Shipment_Detail__c>();
            for(WOD_2__Transaction_Memo_History__c tmhLst:tmh){               
                if(tmhLst.WOD_2__Transaction_Status__c =='Pending'){
                    pending++;
                }
                if(tmhLst.WOD_2__Transaction_Status__c == 'Paid'){
                    paid++;
                }
            }
            if(clm.WOD_2__Claim_Status__c=='Additional Information Required'){
                ProcessInstanceWorkitem workItem = [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: clm.Id AND ProcessInstance.Status = 'Pending'];
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setComments('Claim is Cancelled');
                req.setAction('Removed');
                req.setWorkitemId(workItem.id);
                Approval.ProcessResult result =  Approval.process(req);
            }
            if(clm.id!=null && ((clm.WOD_2__Claim_Status__c =='Draft' || clm.WOD_2__Claim_Status__c=='Additional Information Required' || clm.WOD_2__Claim_Status__c == 'Appeal') && tmh.size()==0) ||((clm.WOD_2__Claim_Status__c =='Appeal' || clm.WOD_2__Claim_Status__c =='Additional Information Required') && paid>0)){             
                if((clm.WOD_2__Claim_Status__c =='Draft' || clm.WOD_2__Claim_Status__c=='Additional Information Required' || clm.WOD_2__Claim_Status__c == 'Appeal') && tmh.size()==0){
                    if(cmpgnMemLst.size()>0){
                        //ALSN-209 deleting the MTA record using without sharing
                        ATI_QueryRunWithoutSharing.deleteData(cmpgnMemLst,true); 
                        //delete cmpgnMemLst;
                    }                   
                    String trackingNumber = clm.ATI_Tracking_Number__c;
                    clm.ATI_Tracking_Number__c = trackingNumber +'-'+'Cancelled';
                    for(WOD_2__Shipment_Detail__c shp:shpLst){                  
                        shp.WOD_2__Status__c ='Rejected';
                        updateShp.add(shp);                
                    }
                    if(updateShp.size()>0){
                        update updateShp;
                    }
                }
                clm.WOD_2__Claim_Status__c = 'Cancelled';                        
                update clm;                              
                return new ResponseWrapper('',true,'');
            }   
            else{
                return new ResponseWrapper('',false,'Claim cannot be cancelled');
            }
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            return new ResponseWrapper('',false,e.getMessage());
        }
    }
}