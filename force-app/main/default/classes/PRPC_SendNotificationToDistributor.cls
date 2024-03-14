/*
 * Created By : Sapna Kumari
 *
 * Update : CHG44065 -Update the profile check for PRP Admin & CSM User to custom permissions.
 * Update By : 08/23/2023, Susovan Mondal & Chinmaya Das
 */


global class PRPC_SendNotificationToDistributor {
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
        if( Month == 1){
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
            accList = [Select Id, Name, ParentId, Type, parent.AccountSAPField__c from Account where Id NOT IN :dealers AND PRP_Participation__c = true];
            
            Set<Id> distributors = new Set<Id>();
            for(Account d : accList){
                if(d.Type == 'Distributor Branch')
                    distributors.add(d.parentId);
                else if(d.Type == 'Direct Dealer')
                    distributors.add(d.Id);
            }
            List<User> partners = [Select Id, Name, Email, Contact.Account.AccountSAPField__c FROM User WHERE contact.AccountId IN :distributors AND contact.IsPrimary__c = true];
            List<User> prpAdmins = new List<User>();
         //CHG44065 Removing the PRP_Profile__mdt metadata.
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
            
            
        Map<String,String> pmap = new Map<String,String>();
        Set<String> pset = new set<String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(pmap.get(s)=='PRP Admin'){
               pset.add(s);
            }
        }*/
            //CHG44065 Check the Custom permission.
            List<String> lstPRPAdmin = New List<String>();
            String permissionId;
            For(CustomPermission customPer :[Select id from CustomPermission where DeveloperName =: 'ATI_PRP_Admin']){
               permissionId = String.valueOf(customPer.id);
            }
            For(SetupEntityAccess setEntity:[SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityType =:'CustomPermission'and SetupEntityId =: permissionId]){
                lstPRPAdmin.add(String.valueof(setEntity.ParentId));
            }
            
            
            if(partners.size() > 0){
                //prpAdmins = [Select Id, Name, Email FROM User WHERE Profile.name = 'PRP Admin'];
                prpAdmins = [sELECT Id, Name, Email FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :lstPRPAdmin)];
            }
            
            List<String> finalEmailTo = new List<String>();
            String HtmlBody = '';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            for(User to : prpAdmins){
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
            email.setSubject('Defaulters for ' + monthName + ' ' + year);
            
            HtmlBody+='Dear PRP Admin, <br/><br/>Greetings of the day.<br/>This is to inform you that below list of distributors have not submitted the Turn Time File for ' + monthName + ' ' + year + '.<br/>Please take the required step as soon as possible.<br/><br/>';
            HtmlBody+= '<table border="1" style="border-collapse: collapse"><tr><th>Account Name</th><th>Contact Name</th><th>Email</th></tr>';
            for(User con : partners){
                HtmlBody += '<tr><td>' + Con.Contact.Account.AccountSAPField__c + '</td><td>' + con.Name + '</td><td>' + con.Email + '</td></tr>';
            }
            HtmlBody += '</table>';
            HtmlBody += '<br/><br/>Regards,<br/>Allison Transmission Support';
            email.setHtmlBody(HtmlBody);
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            }
            catch(Exception e){
                System.debug('Email not sent!!!');
            }
        }

    }
    
}