/*
    Class Name  :   ATI_QueryRunWithoutSharingTest
    Description :   Test class for ATI_QueryRunWithoutSharing
*/
@isTest
public class ATI_QueryRunWithoutSharingTest {
    /*
        Method Name :   testSetup
        Description :   Method to create test data
    */
    @testSetup
    static void testSetup(){
        List<Account> accLst = TestDataFactory.createAccount(10);   
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst;
    }
    
    /*
        Method Name :   testRunQuery
        Description :   Method to test runQuery
    */
    @isTest
    private static void testRunQuery(){
        List<Account> accLst=[select Id from Account];
        List<Id> acctids=new List<Id>();
        for(Account accobj:accLst){
            acctids.add(accobj.id);
        }
        List<sObject> accLst1 = ATI_QueryRunWithoutSharing.runQuery('select id from account limit 1');   
        ATI_QueryRunWithoutSharing.runQueryWithIds('select id from account limit 1',acctids);   
        ATI_QueryRunWithoutSharing.runQueryWithIdsStringList('select id from account limit 1',acctids);   
        ATI_QueryRunWithoutSharing.save(accLst); 
        ATI_QueryRunWithoutSharing.insertData(accLst); 
        ATI_QueryRunWithoutSharing.updateRecordsWithoutSharing(accLst,true); 
        
        System.assertEquals(1, accLst1.size(), 'One account must be retrieved');
    }
    
    /*
        Method Name :   testRunQuery
        Description :   Method to test claimQuery
    */
    @isTest
    private static void testClaimQuery(){
        List<Account> account = [SELECT Id FROM Account LIMIT 1];
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = account[0].id;
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
            inventory.WOD_2__Account__c = account[0].id;
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
            claimObj.WOD_2__Claim_Status__c = 'Submitted';
            claimObj.WOD_2__Account__c = account[0].id;
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
        
        WOD_2__Claim__c claimObj = ATI_QueryRunWithoutSharing.fetchClaimParentAccountForDistributor(new List<String>{'Name','WOD_2__Inventory__c'},claimLst[0].Id); 
        System.assertEquals(true, claimObj != NULL, 'claim must be returned');
    }
}