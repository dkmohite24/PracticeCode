/*
    Class Name  :   ATI_InventoryRecordSearchTableCOTest
    Description :   Test class for ATI_InventoryRecordSearchTableCO
*/
@isTest
private class ATI_InventoryRecordSearchTableCOTest{
    /*
        Method Name :   makeData
        Description :   Method to create test data
    */
    @testSetup
    static void makeData(){
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst; 
        List<WOD_2__Inventory__c> invLst=TestDataFactory.createInventory(2);
        for(WOD_2__Inventory__c inventory:invLst){
            inventory.RecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
            inventory.WOD_2__Account__c = accLst[0].id;
        }
        invLst[1].RecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
        insert invLst;
    }
    
    /*
        Method Name :   makeData
        Description :   Method to test query records
    */
    @isTest
    private static void testQueryRecords(){
        Test.startTest();
        ATI_InventoryRecordSearchTableCO invRecordSTClassOverObj = new ATI_InventoryRecordSearchTableCO ();
        //String queryBuilderWrapperStr = '{"comparisonFields":null,"conditions":null,"extraParams":null,"fieldsToQuery":["Name","WOD_2__Account__c"],"fromObject":"WOD_2__Inventory__c","lookUpConfigurationName":null,"orderBy":"","orderByField":null,"orderByLogic":null,"queryConditionList":null,"recordLimit":3,"searchType":null,"userEnteredValue":null,"whereClause":"RecordType.DeveloperName = \'Retail\'"}';
        String queryBuilderWrapperStr = '{}';
        WOD_2.QueryBuilderWrapper queryBuilderWrapperObject = (WOD_2.QueryBuilderWrapper) JSON.deserialize(queryBuilderWrapperStr, WOD_2.QueryBuilderWrapper.class);
        queryBuilderWrapperObject.fromObject = 'WOD_2__Inventory__c';
        queryBuilderWrapperObject.fieldsToQuery = new List<String>{'Name','WOD_2__Account__c'};
        queryBuilderWrapperObject.whereClause = 'RecordType.DeveloperName = \'Retail\'';
        queryBuilderWrapperObject.recordLimit = 3;
        queryBuilderWrapperObject.orderBy = '';
        String str = invRecordSTClassOverObj.queryRecords(queryBuilderWrapperObject);
        queryBuilderWrapperObject.fromObject = 'Account';
        String str1 = invRecordSTClassOverObj.queryRecords(queryBuilderWrapperObject);
        System.assertEquals('',str1,'Assert Failed!');
        String str2 = invRecordSTClassOverObj.fetchRecords(queryBuilderWrapperObject);
        System.assertEquals('',str2,'Assert Failed!');
        Test.stopTest();
    }
    
    /*
        Method Name :   testFetchRecords
        Description :   Method to test fetch records
    */
    @isTest
    private static void testFetchRecords(){
        Test.startTest();
        ATI_InventoryRecordSearchTableCO invRecordSTClassOverObj = new ATI_InventoryRecordSearchTableCO ();
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Account__c FROM WOD_2__Inventory__c WHERE WOD_2__Account__c=:acc[0].id LIMIT 1];
        String queryBuilderWrapperStr = '{}';
        WOD_2.QueryBuilderWrapper queryBuilderWrapObj = (WOD_2.QueryBuilderWrapper) JSON.deserialize(queryBuilderWrapperStr, WOD_2.QueryBuilderWrapper.class);
        queryBuilderWrapObj.fieldsToQuery = new String[]{'WOD_2__Account__c'};
        queryBuilderWrapObj.fromObject  ='WOD_2__Inventory__c';
        queryBuilderWrapObj.whereClause  ='RecordType.DeveloperName = \'Retail\' AND RecordType.DeveloperName = \'Stock\' AND WOD_2__Account__c = \''+ String.escapeSingleQuotes(acc[0].id)+'\'';
        queryBuilderWrapObj.recordLimit = 3;
        queryBuilderWrapObj.orderBy = ''; 
        String str1 = invRecordSTClassOverObj.fetchRecords(queryBuilderWrapObj); 
        System.assertEquals('[]',str1,'Assert Failed!');
        Test.stopTest();
    }
}