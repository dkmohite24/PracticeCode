public class ContactEmailhandller {
    public void BeforeInsert(list<contact>Trinew){
        // Step 0: Create a master list to hold the emails we'll send
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        system.debug('trinew'+Trinew);
        for (Contact myContact : Trinew) {
            if (myContact.Email != null && myContact.LastName != null) {
                // Step 1: Create a new Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Step 2: Set list of people who should get the email
                List<String> sendTo = new List<String>();
                system.debug('trinew'+myContact.Email);
                sendTo.add(myContact.Email);
                mail.setToAddresses(sendTo);
                system.debug('MAil'+sendTo);
                // Step 3: Set who the email is sent from
                mail.setReplyTo('mohitedk24@gmail.com');
                mail.setSenderDisplayName('Salesforce developer');
                
                // (Optional) Set list of people who should be CC'ed
                List<String> ccTo = new List<String>();
                ccTo.add('rishabhgarg580@gmail.com');
                mail.setCcAddresses(ccTo);
                
                // Step 4. Set email contents - you can use variables!
                mail.setSubject('YOURE CONTACT IS CREATED');
                String body = 'Dear ' + myContact.LastName + ', ';
                body += '<html><body>Hello hope your doing well .';
                body += '<br>I am Dhananjay mohite Salesforce developer.\n ';
                body += 'Congradulaton your contact is created on org. \n  ';
                body += '<br>If there is any problem you can contact me on \n 940402240 \n ';
                body += '<br><br> Thanks And Regards </body></html>';
                mail.setHtmlBody(body);
                system.debug('body>>>>>>>>>>>>>'+body);
                // Step 5. Add your email to the master list
                mails.add(mail);
                system.debug('mails>>>>>>>>>>>>>'+mails);
            }
        }
        // Step 6: Send all emails in the master list
        Messaging.sendEmail(mails);
        system.debug('mails>>>>>>>>>>>>>'+mails);
        
    }
    
}