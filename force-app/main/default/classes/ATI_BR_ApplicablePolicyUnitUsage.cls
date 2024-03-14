/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule -> AT: Policy claim on unit which is over 50% beyond wnty mi/kilo/hr
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_ApplicablePolicyUnitUsage implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
            
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Units_Usage__c,WOD_2__Applicable_Policy__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size()>0){
           List<WOD_2__Policy_Definition_Inventory_Usage__c> policyDefUsage = [SELECT Id,WOD_2__Maximum_Unit__c,WOD_2__Policy_Definition__c
                                                                          FROM WOD_2__Policy_Definition_Inventory_Usage__c WHERE WOD_2__Policy_Definition__c = :claimlst[0].WOD_2__Applicable_Policy__c];
            if(policyDefUsage.size()>0){
            Decimal unitUsage = (policyDefUsage[0].WOD_2__Maximum_Unit__c)/2;
            
            if(((policyDefUsage[0].WOD_2__Maximum_Unit__c)/2)<claimlst[0].WOD_2__Units_Usage__c){  
                return true;  
            }
        }
        }
            return false;
        
    }
}