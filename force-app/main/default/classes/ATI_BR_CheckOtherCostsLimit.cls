/**
 -------------------------------------------------------------------------------------------------
* @author         Ravi Goudar
* @created        12-Jan-2021
* @modified
* @description :   Trigger from BU rule Check_Cost_Category_Dollar_Limit -> checking for the limit of other costs
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_CheckOtherCostsLimit implements WOD_2.BR_BusinessRuleInterface{
	public Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        Map<String,Decimal> costCategoryToLimitMap = new Map<String,Decimal>();
        Map<String,ATI_Cost_Category_Dollar_Limit__mdt> costCategoryLimitMdtMap = ATI_Cost_Category_Dollar_Limit__mdt.getAll();
        for(ATI_Cost_Category_Dollar_Limit__mdt ccLimitObj : costCategoryLimitMdtMap.values()){
            costCategoryToLimitMap.put(ccLimitObj.MasterLabel,ccLimitObj.ATI_Value__c);
        }
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        Map<String,Decimal> costCategoryToTotalCostMap = new Map<String,Decimal>();
        for(WOD_2__Other_Cost__c otherCostObj : [SELECT Id,ATI_Total_Cost_in_USD__c,WOD_2__Cost_Category_Type__c 
                                                 	FROM WOD_2__Other_Cost__c WHERE WOD_2__Claim__c =:wrapper.ruleObjectId])
        {
            if(costCategoryToTotalCostMap.containsKey(otherCostObj.WOD_2__Cost_Category_Type__c)){
                Decimal totalAmt = costCategoryToTotalCostMap.get(otherCostObj.WOD_2__Cost_Category_Type__c) + otherCostObj.ATI_Total_Cost_in_USD__c;
                costCategoryToTotalCostMap.put(otherCostObj.WOD_2__Cost_Category_Type__c,totalAmt);
            }else{
                costCategoryToTotalCostMap.put(otherCostObj.WOD_2__Cost_Category_Type__c,otherCostObj.ATI_Total_Cost_in_USD__c);
            }
        }
        
        for(String costCategory : costCategoryToTotalCostMap.keySet()){
            if(costCategoryToLimitMap.containsKey(costCategory) && costCategoryToTotalCostMap.get(costCategory) > costCategoryToLimitMap.get(costCategory)){
                return true;
            }
        }
        return false;
    }
}