@IsTest
public class UserRegistrationClassTest {
    static testMethod void testReport1() {
        
         List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
   
        AWAARE_4WARD__c UpdateAware = new AWAARE_4WARD__c();
        UpdateAware.Username__c='userName123';
        UpdateAware.Address__c='Address';
        UpdateAware.Company__c='Company';
        UpdateAware.City__c = 'City';
        UpdateAware.Country_Picklist__c='Afghanistan';
        UpdateAware.Email__c='abc@gmail.com';
        UpdateAware.FirstName__c='First';
        UpdateAware.LastName__c='Last';
        UpdateAware.Locale__c='en_US';
        UpdateAware.Phone__c='0123456789';
        UpdateAware.State_Province__c='State/Province';
        UpdateAware.Zip__c='Zip';
        insert UpdateAware;
        
        UserRegistrationClass.GetData('userName123');
        UserRegistrationClass.UserWrapper instance = new UserRegistrationClass.UserWrapper();
    }
    
    @Istest(seeAllData=true)
    Public static void testReport2() {
       
       
       
        List<User> uslist = [select id,ProfileId,name,firstname,lastname,username,email,Profile.Name,Country,CompanyName,State,Street,Phone,City,title,IsActive from User where Username LIKE '%@Allison4WARD.com.inactive' AND IsActive=false AND ContactId!=null LIMIT 1];
        SYSTEM.debug('uslist' +uslist);        
        
       
        
        /*ruser.Username__c ='930070000008@Allison4WARD.com';
        ruser.FirstName__c= uslist[0].firstname;
        ruser.LastName__c= uslist[0].lastname;
        ruser.Email__c=uslist[0].email; 
       
        ruser.Phone__c=uslist[0].Phone; 
        ruser.City__c=uslist[0].City; 
        ruser.Address__c=uslist[0].Street; 
        ruser.Country_Picklist__c=uslist[0].Country; 
        ruser.Company__c=uslist[0].CompanyName; 
        ruser.State_Province__c=uslist[0].State; 
        //ruser.Role_Picklist__c=metamap.get(uslist[0].ProfileId);
         ruser.Status__c='Submitted For Approval';
        ruser.Access_Request_Type__c='Reactivation of Existing User';
        //ruser.Job_Title__c = uslist[0].title;
        insert ruser;*/
        
       String username =uslist[0].Username.left(12);
       
        UserRegistrationClass.CreateReactivateRecord(username);
    }
}