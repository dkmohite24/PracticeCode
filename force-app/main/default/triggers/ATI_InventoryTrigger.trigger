trigger ATI_InventoryTrigger on WOD_2__Inventory__c (after insert, before update, after update) {
    //TWOD_TriggerDispatcher.run(new ATI_InventoryTriggerHandler(),'ATI_InventoryTrigger');
    WOD_2__Configuration_Setting__mdt executeTrigger = ATI_Utils.getConfigurationSettingMetaData('ATI_InventoryTrigger');
    if(executeTrigger != null && executeTrigger.WOD_2__isActive__c) {
        new ATI_InventoryTriggerHandler().run();
    }

}