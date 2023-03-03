public class LightningMapCntrl {
	
    @AuraEnabled
    public static  List<Contact> fetchContacts(String accountId){
        List<Contact> conList = [Select Id,Name,Phone,MailingCity,MailingStreet,MailingPostalCode,MailingState,MailingCountry from Contact where accountId=:accountId];
        return conList;
    }
}