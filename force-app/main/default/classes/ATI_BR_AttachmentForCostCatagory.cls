/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule ->  Attachment requires for Towing and Duty Cost catagory
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_AttachmentForCostCatagory implements WOD_2.BR_BusinessRuleInterface{
    public Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('CPU Limit before -> ' + Limits.getCpuTime());
        if(wrapper.ruleObjectId != NULL){
            List<WOD_2__Other_Cost__c> otherCostObj = [SELECT Id,ATI_Total_Cost_in_USD__c,WOD_2__Cost_Category_Type__c 
                                                       FROM WOD_2__Other_Cost__c WHERE WOD_2__Cost_Category_Type__c IN ('Towing','Duty','Sublet','Freight')
                                                       AND WOD_2__Claim__c =:wrapper.ruleObjectId];
            system.debug('otherCostObj'+otherCostObj);
            if(otherCostObj.size() > 0){
                Integer attachmentCount = [Select count() FROM ContentDocumentLink WHERE LinkedEntityId IN (Select Id FROM WOD_2__Claim__c where id = :wrapper.ruleObjectId )];    
                if(attachmentCount == 0){
                    return true;
                }
            }
        }
        return false;
    }
}