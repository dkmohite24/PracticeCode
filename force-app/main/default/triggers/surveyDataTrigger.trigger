trigger surveyDataTrigger on Survey_Data__c (Before Insert, Before Update) {
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        surveyDataHelper.updateScore(trigger.new);
    }
    
}