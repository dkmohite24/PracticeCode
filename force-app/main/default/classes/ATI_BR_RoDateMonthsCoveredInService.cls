/**
 -------------------------------------------------------------------------------------------------
* @author         Akshatha
* @created        28-Dec-2021
* @modified
* @description :   Trigger from BU rule -> If campaign RO date is grater than the Months covered from the in-service date then throw hard error
* --------------------------------------------------------------------------------------------------
*/
global class ATI_BR_RoDateMonthsCoveredInService implements WOD_2.BR_BusinessRuleInterface {
	global Boolean checkBusinessRule(WOD_2.BR_BusinessRuleClassOverrideWrapper wrapper) {
        List<WOD_2__Claim__c> claimlst = [SELECT Id,WOD_2__Claim_Type__c,WOD_2__Inventory__c,WOD_2__Date_Of_Failure__c,twodcms__Member_Template_Association__r.twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.ATI_Months_Covered__c FROM WOD_2__Claim__c WHERE Id =:wrapper.ruleObjectId];
    	if(!claimlst.isEmpty()){
            List<Id> invList = new List<Id>();
            invList.add(claimlst[0].WOD_2__Inventory__c);
            List<WOD_2__Inventory__c> invDetailsList= ATI_WarrantyService.getInventoriesForWR(invList);
            // Alsn-153 added null check for install date
            if(claimlst[0].WOD_2__Claim_Type__c=='Campaign' && claimlst[0].twodcms__Member_Template_Association__r.twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.ATI_Months_Covered__c!=null && invDetailsList[0].WOD_2__Install_Date__c!=null){
                if(claimlst[0].WOD_2__Date_Of_Failure__c>invDetailsList[0].WOD_2__Install_Date__c.addMonths(Integer.valueOf(claimlst[0].twodcms__Member_Template_Association__r.twodcms__Campaign_Members__r.twodcms__Service_Campaign__r.ATI_Months_Covered__c))){  
                    return true;  
                }
            }
        }
        return false;
    }
}