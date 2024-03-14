/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Trigger from BU rule ->AT: Based on the UF code for the PFP, the claim will be held for manual review.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_PFPUfCodeCheck implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());              
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Causal_Part_Number__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size() > 0){
        
        
            List<ATI_UF_Code_Mapper__c> mapperList = [SELECT Id,ATI_Warranty_Product__r.Name,ATI_Warranty_Code__r.Name
                                                      FROM ATI_UF_Code_Mapper__c 
                                                      WHERE ATI_Warranty_Product__c=:claimlst[0].WOD_2__Causal_Part_Number__c AND
                                                      ATI_Warranty_Code__r.Name IN ('VBE12', 'VBE13') ];
            system.debug('mapperList'+claimlst[0].WOD_2__Causal_Part_Number__c);
            
            if(mapperList.Size()>0){
                return true;  
            }
        }
        return false;
    }
}