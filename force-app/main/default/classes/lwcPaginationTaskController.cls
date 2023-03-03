public  class lwcPaginationTaskController 
{
    @AuraEnabled
    public static void conDelete(string conId){
        
        Contact ct = new Contact(Id = conId); 
        
        try {
             delete ct;
            System.debug(ct+'Delete contact');
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<Account> getAccountDataDetails(string Value){

        if(Value == 'ascending'){
     
            List<Account> AccSortList = [select Id, Name from Account ORDER BY Name ASC];
     
           if(!AccSortList.isEmpty()){
     
             return AccSortList;  
     
           } 
     
           }
     
          else if(Value == 'descending'){
     
              List<Account> accLst = [select Id, Name from Account ORDER BY Name DESC];
     
              //null check
      
             If(!accLst.isEmpty())
     
                   return accLst;  
     
          }
     
          else {
     
           }
     
           return null;
     
          }
    
    
    
    @AuraEnabled
    public static contact updateContacts(String conId , String conLastName , String conEmail , String conTitle , String conPhone){
        contact conEdit = new contact();
        // contact ct = [select id , LastName from contact where id =:conId];
        conEdit.Id = conId;
        conEdit.LastName = conLastName;
        conEdit.Email = conEmail;
        conEdit.Title = conTitle;
        conEdit.Phone = conPhone;
        try{
            update conEdit;
        }
        catch(Exception e){
            System.debug('unable to update the record due to'+e.getMessage());
        }
        return conEdit;
        
        
    }
    @AuraEnabled
    public static account updateRecord(String accId,String accChangeName,string accChangeType, string accChangePhone,String accchangeIndustry){
        System.debug('@@@@AccountId@@@'+accId);
        System.debug('@@@@AccountId@@@'+accChangeName);
        System.debug('@@@@AccountId@@@'+accChangeType);
        System.debug('@@@@AccountId@@@'+accChangePhone);
        System.debug('@@@@AccountId@@@'+accchangeIndustry);
        
        //Account acc=[select Id,Name,Site from Account where Id=:accId];
        // acc.site='';
        Account newAcc = new account();
        if(accId != null ){
            newAcc.Id = accId;
        }
        if( accChangeName != 'undefined'){
            newAcc.Name = accChangeName;
        }
        if(accChangeType != 'undefined'){
            newAcc.Type = accChangeType;
        }
        if( accChangePhone != 'undefined'){
            newAcc.Phone = accChangePhone;
        }
        if(  accchangeIndustry != 'undefined'){
            newAcc.Industry = accchangeIndustry;
        }
        
        
        try{
            update newAcc;
            system.debug('updated'+ newAcc);
        }
        catch (Exception e) {
            System.debug('unable to update the record due to'+e.getMessage());
        }
        return newAcc;
    }
    // Create a lightning-datatable and display modal on rowaction
    @AuraEnabled
    public static list<Account> getAccountData(String textkey) {
        textkey = '%' + textkey + '%';  
        list<Account> accLst = [SELECT  Id, Name, Industry, Phone, Type From Account WHERE Name LIKE :textkey];
        
        if(accLst.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return accLst; 
    }
    
    @AuraEnabled
    public static list<contact> getContactData(String accId) {
        accId =  accId ;
        system.debug('accId'+accId);
        list<Contact> conLst = [SELECT  Id, LastName,Phone,Email ,Title From Contact WHERE AccountId=:accId];
        system.debug('conLst'+conLst);
        if(conLst.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        } 
        return conLst; 
    }
    
    
}