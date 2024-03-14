@isTest
public class ATI_ClaimRecordSearchTableCOTest {
	@testSetup
    static void makeData(){
        
        //Distributor Account
        List<Account> accLst = TestDataFactory.createATIDistributorAccount(1);
        accLst[0].Country__c = 'United States';
        accLst[0].BillingCountry = 'United States';
        accLst[0].ATI_Currency__c = 'USD';
        accLst[0].CurrencyIsoCode = 'USD';
        accLst[0].ATI_Price_Group__c = '01';
        insert accLst;
        
        //create business category configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create business category configuration setting
        List<WOD_2__Business_Category_Configuration_Setting__c> lstbccs = TestDataFactory.createBccs(busCategoryConfig[0]);       
        insert lstbccs;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyPro = TestDataFactory.createWarrantyProduct(3);
        insert warrantyPro;
        
        //create Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory:invLst){
            inventory.RecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyPro[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert invLst;
        
        //create fault warranty code
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        
        //create Claim
        List<WOD_2__Claim__c> claim = TestDataFactory.createClaim(1);
        for(WOD_2__Claim__c claimObj : claim){
           	claimObj.RecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
            claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.WOD_2__Inventory__c = invLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyPro[2].id;
            claimObj.WOD_2__Model_Number__c = warrantyPro[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__Claim_Status__c = 'Approved';
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'SN001';
        }
        insert claim; 
        
    } 
    private static testMethod void testQueryRecords(){
        Test.startTest();
        ATI_ClaimRecordSearchTableClassOverride claimRecordSTClassOverObj = new ATI_ClaimRecordSearchTableClassOverride();
        WOD_2.QueryBuilderWrapper queryBuilderWrapperObject = new WOD_2.QueryBuilderWrapper();
        queryBuilderWrapperObject.fromObject = 'WOD_2__Claim__c';
        queryBuilderWrapperObject.fieldsToQuery = new List<String>{'Name','WOD_2__Account__c'};
        queryBuilderWrapperObject.whereClause = 'RecordType.DeveloperName = \'Part\'';
        queryBuilderWrapperObject.recordLimit = 1; 
        queryBuilderWrapperObject.orderBy = '';
        String str = claimRecordSTClassOverObj.queryRecords(queryBuilderWrapperObject);
        List<WOD_2__Claim__c> claim = [SELECT Id,RecordTypeId FROM WOD_2__Claim__c LIMIT 1];
        claim[0].RecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
        update claim;
        WOD_2.QueryBuilderWrapper queryBuilderWrapperObject1 = new WOD_2.QueryBuilderWrapper();
        queryBuilderWrapperObject1.fromObject = 'WOD_2__Claim__c';
        queryBuilderWrapperObject1.fieldsToQuery = new List<String>{'Name','WOD_2__Account__c'};
            queryBuilderWrapperObject1.whereClause = 'RecordType.DeveloperName = \'Machine\'';
        queryBuilderWrapperObject1.recordLimit = 1;
        queryBuilderWrapperObject1.orderBy = 'Name';
        String str1 =  claimRecordSTClassOverObj.queryRecords(queryBuilderWrapperObject1);
        Test.stopTest();
    }
    private static testMethod void testDealerOtherClaimsNull(){
        Test.startTest();
        List<WOD_2__Claim__c> claim = [SELECT Id,WOD_2__Claim_Status__c,RecordTypeId FROM WOD_2__Claim__c LIMIT 1];
        claim[0].WOD_2__Claim_Status__c = 'Draft';
        update claim;
        ATI_ClaimRecordSearchTableClassOverride claimRecordSTClassOverObj = new ATI_ClaimRecordSearchTableClassOverride();
        WOD_2.QueryBuilderWrapper queryBuilderWrapperObject = new  WOD_2.QueryBuilderWrapper();
        queryBuilderWrapperObject.fromObject = 'WOD_2__Claim__c';
        queryBuilderWrapperObject.fieldsToQuery = new List<String>{'Name','WOD_2__Account__c'};
        queryBuilderWrapperObject.whereClause = '';
        queryBuilderWrapperObject.recordLimit = 1; 
        queryBuilderWrapperObject.orderBy = '';
        String str = claimRecordSTClassOverObj.queryRecords(queryBuilderWrapperObject);
        Test.stopTest();
    }
}