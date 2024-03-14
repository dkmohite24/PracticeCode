/* Name: ATI_REST_ExchangeRateSyncTest
Description : Test Class for ATI_REST_ExchangeRateSync,ATI_REST_ExchangeRateValidator, ATI_REST_ExchangeRateRequest 
Author : Tavant(TY)
History:
VERSION     AUTHOR           DATE              DETAIL                UserStory/Req#
1.0 -     Tavant(TY)      18/12/2020      INITIAL DEVELOPMENT            20656                  
*/
@isTest
public class ATI_REST_ExchangeRateSyncTest {
    
    @testSetup
    public static void testSetup(){
        List<ATI_Exchange_Rate__c> exchangeRateLst = TestDataFactory.createExchangeRate(2);
        exchangeRateLst[0].EffectiveDate__c = Date.valueOf('2019-06-01');
        exchangeRateLst[0].EndDate__c = Date.valueOf('2020-07-31');
        exchangeRateLst[1].EffectiveDate__c = Date.valueOf('2020-08-01');
        exchangeRateLst[1].EndDate__c = Date.valueOf('2099-12-31');
        insert exchangeRateLst;
    }
    
    
   	@isTest
    private static void testForSuccessCriteriaERInsertAndDateUpdateCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c,EndDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"A","EffectiveDate":"'+String.valueOf(exchangeRate.EffectiveDate__c.addDays(30))+'","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"}]}';
    	ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
        Map<Id,ATI_Exchange_Rate__c> exchangeRateMap = new Map<Id,ATI_Exchange_Rate__c>([SELECT Id,EffectiveDate__c,EndDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC]);
        System.assertEquals(3,exchangeRateMap.size(),'Number of Exchange Rates has been inserted...!!!');
        System.assertEquals(exchangeRate.EndDate__c,exchangeRateMap.values().get(0).EndDate__c,'New Record End Date Check...!!!');
        System.assertEquals(exchangeRateMap.values().get(0).EffectiveDate__c.addDays(-1),exchangeRateMap.values().get(1).EndDate__c,'Updated Record End Date Check...!!!');
        List<WOD_2__Batch_Log__c> batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Success_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='ExchangeRateSync'];
        System.assert(batchLog.get(0).WOD_2__Total_Record_Count__c == 1,'Number of ExchangeRates Passed in Request');
        System.assert(batchLog.get(0).WOD_2__Success_Record_Count__c == 1,'Number of Success ExchangeRates');
        System.assert(batchLog.get(0).WOD_2__Failure_Record_Count__c == 0,'Number of Failure ExchangeRates');
    }
    
    @isTest
    private static void testForSuccessCriteriaRateUpdateCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c,Rate__c,Ratio__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        exchangeRate.Rate__c = 0.25;
        exchangeRate.Ratio__c = 1.0;
        update exchangeRate;
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"A","EffectiveDate":"'+String.valueOf(exchangeRate.EffectiveDate__c)+'","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"2"}]}';
    	ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
        ATI_Exchange_Rate__c updatedExchangeRate = [SELECT Id,EffectiveDate__c,EndDate__c,Rate__c,Ratio__c FROM ATI_Exchange_Rate__c WHERE Id=:exchangeRate.id];
        System.assertNotEquals(exchangeRate.Rate__c,updatedExchangeRate.Rate__c,'Rate Update Check...!!!');
        System.assertNotEquals(exchangeRate.Rate__c,updatedExchangeRate.Ratio__c,'Rate Update Check...!!!');
        List<WOD_2__Batch_Log__c> batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Success_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='ExchangeRateSync'];
        System.assert(batchLog.get(0).WOD_2__Total_Record_Count__c == 1,'Number of ExchangeRates Passed in Request');
        System.assert(batchLog.get(0).WOD_2__Success_Record_Count__c == 1,'Number of Success ExchangeRates');
        System.assert(batchLog.get(0).WOD_2__Failure_Record_Count__c == 0,'Number of Failed ExchangeRates');
    }
    
    @isTest
    private static void testForInsertExchangeRateCheck(){
        List<ATI_Exchange_Rate__c> exchangeRateLst = [SELECT Id,EffectiveDate__c,EndDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c];
        delete exchangeRateLst;
        String jsonMsg = '{"ExchangeRate":[{"identifier":"1","RateType":"A","EffectiveDate":"2022-01-01","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"},{"identifier":"2","RateType":"A","EffectiveDate":"2021-01-01","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"},{"identifier":"3","RateType":"A","EffectiveDate":"2020-01-01","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"}]}';
    	ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
     //   System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
    }
    
    @isTest
    private static void testForPartialSuccessCriteriaCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"A","EffectiveDate":"2020-07-01","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"2"},{"identifier":"1","RateType":"A","EffectiveDate":"'+exchangeRate.EffectiveDate__c.addDays(30)+'","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"},{"identifier":"3","RateType":"M","EffectiveDate":"2020-07-01","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"2"}]}';
    	ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
       // System.assertEquals('Partial Success', response.status, 'Few records have not been inserted / updated...!!!');
        List<WOD_2__Batch_Log__c> batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Success_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='ExchangeRateSync'];
        System.assert(batchLog.get(0).WOD_2__Total_Record_Count__c == 3,'Number of ExchangeRates Passed in Request');
      //  System.assert(batchLog.get(0).WOD_2__Success_Record_Count__c == 1,'Number of Success ExchangeRates');
     //   System.assert(batchLog.get(0).WOD_2__Failure_Record_Count__c == 2,'Number of Failed ExchangeRates');
    }
    
    @isTest
    private static void testForMandatoryFieldsValidationCheck(){
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"","EffectiveDate":"","FromCurrency":"","ToCurrency":"","Rate":"","Ratio":""}]}';
        ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        List<WOD_2__Batch_Log__c> batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='ExchangeRateSync'];
        System.assert(batchLog.size() == 1,'Number of Logs Created...!!!');
        System.assert(batchLog.get(0).WOD_2__Total_Record_Count__c == 1,'Number of ExchangeRates Passed in Request');
        System.assert(batchLog.get(0).WOD_2__Failure_Record_Count__c == 1,'Number of Failed ExchangeRates');
        System.assert(batchLog.get(0).WOD_2__Success_Record_Count__c == 0,'Number of Success ExchangeRates');
  	}
    
    @isTest
    private static void testForDateValidationCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"A","EffectiveDate":"2020-07-01","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"}]}';
        ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='ExchangeRateSync'];
        System.assert(batchLog.ATI_Error_Message__c.contains('Please provide valid ExchangeRate details'));
  	}
    
    @isTest
    private static void testForInvalidDataCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"A","EffectiveDate":"test","FromCurrency":"test","ToCurrency":"test","Rate":"0.50","Ratio":"1"}]}';
        ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
    }
    
    @isTest
    private static void testForidentifierValidationCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"A","EffectiveDate":"test","FromCurrency":"test","ToCurrency":"test","Rate":"0.50","Ratio":"1"},{"identifier":"","RateType":"A","EffectiveDate":"test","FromCurrency":"test","ToCurrency":"test","Rate":"0.50","Ratio":"1"},{"identifier":"2","RateType":"A","EffectiveDate":"test","FromCurrency":"USD","ToCurrency":"USD","Rate":"0.50","Ratio":"-1"}]}';
        ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
    }

	@isTest
    private static void testForCatchBlockValidationCheck(){
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,EffectiveDate__c,EndDate__c FROM ATI_Exchange_Rate__c ORDER BY EffectiveDate__c DESC LIMIT 1];
        String jsonMsg = '{"ExchangeRate":[{"identifier":"2","RateType":"test","EffectiveDate":"2020-05-02","FromCurrency":"BRL","ToCurrency":"USD","Rate":"0.50","Ratio":"1"}]}';
    	ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = sendExchangeRateRequest(jsonMsg);
        System.assertEquals('Fail', response.status, 'All the records have Failed');
    }
    
    private static ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse sendExchangeRateRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestExchangeRateSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_ExchangeRateSync.ATI_REST_ExchangeRateSyncResponse response = ATI_REST_ExchangeRateSync.doPost();
        Test.stopTest();
        return response;
    }    
}