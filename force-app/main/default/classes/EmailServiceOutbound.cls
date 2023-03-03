public class EmailServiceOutbound {
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody,string recid){
        system.debug('>>>>recordid>&&'+ recid);
        system.debug('>>main>>>'+mMail);
        system.debug('>>subject>>>'+mSubject);
        system.debug('>>body>>>'+mbody);
        //Inserting the record id in Email subject
        string subrec= '('+ recid +')';  
        // For storing Relation Id
        string opcid ='';
        //Email Sending Start
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();  
        //Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();        
        //Set list of people who should get the email        
        List<String> sendTo = mMail.split(',');
        //Setting Senders
        mail.setToAddresses(sendTo);        
        String addrUrl='replyemailtocontact@1de75hjjwb5hhj9nc57t94povzdokxs3ziq8q1tcg5c12cl11a.2w-8qyiwea2.ap16.apex.salesforce.com';
        // Set who the email is sent from
        mail.setReplyTo(addrUrl); // change it with your mail address.
        mail.setSenderDisplayName(UserInfo.getName() ); 
        system.debug('>>>>>=='+ UserInfo.getName() );   
        // Subject from Email Component and Record ID
        mail.setSubject(mSubject + subrec );
        //Setting Body from Email Component
        mail.setHtmlBody(mbody);        
        // Add your email to the master list
        mails.add(mail);        
        try {
            
            //Add Inbound Email Message for contact
            EmailMessage caseEmailMessage = new EmailMessage();
            caseEmailMessage.fromAddress= UserInfo.getUserEmail();
            caseEmailMessage.ToAddress = mMail;
            caseEmailMessage.FromName = UserInfo.getName();
            caseEmailMessage.Subject = mSubject;
            caseEmailMessage.HtmlBody = mbody;
            caseEmailMessage.Incoming= False;
            caseEmailMessage.TextBody = mbody;
            caseEmailMessage.status = '3';
            
            if(recid.startsWith('003')){
                caseEmailMessage.Contact__c = recid;
            }
            else if(recid.startsWith('00Q')){
                caseEmailMessage.Lead__c = recid;
            }
            
            insert caseEmailMessage;  
           
            system.debug('>>>>>=='+ caseEmailMessage ); 
            system.debug('>>>>>=='+ caseEmailMessage.Id );
            
             // Add Email Message Relation for id of the sender
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.EmailMessageId = caseEmailMessage.id;
            emr.RelationAddress = UserInfo.getUserEmail();
            emr.RelationType = 'FromAddress';
            
            //Contact Email Message Relation Id
            if(recid.startsWith('003')){
                 emr.RelationId = recid;
            }
            
            
            //Lead Email Message Relation Id
            else if(recid.startsWith('00Q')){
                 emr.RelationId = recid;
            }
 	    insert emr;     
            system.debug('>>>>>=='+ emr ); 
            system.debug('>>>>>=='+ emr.Id );
          
            // Send all emails in the master list
            Messaging.sendEmail(mails);
            system.debug('>>>>>=='+ mails);           
            
        }
        catch(Exception e){
            System.debug('Queryue: ' + e);
        } 
        
    }   
}