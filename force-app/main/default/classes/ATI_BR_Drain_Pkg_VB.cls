/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Trigger from BU rule -> AT: 00096903 cannot be used unless a 1K/2K valve body is replaced
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_Drain_Pkg_VB implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());              
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c,WOD_2__Causal_Part_Number__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size() > 0){
        List<WOD_2__Claim_Service_Information__c> claimServiceInfoLst = [SELECT Id,WOD_2__Service_Job_Code__r.Name,WOD_2__Claim__c
                                                                         FROM WOD_2__Claim_Service_Information__c 
                                                                         WHERE WOD_2__Claim__c=:claimlst[0].Id AND 
                                                                         WOD_2__Service_Job_Code__r.Name = '00096903'];
        
            List<ATI_UF_Code_Mapper__c> mapperList = [SELECT Id,ATI_Warranty_Product__r.Name,ATI_Warranty_Code__r.Name
                                                      FROM ATI_UF_Code_Mapper__c 
                                                      WHERE ATI_Warranty_Product__c=:claimlst[0].WOD_2__Causal_Part_Number__c AND
                                                      ATI_Warranty_Code__r.Name Like 'VBC%' ];
            system.debug('mapperList'+mapperList);
            
            if(claimServiceInfoLst.size()>0 && mapperList.Size()>0){
                return true;  
            }
        }
        return false;
    }
}