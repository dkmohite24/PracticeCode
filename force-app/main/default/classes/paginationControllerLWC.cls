public with sharing class paginationControllerLWC {
    @AuraEnabled(cacheable=true)
   public static List<Account> getOpps( String searchKey, String sortBy,String sortDirection , String pageSize) {
      
       String query = 'SELECT Id, Name FROM Account';
       system.debug('query---'+query);
       if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' WHERE Name LIKE :key';
       }
       if ( sortBy != null && sortDirection != null ) {
           query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
       }
       system.debug('logs'+ pageSize);
       query = query ;
       return Database.query( query );
   }
   @AuraEnabled(cacheable=true)
    public static List<Contact> getContact(){
        try {
            return [select FirstName,LastName,Email from contact];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}