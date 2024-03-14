/* Name: BulkUploadHandlerTest
Author : Tavant()
History:
VERSION     AUTHOR         DATE             DETAIL                 UserStory/Req#
1.0 -     Tavant()      14/01/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_BulkUploadHandlerTest {
    @testSetup 
    static void setupMethod(){
        Test.startTest();
        List<Account> accountObj = TestDataFactory.createATIDistributorAccount(1);
        insert accountObj;
        
        List<WOD_2__Business_Category_Configuration__c> businessCategoryConfiguration=TestDataFactory.createBusinessCategoryConfiguration(2);
        businessCategoryConfiguration[0].Name = 'Test';
        businessCategoryConfiguration[1].Name = 'Test New';
        insert businessCategoryConfiguration;
        
        List<WOD_2__Inventory__c> inventoriesToInsertLst=TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inv : inventoriesToInsertLst){  
            inv.RecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
            inv.Name = 'Test-1';
            inv.WOD_2__Business_Unit__c = businessCategoryConfiguration[0].Id;
            inv.WOD_2__Account__c = accountObj[0].Id;
        }
        insert inventoriesToInsertLst;
        Test.stopTest();
    }
    
    @isTest 
    private static void testReferenceFieldWithQueryMapNotEMpty() {
        WOD_2__Inventory__c inventoryObj = [Select Id from WOD_2__Inventory__c where Name=:'Test-1' limit 1];
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper();
        
        responseWrapperObj = ATI_BulkUploadController.createBatchLog(inventoryObj.id,'{"Inventory Id" : "'+inventoryObj.id+'"}' ,'WRUpload','TestFileName');
        WOD_2__Batch_Log__c batchLogObj = [Select Id from WOD_2__Batch_Log__c where WOD_2__Process_Type__c=:'WRUpload' limit 1];
        System.assertnotEquals(null,batchLogObj);
        
        responseWrapperObj = ATI_BulkUploadController.uploadChunks('[{"Serial Number":"Test-1"}]',batchLogObj.id);
        
        Test.startTest();
        //set configurations
        ATI_BulkUploadBatch.bulkUploadConfigMdt = new ATI_BulkUploadConfiguration();
        ATI_BulkUploadBatch.bulkUploadConfigMdt.objectApiNameStr = 'WOD_2__Warranty_Registration__c';
        ATI_BulkUploadBatch.configurationObjectFieldLst = new List<String>{'WOD_2__Inventory__c'};
            ATI_BulkUploadBatch.bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        ATI_BulkUploadBatch.bulkUploadFieldMappingLst.add(createBulkUploadFieldMapping('WOD_2__Inventory__c','Test-1',true,'','','Test-2','WOD_2__Serial_Number__c'));
        ATI_BulkUploadHandler.bulkUploadConfigurationObj = new ATI_BulkUploadConfiguration();
        ATI_BulkUploadHandler.bulkUploadConfigurationObj.objectApiNameStr = 'WOD_2__Warranty_Registration__c';
        ATI_BulkUploadHandler.bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        ATI_BulkUploadHandler.bulkUploadFieldMappingLst.add(createBulkUploadFieldMapping('WOD_2__Inventory__c','Serial Number',true,'WOD_2__Serial_Number__c','WOD_2__Inventory__c','Reference',''));
        responseWrapperObj = ATI_BulkUploadController.callBatchJobToInsert(batchLogObj.id);
        ATI_BulkUploadBatch.dummyMethodForCodeCoverage();
        Test.stopTest();
        System.assertEquals(true,responseWrapperObj.Status);
    }
    
    @isTest 
    private static void testbulkUploadDataMapBlank() {
        WOD_2__Inventory__c inventoryObj = [Select Id from WOD_2__Inventory__c where Name=:'Test-1' limit 1];
        Test.startTest();
        WOD_2.ResponseWrapper responseWrapperObj = new  WOD_2.ResponseWrapper();
        
        responseWrapperObj = ATI_BulkUploadController.createBatchLog(inventoryObj.id,'{"Inventory Id" : "'+inventoryObj.id+'"}' ,'WRUpload','fileName');
        WOD_2__Batch_Log__c batchLogObj = [Select Id from WOD_2__Batch_Log__c where WOD_2__Process_Type__c=:'WRUpload' limit 1];
        System.assertnotEquals(null,batchLogObj);
        
        responseWrapperObj = ATI_BulkUploadController.uploadChunks('[{"Serial Number":"Test-1","Inventory Id":"'+inventoryObj.id+'"}]',batchLogObj.id); 
        
        //set configurations
        ATI_BulkUploadBatch.bulkUploadConfigMdt = new ATI_BulkUploadConfiguration();
        ATI_BulkUploadBatch.bulkUploadConfigMdt.objectApiNameStr = 'WOD_2__Warranty_Registration__c';
        ATI_BulkUploadBatch.configurationObjectFieldLst = new List<String>{'WOD_2__Inventory__c'};
            ATI_BulkUploadBatch.bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        ATI_BulkUploadBatch.bulkUploadFieldMappingLst.add(createBulkUploadFieldMapping('','Test-1',true,'','','Test-2','WOD_2__Serial_Number__c'));
        ATI_BulkUploadHandler.bulkUploadConfigurationObj = new ATI_BulkUploadConfiguration();
        ATI_BulkUploadHandler.bulkUploadConfigurationObj.objectApiNameStr = 'WOD_2__Warranty_Registration__c';
        
        ATI_BulkUploadHandler.bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        
        ATI_BulkUploadHandler.bulkUploadFieldMappingLst.add(createBulkUploadFieldMapping('WOD_2__Inventory__c','Inventory Id',true,'Id','WOD_2__Inventory__c','Reference',''));
        ATI_BulkUploadHandler.bulkUploadFieldMappingLst.add(createBulkUploadFieldMapping('WOD_2__Inventory__c','Serial Number',false,'','','String',''));
        responseWrapperObj = ATI_BulkUploadController.callBatchJobToInsert(batchLogObj.id);
        
        Test.stopTest();
    }
    @isTest static void testCreateBulkUploadFieldMappingEmpty() {
        
        WOD_2__Inventory__c inventoryObj = [Select Id from WOD_2__Inventory__c where Name=:'Test-1' limit 1];
        Test.startTest();
        WOD_2.ResponseWrapper responseWrapperObj = new  WOD_2.ResponseWrapper();
        
        responseWrapperObj = ATI_BulkUploadController.createBatchLog(inventoryObj.id,'{"Inventory Id" : "'+inventoryObj.id+'"}' ,'WRUpload','fileName');
        WOD_2__Batch_Log__c batchLogObj = [Select Id from WOD_2__Batch_Log__c where WOD_2__Process_Type__c=:'WRUpload' limit 1];
        System.assertnotEquals(null,batchLogObj);
        
        responseWrapperObj = ATI_BulkUploadController.uploadChunks('[{"Name":"Test-1","Inventory Id":"'+inventoryObj.id+'"}]',batchLogObj.id); 
        
        //set configurations
        ATI_BulkUploadBatch.bulkUploadConfigMdt = new ATI_BulkUploadConfiguration();
        ATI_BulkUploadBatch.bulkUploadConfigMdt.objectApiNameStr = 'WOD_2__Warranty_Registration__c';
        ATI_BulkUploadBatch.configurationObjectFieldLst = new List<String>{'WOD_2__Inventory__c'};
            ATI_BulkUploadBatch.bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        ATI_BulkUploadBatch.bulkUploadFieldMappingLst.add(createBulkUploadFieldMapping('Name','Test-1',true,'','','Test-1','Name'));
        ATI_BulkUploadHandler.bulkUploadConfigurationObj = new ATI_BulkUploadConfiguration();
        ATI_BulkUploadHandler.bulkUploadConfigurationObj.objectApiNameStr = 'WOD_2__Warranty_Registration__c';
        ATI_BulkUploadHandler.bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        responseWrapperObj = ATI_BulkUploadController.callBatchJobToInsert(batchLogObj.id);
        
        Test.stopTest();
    }
    
    // Creating BulkUploadFieldMapping custom metadata records for test class to evaluate
    public static ATI_BulkUploadFieldMapping createBulkUploadFieldMapping(String fieldAPINameStr,String columnNameStr,Boolean isMandatory,String refFieldApiName,String refObjectApiName,String typeStr,String dispName){
        ATI_BulkUploadFieldMapping objFieldMapping = new ATI_BulkUploadFieldMapping();
        objFieldMapping.fieldAPIName = fieldAPINameStr ;
        objFieldMapping.columnName = columnNameStr;
        objFieldMapping.isMandatory = isMandatory ;
        objFieldMapping.referenceFieldAPIName = refFieldApiName;
        objFieldMapping.referenceObjectAPIName = refObjectApiName ;
        objFieldMapping.type = typeStr ;
        objFieldMapping.displayName = dispName;
        return objFieldMapping;
    } 
    
}