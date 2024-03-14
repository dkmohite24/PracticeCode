@istest
public class TriggerhandlerforMailAwaareTest {
    static testMethod void forrejectionEmail() {
        AWAARE_4WARD_Basic__c UpdateAware2 = new AWAARE_4WARD_Basic__c();
        UpdateAware2.Username__c='125656780300';
        UpdateAware2.Address__c='Address';
        UpdateAware2.Company__c='Company';
        UpdateAware2.City__c = 'City';
        UpdateAware2.Country_Picklist__c='Afghanistan';
        UpdateAware2.Email__c='abc@gmail.com';
        UpdateAware2.FirstName__c='First';
        UpdateAware2.LastName__c='Last';
        UpdateAware2.Locale__c='en_US';
        UpdateAware2.Phone__c='0123456789';
        UpdateAware2.State_Province__c='State/Province';
        UpdateAware2.Zip__c='Zip';
        UpdateAware2.Status__c = 'Approved';
        UpdateAware2.Access_Request_Type__c='New 4WARD Account';
        UpdateAware2.Role_Picklist__c='ATI_Read_only_Distributor_and_Dealer';
        UpdateAware2.Job_Title__c='test job title';
        // insert UpdateAware2;
        
        //  TriggerHandlerForMailAwaare.awaare4wardrecordcreation(UpdateAware2);
        
        
    }
    static testMethod void forCustomerCode() {
        list<AWAARE_4WARD_Basic__c> basicList = new list<AWAARE_4WARD_Basic__c>();
        AWAARE_4WARD_Basic__c UpdateAware1 = new AWAARE_4WARD_Basic__c();
        UpdateAware1.Username__c='123345543387';   
        UpdateAware1.Address__c='Address';
        UpdateAware1.Company__c='Company';
        UpdateAware1.City__c = 'City';
        UpdateAware1.Country_Picklist__c='Afghanistan';
        UpdateAware1.Email__c='abc@gmail.com';
        UpdateAware1.FirstName__c='First';
        UpdateAware1.LastName__c='Last';
        UpdateAware1.Phone__c='0123456789';
        UpdateAware1.State_Province__c='State/Province';
        UpdateAware1.Zip__c='Zip';
        basicList.add(UpdateAware1);
        
        TriggerHandlerForMailAwaare.AddCustomerCode(basicList);
    }
    static testMethod void awaare4wardrecordcreationtest() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        AWAARE_4WARD_Basic__c UpdateAware2 = new AWAARE_4WARD_Basic__c();
        UpdateAware2.Username__c='125656780400';
        UpdateAware2.Address__c='Address';
        UpdateAware2.Company__c='Company';
        UpdateAware2.City__c = 'City';
        UpdateAware2.Country_Picklist__c='Afghanistan';
        UpdateAware2.Email__c='abc@gmail.com';
        UpdateAware2.FirstName__c='First';
        UpdateAware2.LastName__c='Last';
        UpdateAware2.Locale__c='en_US';
        UpdateAware2.Phone__c='0123456789';
        UpdateAware2.State_Province__c='State/Province';
        UpdateAware2.Zip__c='Zip';
        
        UpdateAware2.Access_Request_Type__c='New 4WARD Account';
        UpdateAware2.Status__c = 'Submitted For Approval';
        UpdateAware2.Job_Title__c='Test Job Title';
        insert UpdateAware2;
        UpdateAware2.Status__c = 'Approved';
        update UpdateAware2;
        
        
        TriggerHandlerForMailAwaare.awaare4wardrecordcreation(UpdateAware2);
        
        
    }
    @Istest(seeAllData=true)
    public static void userreactivationtest() {
        List<Profile> prf =[select id from Profile where Name like 'PRP P%' limit 1];
        List<Account> lstacc =[Select id from account limit 1];
        
        // Create a Contact in Salesforce using Apex
        Contact newContact = new Contact();
        newContact.FirstName = 'Sarah';
        newContact.LastName = 'Johnson';
        newContact.Email = 'sarah.johnson@example.com';
        newContact.Phone = '1234567890';
        newContact.AccountId = lstacc[0].id;
        
        insert newContact;
        
        
        // Create a User in Salesforce using Apex
        User newUser = new User();
        newUser.FirstName = 'John';
        newUser.LastName = 'Doe';
        newUser.Email = 'john.doe@example.com';
        newUser.Username = '999999999999@Allison4WARD.com.inactive';
        newUser.Alias = 'jdoe';
        newUser.CommunityNickname = 'johndoe';
        newUser.ProfileId = prf[0].Id; 
        newUser.TimeZoneSidKey = 'America/Los_Angeles';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.IsActive = false;
        newUser.ContactId=newContact.id;
        newUser.Title='test';
        insert newUser;
        
        
        String usernm =newUser.Username.left(12);
        
        String role ='ATI_Read_only_Distributor_and_Dealer';
        String username =newUser.Username;   
        String Title =newUser.Title;
        TriggerHandlerForMailAwaare.userreactivation(username,role,Title);
        
        AWAARE_4WARD__c Awaare =new AWAARE_4WARD__c();
        Awaare.Username__c='999999999999';
        Awaare.LastName__c='Test';
        Awaare.Community_User__c=newUser.id;
        insert Awaare;
        TriggerHandlerForMailAwaare.awaare4wardupdation('999999999999',role,Title);
    }
    
}