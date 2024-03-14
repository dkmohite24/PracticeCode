/**
 -------------------------------------------------------------------------------------------------
* @author         Ravi Goudar
* @created        07-May-2021
* @modified
* @description :   Batch that runs every 5 minutes, 
				   It was created to create TMH and update claim to Pending payment, 
				   only for Auto approved claims which dont have part return. 
				   This is done in batch because , PRC is picking after Claim gets approved, 
				   so for Payment conditions like Pay After Return,Ship or Inspection, we are not able to get details in trigger,
				   it was creating TMH and moving claim to pending payment for above payment conditions also. 
* --------------------------------------------------------------------------------------------------
*/
global class ATI_AutoApprovalActionOnClaimBatch implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,(SELECT Id,WOD_2__Payment_Condition__c '+
                       'FROM WOD_2__Removed_Claim_Parts__r WHERE WOD_2__Payment_Condition__c IN '+
            		   '(\'Pay After Inspection\',\'Pay After Return\',\'Pay After Ship\')) '+
            		   'FROM WOD_2__Claim__c WHERE WOD_2__Claim_Status__c =\'Approved\' AND WOD_2__Auto_Approved__c=\'Yes\' AND '+
            		   'WOD_2__Claim_Parts_Pending_Approval__c=0';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<WOD_2__Claim__c> claimsLst){
        try{
            List<Id> claimIdsLst = new List<Id>();
            for(WOD_2__Claim__c claimObj : claimsLst){
                claimIdsLst.add(claimObj.Id);
                claimObj.WOD_2__Claim_Status__c = 'Pending Payment';
            }
            WOD_2.ResponseWrapper response = WOD_2.CRD_CreditDebitService.invokeTMHService(claimIdsLst);
            System.debug('response--------->'+response);
            ATI_CLM_ReplacementService.handleReplacement(claimIdsLst);
            TriggerHandler.bypass('ATI_ClaimTriggerHandler');
            update claimsLst;
            TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');
        }catch(Exception e){
            System.debug('exception----->'+e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    } 
}