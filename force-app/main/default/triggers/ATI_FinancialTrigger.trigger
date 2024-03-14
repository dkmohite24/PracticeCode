/* Name: ATI_FinancialTrigger
   Description : Trigger for WOD_2__Financial__c object
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Akshatha S)    30/11/2020          INITIAL DEVELOPMENT
*/

trigger ATI_FinancialTrigger on WOD_2__Financial__c (after insert,after update) {
	WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_FinancialTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_FinancialTriggerHandler().run();
    }
}