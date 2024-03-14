/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule -> Description required for Towing Detail.
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_TowingDetail implements WOD_2.BR_BusinessRuleInterface{
    public Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('CPU Limit before -> ' + Limits.getCpuTime());
        if(wrapper.ruleObjectId != NULL){
        List<WOD_2__Other_Cost__c> otherCostList = [SELECT Id,ATI_Total_Cost_in_USD__c,WOD_2__Cost_Category_Type__c 
                                             FROM WOD_2__Other_Cost__c WHERE WOD_2__Claim__c =:wrapper.ruleObjectId AND WOD_2__Cost_Category_Type__c = 'Towing'];
            
        if(otherCostList.size()>0){
            return true;
        }
        }
        return false;
    }
}