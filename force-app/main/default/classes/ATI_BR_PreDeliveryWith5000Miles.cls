/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Trigger from BU rule -> PreDeliveryWith5000Miles
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_PreDeliveryWith5000Miles implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Inventory__c,WOD_2__Units_Usage__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId AND WOD_2__Units_Usage__c > 5000];
        if(claimObj != NULL){
            List<WOD_2__Warranty_Registration__c> warrantyRegLst = [SELECT Id,ATI_Pre_Delivery__c FROM WOD_2__Warranty_Registration__c 
                                                                    WHERE ATI_Pre_Delivery__c = TRUE AND WOD_2__Inventory__c = :claimObj.WOD_2__Inventory__c];
            
            if(warrantyRegLst.size()>0){   
                return true; 
            }
            
        }
          return false;         
         
    }
}