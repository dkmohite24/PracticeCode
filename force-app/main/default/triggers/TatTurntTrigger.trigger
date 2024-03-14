trigger TatTurntTrigger on TAT_Turnt_staging__c (Before Update, After Insert, After Update) {
     if(!Disable_Rules__c.getInstance('TatTurntTrigger').Disable__c) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        //tatStageHelper.recursion = false;
        tatStageHelper.beforeUpdateHelper(Trigger.new);
         
     }
    if(Trigger.isAfter && Trigger.isUpdate) {
        //tatStageHelper.recursion = false;
        tatStageHelper.deleteTatStaging();
    }
     }
}