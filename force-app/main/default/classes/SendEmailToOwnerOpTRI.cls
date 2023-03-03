Public Class SendEmailToOwnerOpTRI{
    Public void SendEmailOpportunity(list<Opportunity>NewOP , list<Opportunity>OldOP){
    list<string>TosendEmail = new list<string>();
    list<messaging.singleEmailmessage> lstmail = new list<messaging.singleEmailmessage>();
    Messaging.singleEmailMessage mail= new Messaging.singleEmailMessage();
    list<opportunity> oppty = 
        [select id,Name, StageName,owner.name, owner.email from opportunity where id in :NewOP];   
       System.debug('List trigger.new oppty ::::'+oppty);             
       System.debug('List trigger.new NewOP ::::'+NewOP);
       System.debug('List trigger.old::::'+OldOP);
       
        for(Opportunity OpNew: oppty){
        
            system.debug('List soql ::::'+OpNew.stageName);
            
            for(Opportunity Opold: OldOP){
            
            system.debug('List soql ::::'+Opold.stageName);
            
               if(OpNew.stageName != Opold.stageName){
               TosendEmail.Add(OpNew.owner.email);
               
               /*mail.setReplyTo('mohite24@gmsil.com');
               system.debug('listOwnerEmail ::::'+TosendEmail);
                    mail.setToAddresses(TosendEmail);
                    mail.setSubject('Duplicate Account is Created');
                    mail.setHtmlBody('Hi,'+OpNew.Owner +'<br/><br/> Account is created  as');
                    lstMail.add(mail);
                    system.debug('Lstmail ::::'+lstMail);*/
               
               System.debug('List of mail ID to be send ::::'+OpNew.owner.email);
               System.debug('List of mail ID to be send TosendEmail ::::'+TosendEmail);
               mail.setReplyTo('mohite24@gmsil.com');
               mail.setToAddresses(TosendEmail);
               mail.setSubject('Stage is changed of your opportunity Named As'  +OpNew.name  );
               mail.setHtmlBody('Hi,' +Opnew.owner.name +'<br/><br/> Opportunity stage is changed from:\n' +OpNew.stageName
                                      + '  to  '  +Opold.stageName );
               lstMail.add(mail);
               system.debug('Lstmail ::::'+lstMail);
               }
            }
            
         }  
         if(lstMail<> NULL && !lstMail.isEmpty()){
         Messaging.sendEmail(lstMail); 
            } 
    }
}