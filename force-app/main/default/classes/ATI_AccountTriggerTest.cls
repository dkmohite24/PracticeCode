/* Name: ATI_AccountTriggerTest
Description : Test Class for ATI_AccountTrigger
Author : Tavant ()
History :
VERSION      AUTHOR           DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant ()     18/09/2019         INITIAL DEVELOPMENT
*/
@isTest
public class ATI_AccountTriggerTest {
    @isTest
    static void testAccountCreation(){
        List<Account> accounts = TestDataFactory.createAccount(1);
        Test.startTest();
        accounts[0].ATI_Customer_Group__c = '01';
        accounts[0].ATI_Financial_BP_Code__c = 'Test';
        insert accounts;
        Test.stopTest();
        Account newAccount = [SELECT ID, ParentId, Public_Group_Id__c FROM ACCOUNT where id = :accounts[0].id]; 
        System.assertEquals(true, newAccount != null, 'Expected Only one Account');
    }

    @isTest
    static void testAccountUpdation(){
        List<Account> accounts = TestDataFactory.createAccount(2);
        insert accounts;
        Test.startTest();
        accounts[0].parentId = accounts[1].id;
        accounts[0].WOD_2__Warranty_Account_Type__c = 'Customer';
        update accounts[0];
        Test.stopTest();
        Account newAccount = [SELECT ID, ParentId, Public_Group_Id__c FROM ACCOUNT where id = :accounts[0].id]; 
        System.assertEquals(true, newAccount.ParentId != null, 'Expected Only one Account');
    }

    @isTest
    static void testAccountDeletion(){
        List<Account> accounts = TestDataFactory.createAccount(1);
        insert accounts;
        Test.startTest();
        delete accounts[0];
        Test.stopTest();
        List<Account> newAccounts = [SELECT ID, ParentId, Public_Group_Id__c FROM ACCOUNT where id = :accounts[0].id]; 
        System.assertEquals(true, newAccounts.isEmpty(), 'Expected 0 Accounts');
    }
    
    @isTest
    static void testCreateDealerPublicGroupsQueueable(){
        List<Account> accounts = TestDataFactory.createAccount(2);
        
      	for(Integer i=0;i<accounts.size();i++){
        	accounts[i].Sales_RegionA__c = 'EMEA';
            accounts[i].SAP_ID__c = '1223123'+i;
            accounts[i].Location_Type__c = 'test'+i;    
        }
        accounts[0].WOD_2__Warranty_Account_Type__c='Dealer';
        accounts[0].ATI_RPS_Status__c=true;
        accounts[1].WOD_2__Warranty_Account_Type__c='Dealer';
        
        Test.startTest();
        insert accounts;
        System.enqueueJob(new ATI_CreateDealerPublicGroupsQueueable(accounts, false));
        
        accounts[0].ATI_Alternate_Parent__c = accounts[1].id;
        update accounts[0]; 
        
        System.enqueueJob(new ATI_UpdateDealerPublicGroupsQueueable(new List<Account>{accounts[0]}));
        Test.stopTest();
        /*Account newAccount = [SELECT ID, ParentId, Public_Group_Id__c FROM ACCOUNT where id = :accounts[0].id]; 
        System.assertEquals(true, newAccount != null, 'Expected Account not created');
        Group newGroup = [select id, Name from Group where name = :'ATI_Dealer_'+newAccount.Id];
		System.assertEquals(true, newGroup != null, 'Expected Only one Group');
        System.assertEquals(newAccount.Public_Group_Id__c, newGroup.Id, 'Expected Only one Group');*/
    }

    /* @isTest
   static void testCDPGroupsQueueableWithParent(){
        List<Account> accounts = TestDataFactory.createAccount(2);
        insert accounts[0];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Test.startTest();
        accounts[1].parentId = accounts[0].id;
		Group accGrp = new Group(Name='ATI_'+accounts[0].WOD_2__Warranty_Account_Type__c+'_'+accounts[0].Id,Type='Regular',DeveloperName='ATI_'+accounts[0].WOD_2__Warranty_Account_Type__c+'_'+accounts[0].Id);
        insert accGrp;
       accounts[0].Public_Group_Id__c  = accGrp.id;
       //accounts[1].Public_Group_Id__c  = accGrp.id;
		Database.SaveResult sr = Database.insert(accounts[1], dml);
        //System.enqueueJob(new ATI_CreateDealerPublicGroupsQueueable(accounts, false));
        System.enqueueJob(new ATI_UpdateDealerPublicGroupsQueueable(accounts));
        Test.stopTest();
        Account newAccount = [SELECT ID, ParentId, Public_Group_Id__c FROM ACCOUNT where id = :accounts[1].id]; 
        System.assertEquals(true, newAccount != null, 'Expected Account not created');
        Group newGroup = [select id, Name from Group where name = :'ATI_Dealer_'+newAccount.Id];
		System.assertEquals(true, newGroup != null, 'Expected Only one Group');
        System.assertEquals(newAccount.Public_Group_Id__c, newGroup.Id, 'Expected Only one Group');
        List<GroupMember> gmList = [select id from GroupMember where GroupId = :newGroup.Id];
        System.debug('gmList -> ' + gmList);
        System.assertEquals(1, gmList.size(), 'Parent Account is not marked as child group');
    } */
    
    
}