/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: Prev claim on Serial Number has higher Mile/Kilo/Hr (roll back)



* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_PriorAFAHigherUsage implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Causal_Part_Number__c,ATI_Total_Requested_Amount__c,WOD_2__Inventory__c,
                                          WOD_2__Date_Of_Failure__c,WOD_2__Account__c,WOD_2__Units_Usage__c 
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size()>0){
         Integer prevUnitUsage = [SELECT Count() 
                                     FROM WOD_2__Claim__c 
                                     WHERE Id != :claimlst[0].Id 
                                     AND  WOD_2__Inventory__c = :claimlst[0].WOD_2__Inventory__c 
                                     AND WOD_2__Units_Usage__c > :claimlst[0].WOD_2__Units_Usage__c];
            system.debug('prevUnitUsage'+prevUnitUsage);
            
            if(prevUnitUsage > 0){  
                return true;  
            }
        }
        return false;
        
    }
}