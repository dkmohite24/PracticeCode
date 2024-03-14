/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Trigger from BU rule -> BP: Labor code 00094005 can only be used on 2008FA06 claims
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_LaborCodeSpecialActivity implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());              
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Inventory__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimObj != NULL){
        List<WOD_2__Claim_Service_Information__c> claimServiceInfoLst = [SELECT Id,WOD_2__Service_Job_Code__r.Name,WOD_2__Claim__c
                                                                         FROM WOD_2__Claim_Service_Information__c 
                                                                         WHERE WOD_2__Claim__c=:claimObj.Id AND 
                                                                         WOD_2__Service_Job_Code__r.Name = '00094005'];
        
        
        if(claimServiceInfoLst.size()>0){
            return true;  
        }
        }
        return false;
    }
}