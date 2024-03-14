/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        07-SEP-2021
* @modified
* @description :   BP: Based on the primary failed part, a trans. diagnostic code is required
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_CheckPFPForElectricalCodes implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        List<WOD_2__Claim__c> claimLst = [SELECT Id,WOD_2__Inventory__c,
                                    WOD_2__Account__c,WOD_2__Units_Usage__c,WOD_2__Account__r.ATI_Max_Travel_Distance__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
         if(claimLst.size()>0){
         Integer  disgCodeInteger = [SELECT Count() FROM ATI_Diagnostic_Code__c WHERE Claim__c = :claimLst[0].Id];
            
            if(disgCodeInteger == 0){   
                return true; 
            }
            
        }
          return false;      
         
    }
}