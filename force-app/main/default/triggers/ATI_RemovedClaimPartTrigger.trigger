/* Name: ATI_RemovedClaimPartTrigger
Description : Trigger for WOD_2__Removed_Claim_Part__c object
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL              UserStory/Req#
1.0 -     Tavant(TY)      01-Mar-2021      INITIAL DEVELOPMENT                              
*/
trigger ATI_RemovedClaimPartTrigger on WOD_2__Removed_Claim_Part__c(before insert,after insert, before update, after update) {
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_RemovedClaimPartTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_RemovedClaimPartTriggerHandler().run();
    }
}