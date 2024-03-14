/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        15-December-2021
* @modified
* @description :   Trigger from BU rule ->470 Bu Rule AT:For pre-deliv. the RO date can't be 24O mos. after build date call QA if legit
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_RoDate24MonthInService implements WOD_2.BR_BusinessRuleInterface{
    global Integer months;
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__BusinessCategory__c,WOD_2__Inventory__c,ATI_isPreDelivery__c,WOD_2__Date_Of_Failure__c
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId
                                          AND ATI_isPreDelivery__c =: TRUE];
        if(claimlst.size()>0){
            List<Id> invList = new List<Id>();
            invList.add(claimlst[0].WOD_2__Inventory__c);
            List<WOD_2__Inventory__c> invDetailsList= ATI_WarrantyService.getInventoriesForWR(invList);
            Integer months =  Integer.valueof(ATI_Utils.getConfiguration(claimlst[0].WOD_2__BusinessCategory__c, 'ATI_RepairOrderPre_delivery').WOD_2__Value__c);
            system.debug('months'+months);
            List<WOD_2__Warranty_Registration__c> warrantyRegLst = [SELECT Id,ATI_Pre_Delivery__c FROM WOD_2__Warranty_Registration__c 
                                                                    WHERE ATI_Pre_Delivery__c = TRUE AND WOD_2__Inventory__c = :invDetailsList[0].Id];
            
            if(warrantyRegLst.size()>0 && claimlst[0].WOD_2__Date_Of_Failure__c>invDetailsList[0].WOD_2__Manufacturing_Date__c.addMonths(24)){  
                return true;  
            }
        }
        return false;
        
    }
}