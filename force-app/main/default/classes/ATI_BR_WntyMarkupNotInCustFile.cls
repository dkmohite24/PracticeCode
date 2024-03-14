/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        7-Sept-2021
* @modified
* @description :   Trigger from BU rule ->AT: Prev claim on file with same Serial Nbr, PFP and Mile/Kilo/Hr


* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_WntyMarkupNotInCustFile implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Causal_Part_Number__c,ATI_Total_Requested_Amount__c,WOD_2__Inventory__c,
                                          WOD_2__Date_Of_Failure__c,WOD_2__Account__c,WOD_2__Units_Usage__c 
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size()>0){
            List<WOD_2__Financial_Line_Item__c> listOfFLI = [SELECT Id,WOD_2__Claim__c,ATI_Markup__c FROM WOD_2__Financial_Line_Item__c
                                                             WHERE WOD_2__Claim__c =: claimlst[0].Id];            
            
            if(listOfFLI.size()>0){ 
                for(WOD_2__Financial_Line_Item__c fli : listOfFLI){
                    if(fli.ATI_Markup__c == 0){
                        return true; 
                    }
                }
            }
        }
        return false;
        
    }
}