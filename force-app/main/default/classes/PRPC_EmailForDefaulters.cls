global class PRPC_EmailForDefaulters {
    	public static Integer monthValue;
    public static void sentEmail() {
        Set<Id> dealers = new Set<Id>();
        List<KPI_Date_Settings__c> KPIfilesubmission = [Select Id,No_Of_Days_To_File_Submission_Date__c from KPI_Date_Settings__c 
                                                        where No_Of_Days_To_File_Submission_Date__c= -1];  
        
        Integer Month = Date.Today().Month();
        Integer year = Date.Today().Year();
        if(Test.isRunningTest()){
            Month = monthValue;
        }
        if(	Month == 1){
            Month = 12;
            year = year-1;
        }
        else{
            Month = Month - 1;
        }
        
        String monthName = '';
        if(Month == 1)
            monthName = 'Jan';
        else if(Month == 2)
            monthName = 'Feb';
        else if(Month == 3)
            monthName = 'Mar';
        else if(Month == 4)
            monthName = 'Apr';
        else if(Month == 5)
            monthName = 'May';
        else if(Month == 6)
            monthName = 'June';
        else if(Month == 7)
            monthName = 'July';
        else if(Month == 8)
            monthName = 'Aug';
        else if(Month == 9)
            monthName = 'Sept';
        else if(Month == 0)
            monthName = 'Oct';
        else if(Month == 11)
            monthName = 'Nov';
        else
            monthName = 'Dec';
            
        
        List<Account> accList = new List<Account>();
        if(KPIfilesubmission.size() > 0){
            List<TAT_Data__c> tatrecord = [Select Id,Name,Dealer_Id__c,Partner_Code__c,Date_of_File_Submission__c from TAT_Data__c 
                                           where Dealer_Id__c != Null AND Month__c = :Month AND Year__c = :year];
            
            for(TAT_Data__c tat : tatrecord){
                dealers.add(tat.Dealer_Id__c);
            }
            accList = [Select Id, Name, ParentId, Type from Account where Id NOT IN :dealers AND PRP_Participation__c = true];
            
            Set<Id> distributors = new Set<Id>();
            for(Account d : accList){
                if(d.Type == 'Distributor Branch')
                	distributors.add(d.ParentId);
                else if(d.Type == 'Direct Dealer')
                    distributors.add(d.Id);
            }
            
            List<AccountContactRelation> accRel = new List<AccountContactRelation>();
            accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where AccountId IN :distributors];
            Set<String> con = new Set<String>();
            for(AccountContactRelation c : accRel){
                con.add(c.ContactId);
            }
            
            System.debug('con - ' + con);
            
            List<User> primaryContact = [Select Id, Email FROM User WHERE contactId IN :con AND contact.IsPrimary__c = true];
            List<String> emailTo = new List<String>();
            List<String> finalEmailTo = new List<String>();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            for(User to : primaryContact){
                if(to.Email !=null && to.Email != ''){
                    finalEmailTo.add(to.Email);
                }
            }
            email.setSenderDisplayName('PRP Team');
            email.setReplyTo('no-reply@allisontransmissionenterprise.com');
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setSaveAsActivity(false);
            email.setToAddresses(finalEmailTo);
            email.setSubject('Turn Time Data not submitted for ' + monthName + ' ' + year);
            email.setHtmlBody('Dear Partner, <br/><br/>Greetings of the day.<br/>This is to inform you that your Turn Time Data is not yet submitted for ' + monthName + ' ' + year + '.<br/>Please submit it as soon as possible.<br/><br/>Regards,<br/>Allison Transmission Support');
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }
            catch(Exception e){
                System.debug('Email not sent!!!');
            }
        }

    }

}