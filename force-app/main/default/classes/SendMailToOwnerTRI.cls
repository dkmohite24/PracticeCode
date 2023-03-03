public class SendMailToOwnerTRI{
    public void sendEmail(list<Account> lstAccount){
            list<Messaging.singleEmailMessage> lstMail= new list<Messaging.singleEmailMessage>();
            Messaging.singleEmailMessage mail= new Messaging.singleEmailMessage();
            
            list<Account> lstAccountNew = new list<Account>();
            list<Id>LstId = new list<id>();
            for(account AcId:lstAccount){
                
                LstId.Add(AcId.id);
                }
            system.debug('lstAccountNew ::::'+LstId);
            lstAccountNew = [SELECT Email__c,Exeternal_ID__c,Id,Name,OwnerId,owner.Email,Type FROM Account where id in:LstId];
            system.debug('lstAccountNew ::::'+lstAccountNew);
            List<string> listOwnerEmail;
            system.debug('TRigger ::::'+lstAccount);
            for(Account objAcc: lstAccountNew){
                listOwnerEmail = new List<string>();
                system.debug('TobjAcc.Owner.Email ::::'+objAcc.Ownerid);
                system.debug('TobjAcc.Owner.Email ::::'+objAcc.Owner.Email);
                if(objAcc.Owner.Email <> NULL){
                    listOwnerEmail.add(objAcc.Owner.Email);
                    system.debug('TRigger objAcc ::::'+objAcc);
                    system.debug('listOwnerEmail ::::'+listOwnerEmail);
                    
                    system.debug('TRigger ::::'+lstAccount);
                    
                    //listOwnerEmail.add(objAcc.Email__C);
                    mail.setReplyTo('mohite24@gmsil.com');
                    system.debug('listOwnerEmail ::::'+listOwnerEmail);
                    mail.setToAddresses(listOwnerEmail);
                    mail.setSubject('Duplicate Account is Created');
                    mail.setHtmlBody('Hi,'+objAcc.Owner +'<br/><br/> Account is created  as:\n' +objAcc.Name+'\n');
                    lstMail.add(mail);
                    system.debug('Lstmail ::::'+lstMail);
                }
                          
            }
            if(lstMail<> NULL && !lstMail.isEmpty()){
                Messaging.sendEmail(lstMail); 
            }
        }
        
}