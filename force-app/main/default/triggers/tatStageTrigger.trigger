trigger tatStageTrigger on TAT_Staging_Data__c (Before Update, After Insert, After Update) {
    if(Trigger.isAfter) {
        tatStageHelper.afterHelper(Trigger.new);
        
    }
     /*if(Trigger.isBefore && Trigger.isUpdate) {
         tatStageHelper.beforeUpdateHelper(Trigger.new);
         
     }
    if(Trigger.isAfter && Trigger.isUpdate) {
        tatStageHelper.deleteTatStaging();
    }*/

}