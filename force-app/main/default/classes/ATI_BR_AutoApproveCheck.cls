/**
 -------------------------------------------------------------------------------------------------
* @author         Ravi Goudar
* @created        21-Jan-2021
* @modified
* @description :   
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_AutoApproveCheck implements WOD_2.BR_BusinessRuleInterface {
	public Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        System.debug('wrapper.ruleObjectId---------->'+wrapper.ruleObjectId);
        Map<String,WOD_2__Business_Category_Configuration_Setting__c> bccsSettingRecsMap = new Map<String,WOD_2__Business_Category_Configuration_Setting__c>();
        for(WOD_2__Business_Category_Configuration_Setting__c bccssetObj : [SELECT id, Name,WOD_2__Value__c,WOD_2__Display_Message__c 
                                                                            	FROM WOD_2__Business_Category_Configuration_Setting__c 
                                                                            	WHERE Name = 'ATI_CLM_ThresholdAmountForAutoApproval' 
                                                                            		OR Name = 'ATI_Check_For_Auto_Approval'])
        {
            bccsSettingRecsMap.put(bccssetObj.Name,bccssetObj);
        }
        
        List<WOD_2__Business_Rule__c> exceptionsLst = new List<WOD_2__Business_Rule__c>();
        List<WOD_2__Business_Rule__c> exceptionsLstTemp = [SELECT Id,WOD_2__Message__c FROM WOD_2__Business_Rule__c WHERE WOD_2__Claim__c=:wrapper.ruleObjectId];
        for(WOD_2__Business_Rule__c buRuleObj : exceptionsLstTemp){
            if(exceptionsLstTemp[0].WOD_2__Message__c != NULL 
               && bccsSettingRecsMap.containsKey('ATI_Check_For_Auto_Approval') && bccsSettingRecsMap.get('ATI_Check_For_Auto_Approval').WOD_2__Display_Message__c != NULL
               && !exceptionsLstTemp[0].WOD_2__Message__c.equals(bccsSettingRecsMap.get('ATI_Check_For_Auto_Approval').WOD_2__Display_Message__c)){
                   exceptionsLst.add(buRuleObj);
               } 
        }
        
        List<WOD_2__Claim__c> claimLst = [SELECT Id,ATI_Total_Requested_Amount__c FROM WOD_2__Claim__c WHERE Id=:wrapper.ruleObjectId];
        if(!claimLst.isEmpty() && exceptionsLst.isEmpty() && claimLst[0].ATI_Total_Requested_Amount__c != 0.0 && claimLst[0].ATI_Total_Requested_Amount__c != NULL && bccsSettingRecsMap.containsKey('ATI_CLM_ThresholdAmountForAutoApproval')
          && bccsSettingRecsMap.get('ATI_CLM_ThresholdAmountForAutoApproval').WOD_2__Value__c != NULL  && claimLst[0].ATI_Total_Requested_Amount__c < Decimal.valueOf(bccsSettingRecsMap.get('ATI_CLM_ThresholdAmountForAutoApproval').WOD_2__Value__c)){
			return true;
        }
        return false;
    }
}