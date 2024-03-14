/*
    Class Name  :   ATI_DetailPageUrlLocatorControllerTest
    Description :   Test class for ATI_DetailPageUrlLocatorController
*/
@isTest
public class ATI_DetailPageUrlLocatorControllerTest {
    /*
        Method Name :   testSetUp
        Description :   Method to create test data
    */
    @TestSetup
    public static void testSetUp(){
        Test.startTest();
        //create account
        List<Account> accountList = TestDataFactory.createAccount(1);   
        for(Integer i=0;i<accountList.size();i++){
        	accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'test'+i;    
        }
        insert accountList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = accountList[0].id;
        accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryConfig;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
            for(Integer i=0;i<warrantyProLst.size();i++){
                //warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
            }
        insert warrantyProLst;
        
        Id stockInvRecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByDeveloperName().get('Stock').getRecordTypeId(); 
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.RecordTypeId = stockInvRecordTypeId;
            inventory.WOD_2__Type__c = 'Stock';
            inventory.WOD_2__Account__c = accountList[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        Id partClaimRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        //create rejected claims
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(1); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.RecordTypeId = partClaimRecordTypeId;
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Account__c = accountList[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
        }
        insert claimLst;
        Test.stopTest();
    }

    /*
        Method Name :   testDetailGetURL
        Description :   Testing getURL method
    */
    private static testmethod void testDetailGetURL(){
        Test.startTest();
        List<WOD_2__Inventory__c> lstInv=[SELECT Id,Name,WOD_2__Type__c FROM WOD_2__Inventory__c] ; 
        WOD_2.ResponseWrapper resWrapObj=ATI_DetailPageUrlLocatorController.getURL(lstInv[0].Id,'DetailPageUrlLocatorOverride');
        System.assertEquals(true,resWrapObj.status,'Detail Page URL should be returned');
        List<WOD_2__Claim__c> lstClaim=[SELECT Id,RecordType.Name FROM WOD_2__Claim__c];
        resWrapObj=ATI_DetailPageUrlLocatorController.getURL(lstClaim[0].Id,'ClaimDetailPageUrlLocatorOverride');
        System.assertEquals(true,resWrapObj.status,'Detail Page URL should be returned');
        Test.stopTest();
    }
}