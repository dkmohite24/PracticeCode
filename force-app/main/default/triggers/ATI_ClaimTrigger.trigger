/* Name: ATI_ClaimTrigger
   Description : Trigger for WOD_2__Claim__c object
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Akshatha S)    30/11/2020          INITIAL DEVELOPMENT
*/

trigger ATI_ClaimTrigger on WOD_2__Claim__c (before insert,after insert, before update, after update) {
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_ClaimTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_ClaimTriggerHandler().run();
    }
}