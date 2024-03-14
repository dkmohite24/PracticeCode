/* Name: ATI_ShipmentTrigger
Description : 
Author : Tavant(MB)
History:
VERSION     AUTHOR              DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(MB)        15/03/2021       INITIAL DEVELOPMENT                              
*/

trigger ATI_ShipmentTrigger on WOD_2__Shipment_Detail__c (After insert, After update,before delete, before update) {
    System.debug('>> ATI_ShipmentTrigger :');
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_InventoryTrigger');
    System.debug('>> executeTrigger :'+executeTrigger);
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        System.debug('>> executeTrigger.WOD_2__isActive__c :'+executeTrigger.WOD_2__isActive__c);
        new ATI_ShipmentTriggerHandler().run();
    }
 
    
}