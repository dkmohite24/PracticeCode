trigger EndCustTrigger on End_Customer_Staging_Data__c (Before Update, After Insert, After Update) {
     if(!Disable_Rules__c.getInstance('EndCustTrigger').Disable__c) {
    if(Trigger.isBefore && Trigger.isUpdate) {
        //tatStageHelper.recursion = false;
        EnCustStageHelper.beforeUpdateHelper(Trigger.new);
         
     }
    if(Trigger.isAfter && Trigger.isUpdate) {
        //tatStageHelper.recursion = false;
        EnCustStageHelper.deleteTatStaging();
    }
}
}