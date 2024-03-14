public without sharing class NewSalesforceUserFormClass {
    @AuraEnabled
    public static String CreateRecord(String Recupdate,String Userupdate ,AWAARE_4WARD__c awr){
        AWAARE_4WARD__c UpdateAware = new AWAARE_4WARD__c();
        UpdateAware.id =Recupdate ;
        UpdateAware.Address__c=awr.Address__c;
        UpdateAware.City__c = awr.City__c;
        UpdateAware.Country_Picklist__c=awr.Country_Picklist__c;
        UpdateAware.Phone__c=awr.Phone__c;
        UpdateAware.State_Province__c=awr.State_Province__c;
        UpdateAware.Zip__c=awr.Zip__c;
        UpdateAware.Job_Title__c=awr.Job_Title__c;
        update UpdateAware;
        
        return awr.City__c ;
    }
       @AuraEnabled
    public static id CreateRecordforAwaareBasic(AWAARE_4WARD_Basic__c awr2, String un){
       // String Uname='_'+un+'@Allison4WARD.com';
       //  list<User> userlist = [SELECT Id,Username,Name,Profile.Name,Email,IsActive,ContactId FROM User WHERE Username=:Uname AND ContactId=null AND IsActive=false LIMIT 1];
     
         List<AWAARE_4WARD_Basic__c> blist=[Select Id,Username__c,Status__c from AWAARE_4WARD_Basic__c where Username__c=:un LIMIT 1];
        System.debug('Inside CreateRecordforAwaareBasic'); 
      
         if(blist.size()==0 || blist[0].Status__c == 'Rejected')
        { 
        awr2.Username__c=un;
        awr2.Status__c = 'Submitted For Approval';
        awr2.Locale__c='en_US';
        awr2.Access_Request_Type__c='New 4WARD Account';
        insert awr2;
        }
      
        return awr2.id;
    }
    @AuraEnabled
    public static List<AWAARE_4WARD__c> getDetailsRelatedToRecord(String URLuserName){
        System.debug('userName1 from apex is:'+URLuserName);
        List<AWAARE_4WARD__c> UpdateQuery=[Select Id,Username__c,FirstName__c,LastName__c,Email__c,Role_Picklist__c,City__c,Company__c,Country_Picklist__c,Customer_Code__c,Locale__c,Phone__c,State_Province__c,Zip__c from AWAARE_4WARD__c where Username__c=:URLuserName LIMIT 1];
        return UpdateQuery ;
    }
     @AuraEnabled
     public static List<String> getPickListValuesIntoList()
     {
       List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = AWAARE_4WARD__c.Country_Picklist__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }   
         return pickListValuesList;
}
}