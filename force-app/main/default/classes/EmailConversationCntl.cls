global with sharing class EmailConversationCntl{
    
    /**
* @description : To get all Email messages related to Record ID  
* 
* @return : List<EmailMessage>
**/
    
    @AuraEnabled
    global static List<EmailMessage> getEmailMessages(String RecId){
        
        system.debug('>>>>>>>>>>Id>>>'+ RecId);
        String ObjectName='';
        List<String> myFilter = new List<String>();    
        if(RecId.startsWith('00Q')){
            ObjectName='Lead__c';
            myFilter.add('Lead__c  =\''+ RecId+'\'');
        }
        
        else if(recid.startsWith('003')){
            ObjectName='Contact__c';
            myFilter.add('Contact__c  =\''+ RecId+'\'');
        }   
        
        System.debug('@@@@@Obejct NAme@@'+ObjectName);
        System.debug('@@@@@REcord Id@@'+RecId);
        
        String  queryString='SELECT Id, Subject,Status,TextBody,Incoming,HtmlBody,Headers,FromName,FromAddress,ToAddress,Contact__c,Opportunity__c,MessageDate,Lead__c,Account__c FROM EmailMessage';
        
        if(myFilter.size()>0){
            queryString += ' WHERE ' + myFilter[0];
            
        }
        else {
            string ss = 'No Emails';
        }
        system.debug('Structured Query>>>'+queryString);
        List<EmailMessage> allEmailMessages= database.query(queryString);
        system.debug('>>>>>>>>>>All Records>>>'+allEmailMessages);
        return allEmailMessages;
        
    }
    
    @AuraEnabled
    global static string getpassemaildetails(String RecordId){
        system.debug('>>>>>>>>>>Id>>>'+ RecordId);
        string idm = RecordId;
        string email='';
        system.debug('>>>>>>>>>>RecordId>>>'+ idm);
        
        If (idm.startsWith('003')){
            List<Contact> passvalues = [select id,Name,Email from Contact WHERE id =: idm limit 1];
            for(Contact l:passvalues ){
                email= l.Email ;
            }
            return email;
        }
        else if(idm.startsWith('00Q')){
            List<Lead> passvalues = [select id,Name,Email from Lead WHERE id =: idm limit 1];
            for(Lead l:passvalues ){
                email= l.Email ;
            }
            return email;
        }
        return email;
    }
    
    
    @AuraEnabled
    global static EmailMessage getemailAddress(String EMsgId){
        system.debug('>>>>>>>>>>Id>>>'+ EMsgId);
        string emid = EMsgId;
        system.debug('>>>>>>>>>>RecordId>>>'+ emid);
        List<EmailMessage> passemid = [select id,FromAddress,Lead__c,Contact__c,TextBody,ToAddress,Subject,Opportunity__c,HtmlBody,Incoming from EmailMessage WHERE id =: emid limit 1];
        string email='';
        
        return passemid[0];
    }
    
}