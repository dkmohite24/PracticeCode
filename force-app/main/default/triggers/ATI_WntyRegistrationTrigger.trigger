/* Name: ATI_WntyRegistrationTrigger
Description : ATI_WntyRegistrationTrigger - Trigger on WOD_2__Warranty_Registration__c to compute and add accurals for purchased Ext. Warranty Policy.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      24-JAN-2021          INITIAL DEVELOPMENT
*/
trigger ATI_WntyRegistrationTrigger on WOD_2__Warranty_Registration__c (after insert, after update, before update) {
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_WntyRegistrationTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
		new ATI_WntyRegistrationTriggerHandler().run();
    }
}