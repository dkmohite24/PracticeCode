/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: Low Mile/Kilo/Hr since last repair, same PFP (come back)
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_dupRuleInClaimUnitUsage implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Units_Usage__c,WOD_2__Causal_Part_Number__c,
                                          WOD_2__Account__c
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size()>0){
            List<WOD_2__Claim__c>  lastClaim = [SELECT Id,WOD_2__Inventory__r.WOD_2__Units_Usage__c,WOD_2__Inventory__c,WOD_2__Units_Usage__c,WOD_2__Causal_Part_Number__c
                                          FROM WOD_2__Claim__c 
                                          WHERE Id != :claimlst[0].Id 
                                          AND WOD_2__Inventory__c = :claimlst[0].WOD_2__Inventory__c 
                                          AND WOD_2__Causal_Part_Number__c =: claimlst[0].WOD_2__Causal_Part_Number__c
                                          AND WOD_2__Units_Usage__c > :claimlst[0].WOD_2__Units_Usage__c ORDER BY CreatedDate DESC LIMIT 1];
            
            if(lastClaim.size()>0){  
                return true;  
            }
        }
           return false;
    
    }
}