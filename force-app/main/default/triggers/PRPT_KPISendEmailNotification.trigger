trigger PRPT_KPISendEmailNotification on KPI_Date_Settings__c (after insert, after update) {
    //Map<kpiDateRec.KPI_Setup__r.Region__c, kpiDateRec.No_Of_Days_To_File_Submission_Date__c>
    Map<String,Decimal> kpiMapElement = new Map<String,Decimal>();
    for(KPI_Date_Settings__c kpiDateRec : [SELECT id ,No_Of_Days_To_File_Submission_Date__c, KPI_Setup__r.Region__c FROM KPI_Date_Settings__c WHERE Id IN : Trigger.new]){       
        kpiMapElement.put(kpiDateRec.KPI_Setup__r.Region__c, kpiDateRec.No_Of_Days_To_File_Submission_Date__c);   
    }
   // get list of accountContactROle with Account.Sales region and  contact email address for primary contacts  
    list<AccountContactRole> accConRelatedRec = new list<AccountContactRole>();
    accConRelatedRec= [SELECT id, IsPrimary ,Contact.Name , Contact.Email, Account.Name, Account.Sales_Region__c FROM AccountContactRole WHERE IsPrimary = True];
    // for each AccountContactRole 
    for(AccountContactRole accCon : accConRelatedRec){ 
        //get the accounts of same region as KPI setup region 
        // check if the number of days left is 0-7 
        if((kpiMapElement.containsKey(accCon.Account.Sales_Region__c)) && ((kpiMapElement.get(accCon.Account.Sales_Region__c) >= 0 || (kpiMapElement.get(accCon.Account.Sales_Region__c) <= 7)))){    
            // send email to the email address list 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { accCon.Contact.Email };
                message.optOutPolicy = 'FILTER';
            message.subject = 'File Submission';
            message.plainTextBody = ' Hello , The file submission date is witthin next 7 days , please send within given date . thanks  ';
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            } 
        }  
    } 
}