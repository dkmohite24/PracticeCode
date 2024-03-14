@IsTest
public class CommunityUserLookupAutoTestClass {
    @testsetup
    public static void UserCreation(){
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='riturajsingh2508@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='abcdefghijkl@Allison4WARD.com');
        insert u;
        
        Profile pInternal = [SELECT Id FROM Profile WHERE Name='ATI Part Inspector']; 
        User uInternal = new User(Alias = 'standt', Email='123456789658@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pInternal.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='123456789658@gmail.com');
        insert uInternal;

        Profile pInternal2 = [SELECT Id FROM Profile WHERE Name='ATI Warranty Admin']; 
        User uInternal2 = new User(Alias = 'standj', Email='876780989658@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pInternal2.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='876780989658@gmail.com');
        insert uInternal2;
        	PackageLicense pl =[select Id from PackageLicense where NamespacePrefix='WOD_2'];
                	UserPackageLicense upl = new UserPackageLicense();
               		upl.UserId=uInternal2.id;
           			upl.PackageLicenseId=pl.id;
                	insert upl;  
        Profile pInternal3 = [SELECT Id FROM Profile WHERE Name='ATI Part Receiver']; 
        User uInternal3 = new User(Alias = 'standl', Email='876780989687656@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = pInternal3.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='876780989658test@gmail.com');
        insert uInternal3;
        
        uInternal3.Isactive = false;
        update uInternal3;
        
        uInternal2.Isactive = false;
        update uInternal2;
        
       /*  List<PermissionSet> perAssignments = [select id, Name from PermissionSet where Name ='ATI_Warranty_Admin_Permission' LIMIT 1];
         PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = uInternal2.Id;
        psa.PermissionSetId = perAssignments[0].Id;
        insert psa;*/
    }
    
    
    
    
    
    
   @IsTest
    public static void AutoPopulationMethod(){
         List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        List<User> Userlist = new list<User>();
        User user = [select id, Username from User where Username LIKE '%@Allison4WARD.com' LIMIT 1] ;  
        Userlist.add(user);
        AWAARE_4WARD__c awr = new AWAARE_4WARD__c();
        awr.Username__c ='abcdefghijkl';
        
        insert awr;
        test.startTest();
        awr.Community_User__c = user.id;
        update awr;
        CommunityUserLookupAutoPopulation.CommunityAutopopulation(Userlist);
        test.stopTest();
    }
    
  
}