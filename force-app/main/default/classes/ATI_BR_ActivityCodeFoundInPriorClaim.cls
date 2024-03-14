/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: This Special Activity already performed for this Serial Number.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_ActivityCodeFoundInPriorClaim implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Claim__c> claimlst = [SELECT Id,ATI_Special_Activity__c,WOD_2__Inventory__c 
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        
        if(claimlst.size()>0 && claimlst[0].ATI_Special_Activity__c != NULL){
         Integer splActivity = [SELECT Count() 
                                     FROM WOD_2__Claim__c 
                                     WHERE WOD_2__Inventory__c = :claimlst[0].WOD_2__Inventory__c 
                                     AND ATI_Special_Activity__c = :claimlst[0].ATI_Special_Activity__c];
            
            if(splActivity > 0){  
                return true;  
            }
        }
        return false;
        
    }
}