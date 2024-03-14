/* Name: ATI_FinancialTriggerHandlerTest
   Description : Test class for ATI_FinancialTriggerHandler
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                 DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Akshatha S)    02/12/2020          INITIAL DEVELOPMENT
*/

@isTest
public with sharing class ATI_FinancialTriggerHandlerTest {
    /*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
	@testSetup
    public static void testSetup(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<Account> accountList = TestDataFactory.createAccount(1); 
        for(Integer i=0;i<accountList.size();i++){
        	accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'Type'+i;
            accountList[i].WOD_2__Warranty_Account_Type__c='Dealer';
        }
        insert accountList;
        Group accGrp = new Group(Name='ATI_'+accountList[0].WOD_2__Warranty_Account_Type__c+'_'+accountList[0].Id,Type='Regular',DeveloperName='ATI_'+accountList[0].WOD_2__Warranty_Account_Type__c+'_'+accountList[0].Id);
        insert accGrp;
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        insert invList;

       //casual part creation
       WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
       casualPart.WOD_2__Business_Unit__c = bcc.Id;
       casualPart.External_Product_Code__c = casualPart.Name;
       casualPart.WOD_2__Item_Type__c = 'Machine';
       casualPart.WOD_2__Track_Type__c = 'Non-Serialized';
       insert casualPart;
    }
    /*
        Method Name :   financialSharingTest
        Description :   Method to test financial sharing with account's group on financial creation
    */
    @isTest
    public static void financialSharingTest(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        WOD_2__Warranty_Product__c casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        
        Test.startTest();
            WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart.Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart.Id );
            //ClaimBaseController.saveClaimInformation(JSON.serialize(claim),'Machine');
            claim.WOD_2__Claim_Status__c='Approved';
            insert claim;
        Test.stopTest();
        
        List<WOD_2__Financial__c> financialList = new List<WOD_2__Financial__c>();
        financialList = [SELECT id FROM WOD_2__Financial__c WHERE WOD_2__Claim__c = :claim.Id];
        List<WOD_2__Financial__Share> financialShareList = new  List<WOD_2__Financial__Share>();
        financialShareList = [SELECT Id FROM WOD_2__Financial__Share WHERE rowcause='Manual' AND ParentId IN :financialList];
        system.assertEquals(1, financialShareList.size(),'Success');
    }
}