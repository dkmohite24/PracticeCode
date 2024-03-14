/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Over 2 years from trans. build date to in-service date
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_BuildDateAndInServiceDate implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        List<WOD_2__Claim__c> claimLst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Inventory__r.WOD_2__Install_Date__c,WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimLst.Size()>0){
            List<WOD_2__Warranty_Registration__c> warrantyRegLst = [SELECT Id,ATI_Pre_Delivery__c FROM WOD_2__Warranty_Registration__c 
                                                                    WHERE ATI_Pre_Delivery__c = TRUE AND WOD_2__Inventory__c = :claimLst[0].WOD_2__Inventory__c];
            
            if(warrantyRegLst.size()>0 && claimLst[0].WOD_2__Inventory__r.WOD_2__Manufacturing_Date__c.addMonths(24)< claimLst[0].WOD_2__Inventory__r.WOD_2__Install_Date__c ){   
                return true; 
            }
            
        }
          return false;      
         
    }
}