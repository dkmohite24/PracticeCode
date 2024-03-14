/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   Trigger from BU rule -> Calim attachment
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_ClaimAttachment implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());              
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Inventory__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
        if(claimlst.size()>0){
        Integer attachmentCount = [Select count() FROM ContentDocumentLink WHERE LinkedEntityId IN (Select Id FROM WOD_2__Claim__c where id = :claimlst[0].Id )];
        
        if(attachmentCount >0){
            return false;  
        }
        }
        return true;
    }
}