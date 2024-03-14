/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        21-July-2021
* @modified
* @description :   Trigger from BU rule -> AT: Travel Miles/Kilo excessive

* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_UnitUsageExcessive implements WOD_2.BR_BusinessRuleInterface{
    global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        System.debug('CPU Limit Before -> ' + Limits.getCpuTime());  
        if(wrapper.ruleObjectId != NULL){
        List<WOD_2__Claim__c> claimLst = [SELECT Id,WOD_2__Inventory__c,
                                    WOD_2__Account__c,WOD_2__Units_Usage__c,WOD_2__Account__r.ATI_Max_Travel_Distance__c
                                    FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
            if(claimLst.size()>0){  
                List<WOD_2__Other_Cost__c> otherCostLst = [SELECT Id,WOD_2__UnitsUsage__c,ATI_Total_Cost_in_USD__c,WOD_2__Cost_Category_Type__c 
                                                           FROM WOD_2__Other_Cost__c
                                                           WHERE WOD_2__Claim__c =:claimLst[0].Id];
                For(WOD_2__Other_Cost__c otherCost : otherCostLst ) {         
                    if(claimLst[0].WOD_2__Account__r.ATI_Max_Travel_Distance__c!=NULL && claimLst[0].WOD_2__Account__r.ATI_Max_Travel_Distance__c < otherCost.WOD_2__UnitsUsage__c){
                        system.debug('---'+claimLst[0].WOD_2__Account__r.ATI_Max_Travel_Distance__c);   
                        return true;  
                    }
                }
            }
        }
        return false;
        
    }
}