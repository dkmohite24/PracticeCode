/* Name: ATI_StringToolController
Description : ATI_StringToolController - Controller for String tool.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      13-NOV-2021          INITIAL DEVELOPMENT
*/

public with sharing class ATI_StringToolController {

    @AuraEnabled
    public static WOD_2.ResponseWrapper getClaimDetails(String claimId){
        WOD_2.ResponseWrapper resWrapper = new WOD_2.ResponseWrapper('' , true, '');
        try {
            ReplacementInfo repInfo = getReplacementInfo(claimId);
            resWrapper.data = JSON.serialize(repInfo);
        }catch(Exception e){
            resWrapper.status = false;
            resWrapper.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return resWrapper;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper validateReplacement(String claimId, String replacementInfo){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('', true, '');
        ReplacementInfo oldRepInfo = getReplacementInfo(claimId);
        ReplacementInfo newRepInfo = (ReplacementInfo) JSON.deserialize(replacementInfo, ReplacementInfo.class);
        response.data = checkIfSNIsReplacedInFuture(oldRepInfo);
        List<String> invFields = new List<String>{'Name','WOD_2__Serial_Number__c','WOD_2__Type__c'};      
        List<Id> invIdList = new List<Id>{newRepInfo.originalSNId};    
		if(String.isNotBlank(newRepInfo.replacementSNId)){
			invIdList.add(newRepInfo.replacementSNId);        	        
        }            
        ATI_Utils.checkForAccess('WOD_2__Inventory__c','READ', invFields);                            
        Map<Id, WOD_2__Inventory__c> invMap = new Map<Id, WOD_2__Inventory__c>([
            select id, Name, WOD_2__Serial_Number__c, WOD_2__Type__c from WOD_2__Inventory__c where id in :invIdList
        ]);
        if(oldRepInfo.transmissionReplaced && !newRepInfo.transmissionReplaced){// case when replacement needs to be reverted
            if(invMap.get(newRepInfo.originalSNId).WOD_2__Type__c != 'Stock'){
               response.errormessage = 'Original Serial Number is not in STOCK';
            }
        } else if(String.isNotBlank(newRepInfo.replacementSNId) && newRepInfo.replacementSNId != oldRepInfo.replacementSNId && invMap.get(newRepInfo.replacementSNId).WOD_2__Type__c != 'Stock'){ // case when replacement is being added or updated
            response.errormessage = 'Replacement Serial Number is not in STOCK';    
        }
        return response;
    } 
    
    private static String checkIfSNIsReplacedInFuture(ReplacementInfo repInfo){
        ATI_WarrantyService.WRDetailsWrapper wrDetails = null;
        if(repInfo != null && repInfo.wrDetails != null){
            wrDetails = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(repInfo.wrDetails, ATI_WarrantyService.WRDetailsWrapper.class);
        }
        if(wrDetails != null && wrDetails.vehicleInfo != null){
            String vehicleInfoId = wrDetails.vehicleInfo.Id;
            if(String.isBlank(vehicleInfoId)){
                List<ATI_VIN_Transmission_Mapper__c> mapper = 
                    [select ATI_Inventory__c, ATI_Vehicle_Information__c from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__c =:repInfo.originalSNId];
                if(mapper.isEmpty()){
                    throw new TWODException('Vehicle information not found for serial number ' + repInfo.originalSN);
                }
				vehicleInfoId = mapper[0].ATI_Vehicle_Information__c;                
            }
        	List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = [SELECT Id,ATI_Vehicle_Information__c FROM ATI_VIN_Transmission_Mapper__c WHERE ATI_Inventory__c=:repInfo.replacementSNId ORDER BY CreatedDate Limit 1];
            ATI_Utils.checkForAccess('ATI_Inventory_Replacement_History__c','READ', new List<String>{'Name'});
            List<ATI_Inventory_Replacement_History__c> invRepHistory =
                [select id from ATI_Inventory_Replacement_History__c where ATI_Failed_Inventory__c = :repInfo.originalSNId and 
                 ATI_Replacement_Date__c > :repInfo.roDate and ATI_Vehicle_Information__c = :vehicleInfoId];
            if(!invRepHistory.isEmpty()){
                return 'Replacement claim exists on ' + repInfo.originalSN + ' with a future RO date and same VIN';
            }
        }
		return '';        
    }

    @AuraEnabled
    public static WOD_2.ResponseWrapper handleReplacement(String claimId, String replacementInfo){
        ReplacementInfo oldRepInfo = getReplacementInfo(claimId);
        ReplacementInfo newRepInfo = (ReplacementInfo) JSON.deserialize(replacementInfo, ReplacementInfo.class);
		String actionToBePerformed = getActionToBePerformed(oldRepInfo, newRepInfo);
        switch on actionToBePerformed {
            when 'TRANSFER' {
                return performReplacementTransfer(newRepInfo);
            }
            when 'ADD' {
                return addReplacement(claimId, newRepInfo);
            }   
            when 'DELETE'{
                return deleteReplacement(claimId, newRepInfo, oldRepInfo);
            }
            when 'UPDATE' {
                return updateReplacement(claimId, oldRepInfo, newRepInfo);
            }
        }
        return new WOD_2.ResponseWrapper('', false, 'Invalid Action : ' + actionToBePerformed);
    }

    private static WOD_2.ResponseWrapper updateReplacement(String claimId, ReplacementInfo oldRepInfo, ReplacementInfo newRepInfo){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('', true, '');
        Savepoint sp = Database.setSavepoint();
        try{
            updateReplacementInfo(claimId, newRepInfo);
			ATI_CLM_ReplacementService.updateReplacement(claimId, oldRepInfo.replacementSNId);
            response.data = 'Replacement details updated successfully.';
            return response;
        }catch(Exception e){
            Database.rollback(sp);
            response.status = false;
            response.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return response;
    }

    private static WOD_2.ResponseWrapper deleteReplacement(String claimId, ReplacementInfo newRepInfo, ReplacementInfo oldRepInfo){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('', true, '');
        Savepoint sp = Database.setSavepoint();
        try{
            ATI_CLM_ReplacementService.deleteReplacement(claimId, newRepInfo.originalSNId, oldRepInfo.replacementSNId);
            updateReplacementInfo(claimId, newRepInfo);
            response.data = 'Replacement details deleted successfully.';
            return response;
        }catch(Exception e){
            Database.rollback(sp);
            response.status = false;
            response.errormessage = e.getMessage() + e.getStackTraceString();
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        return response;
    }

    private static WOD_2.ResponseWrapper addReplacement(String claimId, ReplacementInfo newRepInfo){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('', true, '');
        Savepoint sp = Database.setSavepoint();
        try{
            updateReplacementInfo(claimId, newRepInfo);
            ATI_CLM_ReplacementService.handleReplacement(new List<Id>{claimId}, true);            
            response.data = 'Replacement details updated successfully.';
            return response;
        }catch(Exception e){
            Database.rollback(sp);
            response.status = false;
            response.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return response;
    }    

    // this method transfer any pending policies from failed inventory to replaced inventory.
    private static WOD_2.ResponseWrapper performReplacementTransfer(ReplacementInfo newRepInfo){
        WOD_2.ResponseWrapper response = new WOD_2.ResponseWrapper('', true, '');
        Savepoint sp = Database.setSavepoint();
        try{
            ATI_Utils.checkForAccess('WOD_2__Warranty_Registration__c','READ', new List<String>{'Name'});
            Id oldWRId = [select id from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :newRepInfo.originalSNId order by createddate desc limit 1][0].Id;
            Id newWRId = [select id from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :newRepInfo.replacementSNId order by createddate desc limit 1][0].Id;
            Set<Id> wrIdSet = new Set<Id>{oldWRId, newWRId};
            List<WOD_2__Warranty_Coverages__c> wcList = ATI_CLM_ReplacementService.fetchWarrantyCoverages(wrIdSet);
            Map<String, WOD_2__Warranty_Coverages__c> failedWCMap = new Map<String, WOD_2__Warranty_Coverages__c>();
            Map<String, WOD_2__Warranty_Coverages__c> replacedWCMap = new Map<String, WOD_2__Warranty_Coverages__c>();
            for(WOD_2__Warranty_Coverages__c wc : wcList){
                String key = ''+wc.WOD_2__Policy_Definition__c + wc.WOD_2__Warranty_Start_Date__c + wc.WOD_2__Warranty_End_Date__c;
                if(wc.WOD_2__Warranty_Registration__r.WOD_2__Inventory__c == newRepInfo.originalSNId){
                    failedWCMap.put(key, wc);
                } else {
                    replacedWCMap.put(key, wc);
                }
            }
            failedWCMap.keySet().removeAll(replacedWCMap.keySet());// this will remove all the new policies from old
            if(!failedWCMap.isEmpty()){ // these coerages needs to be created on new WR
                List<WOD_2__Warranty_Coverages__c> clonedCoverageList = new List<WOD_2__Warranty_Coverages__c>();
                for(WOD_2__Warranty_Coverages__c c : failedWCMap.values()){
                    WOD_2__Warranty_Coverages__c clonedCoverage = c.clone(false,false,false,false);
                    clonedCoverage.WOD_2__Warranty_Registration__c = newWRId;
                    clonedCoverageList.add(clonedCoverage);
                }
                insert clonedCoverageList;             
                response.data = failedWCMap.size () + ' coverage/s are transfered from failed SN to repalced SN';
            } else { 
                response.errormessage = 'No new coverages found for transfer';
            }
            return response;
        }catch(Exception e){
            Database.rollback(sp);
            response.status = false;
            response.errormessage = e.getMessage() + e.getStackTraceString();
        }
        return response;

    }    
    private static String getActionToBePerformed(ReplacementInfo oldRepInfo, ReplacementInfo newRepInfo){
        if(oldRepInfo.transmissionReplaced && !newRepInfo.transmissionReplaced){
            return 'DELETE';
        }else if(!oldRepInfo.transmissionReplaced && newRepInfo.transmissionReplaced){
            return 'ADD';
        }else if(oldRepInfo.replacementSNId != newRepInfo.replacementSNId){
            return 'UPDATE';
        }
        return 'TRANSFER';
    }
    
    @TestVisible
    private static ReplacementInfo getReplacementInfo(String claimId){
        List<String> claimFields = new List<String>{'WOD_2__Inventory__c','WOD_2__Inventory__r.Name','WOD_2__Date_Of_Failure__c',
            'WOD_2__Inventory__r.WOD_2__Item__r.Name','ATI_Replacement_Type__c','ATI_Replaced_Inventory__r.WOD_2__Item__r.Name','ATI_WR_Details__c',
            'ATI_Replacement_Claims__c','ATI_Replaced_Inventory__c','ATI_Replaced_Inventory__r.Name', 'WOD_2__BusinessCategory__c'};
		ATI_Utils.checkForAccess('WOD_2__Claim__c','READ', claimFields);                
		ReplacementInfo replacementInfo = new ReplacementInfo();
        String query = 'Select Id,' + String.join(claimFields, ', ') + ' from WOD_2__Claim__c where id = :claimId';
       	WOD_2__Claim__c claim = Database.query(String.escapeSingleQuotes(query));
        replacementInfo.originalSN = claim.WOD_2__Inventory__r.Name;
        replacementInfo.originalSNId = claim.WOD_2__Inventory__c;
        replacementInfo.originalModel = claim.WOD_2__Inventory__r.WOD_2__Item__r.Name;
        replacementInfo.transmissionReplaced = claim.ATI_Replacement_Claims__c;
        replacementInfo.replacementSNId = claim.ATI_Replaced_Inventory__c;
        replacementInfo.replacementModel = claim.ATI_Replaced_Inventory__r.WOD_2__Item__r.Name;
        replacementInfo.replacementModelId = claim.ATI_Replaced_Inventory__r.WOD_2__Item__r.Id;
        replacementInfo.replacementType = claim.ATI_Replacement_Type__c;
        replacementInfo.buId = claim.WOD_2__BusinessCategory__c;
        replacementInfo.roDate = claim.WOD_2__Date_Of_Failure__c;
        replacementInfo.wrDetails = claim.ATI_WR_Details__c;
        return replacementInfo;
    }
    
    private static void updateReplacementInfo(String claimId, ReplacementInfo newRepInfo){
        List<String> claimFields = new List<String>{'ATI_Replacement_Claims__c','ATI_Replacement_Type__c','ATI_Replaced_Inventory__c','ATI_Replaced_Model__c'};
		ATI_Utils.checkForAccess('WOD_2__Claim__c','UPDATE', claimFields);            
		WOD_2__Claim__c claim = [select id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c, ATI_Replaced_Inventory__c, ATI_Replaced_Model__c from WOD_2__Claim__c where id = :claimId];            
        claim.ATI_Replacement_Claims__c = newRepInfo.transmissionReplaced;
        claim.ATI_Replacement_Type__c = String.isNotBlank(newRepInfo.replacementType) ? newRepInfo.replacementType : null;
        claim.ATI_Replaced_Inventory__c = String.isNotBlank(newRepInfo.replacementSNId) ? newRepInfo.replacementSNId : null;
        claim.ATI_Replaced_Model__c = String.isNotBlank(newRepInfo.replacementModelId) ? newRepInfo.replacementModelId : null;
        claim.ATI_Replacement_Comments__c = newRepInfo.replacementComments;
		TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        Boolean claimLocked = Approval.isLocked(claimId);
        if(claimLocked){
            ATI_WithoutSharingService.unlockRecords(new List<Id>{claimId});
        }
        update claim;
        if(claimLocked){
            ATI_WithoutSharingService.lockRecords(new List<Id>{claimId});
        }
        TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
    }
    
    @TestVisible
    public class ReplacementInfo {
        public String originalSN;
        public String originalSNId;
        public String originalModel;
        public Boolean transmissionReplaced;
        public String replacementSNId;
        public String replacementType;
        public String replacementModel;
        public String replacementModelId;
        public String buId; 
        public Date roDate;
        public String wrDetails;
        public String replacementComments;
    }
}