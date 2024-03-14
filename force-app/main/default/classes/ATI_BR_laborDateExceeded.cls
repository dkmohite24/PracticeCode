/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule -> AT: Time limit between Last Labor and Submit Date has been exceeded 
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_laborDateExceeded implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name = 'CLM_Last_Labor_Submit_Date_exceeded' LIMIT 1];
        if(!bccsList.isEmpty() && Integer.valueOf(bccsList[0].WOD_2__Value__c) >= 0){
            months =  Integer.valueOf(bccsList[0].WOD_2__Value__c);
            
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Inventory__c,WOD_2__Date_Of_Repair__c,ATI_Today__c,WOD_2__Inventory__r.WOD_2__Warranty_End_Date__c
                                        FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
            Integer noOfDays = claimObj.ATI_Today__c.daysBetween(claimObj.WOD_2__Date_Of_Repair__c);
            
            /*Integer claimUnitLimit = claimObj.WOD_2__Inventory__r.WOD_2__Warranty_End_Date__c != null ? 
                claimObj.WOD_2__Date_Of_Repair__c.daysBetween(claimObj.WOD_2__Inventory__r.WOD_2__Warranty_End_Date__c) : 0;*/
            
            if(noOfDays > months){  
                return true;  
            } /*else if(claimObj.WOD_2__Inventory__r.WOD_2__Warranty_End_Date__c != NULL && claimUnitLimit > months){  
                return true;  
            }*/
        }
            return false;
        
    }
}