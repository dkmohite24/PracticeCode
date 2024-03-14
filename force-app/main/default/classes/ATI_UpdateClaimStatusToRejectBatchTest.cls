@isTest
public class ATI_UpdateClaimStatusToRejectBatchTest {
    @testSetup
    public static void testSetup(){
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = new List<WOD_2__Business_Category_Configuration_Setting__c>();
        WOD_2__Business_Category_Configuration_Setting__c bccs = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs.Name = 'CLM_StatusUpdateToRejectAfter_Days';
        bccs.WOD_2__Value__c = '2';
        bccsList.add(bccs);
        
        WOD_2__Business_Category_Configuration_Setting__c bccs1 = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs1.Name = 'ATI_CLM_StatusUpdateToCloseAfter_Months';
        bccs1.WOD_2__Value__c = '1';
        bccsList.add(bccs1);
        
        WOD_2__Business_Category_Configuration_Setting__c bccs2 = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs2.Name = 'ATI_CLM_CloseStatusFilter';
        bccs2.WOD_2__Value__c = 'Rejected';
        bccsList.add(bccs2);
        
        insert bccsList;
            
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<Account> accList = TestDataFactory.createAccount(1);
        insert accList;
        WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
        casualPart.WOD_2__Business_Unit__c = bcc.Id;
        casualPart.External_Product_Code__c = 'Test';
        casualPart.WOD_2__Item_Type__c = 'Machine';
        casualPart.WOD_2__Track_Type__c = 'Non-Serialized';
        insert casualPart;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accList[0].Id;
        insert invList;
        
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        WOD_2__Claim__c claim = new WOD_2__Claim__c();
        claim.name = 'testClaim';
        claim.WOD_2__Account__c = accList[0].id;
        claim.WOD_2__Claim_Status__c = 'Additional Information Required';
        claim.ATI_Additional_Info_statusDate__c = system.today().addDays(-120);
        claim.WOD_2__Model_Number__c = casualPart.id;
        claim.WOD_2__Date_Of_Failure__c=system.today();
        claim.WOD_2__Causal_Part_Number__c=casualPart.Id;
        claim.WOD_2__Date_Of_Repair__c=system.today();
        claim.WOD_2__Inventory__c = invList[0].id;
        insert claim;
        
        WOD_2__Claim__c claim1 = new WOD_2__Claim__c();
        claim1.name = 'AT0500234';
        claim1.WOD_2__Account__c = accList[0].id;
        claim1.WOD_2__Claim_Status__c = 'Rejected';
        claim1.ATI_Additional_Info_statusDate__c = system.today().addDays(-120);
        claim1.WOD_2__Model_Number__c = casualPart.id;
        claim1.WOD_2__Date_Of_Failure__c=system.today();
        claim1.WOD_2__Causal_Part_Number__c=casualPart.Id;
        claim1.WOD_2__Date_Of_Repair__c=system.today();
        claim1.WOD_2__Inventory__c = invList[0].id;
        insert claim1;
    }
     @isTest
    public static void batchTest(){
        Test.startTest();
        ATI_ClaimStarusUpdateToReject_Scheduled sh = new ATI_ClaimStarusUpdateToReject_Scheduled();
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, sh);
        Test.stopTest();
        WOD_2__Claim__c claim = [SELECT id, WOD_2__Claim_Status__c,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c WHERE name = 'testClaim' LIMIT 1];
    	//system.assertNotEquals(claim.WOD_2__Claim_Status__c, 'Reject');
    }
    
    @isTest
    public static void batchToClosedTest(){
        WOD_2__Claim__c c = [SELECT id FROM WOD_2__Claim__c WHERE WOD_2__Claim_Status__c = 'Rejected'];
        system.debug('>>>> Claim'+c);
        Test.startTest();
        ATI_ClaimStarusUpdateToClosed_Scheduled sh = new ATI_ClaimStarusUpdateToClosed_Scheduled();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, sh);
        Test.stopTest();
        WOD_2__Claim__c claim = [SELECT id,ATI_IsClosed__c, WOD_2__Claim_Status__c,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c WHERE name = 'AT0500234' LIMIT 1];
    	system.assertNotEquals(claim.ATI_IsClosed__c, true);
    }
}