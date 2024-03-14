/**
 * @description       : 
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 11-23-2023
 * @last modified by  : Abhishek Mohapatra
**/
@isTest
public class PRPC_BranchCountTest {
    @testSetup static void setup() {
        
        
       List<Disable_Rules__c> disableRules = ATI_TAC_TestDataFactory.createDisableRules();
          
       
        
       /* Account accountRec = new Account();
        accountRec.Name = 'Test ';
        accountRec.Type = 'Distributor';
        accountRec.Location_Type__c = 'D';
        accountRec.Sales_RegionA__c = 'North America';
        accountRec.ShippingCity = 'City';
        accountRec.SAP_ID__c = '0105';
        accountRec.ShippingCountry = 'Country';
        accountRec.ShippingState = 'State';
        accountRec.ShippingPostalCode = '765432';
        accountRec.ShippingStreet = 'Street';
        accountRec.PRP_Participation__c = true;
        accountRec.Number_Of_Active_Branches__c = 5;
		INSERT accountRec;
        
        Account accountRecDis = new Account();
        accountRecDis.Name = 'Test Branch ';
        accountRecDis.Type = 'Distributor Branch';
        accountRecDis.Location_Type__c = 'DB';
        accountRecDis.SAP_ID__c = '0105000002';
        accountRecDis.Sales_RegionA__c = 'North America';
        accountRecDis.ShippingCity = 'City';
        accountRecDis.ShippingCountry = 'Country';
        accountRecDis.ShippingState = 'State';
        accountRecDis.ShippingPostalCode = '765432';
        accountRecDis.ShippingStreet = 'Street';
        accountRecDis.PRP_Participation__c = true;
        accountRecDis.Number_Of_Active_Branches__c = 1;
        accountRecDis.ParentId = accountRec.Id;
        INSERT accountRecDis;*/
        
        // Create test data for the parent distributor account
        Account distributorAccount = ATI_TAC_TestDataFactory.createTestDistributorAccount();

        // Create test data for the distributor branch with parent
        ATI_TAC_TestDataFactory.createTestDistributorBranchAccount(distributorAccount.Id);        
        List<Account> distributorsForUpdate = ATI_TAC_TestDataFactory.createTestDistributorsForUpdate();
        List<Account> distributorsForDelete = ATI_TAC_TestDataFactory.createTestDistributorsForDelete();
        
        insert distributorsForUpdate;
        insert distributorsForDelete;
        
        
    }
        
        
    
    static testMethod void testReport() {
    
       
        
        
        {
            
            
         
        
        List<Account> distList = [SELECT Id,Type,ParentId,Number_Of_Active_Branches__c,PRP_Participation__c FROM Account WHERE Type = 'Distributor'];
        List<Account> distBranchList = [SELECT Id,Type,ParentId,Number_Of_Active_Branches__c,PRP_Participation__c FROM Account WHERE Type = 'Distributor Branch'];
        PRPC_BranchCount.forInsert(distList);
        PRPC_BranchCount.forUpdate(distBranchList);
        PRPC_BranchCount.forDelete(distBranchList);
    }
   }
    
    
    @isTest
    static void testForInsert() {

        List<Account> newAccounts = new List<Account>();

        Test.startTest();
        PRPC_BranchCount.forInsert(newAccounts);
        Test.stopTest();
        
    }
    
    // Test the forUpdate method with if and else conditions
    @isTest
    static void testForUpdate() {
        
        List<Account> updatedAccounts = new List<Account>();
        
        Test.startTest();
        PRPC_BranchCount.forUpdate(updatedAccounts);
        Test.stopTest();
        
        
    }
    
    // Test the forDelete method with if and else conditions
    @isTest
    static void testForDelete() {
        // Create test data for the delete operation that triggers the if and else conditions
        List<Account> deletedAccounts = new List<Account>();
        
        
        Test.startTest();
        PRPC_BranchCount.forDelete(deletedAccounts);
        Test.stopTest();
        
        
    }

    @isTest
    static void testForNonHappyTrigger(){

        User adminUser = [Select Id, UserRoleId,isActive From User Where Profile.Name='System Administrator' AND isActive= True  Limit 1];

        ATI_Record_Bypass_Settings__c insertBypassRule = new ATI_Record_Bypass_Settings__c();
        insertBypassRule.ATI_TAC_Trigger_Skip__c = TRUE;

        insertBypassRule.SetupOwnerId = adminUser.Id;
        Insert insertBypassRule;
    


        Test.startTest();
        System.runAs(adminUser){
            Account acc = ATI_TAC_TestDataFactory.createTestAccount();
            List<Account> distList = [SELECT Id,Type,ParentId,Number_Of_Active_Branches__c,PRP_Participation__c FROM Account WHERE Type = 'Distributor'];
            distList[0].Name = 'testCheck';
            Update distList[0];

        }
        Test.stopTest();
        
    }
}