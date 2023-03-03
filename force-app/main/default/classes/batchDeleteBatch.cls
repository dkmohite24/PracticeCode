global class batchDeleteBatch implements Database.Batchable<Sobject>{
    global final String query;
    global Database.QueryLocator start(Database.BatchableContext bc) {
      return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Sobject> scope) {
      Database.delete(scope,false); // Delete the records
      Database.emptyRecyclebin(scope); //Delete from the recycle bin
    }
    global void finish(Database.BatchableContext bc) {
      //Get the status of the Batch Job
      AsyncApexJob a = [select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email From AsyncApexJob where Id = :bc.getJobId() ];
      //Send an email to the user who executed the Batch Job
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String[] toAddress = new String[]{a.CreatedBy.Email};
      mail.setToAddresses(toAddress);
      mail.setSubject('Apex job Status' + a.Status);
      mail.setPlainTextBody('The apex job processed ' + a.TotalJobItems + ' Batches with ' + a.NumberOfErrors + ' failures');
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}