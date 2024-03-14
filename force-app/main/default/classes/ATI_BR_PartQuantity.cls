/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Trigger from BU rule -> AT: Part Quantity excessive
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_PartQuantity implements WOD_2.BR_BusinessRuleInterface{
    global Integer quantity;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = [SELECT id, Name,WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE name = 'CLM_Part_Quantity' LIMIT 1];
        system.debug('bccsList'+bccsList);
        if(!bccsList.isEmpty() && Integer.valueOf(bccsList[0].WOD_2__Value__c) >= 0){
            quantity =  Integer.valueOf(bccsList[0].WOD_2__Value__c);
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Inventory__c
                                        FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
            system.debug('claimObj'+claimObj);
            if(claimObj != NULL){
                List<WOD_2__Claim_Part__c> partList = [SELECT Id,WOD_2__Invoice_Quantity__c
                                                       FROM 	WOD_2__Claim_Part__c WHERE WOD_2__Claim__c = :claimObj.Id];
                system.debug('partList'+partList);
                if(partList.size()>0 && partList[0].WOD_2__Invoice_Quantity__c >quantity){
                    return true;  
                }
            }
        }
        return false;
    }
}