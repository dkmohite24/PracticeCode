trigger EndCustomerTrigger on End_Customer_Staging_Data__c (Before Update, After Insert, After Update) {
if(Trigger.isAfter) {
        //EnCustStageHelper.afterHelper(Trigger.new);
    }
}