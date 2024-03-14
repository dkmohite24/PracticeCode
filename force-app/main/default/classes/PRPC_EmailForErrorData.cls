public class PRPC_EmailForErrorData {
    
    public static void sendEmail(){
        List<TAT_Turnt_staging__c> tatData = [select id from TAT_Turnt_staging__c where Error_Log__c !=null and Distributor_Ship_To__c != null];
        List<PRPMD_All_Staging_object_Data__mdt> ttTurntList = [select id,EmailCheck__c,DateFrom__c,DateTo__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c ='TAT_Turnt_staging__c' LIMIT 1];
        Boolean flag = ttTurntList[0].EmailCheck__c;
        string storeDate = string.valueof(Date.today().day());
        string endPoint = [select id,EmailCheck__c,EndPoint_URL__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c ='TAT_Turnt_staging__c'].EndPoint_URL__c;
        Set<ID> tatId = new Set<ID>();
        for(TAT_Turnt_staging__c t : tatData){
            tatId.add(t.Id);
        }
        List<String> SAPId = new List<String>();
        List<TAT_Turnt_staging__c> tt = [select id, Distributor_Ship_To__c, Error_Log__c  from TAT_Turnt_staging__c where ID IN :tatId AND Error_Log__c != null];
        for(TAT_Turnt_staging__c tat : tt){
            if(tat.Distributor_Ship_To__c!=null){
                if(tat.Distributor_Ship_To__c.length() == 9){
                    tat.Distributor_Ship_To__c = '0' + tat.Distributor_Ship_To__c;
                    SAPId.add(tat.Distributor_Ship_To__c);
                }
                else
                    SAPId.add(tat.Distributor_Ship_To__c); 
            }
        }
        System.debug('SAP ID - ' + SAPId);
        
        List<Account> distributors = [SELECT ID, SAP_ID__c, ParentId, Type FROM Account WHERE SAP_ID__c IN :SAPId AND PRP_Participation__c = true];
        Set<Id> distId = new Set<Id>();
        for(Account d : distributors){
            if(d.Type == 'Distributor Branch')
                distId.add(d.ParentId);
            else if(d.Type == 'Direct Dealer')
                distId.add(d.Id);
        }
        System.debug('distId - ' + distId);
        List<AccountContactRelation> accRel = new List<AccountContactRelation>();
        accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where AccountId IN :distId];
        Set<Id> con = new Set<Id>();
        for(AccountContactRelation c : accRel){
            con.add(c.ContactId);
        }
        
        System.debug('con - ' + con);
        
        List<User> primaryContact = [Select Id, Email FROM User WHERE contactId IN :con AND contact.IsPrimary__c = true];
        system.debug('primaryContact: '+primaryContact);
        List<String> emailTo = new List<String>();
        List<String> finalEmailTo = new List<String>();
        Messaging.Email[] messages = new Messaging.Email[0];
        
        String[] ccAddresses = new String[] {'pankhurhi.mallik@gyansys.com','raeanne.jordan@allisontransmission.com'};
        for(User to : primaryContact){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(to.Email !=null && to.Email != ''){
                finalEmailTo.add(to.Email);
                
                email.setSenderDisplayName('PRP Team');
                email.setReplyTo('no-reply@allisontransmissionenterprise.com');
                email.setUseSignature(false);
                email.setBccSender(false);
                email.setSaveAsActivity(false);
                email.setCcAddresses(ccAddresses);
                //email.setToAddresses(string.valueof(to.Email));
                email.setTargetObjectId(to.Id);
                email.setSubject('Invalid Turn Time Data');
                email.setHtmlBody('Dear Channel Partner, <br/><br/>This is to notify you that there is an issue with your Turn Time file.  Please login to the PRP System or select the link below to view and correct the errors.<br/><br/><a href=\''+endPoint+'\'>Error Logs</a><br/><br/>Please contact Raeanne Jordan (<a href="mailto:raeanne.jordan@allisontransmission.com">raeanne.jordan@allisontransmission.com</a>) if you have any questions.<br/><br/>Regards,<br/>Allison Transmission Support');
                messages.add(email);
                /*try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                }
                catch(Exception e){
                    System.debug('Email not sent!!!');
                }*/
            }
        }
        system.debug('messages: '+messages);
        system.debug('messagesSize: '+messages.size());
        try{
            if(Integer.valueof(storeDate) >= integer.valueOf(ttTurntList[0].DateFrom__c) && integer.valueOf(storeDate) <= integer.valueOf(ttTurntList[0].DateTo__c)  && flag == true){
			//system.debug('enter');
            Messaging.sendEmail(messages);
            }
        }
        catch(Exception e){
            System.debug('Email not sent!!!');
        }
    }
    
    
    public static void sendEmailToCustomers(){
        List<End_Customer_Staging_Data__c> endCustData = [Select id from End_Customer_Staging_Data__c where Error_Log__c!=null and Distributor_Ship_To__c!=null];
        List<PRPMD_All_Staging_object_Data__mdt> endCustList = [select id,EmailCheck__c,DateFrom__c,DateTo__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c ='End_Customer_Staging_Data__c' LIMIT 1];
		Boolean flag2 = endCustList[0].EmailCheck__c;
        string storeDate = string.valueof(Date.today().day());
        string endPoint = [select id,EmailCheck__c,EndPoint_URL__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c ='End_Customer_Staging_Data__c'].EndPoint_URL__c;
        Set<ID> endId = new Set<ID>();
        for(End_Customer_Staging_Data__c t : endCustData){
            endId.add(t.Id);
        }
        List<String> SAPId = new List<String>();
        List<End_Customer_Staging_Data__c> tt = [select id, Distributor_Ship_To__c, Error_Log__c  from End_Customer_Staging_Data__c where ID IN :endCustData AND Error_Log__c != null];
        for(End_Customer_Staging_Data__c tat : tt){
            if(tat.Distributor_Ship_To__c!=null){
                if(tat.Distributor_Ship_To__c.length() == 9){
                    tat.Distributor_Ship_To__c = '0' + tat.Distributor_Ship_To__c;
                    SAPId.add(tat.Distributor_Ship_To__c);
                }
                else
                    SAPId.add(tat.Distributor_Ship_To__c); 
            }
        }
        System.debug('SAP ID - ' + SAPId);
        
        List<Account> distributors = [SELECT ID, SAP_ID__c, ParentId, Type FROM Account WHERE SAP_ID__c IN :SAPId AND PRP_Participation__c = true];
        Set<Id> distId = new Set<Id>();
        for(Account d : distributors){
            if(d.Type == 'Distributor Branch')
                distId.add(d.ParentId);
            else if(d.Type == 'Direct Dealer')
                distId.add(d.Id);
        }
        System.debug('distId - ' + distId);
        List<AccountContactRelation> accRel = new List<AccountContactRelation>();
        accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where AccountId IN :distId];
        Set<Id> con = new Set<Id>();
        for(AccountContactRelation c : accRel){
            con.add(c.ContactId);
        }
        
        System.debug('con - ' + con);
        
        List<User> primaryContact = [Select Id, Email FROM User WHERE contactId IN :con AND contact.IsPrimary__c = true];
        system.debug('primaryContact: '+primaryContact);
        List<String> emailTo = new List<String>();
        List<String> finalEmailTo = new List<String>();
        Messaging.Email[] messages = new Messaging.Email[0];
        
        String[] ccAddresses = new String[] {'spandana.chennupati@gyansys.com','raeanne.jordan@allisontransmission.com'};
        for(User to : primaryContact){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(to.Email !=null && to.Email != ''){
                finalEmailTo.add(to.Email);
                
                email.setSenderDisplayName('PRP Team');
                email.setReplyTo('no-reply@allisontransmissionenterprise.com');
                email.setUseSignature(false);
                email.setBccSender(false);
                email.setCcAddresses(ccAddresses);
                email.setSaveAsActivity(false);
                //email.setToAddresses(string.valueof(to.Email));
                email.setTargetObjectId(to.Id);
                email.setSubject('Invalid End Customer Data');
                email.setHtmlBody('Dear Channel Partner, <br/><br/>This is to notify you that there is an issue with your monthly Customer file that was recently submitted.  Please login to the PRP System or select the link below to view and correct the errors.<br/><br/><a href=\''+endPoint+'\'>Error Logs</a><br/><br/>Please contact Raeanne Jordan (<a href="mailto:raeanne.jordan@allisontransmission.com">raeanne.jordan@allisontransmission.com</a>) if you have any questions.<br/><br/>Regards,<br/>Allison Transmission Support');
                messages.add(email);
                /*try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                }
                catch(Exception e){
                    System.debug('Email not sent!!!');
                }*/
            }
        }
        try{
            if(Integer.valueof(storeDate) >= Integer.valueof(endCustList[0].DateFrom__c)  && Integer.valueof(storeDate) <= Integer.valueof(endCustList[0].DateTo__c)  && flag2 == true){
            Messaging.sendEmail(messages);
            }
        }
        catch(Exception e){
            System.debug('Email not sent!!!');
        }
    }
    
}