/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        22-Nov-2021
* @modified
* @description :   Trigger from BU rule ->Replacement claim exists on SN1 with a future RO date and same VIN

* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_ReplaceRoAndVin implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());
        List<WOD_2__Claim__c> claimlst = [SELECT Id,ATI_Replaced_Inventory__c,ATI_Replacement_Claims__c,WOD_2__Inventory__c,
                                          WOD_2__Date_Of_Failure__c,ATI_Today__c,ATI_WR_Details__c
                                          FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId
                                          AND ATI_Replacement_Claims__c = True];
        system.debug('claimlst VIn'+claimlst);
        if(claimlst.size()>0 && claimlst[0].ATI_WR_Details__c != Null && claimlst[0].ATI_WR_Details__c != ''){
        
            ATI_WarrantyService.WRDetailsWrapper wrDetails = (ATI_WarrantyService.WRDetailsWrapper)JSON.deserialize(claimlst[0].ATI_WR_Details__c, ATI_WarrantyService.WRDetailsWrapper.class);
            if(wrDetails != null && wrDetails.vehicleInfo != null){
                String vehicleInfoId = wrDetails.vehicleInfo.Id;
                system.debug('vehicleInfoId'+vehicleInfoId);
                List<ATI_Inventory_Replacement_History__c> invRepHistory =[SELECT Id,ATI_Replacement_Date__c,ATI_Claim__c,ATI_Claim__r.ATI_Replaced_Inventory__c,ATI_Claim__r.WOD_2__Date_Of_Failure__c,ATI_Failed_Inventory__c,ATI_Vehicle_Information__c
                                                                           FROM ATI_Inventory_Replacement_History__c 
                                                                           WHERE ATI_Failed_Inventory__c = :claimlst[0].ATI_Replaced_Inventory__c
                                                                           AND ATI_Vehicle_Information__c = :vehicleInfoId
                                                                           AND ATI_Replacement_Date__c > :claimlst[0].WOD_2__Date_Of_Failure__c];
                system.debug('invRepHistory'+invRepHistory);
        
            if(!invRepHistory.isEmpty()){  
                return true;  
            }
        }
        }
        return false;
        
    }
    
}