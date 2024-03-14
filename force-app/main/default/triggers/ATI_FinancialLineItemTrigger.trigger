/**
 -------------------------------------------------------------------------------------------------
* @author         TAVANT
* @created        1-2-2021
* @modified
* @description :   Trigger on Financial Line Item
* --------------------------------------------------------------------------------------------------
*/
trigger ATI_FinancialLineItemTrigger on WOD_2__Financial_Line_Item__c (before insert,before update) {
	WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_FinancialLineItemTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_FinancialLineItemTriggerHandler().run();
    }
}