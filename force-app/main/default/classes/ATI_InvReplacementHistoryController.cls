/* Name: ATI_InvReplacementHistoryController
Description : ATI_InvReplacementHistoryController - Controller class for ATI_InvReplacementHistoryComponent
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      19-FEB-2021          INITIAL DEVELOPMENT
*/
public class ATI_InvReplacementHistoryController {

    @auraenabled
    public static WOD_2.ResponseWrapper createZeroDollarClaim(String vehicleInfoId, String claimStr){
        WOD_2__Claim__c claim = (WOD_2__Claim__c) JSON.deserialize(claimStr, WOD_2__Claim__c.class);
        claim.WOD_2__Date_Of_Failure__c = claim.WOD_2__Date_Of_Repair__c;
		Savepoint sp = Database.setSavepoint();
        try{
            checkClaimCreateAccess(claim);
            Id zdcRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('ATI_Zero_Dollar_Claim').getRecordTypeId();
          	claim.RecordTypeId = zdcRecordTypeId;
            ATI_ClaimTriggerHandler.RUN_BU_RULES = false;
        	insert claim;    
            handleReplacementForStringCorrection(vehicleInfoId, claim);
            return new WOD_2.ResponseWrapper(JSON.serialize(claim), true, '');
        }catch(Exception e){
            Database.rollback(sp);
            return new WOD_2.ResponseWrapper('', false, e.getMessage() + ' -> ' + e.getStackTraceString());
        }
    }
    
    private static void handleReplacementForStringCorrection(String vehicleInfoId, WOD_2__Claim__c clm){
        Map<String, ATI_Inventory_Replacement_History__c> invRepHistMap = ATI_CLM_ReplacementService.getInvReplacementHistMap(new Set<Id>{vehicleInfoId});
        ATI_Inventory_Replacement_History__c irh = new ATI_Inventory_Replacement_History__c();
        irh.ATI_Claim__c = clm.Id;
        irh.ATI_Account__c = clm.WOD_2__Account__c;
        irh.ATI_Failed_Inventory__c = clm.WOD_2__Inventory__c;
        irh.ATI_Replaced_Inventory__c = clm.ATI_Replaced_Inventory__c;
        irh.ATI_Replacement_Date__c = clm.WOD_2__Date_Of_Repair__c;
        irh.ATI_Replacement_Type__c = clm.ATI_Replacement_Type__c;
        irh.ATI_Vehicle_Information__c = vehicleInfoId;
        String key = String.valueOf(clm.WOD_2__Inventory__c) + irh.ATI_Vehicle_Information__c;
        irh.ATI_Original_Inventory__c = 
            (invRepHistMap.containsKey(key)) ? invRepHistMap.get(key).ATI_Original_Inventory__c : clm.WOD_2__Inventory__c;
        ATI_Utils.checkForAccess('ATI_Inventory_Replacement_History__c', 'CREATE',  new List<String>{'ATI_Claim__c',
                'ATI_Account__c','ATI_Failed_Inventory__c','ATI_Replaced_Inventory__c','ATI_Replacement_Date__c',
                'ATI_Replacement_Type__c','ATI_Vehicle_Information__c'});
		insert irh;
    }
    
    @auraenabled
    public static WOD_2.ResponseWrapper showAddClaimButton(Id entityId){
        Boolean showAddClaimButton = false;
        String entityType = String.valueOf(entityId.getSobjectType());
        if(entityType == 'ATI_Vehicle_Information__c'){
            showAddClaimButton = true;
        }
        return new WOD_2.ResponseWrapper(JSON.serialize(showAddClaimButton), true, '');
    }    
    
    @auraenabled
    public static WOD_2.ResponseWrapper fetchReplacementHistory(Id entityId, List<String> objectFieldsAPINames){
        try{
            String entityType = String.valueOf(entityId.getSobjectType());
            if(entityType == 'WOD_2__Inventory__c'){
                return fetchReplacementHistoryByInvId(entityId, objectFieldsAPINames);
            }else if(entityType == 'ATI_Vehicle_Information__c'){
                return fetchReplacementHistoryByVehInfoId(entityId, objectFieldsAPINames);
            }
            return new WOD_2.ResponseWrapper('', false, 'Invalid Entity Type');
        }catch(Exception e){
            return new WOD_2.ResponseWrapper('', false, e.getMessage());
        }
    }
    
    private static WOD_2.ResponseWrapper fetchReplacementHistoryByInvId(Id invId, List<String> objectFieldsAPINames){
        List<String> fieldList = getIRHFieldsWithAccessCheck(objectFieldsAPINames);
        String query = 'select ID, ' + String.join(fieldList, ', ') + ' from ATI_Inventory_Replacement_History__c where ' + 
            'ATI_Failed_Inventory__c = :invId or ATI_Replaced_Inventory__c = :invId order by CreatedDate ASC ';
        List<ATI_Inventory_Replacement_History__c> irhList = Database.query(String.escapeSingleQuotes(query));
        return new WOD_2.ResponseWrapper(JSON.serialize(irhList), true, '');
    }
    
    private static WOD_2.ResponseWrapper fetchReplacementHistoryByVehInfoId(Id viId, List<String> objectFieldsAPINames){
        List<String> fieldList = getIRHFieldsWithAccessCheck(objectFieldsAPINames);
        String query = 'select ID, ' + String.join(fieldList, ', ') + ' from ATI_Inventory_Replacement_History__c where ' + 
            'ATI_Vehicle_Information__c = :viId order by  CreatedDate ASC';
        List<ATI_Inventory_Replacement_History__c> irhList = Database.query(String.escapeSingleQuotes(query));
        return new WOD_2.ResponseWrapper(JSON.serialize(irhList), true, '');
    }

    private static List<String> getIRHFieldsWithAccessCheck(List<String> objectFieldsAPINames){
		ATI_Utils.NoAccessObjectFieldWrapper irhAccess = ATI_Utils.fetchReadAccess('ATI_Inventory_Replacement_History__c', objectFieldsAPINames);
        if(!irhAccess.noAccessObjectList.isEmpty() || !irhAccess.noAccessFieldList.isEmpty()){
            throw new TWoDException(Label.ATI_Log_Insufficient_access + ' Object: ATI_Inventory_Replacement_History__c, Fields: '+String.join(irhAccess.noAccessFieldList, ','));
        }
        return objectFieldsAPINames;
    }

    private static List<String> checkClaimCreateAccess(WOD_2__Claim__c claimObj){
        List<String> objectFieldsAPINames = new List<String>();
        for(String fieldName : claimObj.getPopulatedFieldsAsMap().keySet()){
            objectFieldsAPINames.add(fieldName);
        }
		ATI_Utils.NoAccessObjectFieldWrapper claimCreateAccess = ATI_Utils.fetchReadAccess('WOD_2__Claim__c', objectFieldsAPINames);
        if(!claimCreateAccess.noAccessObjectList.isEmpty() || !claimCreateAccess.noAccessFieldList.isEmpty()){
            throw new TWoDException(Label.ATI_Log_Insufficient_access + ' Object: WOD_2__Claim__c, Fields: '+String.join(claimCreateAccess.noAccessFieldList, ','));
        }
        return objectFieldsAPINames;
    }

    
}