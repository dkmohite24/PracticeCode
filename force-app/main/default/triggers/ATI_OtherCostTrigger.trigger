/**
 -------------------------------------------------------------------------------------------------
* @author         Ravi Goudar
* @created        12-Jan-2021
* @modified
* @description :   Trigger on other cost
* --------------------------------------------------------------------------------------------------
*/
trigger ATI_OtherCostTrigger on WOD_2__Other_Cost__c (after insert,before insert,before update) {
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_OtherCostTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_OtherCostTriggerHandler().run();
    }
}