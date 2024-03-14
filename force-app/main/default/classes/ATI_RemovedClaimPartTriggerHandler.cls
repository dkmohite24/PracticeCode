/* Name: ATI_RemovedClaimPartTriggerHandler
Description : Handler for creating rollup summary fields on claim object
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL              UserStory/Req#
1.0 -     Tavant(TY)      01-Mar-2021      INITIAL DEVELOPMENT                              
*/
public class ATI_RemovedClaimPartTriggerHandler extends TriggerHandler{
    private Map<Id,WOD_2__Claim__c> mapOfIdWithClaims;
    private List<WOD_2__Removed_Claim_Part__c> rcpLst;
    private List<WOD_2__Removed_Claim_Part__c> newRCPList;
    private List<WOD_2__Removed_Claim_Part__c> oldRCPList; 
    private Map<id,WOD_2__Removed_Claim_Part__c> rcpOldMap;// Added By Mukesh
    Map<Id, WOD_2__Removed_Claim_Part__c> rcpNewMap;
    public static Boolean skipRemovedPartTriggerForITR = false;
    public static Boolean skipPRCForITR = false;
    private static Boolean isClaimUpdate = true;
    //Map<Id, WOD_2__Removed_Claim_Part__c> rcpOldMap = (Map<Id, WOD_2__Removed_Claim_Part__c>)trigger.oldMap;
    
    /*
Method Name :   ATI_RemovedClaimPartTriggerHandler
Params      :   Constructor
*/
    public ATI_RemovedClaimPartTriggerHandler(){
        this.mapOfIdWithClaims = new Map<Id,WOD_2__Claim__c>();
        this.newRCPList = (List<WOD_2__Removed_Claim_Part__c>)Trigger.new;
        this.oldRCPList = (List<WOD_2__Removed_Claim_Part__c>)Trigger.old;
        this.rcpOldMap = (Map<id,WOD_2__Removed_Claim_Part__c>)Trigger.oldMap; 
        this.rcpNewMap =(Map<Id, WOD_2__Removed_Claim_Part__c>)trigger.newMap;
    }
    public override void beforeInsert(){
        if(!skipRemovedPartTriggerForITR){
            Map<ID,WOD_2__Claim__c> claimIdToClaimRecordMap = New Map<ID,WOD_2__Claim__c>();
            for (WOD_2__Removed_Claim_Part__c removeClaimRec: newRCPList){
                if( removeClaimRec.WOD_2__Claim__c != NULL){
                    claimIdToClaimRecordMap.put(removeClaimRec.WOD_2__Claim__c,new WOD_2__Claim__c());  
                }
                
            }
            for(WOD_2__Claim__c claim : [SELECT Id,ATI_Account_Email__c,WOD_2__Inventory__c FROM WOD_2__Claim__c WHERE ID IN:claimIdToClaimRecordMap.keySet()]){
                claimIdToClaimRecordMap.put(claim.Id,claim); 
            }
            for (WOD_2__Removed_Claim_Part__c removeClaimRec: newRCPList){
                if( removeClaimRec.WOD_2__Claim__c != NULL){
                    removeClaimRec.ATI_Claim_Email__c = claimIdToClaimRecordMap.get(removeClaimRec.WOD_2__Claim__c).ATI_Account_Email__c;
                    removeClaimRec.WOD_2__Inventory__c = claimIdToClaimRecordMap.get(removeClaimRec.WOD_2__Claim__c).WOD_2__Inventory__c;
                }
            }
        }
    }
    
    public override void afterInsert(){
        shareRCPRecordsToPublicGroup();
        //createOrUpdateRollUpSummaryFields();
        //checkPayMentConditionUpdateClaimAfterInsert(newRCPList);
    }
    
    public override void afterUpdate() {
        createOrUpdateRollUpSummaryFields();
        if(!skipPRCForITR){
            backUpdateClaimPRCStatus();//Added by Mukesh 
            updateClaimOnInspectionRejection(rcpOldMap);
        }
    }
    
    public override void afterUndelete() {
        createOrUpdateRollUpSummaryFields();
    }
    
    public override void afterDelete() {
        createOrUpdateRollUpSummaryFields();
    }
    
    //share wr records to parents
    public static void shareRCPRecordsToPublicGroup(){
        set<String> accGroupIds = new set<String>();
        set<Id> rcpIds = new set<Id>();
        for(WOD_2__Removed_Claim_Part__c rcpObj : [SELECT Id,WOD_2__Claim__r.WOD_2__Account__c FROM WOD_2__Removed_Claim_Part__c
                                                   WHERE Id IN:Trigger.New]){
                                                       accGroupIds.add('ATI_Dealer_'+ rcpObj.WOD_2__Claim__r.WOD_2__Account__c);
                                                       rcpIds.add(rcpObj.Id);
                                                   }
        if(!rcpIds.isEmpty() && !accGroupIds.isEmpty() && !system.isBatch()){
            ATI_QueueableUtil.enqueueJob(new ATI_ShareRCPToPublicGroupQueueable(accGroupIds,rcpIds));
        }else if(!rcpIds.isEmpty() && !accGroupIds.isEmpty() && system.isBatch()){
            new ATI_ShareRCPToPublicGroupQueueable(accGroupIds,rcpIds).execute(null); 
        }
    }
    
    //Move claim to pending approval when any part is rejected
    private static void updateClaimOnInspectionRejection(Map<id,WOD_2__Removed_Claim_Part__c> rcpOldMap){
        Map<Id,WOD_2__Claim__c> claimsToUpdateMap = new Map<Id,WOD_2__Claim__c>();
        for(WOD_2__Removed_Claim_Part__c rcPartObj : (List<WOD_2__Removed_Claim_Part__c>)Trigger.New){
            if((rcPartObj.WOD_2__Inspection_Status__c == 'Rejected' || rcPartObj.WOD_2__Inspection_Status__c =='Inspection Error')
               && !claimsToUpdateMap.containsKey(rcPartObj.WOD_2__Claim__c)){
                   // claimsToUpdateMap.put(rcPartObj.WOD_2__Claim__c, new WOD_2__Claim__c(Id=rcPartObj.WOD_2__Claim__c,
                   //          WOD_2__Claim_Status__c='Pending Approval'));
                   if(rcpOldMap.get(rcPartObj.Id).WOD_2__Claim__r.WOD_2__Claim_Status__c == 'Approved' && rcpOldMap.get(rcPartObj.Id).WOD_2__Claim__r.Shipment_Status__c =='Partial Shipment'){  
                       rcpOldMap.get(rcPartObj.Id).WOD_2__Claim__r.WOD_2__In_Approval_Process__c = true;
                   }
               }
        }
        
        if(claimsToUpdateMap.values().size() > 0){
            update claimsToUpdateMap.values();
        }
    }
    
    private void createOrUpdateRollUpSummaryFields(){
        if(!skipRemovedPartTriggerForITR && isClaimUpdate){
            if(Trigger.isDelete){
                rcpLst = this.oldRCPList;
            }else{
                rcpLst =  this.newRCPList;
            }
            //create context with required roll up summary fields for PRCTriggeredParts
            ATI_LREngine.Context prcTriggeredParts = new ATI_LREngine.Context(WOD_2__Claim__c.SobjectType, // parent object
                                                                              WOD_2__Removed_Claim_Part__c.SobjectType,  // child object
                                                                              Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.WOD_2__Claim__c, // relationship field name
                                                                              'WOD_2__Part_Return_Requested__c = TRUE'  // filters                   
                                                                             );
            /*
Next, one can add multiple rollup fields on the above relationship. 
Here specify 
1. The field to which aggregated value will be saved in master/parent object
2. The field to aggregate in child object
3. The aggregate operation to be done i.e. SUM, AVG, COUNT, MIN/MAX
*/
            prcTriggeredParts.add(new ATI_LREngine.RollupSummaryField(
                Schema.SObjectType.WOD_2__Claim__c.fields.ATI_No_of_Requested_Parts__c,
                Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.Id,
                ATI_LREngine.RollupOperation.Count
            ));
            
            /* 
Calling rollup method returns in memory master objects with aggregated values in them. 
Please note these master records are not persisted back, so that client gets a chance 
to post process them after rollup
*/ 
            List<WOD_2__Claim__c> prcPartsLst = (List<WOD_2__Claim__c>)ATI_LREngine.rollUp(prcTriggeredParts, rcpLst);
            for(WOD_2__Claim__c claim : prcPartsLst){
                if(mapOfIdWithClaims.containsKey(claim.id)){
                    WOD_2__Claim__c claimData = mapOfIdWithClaims.get(claim.id);
                    claimData.ATI_No_of_Requested_Parts__c = claim.ATI_No_of_Requested_Parts__c;
                    mapOfIdWithClaims.put(claim.id,claimData);
                }else{
                    if(claim.id != null){
                        mapOfIdWithClaims.put(claim.id,claim); 
                    }               
                }
            }
            
            // create context with required roll up summary fields for ShippedParts
            ATI_LREngine.Context shippedParts = new ATI_LREngine.Context(WOD_2__Claim__c.SobjectType, // parent object
                                                                         WOD_2__Removed_Claim_Part__c.SobjectType,  // child object
                                                                         Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.WOD_2__Claim__c, // relationship field name
                                                                         'WOD_2__Part_Return_Requested__c = TRUE AND WOD_2__Is_Shipped__c = TRUE'  // filters                   
                                                                        );
            
            shippedParts.add(new ATI_LREngine.RollupSummaryField(
                Schema.SObjectType.WOD_2__Claim__c.fields.ATI_No_of_Shipped_Parts__c,
                Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.Id,
                ATI_LREngine.RollupOperation.Count
            )); 
            List<WOD_2__Claim__c> shippedPartsLst = (List<WOD_2__Claim__c>)ATI_LREngine.rollUp(shippedParts, rcpLst);
            for(WOD_2__Claim__c claim : shippedPartsLst){
                if(mapOfIdWithClaims.containsKey(claim.id)){
                    WOD_2__Claim__c claimData = mapOfIdWithClaims.get(claim.id);
                    claimData.ATI_No_of_Shipped_Parts__c = claim.ATI_No_of_Shipped_Parts__c;
                    mapOfIdWithClaims.put(claim.id,claimData);
                }else{
                    if(claim.id != null){
                        mapOfIdWithClaims.put(claim.id,claim); 
                    }
                }
            }
            
            // create context with required roll up summary fields for ReceivedParts
            ATI_LREngine.Context receivedParts = new ATI_LREngine.Context(WOD_2__Claim__c.SobjectType, // parent object
                                                                          WOD_2__Removed_Claim_Part__c.SobjectType,  // child object
                                                                          Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.WOD_2__Claim__c, // relationship field name
                                                                          'WOD_2__Part_Return_Requested__c = TRUE AND WOD_2__Is_Returned__c = TRUE'  // filters                   
                                                                         );
            
            receivedParts.add(new ATI_LREngine.RollupSummaryField(
                Schema.SObjectType.WOD_2__Claim__c.fields.ATI_No_of_Received_Parts__c,
                Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.Id,
                ATI_LREngine.RollupOperation.Count
            )); 
            List<WOD_2__Claim__c> receivedPartsLst = (List<WOD_2__Claim__c>)ATI_LREngine.rollUp(receivedParts, rcpLst);
            for(WOD_2__Claim__c claim : receivedPartsLst){
                if(mapOfIdWithClaims.containsKey(claim.id)){
                    WOD_2__Claim__c claimData = mapOfIdWithClaims.get(claim.id);
                    claimData.ATI_No_of_Received_Parts__c = claim.ATI_No_of_Received_Parts__c;
                    mapOfIdWithClaims.put(claim.id,claimData);
                }else{
                    if(claim.id != null){
                        mapOfIdWithClaims.put(claim.id,claim); 
                    }   
                }
            }
            
            //create context with required roll up summary fields for InspectedParts
            ATI_LREngine.Context inspectedParts = new ATI_LREngine.Context(WOD_2__Claim__c.SobjectType, //parent object
                                                                           WOD_2__Removed_Claim_Part__c.SobjectType,  //child object
                                                                           Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.WOD_2__Claim__c, // relationship field name
                                                                           'WOD_2__Part_Return_Requested__c = TRUE AND WOD_2__Is_Inspected__c = TRUE'  // filters                   
                                                                          );
            
            inspectedParts.add(new ATI_LREngine.RollupSummaryField(
                Schema.SObjectType.WOD_2__Claim__c.fields.ATI_No_of_Inspected_Parts__c,
                Schema.SObjectType.WOD_2__Removed_Claim_Part__c.fields.Id,
                ATI_LREngine.RollupOperation.Count
            )); 
            List<WOD_2__Claim__c> inspectedPartsLst = (List<WOD_2__Claim__c>)ATI_LREngine.rollUp(inspectedParts, rcpLst);
            for(WOD_2__Claim__c claim : inspectedPartsLst){
                if(mapOfIdWithClaims.containsKey(claim.id)){
                    WOD_2__Claim__c claimData = mapOfIdWithClaims.get(claim.id);
                    claimData.ATI_No_of_Inspected_Parts__c = claim.ATI_No_of_Inspected_Parts__c;
                    mapOfIdWithClaims.put(claim.id,claimData);
                }else{
                    if(claim.id != null){
                        mapOfIdWithClaims.put(claim.id,claim); 
                    }               
                }
            }
            if(!mapOfIdWithClaims.isEmpty()){
                TriggerHandler.bypass('ATI_ClaimTriggerHandler');
                update mapOfIdWithClaims.values();
                isClaimUpdate = false;
                TriggerHandler.clearByPass('ATI_ClaimTriggerHandler');
            }
        }
    }
    
    /* Method Created By Mukesh 3/22/2021
* 
*/
    private void backUpdateClaimPRCStatus() {
        Map<Id, List<WOD_2__Removed_Claim_Part__c> > claimRCPMap = new Map<Id, List<WOD_2__Removed_Claim_Part__c> >();
        Boolean claimUpdated = false;
        List<WOD_2__Claim__c> claimList = new List<WOD_2__Claim__c>();
        List<Id> impactedClaimIdList = new List<Id>();
        List<Id> completedClaimIdList = new List<Id>();
        Set<Id> idsSetTest = new Set<Id>();
        for(WOD_2__Removed_Claim_Part__c rcp : rcpNewMap.values()){
            if(rcp.WOD_2__Payment_Condition__c == 'Pay After Return' && rcp.WOD_2__Is_Returned__c && !rcpOldMap.get(rcp.Id).WOD_2__Is_Returned__c)
                impactedClaimIdList.add(rcp.WOD_2__Claim__c);
            if(rcp.WOD_2__Payment_Condition__c == 'Pay After Ship' && rcp.WOD_2__Is_Shipped__c && !rcpOldMap.get(rcp.Id).WOD_2__Is_Shipped__c)
                impactedClaimIdList.add(rcp.WOD_2__Claim__c);
            if(rcp.WOD_2__Payment_Condition__c == 'Pay After Inspection' && rcp.WOD_2__Is_Inspected__c && !rcpOldMap.get(rcp.Id).WOD_2__Is_Inspected__c)
                impactedClaimIdList.add(rcp.WOD_2__Claim__c);
            //Alsn-143
            if(rcp.WOD_2__Payment_Condition__c =='Pay After Inspection' && rcp.Inspected_Quantity__c!=rcp.WOD_2__Shipped_Quantity__c )
                impactedClaimIdList.add(rcp.WOD_2__Claim__c);
            if(rcp.WOD_2__Payment_Condition__c =='Pay After Inspection' && rcp.Inspected_Quantity__c==rcp.WOD_2__Shipped_Quantity__c)
                completedClaimIdList.add(rcp.WOD_2__Claim__c);   
            //end of Alsn-143
        }        
        for(WOD_2__Removed_Claim_Part__c rcp : [SELECT Id, Name,WOD_2__Inspection_Status__c, WOD_2__Payment_Condition__c,Received_Quantity__c,Inspected_Quantity__c,WOD_2__Shipped_Quantity__c,WOD_2__Claim__c,WOD_2__Is_Shipped__c,WOD_2__Is_Returned__c,WOD_2__Is_Inspected__c
                                                FROM WOD_2__Removed_Claim_Part__c
                                                WHERE (WOD_2__Claim__c IN :impactedClaimIdList or WOD_2__Claim__c IN :completedClaimIdList)
                                                AND WOD_2__Part_Return_Requested__c = true
                                                AND WOD_2__Payment_Condition__c IN ('Pay After Return','Pay After Ship','Pay After Inspection')
                                               ]){
                                                   if(claimRCPMap.containsKey(rcp.WOD_2__Claim__c))
                                                       claimRCPMap.get(rcp.WOD_2__CLaim__c).add(rcp);
                                                   else
                                                       claimRCPMap.put(rcp.WOD_2__CLaim__c, new List<WOD_2__Removed_Claim_Part__c> {rcp});
                                               }
        claimList = [SELECT Id, WOD_2__Claim_Parts_Pending_Approval__c,Shipment_Status__c,WOD_2__Claim_Status__c
                     FROM WOD_2__Claim__c
                     WHERE (ID IN :impactedClaimIdList) or (ID in : completedClaimIdList)];
        for(WOD_2__Claim__c claim : claimList) {
            if(claimRCPMap.containskey(claim.Id)) {
                claimUpdated = true;
                Integer totalRemovedPart = claimRCPMap.get(claim.Id).size();
                Integer criteriaSatisfiedRecords = 0;
                Integer partialShipment = 0;
                Integer completeShipment =0;
                /* Alsn - 143... changes...1.Added new field Shipment_Status__c on claim 
2. Making WOD_2__Claim_Parts_Pending_Approval__c as 0 only when if all the shipped parts are received or inspected */
                for(WOD_2__Removed_Claim_Part__c rcp : claimRCPMap.get(claim.Id)) {
                    System.debug('trueeeeeee');
                    if(rcp.WOD_2__Payment_Condition__c =='Pay After Ship' && rcp.WOD_2__Is_Shipped__c) {
                        criteriaSatisfiedRecords++;
                        completeShipment++;
                        
                    }
                    if(rcp.WOD_2__Payment_Condition__c =='Pay After Return' && rcp.WOD_2__Is_Returned__c) {
                        criteriaSatisfiedRecords++;
                        if(rcp.Received_Quantity__c == rcp.WOD_2__Shipped_Quantity__c && rcp.Received_Quantity__c>0){                          
                            completeShipment++;
                        }
                        else{
                            if((rcp.Received_Quantity__c == 0 && rcp.WOD_2__Shipped_Quantity__c==0) || (rcp.Received_Quantity__c < rcp.WOD_2__Shipped_Quantity__c && rcp.Received_Quantity__c > 0))
                                partialShipment++; 
                        }
                    }
                    if(rcp.WOD_2__Payment_Condition__c =='Pay After Inspection' && rcp.WOD_2__Is_Inspected__c){
                        criteriaSatisfiedRecords++;
                        if(rcp.Inspected_Quantity__c == rcp.WOD_2__Shipped_Quantity__c && rcp.Inspected_Quantity__c>0 && (rcp.WOD_2__Inspection_Status__c!='Inspection Error' && rcp.WOD_2__Inspection_Status__c!='Rejected')){
                            completeShipment++;
                        }
                        else{
                            if((rcp.Inspected_Quantity__c == 0 && rcp.Received_Quantity__c==0) || (rcp.Inspected_Quantity__c < rcp.WOD_2__Shipped_Quantity__c && rcp.Inspected_Quantity__c > 0) || (rcp.WOD_2__Inspection_Status__c=='Inspection Error')){
                                partialShipment++; 
                            }
                        }                        
                    }
                    
                }
                if(partialShipment >0)
                    claim.Shipment_Status__c ='Partial Shipment';
                if(completeShipment > 0 && completeShipment == totalRemovedPart){
                    claim.Shipment_Status__c ='Shipment Completed';
                    System.debug('trueeeeeeeeeee'+claim.Shipment_Status__c);
                }
                if(totalRemovedPart == criteriaSatisfiedRecords){
                    claim.WOD_2__Claim_Parts_Pending_Approval__c =0;
                }else{
                    claim.WOD_2__Claim_Parts_Pending_Approval__c =totalRemovedPart - criteriaSatisfiedRecords;                 
                }    
                if(claim.WOD_2__Claim_Status__c == 'Approved' && claim.Shipment_Status__c =='Partial Shipment'){  
                    claim.WOD_2__In_Approval_Process__c = true;
                }
            }
        }
        if(claimUpdated && !claimList.isEmpty()){
            //ClaimTriggerHandler.isShipmentCreated = true;
            //ClaimTriggerHandler.skiprollUpFinancialHeader = true;
            //Alsn-213 bypassed Claimtriggerhandler and removedclaimparttriggerhandler to avoid the updates that were not necessary
           TriggerHandler.bypass('ATI_ClaimTriggerHandler');
           TriggerHandler.bypass('ATI_RemovedClaimPartTriggerHandler');
            update claimList;
           TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
           TriggerHandler.clearBypass('ATI_RemovedClaimPartTriggerHandler');
        }
    }
}