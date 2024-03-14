/* Name: ATI_UserTriggerHandlerTest
Description : Test Class for ATI_UserTriggerHandler
Author : Tavant (Punam Chakraborty)
History :
VERSION      AUTHOR                           DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (Punam Chakraborty)     03/12/2020         INITIAL DEVELOPMENT
*/
@isTest
public class ATI_UserTriggerHandlerTest {
    
    /*
        Method Name :   testSetup
		Method Added By Punam
		Create all test data for test class execution.
    */
    @testSetup
    public static void testSetup(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        createAccountContact(portalAccountOwner1.Id);
        
    }
    
    /*
        Method Name :   createAccountContact
		Method Added By Punam
		Create Account,Contact and Group test data for test class execution. 
    */
	
    @future
    public static void createAccountContact(Id portalAccountOwner1){
        //Create account
        List<Account> accountList = TestDataFactory.createATIDistributorAccount(1); 
        accountList[0].OwnerId = portalAccountOwner1;
        accountList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accountList[0].WOD_2__Business_Units__c = 'ATI';
        TriggerHandler.bypass('ATI_AccountTriggerHandler');
        Database.insert(accountList);
        TriggerHandler.clearBypass('ATI_AccountTriggerHandler');
        
        //Create contact
        List<Contact> conObjList = TestDataFactory.createContact(1);
        conObjList[0].AccountId = accountList[0].Id;
        conObjList[0].Email = System.now().millisecond() + 'test@test.com';
        Database.insert(conObjList);
        
        //Create Group
        Group groupObj = new Group(Name='ATI_'+accountList[0].WOD_2__Warranty_Account_Type__c+'_'+accountList[0].id);
        insert groupObj;
        
        Account accObj = [SELECT Id,Public_Group_Id__c FROM Account WHERE Id=:accountList[0].Id Limit 1];
        accObj.Public_Group_Id__c = groupObj.Id;
        update accObj;
    }
    
    /*
        Method Name :   testUserTriggerHandler
		Method Added By Punam
		Test method to cover User Trigger handler. 
    */
    @isTest
    public static void testUserTriggerHandler(){
        //Create portal account owner
        
        List<Contact> conObjList =[Select Id,AccountId,Account.CurrencyISOCode, Account.WOD_2__Business_Units__c From Contact limit 1];
        //Create user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name= 'ATI Distributor and Dealer' Limit 1];
        List<User> userObjList = TestDataFactory.createUser(1);
        userObjList[0].ContactId=conObjList[0].Id;
        userObjList[0].profileId=portalProfile.Id;
        Database.insert(userObjList);
        //GroupMember grpMember =[Select Id,UserOrGroupId From GroupMember limit 1];
        system.assertNotEquals(null, userObjList[0].Id);
        User u = [select Id, DefaultCurrencyIsoCode,WOD_2__Business_Units__c from User where id =:userObjList[0].Id];
        System.assertEquals(conObjList[0].Account.CurrencyISOCode, u.DefaultCurrencyIsoCode, 'Account Currency is not set to User');
        System.assertEquals(conObjList[0].Account.WOD_2__Business_Units__c, u.WOD_2__Business_Units__c, 'Account BU is not set to User');
    }
    
    @isTest
    public static void testUserTriggerAfterUpdateHandler(){
        //Create portal account owner
        Group grpObj = [SELECT Id FROM Group LIMIT 1];
        List<Contact> conObjList =[Select Id,AccountId,Account.CurrencyISOCode, Account.WOD_2__Business_Units__c From Contact limit 1];
        //Create user
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name= 'ATI Dealer Warranty Approver' Limit 1];
        List<User> userObjList = TestDataFactory.createUser(1);
        userObjList[0].ContactId=conObjList[0].Id;
        userObjList[0].profileId=communityProfile.Id;
        Database.insert(userObjList);
        
        System.assertNotEquals(1, [SELECT Id FROM GroupMember WHERE UserOrGroupId=:userObjList[0].Id].size(),'No group member should be there!');
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name= 'ATI Distributor and Dealer' Limit 1];
        userObjList[0].profileId=portalProfile.Id;
        update userObjList[0];
        System.assertNotEquals(2, [SELECT Id FROM GroupMember WHERE UserOrGroupId=:userObjList[0].Id].size(),'group member should be created!');
    }

}