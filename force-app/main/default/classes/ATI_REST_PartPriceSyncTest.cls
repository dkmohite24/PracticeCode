/* Name: ATI_REST_PartPriceSyncTest
Description : Test Class for ATI_REST_PartPriceSync,ATI_REST_PartPriceValidator, ATI_REST_PartPriceRequest 
Author : Tavant(TY)
History:
VERSION     AUTHOR           DATE              DETAIL                UserStory/Req#
1.0 -     Tavant(TY)      14/01/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_PartPriceSyncTest {
    @testSetup
    public static void testSetup(){
        //Create WarrantyProduct
        List<WOD_2__Warranty_Product__c> wpLst = TestDataFactory.createWarrantyProduct(3);
        wpLst[2].WOD_2__Item_Type__c = 'Part';
        insert wpLst;
        
        //Create WarrantyProductPriceBook
        List<WOD_2__Warranty_Product_Pricebook__c> exchangeRateLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,wpLst.get(2).Id);
        exchangeRateLst.get(0).WOD_2__Price__c = 100;
        insert exchangeRateLst;
    }
    
    @isTest
    private static void testForSuccessBulkInsertionCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonMsg = '';
        for(Integer i=0; i<1000;i++){
            jsonMsg += '{"PartPrice":[{"identifier": "1","ManufNumber":"'+wp.Name+'","ConditionType":"PR00","PriceGroup":"07","EffectiveDate":"2020-04-01","EndDate":"2025-01-12","Value":"1500","PriceUnit":"EA"}]}';
        }
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
        //System.assertEquals('Success', response.status, 'All the records have been inserted successfully...!!!');
        List<WOD_2__Warranty_Product_Pricebook__c> warrantyProductPricebook = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id!=:wpb.id];
       // System.assertEquals(1,warrantyProductPricebook.size(),'Number Of WarrantyProductPricebooks have been Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
       // System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of PartPrice WPBs Passed in Request');
       // System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed PartPrice WPBs');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForidentifierValidationCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"","ConditionType":"PR00","PriceGroup":"","EffectiveDate":"","EndDate":"","Value":"","PriceUnit":""},{"identifier": "1","ManufNumber":"","ConditionType":"PR00","PriceGroup":"","EffectiveDate":"","EndDate":"","Value":"","PriceUnit":""},{"identifier": "","ManufNumber":"","ConditionType":"PR00","PriceGroup":"","EffectiveDate":"","EndDate":"","Value":"","PriceUnit":""}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
        //System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
    }
    
    @isTest
    private static void testForMandatoryFieldsValidationCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"","ConditionType":"PR00","PriceGroup":"","EffectiveDate":"","EndDate":"","Value":"","PriceUnit":""}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        List<WOD_2__Warranty_Product_Pricebook__c> warrantyProductPricebook = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id!=:wpb.id];
        System.assertEquals(0,warrantyProductPricebook.size(),'Number Of WarrantyProductPricebooks have been Inserted/Updated...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
       // System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of PartPrice WPBs Passed in Request');
        //System.assert(batchLog.WOD_2__Failure_Record_Count__c == 1,'Number of Failed PartPrice WPBs');
     //   System.assert(batchLog.WOD_2__Success_Record_Count__c == 0,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForInvalidWPCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String wpName = wp.Name+'test';
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"'+wpName+'","ConditionType":"PR00","PriceGroup":"07","EffectiveDate":"2020-04-01","EndDate":"2025-31-12","Value":"1500","PriceUnit":"EA"}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        List<WOD_2__Warranty_Product_Pricebook__c> warrantyProductPricebook = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id!=:wpb.id];
        System.assertEquals(0,warrantyProductPricebook.size(),'Number Of WarrantyProductPricebooks have been Inserted/Updated...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
       // System.assert(batchLog.ATI_Error_Message__c.contains('Part Number is invalid'),'Part Number Validation Check...!!!');
       // System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of PartPrice WPBs Passed in Request');
        //System.assert(batchLog.WOD_2__Failure_Record_Count__c == 1,'Number of Failed PartPrice WPBs');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 0,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForSuccessInsertionCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"'+wp.Name+'","ConditionType":"PR00","PriceGroup":"07","EffectiveDate":"2020-04-01","EndDate":"2025-01-12","Value":"1500","PriceUnit":"EA"}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
        //System.assertEquals('Success', response.status, 'All the records have been inserted successfully...!!!');
        List<WOD_2__Warranty_Product_Pricebook__c> warrantyProductPricebook = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id!=:wpb.id];
        //System.assertEquals(1,warrantyProductPricebook.size(),'Number Of WarrantyProductPricebooks have been Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
      //  System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of PartPrice WPBs Passed in Request');
      //  System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed PartPrice WPBs');
      //  System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForSuccessUpdationCheck(){
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id,ATI_Price_Group__c,WOD_2__Valid_From__c,WOD_2__Valid_Until__c,WOD_2__Price__c,ATI_Unit_of_Measure__c FROM WOD_2__Warranty_Product_Pricebook__c];
        String price = String.valueOf(wpb.WOD_2__Price__c+50);
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"'+wp.Name+'","ConditionType":"PR00","PriceGroup":"'+wpb.ATI_Price_Group__c+'","EffectiveDate":"'+String.valueOf(wpb.WOD_2__Valid_From__c)+'","EndDate":"'+String.valueOf(wpb.WOD_2__Valid_Until__c)+'","Value":"'+price+'","PriceUnit":"'+wpb.ATI_Unit_of_Measure__c+'"}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
       // System.assertEquals('Success', response.status, 'All the records have been updated successfully...!!!');
        WOD_2__Warranty_Product_Pricebook__c warrantyProductPricebook = [SELECT Id,WOD_2__Price__c FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id=:wpb.Id];
       // System.assertEquals(150,warrantyProductPricebook.WOD_2__Price__c,'Number Of WarrantyProductPricebooks have been Updated...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
       // System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of PartPrice WPBs Passed in Request');
       // System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed PartPrice WPBs');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForUniqueWPBCheck(){
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id,ATI_Price_Group__c,WOD_2__Valid_From__c,WOD_2__Valid_Until__c,WOD_2__Price__c,ATI_Unit_of_Measure__c FROM WOD_2__Warranty_Product_Pricebook__c];
        String price = String.valueOf(wpb.WOD_2__Price__c+50);
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"","ConditionType":"PR00","PriceGroup":"'+wpb.ATI_Price_Group__c+'","EffectiveDate":"'+String.valueOf(wpb.WOD_2__Valid_From__c)+'","EndDate":"'+String.valueOf(wpb.WOD_2__Valid_Until__c)+'","Value":"'+price+'","PriceUnit":"'+wpb.ATI_Unit_of_Measure__c+'"}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
       // System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
        WOD_2__Warranty_Product_Pricebook__c warrantyProductPricebook = [SELECT Id,WOD_2__Price__c FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id=:wpb.Id];
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
      //  System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of PartPrice WPBs Passed in Request');
      //  System.assert(batchLog.WOD_2__Failure_Record_Count__c == 1,'Number of Failed PartPrice WPBs');
     //   System.assert(batchLog.WOD_2__Success_Record_Count__c == 0,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForMandatoryFieldsPartialSuccessCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"'+wp.Name+'","ConditionType":"PR00","PriceGroup":"07","EffectiveDate":"2020-04-01","EndDate":"2025-01-12","Value":"1500","PriceUnit":"EA"},';
        jsonMsg += '{"identifier": "2","ManufNumber":"","ConditionType":"PR00","PriceGroup":"","EffectiveDate":"","EndDate":"","Value":"","PriceUnit":""}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
      //  System.assertEquals('Partial Success', response.status, 'All the records have failed to update...!!!');
        List<WOD_2__Warranty_Product_Pricebook__c> warrantyProductPricebook = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c WHERE Id!=:wpb.id];
       // System.assertEquals(1,warrantyProductPricebook.size(),'Number Of WarrantyProductPricebooks have been Inserted/Updated...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync' limit 1];
       // System.assert(batchLog.WOD_2__Total_Record_Count__c == 2,'Number of PartPrice WPBs Passed in Request');
       // System.assert(batchLog.WOD_2__Failure_Record_Count__c == 1,'Number of Failed PartPrice WPBs');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success PartPrice WPBs');
    }
    
    @isTest
    private static void testForFailCriteriaCheck(){
        WOD_2__Warranty_Product_Pricebook__c wpb = [SELECT Id FROM WOD_2__Warranty_Product_Pricebook__c];
        WOD_2__Warranty_Product__c wp = [SELECT Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonMsg = '{"PartPrice":[{"identifier": "1","ManufNumber":"'+wp.Name+'","ConditionType":"PR00","PriceGroup":"test","EffectiveDate":"2020-04-01","EndDate":"2025-01-12","Value":"1500","PriceUnit":"EA"}]}';
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = sendPartPriceRequest(jsonMsg);
      //  System.assertEquals('Fail', response.status, 'All the records have Failed');
    }
    
    @isTest
    private static void testForcreateLogForAccess(){
        Test.startTest();
        ATI_LogService.createLogForAccess('PartPriceSync','Insufficient WarrantyProduct Read Access');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='PartPriceSync'];
        System.assert(batchLog.ATI_Error_Message__c.contains('Insufficient WarrantyProduct Read Access'),'Part Number Validation Check...!!!');
        Test.stopTest();
    }
    
    private static ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse sendPartPriceRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestPartPriceSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_PartPriceSync.ATI_REST_PartPriceSyncResponse response = ATI_REST_PartPriceSync.doPost();
        Test.stopTest();
        return response;
    }
}