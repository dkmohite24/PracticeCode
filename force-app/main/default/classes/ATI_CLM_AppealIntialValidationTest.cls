@isTest
public class ATI_CLM_AppealIntialValidationTest {
	@testSetup
    private static void setUp(){
        List<WOD_2__Business_Category_Configuration__c> bccs = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert bccs;
        
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer'; 
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bccs[0]);
        insert bccsList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(4);
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        warrantyProductList[3].WOD_2__Type__c = 'Item';
        warrantyProductList[3].WOD_2__Item_Type__c = 'Part';
        warrantyProductList[3].WOD_2__Track_Type__c = 'Non-Serialized';
      	insert warrantyProductList;

		//Create WarrantyProductPriceBook
        Id partCostRTId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,warrantyProductList[3].Id);
        wpPbLst[0].RecordTypeId = partCostRTId;
        wpPbLst[0].WOD_2__Price__c = 100;
        insert wpPbLst;
		        
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(2);
        inventoryList[0].Name = inventoryList[0].WOD_2__Serial_Number__c = 'FailedInvSerialNumber';
        inventoryList[0].WOD_2__Install_Date__c = System.today();
        inventoryList[0].WOD_2__Warranty_Start_Date__c = System.today();
        inventoryList[1].Name = inventoryList[1].WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber';
        for(WOD_2__Inventory__c inv : inventoryList){
            inv.WOD_2__Business_Unit__c = busCategoryList[0].Id;
            inv.WOD_2__Account__c = accList[0].Id;
            inv.WOD_2__Item__c = warrantyProductList[2].Id;
        }
        insert inventoryList;
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='MachineClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today(),
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id,WOD_2__Work_Performed_Comments__c='Test',
                                                  ATI_Technician_Name__c='Test');
        claim.WOD_2__BusinessCategory__c = bccs[0].Id;
        insert claim;
    }
    
    @isTest
    private static void testClaimAppealValidation(){
        WOD_2__Business_Category_Configuration__c busCategoryObj = [SELECT Id FROM WOD_2__Business_Category_Configuration__c LIMIT 1];
		WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c LIMIT 1];
        claim.WOD_2__Claim_Status__c = 'Rejected';
        update claim;
        
        Test.startTest();
        	ATI_CLM_AppealIntialValidation controller = new ATI_CLM_AppealIntialValidation();
            WOD_2.ResponseWrapper resWrapperObject = controller.doInitialValidation(claim.Id);
        	System.assertEquals(false,resWrapperObject.status);
        
        	String recordId = Schema.SObjectType.WOD_2__Business_Category_Configuration_Setting__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId();
        	insert new WOD_2__Business_Category_Configuration_Setting__c(WOD_2__Business_Category_Configuration__c = busCategoryObj.id, recordtypeId =recordId,Name = 'CLM_Appeal_RejectedClaimStatuses',WOD_2__Unique_Rule_Name__c = 'CLM_Appeal_RejectedClaimStatuses',WOD_2__Value__c='Paid,Rejected',WOD_2__isActive__c = true,WOD_2__Rule_Object__c='WOD_2__Claim__c',WOD_2__Module__c='Claim',WOD_2__Sub_Module__c='Claim Appeal',WOD_2__Type__c='Multi-Select Picklist');
        	WOD_2.ResponseWrapper resWrapperObject1 = controller.doInitialValidation(claim.Id);
        	System.assertEquals(true,resWrapperObject1.status);
        Test.stopTest();
    }
}