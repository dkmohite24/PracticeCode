/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: ETC coverage denied previously for this Serial Number
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_ETCDeniedSerialNumber implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Warranty_Registration__c> wrList = [SELECT Id,WOD_2__Status__c,WOD_2__Inventory__c,WOD_2__Registration_Type__c
                                                        FROM WOD_2__Warranty_Registration__c WHERE Id =:wrapper.ruleObjectId];
      
        if(wrList.size()>0){
            Integer prevWrStatus = [SELECT Count() 
                                    FROM WOD_2__Warranty_Registration__c 
                                    WHERE Id != :wrList[0].Id 
                                    AND WOD_2__Inventory__c = :wrList[0].WOD_2__Inventory__c 
                                    AND WOD_2__Status__c = 'Rejected'
                                   AND WOD_2__Registration_Type__c = 'Extended'];
            system.debug('prevWrStatus'+prevWrStatus);
            if(prevWrStatus>0){
                return true;  
            }
        }
        return false;
        
    }
}