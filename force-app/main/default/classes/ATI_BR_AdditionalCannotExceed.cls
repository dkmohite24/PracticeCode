/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->BP:00096900 cannot exceed 1.55 hrs for 2009FA06.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_AdditionalCannotExceed implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
       List<WOD_2__Claim__c> claimLst = [SELECT Id,WOD_2__Inventory__c,ATI_Special_Activity__c
                                           FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimLst.Size()>0){
            List<WOD_2__Claim_Service_Information__c> claimServiceInfoLst = [SELECT Id,WOD_2__Additional_Labor_Hour__c,WOD_2__Service_Job_Code__r.Name,
                                                                             WOD_2__Claim__c,WOD_2__Claim__r.ATI_Special_Activity__c 
                                                                             FROM WOD_2__Claim_Service_Information__c 
                                                                             WHERE WOD_2__Claim__c=:claimLst[0].Id AND 
                                                                             WOD_2__Service_Job_Code__r.Name = :'00096900'
                                                                             AND WOD_2__Additional_Labor_Hour__c > 1.55
                                                                             /*AND WOD_2__Claim__r.ATI_Special_Activity__c = :'2009FA06'*/]; 
            if(claimServiceInfoLst.size()>0){
                return true;  
            }
        }
        return false;
    }
}