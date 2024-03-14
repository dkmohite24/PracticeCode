/*
    Class Name  :   ATI_QueryBuilderControllerTest
    Description :   Test class for ATI_QueryBuilderController
*/
@isTest
public class ATI_QueryBuilderControllerTest {
    /*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
    @testSetup 
    static void setupMethod(){
        Test.startTest();
        //create Account
        List<Account> accountList=TestDataFactory.createAccount(1);   
        for(Integer i=0;i<accountList.size();i++){
        	accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'test'+i;    
        }
        insert accountList;
        Test.stopTest();
        //Create Business category
        List<WOD_2__Business_Category_Configuration__c> businessCategoryConfiguration=TestDataFactory.createBusinessCategoryConfiguration(2);    
        businessCategoryConfiguration[0].Name='Test';
        businessCategoryConfiguration[1].Name='Test New';    
        insert businessCategoryConfiguration;
        
        //create Inventory
        List<WOD_2__Inventory__c> inventoriesToInsertLst=TestDataFactory.createInventory(3);
        for(WOD_2__Inventory__c inv:inventoriesToInsertLst)
        {
            inv.WOD_2__Business_Unit__c=businessCategoryConfiguration[0].Id;
            inv.WOD_2__Account__c=accountList[0].Id;
        }
        insert inventoriesToInsertLst;
    }
    
    /*
        Method Name :   testGetWhereCondition
        Description :   Method to test get where condition
    */
    private static testmethod void testGetWhereCondition(){
        Test.startTest();
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        List<WOD_2__Business_Category_Configuration__c> busCatObj = [SELECT ID FROM WOD_2__Business_Category_Configuration__c];
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]}, {"id":2,"field":"WOD_2__Install_Date__c","operator":"=","fieldType":"DATE","values":["2018-04-04"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"Name","operator":"contains","fieldType":"STRING","values":["test"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"Name","operator":"starts with","fieldType":"STRING","values":["test"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"Name","operator":"ends with","fieldType":"STRING","values":["test"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2', 
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"WOD_2__Type__c","operator":"!=","fieldType":"PICKLIST","values":["Retail"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"WOD_2__Type__c","operator":"=","fieldType":"PICKLIST","values":["Retail"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"WOD_2__Type__c","operator":"contains","fieldType":"PICKLIST","values":["Retail"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["'+busCatObj[0].id+'"]},{"id":2,"field":"WOD_2__Type__c","operator":"starts with","fieldType":"PICKLIST","values":["Retail"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        responseWrapperObj = ATI_QueryBuilderController.getWhereCondition('1 AND 2',
                                                                         '[{"id":1,"field":"WOD_2__Business_Unit__c","operator":"=","fieldType":"REFERENCE","values":["busCatObj[0].id+"]},{"id":2,"field":"WOD_2__Type__c","operator":"ends with","fieldType":"PICKLIST","values":["Retail"]}]');
        System.assertEquals(true, responseWrapperObj.status,'Assert Failed!');
        Test.stopTest();
    } 

    /*
        Method Name :   testGetCustomMetaData
        Description :   Method to test get custom metadata
    */
    private static testmethod void testGetCustomMetaData(){
        Test.startTest();
        WOD_2__Class_Override_Setting__mdt customdata = ATI_QueryBuilderController.getCustomMetaData('FilterCriteriaOverride');
        System.debug('customMetadata logic name'+customdata);
        System.assertEquals(null,customdata,'Assert Failed!');
        customdata = ATI_QueryBuilderController.getCustomMetaData('ValidateInventoryDetailPageAccess');
        Test.stopTest();
    } 

    /*
        Method Name :   tetInventoryWrapper
        Description :   Method to cover wrapper
    */
    private static testmethod void tetInventoryWrapper(){
        Test.startTest();
        List<WOD_2__Inventory__c> invObj = [SELECT Id FROM WOD_2__Inventory__c];
        List<sObject> sObj = new List<sObject>();
        sObj.addAll(invObj);
        ATI_QueryBuilderController.InventoryWrapper invWrap = new  ATI_QueryBuilderController.InventoryWrapper(new List<sObject>(sObj),1);
        System.assertEquals(true,invWrap.recordCount ==1,'Assert Failed!');
        Test.stopTest();   
    } 
}