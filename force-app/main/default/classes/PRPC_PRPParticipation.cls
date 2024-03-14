public class PRPC_PRPParticipation {
	@AuraEnabled
    public static List<Account> Recorddatafetch(String Distributorr){
        List<Account> FACAUD = new List<Account>();
        FACAUD = [select Id,Name,PRP_Participation__c,ShippingCity,SAP_ID__c from Account where ParentId=:Distributorr];
        return FACAUD;
    } 
    
    @AuraEnabled
    public static void updateAccRecord(List<Account> AccId){
        System.debug('AccId'+AccId);
        /*List<Account> acclist = [select Id,Name,PRP_Participation__c from Account where Id IN:AccId];
        List<Account> accTobeUpdated = new List<Account>();
        for(Account acc:acclist){
            System.debug(acc.PRP_Participation__c);
            if(acc.PRP_Participation__c != true){
                acc.PRP_Participation__c = true;
            }
            accTobeUpdated.add(acc);
        }*/
        update AccId;
    } 
    
    @AuraEnabled
    public static Account RecorddatafetchforDistributer(String Distributorr){
        System.debug(Distributorr);
        Account FACAUD = new Account();
        FACAUD = [select Id,Name,PRP_Participation__c from Account where Id=:Distributorr];
        return FACAUD;
    } 
    //To update the account as well on change of the PRP Participation Checckbox
    @AuraEnabled
    public static List<Account> updateDistributer(String Distributorr,Boolean PRPVal,List<String> AccId){
        System.debug(Distributorr);
        List<Account> accTobeUpdated = new List<Account>();
        Account FACAUD = new Account();
        FACAUD = [select Id,Name,PRP_Participation__c from Account where Id=:Distributorr];
        FACAUD.PRP_Participation__c = PRPVal;
        accTobeUpdated.add(FACAUD);
        
        //To update all the related record of account
        List<Account> acclist = [select Id,Name,PRP_Participation__c from Account where Id IN:AccId];       
        for(Account acc:acclist){
            acc.PRP_Participation__c = PRPVal;
            accTobeUpdated.add(acc);
        }
        update accTobeUpdated;
        
        //To send the updated record of related branch
        List<Account> updatdbranch = new List<Account>();
        updatdbranch = [select Id,Name,PRP_Participation__c from Account where ParentId=:Distributorr];
        return updatdbranch;

    } 
}