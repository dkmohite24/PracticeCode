public class PRPC_ProgramContacts {
    
    @AuraEnabled
    public static List<Contact_Person__mdt> findProgramContacts(){
        ID userId = UserInfo.getUserId();
        User u = [select id, contact.Account.Sales_RegionA__c from User where id = : UserId];
        List<Contact_Person__mdt> contactPerson = [Select Name__c, Phone_Number__c, Email__c, Region__c FROM Contact_Person__mdt ORDER by Region__c];
        System.debug('Contact - ' + contactPerson);
        return contactPerson;
    }
}