@isTest
public class ATI_ExchangeRateServiceTest {
    @testSetup
    private static void dataSetUp(){
        Test.startTest();
        List<ATI_Exchange_Rate__c> exchangeRates = TestDataFactory.createExchangeRate(1);
        insert exchangeRates;
        Test.stopTest();
    }
    
    @isTest 
    private static void testExchangeRateService(){
        ATI_ExchangeRateService.ExchangeWrapper erObj = new  ATI_ExchangeRateService.ExchangeWrapper();
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;	
        ATI_Exchange_Rate__c exchangeRate = [SELECT Id,FromCurrency__c, Rate__c, ToCurrency__c,Value__c, EffectiveDate__c, EndDate__c FROM ATI_Exchange_Rate__c limit 1];
        Test.startTest();
        Date dt = Date.today();
       	ATI_ExchangeRateService.convertCurrency('123','456',dt); 
        ATI_ExchangeRateService.convertCurrency('','',null);
        ATI_ExchangeRateService.convertCurrency('BRL','USD',dt); 
        erObj = ATI_ExchangeRateService.convertCurrencyForAccount('BRL','USD',dt,accList[0].id);
        Test.stopTest();
    }
}