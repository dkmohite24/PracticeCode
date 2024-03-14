/* Name: ATI_REST_CustomerMasterSyncTest
Description : Test Class for ATI_REST_CustomerMasterSync,ATI_REST_CustomerMasterValidator,ATI_REST_CustomerMasterRequest
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(TY)       25/11/2020        INITIAL DEVELOPMENT             20659                 
*/
@isTest
public class ATI_REST_CustomerMasterSyncTest {
    @testSetup
    public static void testSetup(){
        Test.startTest();
        //Account
        List<Account> accounts = TestDataFactory.createATIDistributorAccount(2);
        insert accounts;
        
        //Labor RateDetails
        List<WOD_2__Rates_Details__c> laborRateDetailsLst = TestDataFactory.createLaborRateDetails(2);
        laborRateDetailsLst[0].WOD_2__Dealer__c = accounts.get(0).id;
        laborRateDetailsLst[0].WOD_2__Active_From__c = Date.valueOf('2019-06-01');
        laborRateDetailsLst[0].WOD_2__Active_Until__c = Date.valueOf('2020-07-31');
        laborRateDetailsLst[1].WOD_2__Dealer__c = accounts.get(0).id;
        laborRateDetailsLst[1].WOD_2__Active_From__c = Date.valueOf('2020-08-01');
        laborRateDetailsLst[1].WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
        insert laborRateDetailsLst;
        
        //Travel RateDetails
        List<WOD_2__Rates_Details__c> travelRateDetailsLst = TestDataFactory.createTravelRateDetails(2);
        travelRateDetailsLst[0].WOD_2__Dealer__c = accounts.get(0).id;
        travelRateDetailsLst[0].WOD_2__Active_From__c = Date.valueOf('2019-06-01');
        travelRateDetailsLst[0].WOD_2__Active_Until__c = Date.valueOf('2020-07-31');
        travelRateDetailsLst[1].WOD_2__Dealer__c = accounts.get(0).id;
        travelRateDetailsLst[1].WOD_2__Active_From__c = Date.valueOf('2020-08-01');
        travelRateDetailsLst[1].WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
        insert travelRateDetailsLst;
        
        //LandingCost RateDetails
        List<WOD_2__Rates_Details__c> landingCostRateDetailsLst = TestDataFactory.createLadingCostRateDetails(2);
        landingCostRateDetailsLst[0].WOD_2__Dealer__c = accounts.get(0).id;
        landingCostRateDetailsLst[0].WOD_2__Active_From__c = Date.valueOf('2019-06-01');
        landingCostRateDetailsLst[0].WOD_2__Active_Until__c = Date.valueOf('2020-07-31');
        landingCostRateDetailsLst[1].WOD_2__Dealer__c = accounts.get(0).id;
        landingCostRateDetailsLst[1].WOD_2__Active_From__c = Date.valueOf('2020-08-01');
        landingCostRateDetailsLst[1].WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
        insert landingCostRateDetailsLst;
        
        Test.stopTest();
    }
    
    @isTest
    private static void testForAccountInsertUpdateBulkCheckInSameTrans(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        String jsonArray = '{"Account":[';
        for(Integer index = 1; index <= 1000; index++){
            jsonArray += '{"identifier":"'+index+'","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc.SAP_Id__c+123+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-09-01"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-09-01"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"2020-09-01"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}';        
            if(index != 1000){
                jsonArray += ',';
            }        
        }
        jsonArray += ']}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonArray); 
        List<Account> acc1 = [SELECT Id,SAP_Id__c,ATI_Max_Travel_Distance__c,ATI_Currency__c,ATI_Distance_Per_Hour__c FROM Account WHERE SAP_Id__c=:acc.SAP_ID__c+'123'];
        System.assertEquals(1,acc1.size(),'Number of Accounts are Inserted!!!');
        System.assertEquals(15,acc1.get(0).ATI_Distance_Per_Hour__c,'Dist Per Hour Check...');
        System.assertEquals(500,acc1.get(0).ATI_Max_Travel_Distance__c,'Max Travel Dist Check...');
        List<WOD_2__Rates_Details__c> rateDetailsLst = [SELECT Id,CurrencyISOCode FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__c=:acc1.get(0).id];
        System.assertEquals(3,rateDetailsLst.size(),'Number of RateDetails are Inserted!!!');
        System.assertEquals(acc1.get(0).ATI_Currency__c,rateDetailsLst.get(0).CurrencyISOCode,'RateDetails Currency Check...');
        System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
    }
    
    @isTest
    private static void testForAccountInsertionForTypeF(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"F","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc.SAP_Id__c+123+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[],"DistanceRateDetails":[],"LandingCostMarkupDetails":[],"BusinessCategoryUnit":"","MarkUpPercent":"2","Email":"","customerCurrency":"","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"","AdjustmentFactor":"","Performance":"","DistanceIndicator":"","ActiveDate":"","InActiveDate":"","RMAExempt":""}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        List<Account> acc1 = [SELECT Id,SAP_Id__c FROM Account WHERE SAP_Id__c=:acc.SAP_ID__c+'123'];
        System.assert(acc1.size() == 1,'Number of Accounts are Inserted!!!');
    }
    
    @isTest
    private static void testForSuccessCriteriaDatesUpdateCheck(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        Map<Id,WOD_2__Rates_Details__c> laborRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> travelRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> landingCostMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc.SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-09-01"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-09-01"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"2020-09-01"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        
        //LaborRate Check
        WOD_2__Rates_Details__c laborRd = [SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE Id NOT IN:laborRatesMap.keySet() AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' LIMIT 1];
        WOD_2__Rates_Details__c updatedLaborRD = [SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c=:laborRatesMap.values().get(0).WOD_2__Active_From__c AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' LIMIT 1];
        System.assertEquals(laborRatesMap.values().get(0).WOD_2__Active_Until__c,laborRd.WOD_2__Active_Until__c,'LaborRate Latest ActiveUntil Date Check!!!');
        System.assertEquals(laborRd.WOD_2__Active_From__c.addDays(-1),updatedLaborRD.WOD_2__Active_Until__c,'LaborRate Updated ActiveUntil Date Check!!!');
        
        //TravelRate Check
        WOD_2__Rates_Details__c travelRd = [SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE Id NOT IN:travelRatesMap.keySet() AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' LIMIT 1];
        WOD_2__Rates_Details__c updatedTravelRD = [SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c=:travelRatesMap.values().get(0).WOD_2__Active_From__c AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' LIMIT 1];
        System.assertEquals(travelRatesMap.values().get(0).WOD_2__Active_Until__c,travelRd.WOD_2__Active_Until__c,'LaborRate Latest ActiveUntil Date Check!!!');
        System.assertEquals(travelRd.WOD_2__Active_From__c.addDays(-1),updatedTravelRD.WOD_2__Active_Until__c,'TravelRate Updated ActiveUntil Date Check!!!');
        
        //LandingCostRate Check
        WOD_2__Rates_Details__c landingCostRd = [SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE Id NOT IN:landingCostMap.keySet() AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' LIMIT 1];
        WOD_2__Rates_Details__c updatedLandingCostRD = [SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c=:landingCostMap.values().get(0).WOD_2__Active_From__c AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' LIMIT 1];
        System.assertEquals(landingCostMap.values().get(0).WOD_2__Active_Until__c,landingCostRd.WOD_2__Active_Until__c,'LandingCostRate Latest ActiveUntil Date Check!!!');
        System.assertEquals(landingCostRd.WOD_2__Active_From__c.addDays(-1),updatedLandingCostRD.WOD_2__Active_Until__c,'LandingCostRate Updated ActiveUntil Date Check!!!');
        System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
    }
    
    @isTest
    private static void testForSuccessCriteriaRateUpdateCheck(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        Map<Id,WOD_2__Rates_Details__c> laborRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> travelRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> landingCostMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc.SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"'+String.valueOf(laborRatesMap.values().get(0).WOD_2__Active_From__c)+'"}],"DistanceRateDetails":[{"DistancePerHour":"5","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"10.00","ActiveFrom":"'+String.valueOf(travelRatesMap.values().get(0).WOD_2__Active_From__c)+'"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"'+String.valueOf(landingCostMap.values().get(0).WOD_2__Active_From__c)+'"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"0.18","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        
        WOD_2__Rates_Details__c updatedLaborRD = [SELECT Id,WOD_2__Labor_Rate__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c=:laborRatesMap.values().get(0).WOD_2__Active_From__c AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' LIMIT 1];
        system.debug('laborRatesMap.values().get(0).WOD_2__Active_Until__c>>'+laborRatesMap.values().get(0).WOD_2__Active_Until__c);
        //System.assertEquals(laborRatesMap.values().get(0).WOD_2__Active_Until__c,updatedLaborRD.WOD_2__Active_Until__c,'LaborRate Latest ActiveUntil Date Check!!!');
        System.assertEquals(100.0000,updatedLaborRD.WOD_2__Labor_Rate__c,'LaborRate!!!');
        
        //TravelRate Check
        WOD_2__Rates_Details__c updatedTravelRD = [SELECT Id,WOD_2__Travel_By_Distance_Rate__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c=:travelRatesMap.values().get(0).WOD_2__Active_From__c AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' LIMIT 1];
        //System.assertEquals(travelRatesMap.values().get(0).WOD_2__Active_Until__c,updatedTravelRD.WOD_2__Active_Until__c,'LaborRate Latest ActiveUntil Date Check!!!');
        System.assertEquals(10.0000,updatedTravelRD.WOD_2__Travel_By_Distance_Rate__c,'TravelByDistanceRate!!!');
        
        //LandingCostRate Check
        WOD_2__Rates_Details__c updatedLandingCostRD = [SELECT Id,ATI_Landed_Cost_Markup__c,ATI_Landing_Cost_Rate__c,WOD_2__Active_Until__c FROM WOD_2__Rates_Details__c WHERE WOD_2__Active_From__c=:landingCostMap.values().get(0).WOD_2__Active_From__c AND WOD_2__Dealer__r.SAP_Id__c=:acc.SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' LIMIT 1];
        //System.assertEquals(landingCostMap.values().get(0).WOD_2__Active_Until__c,updatedLandingCostRD.WOD_2__Active_Until__c,'LaborRate Latest ActiveUntil Date Check!!!');
        System.assertEquals(1000,updatedLandingCostRD.ATI_Landed_Cost_Markup__c,'LandingCostMarkup!!!');
        System.assertEquals(10.00,updatedLandingCostRD.ATI_Landing_Cost_Rate__c,'LandingCostMarkup!!!');
        System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
    }
    
    @isTest
    private static void testForInvalidParentAccountCheck(){
        List<Account> accLst = [SELECT Id,SAP_Id__c FROM Account];
        accLst.get(1).ParentId = accLst.get(0).Id;
        update accLst;
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"Test123","FinancialBPCode":"0000001305","ExternalId":"'+accLst.get(1).SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"09/01/2020"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"09/01/2020"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"09/01/2020"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        System.assertEquals('Failed', response.status, 'Invalid ParentAccount Check');
    }
    
    @isTest
    private static void testForAccountInsertionWithParentAccInSameTrans(){
        List<Account> accLst = [SELECT Id,SAP_Id__c FROM Account];
        String jsonMsg = '{"Account":[{"identifier":"1","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+accLst.get(0).SAP_Id__c+'0123'+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-09-01"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-09-01"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"2020-09-01"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"},';
        jsonMsg += '{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"Distributor","ParentAccount":"'+accLst.get(0).SAP_Id__c+'0123'+'","FinancialBPCode":"0000001305","ExternalId":"'+accLst.get(0).SAP_Id__c+'01234'+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-09-01"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-09-01"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"2020-09-01"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        System.assertEquals('Success', response.status, 'Account Insertion With ParentAccount');
    }
    
    @isTest
    private static void testForAccountInsertionWithParentAccInDiffTrans(){
        List<Account> accLst = [SELECT Id,SAP_Id__c FROM Account];
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"'+accLst.get(0).SAP_Id__c+'","FinancialBPCode":"0000001305","ExternalId":"'+accLst.get(1).SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-09-01"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-09-01"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"2020-09-01"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        System.assertEquals('Success', response.status, 'Account Insertion With ParentAccount');
    }
    
    @isTest
    private static void testForAccountInsertionWithUpdateParentAcc(){
        List<Account> accLst = [SELECT Id,SAP_Id__c FROM Account];
        accLst.get(1).ParentId = accLst.get(0).Id;
        update accLst;
        List<Account> accounts = TestDataFactory.createATIDistributorAccount(1);
        accounts.get(0).Name = 'Test123456';
        accounts.get(0).SAP_ID__c = '12345';
        insert accounts;
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"'+accounts.get(0).SAP_Id__c+'","FinancialBPCode":"0000001305","ExternalId":"'+accLst.get(1).SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-09-01"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-09-01"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"2020-09-01"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"2","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';        
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        System.assertEquals('Success', response.status, 'Account Insertion With ParentAccount');
    }
    
    @isTest
    private static void testForRateDetailActiveFromDateCheck(){
        List<Account> acc = [SELECT Id,SAP_Id__c FROM Account];
        List<WOD_2__Rates_Details__c> rateDetails = [SELECT Id,WOD_2__Active_From__c FROM WOD_2__Rates_Details__c WHERE RecordType.DeveloperName = 'ATI_Labor_Rate' AND WOD_2__Dealer__c=:acc.get(0).Id Order By WOD_2__Active_From__c DESC];
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc[0].SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-01-06"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-06-04"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"5.00","ActiveFrom":"2020-05-06"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
       // System.assertEquals('Failed', response.status, 'Few records have not been updated...!!!');
       // System.assert(response.data.get(0).message.contains('2020-01-06(LaborRate ActiveFrom) should be greater than or equals to ') == true, 'ActiveFromDate Validation Check!!!');
    }
    
    @isTest
    private static void testForPartialSuccessCheck(){
        List<Account> acc = [SELECT Id,SAP_Id__c FROM Account];
        Map<Id,WOD_2__Rates_Details__c> laborRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.get(0).SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> travelRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.get(0).SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> landingCostMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.get(0).SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc[0].SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"'+String.valueOf(laborRatesMap.values().get(0).WOD_2__Active_From__c)+'"}],"DistanceRateDetails":[{"DistancePerHour":"5","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"10.00","ActiveFrom":"'+String.valueOf(travelRatesMap.values().get(0).WOD_2__Active_From__c)+'"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"'+String.valueOf(landingCostMap.values().get(0).WOD_2__Active_From__c)+'"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"0.18","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"},';
        jsonMsg+='{"identifier":"3","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"","ExternalId":"'+acc[1].SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-01-06"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-06-04"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"0","ActiveFrom":"2020-05-06"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05 Distributor Dealer","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        System.assertEquals('Partial Success', response.status, 'Few records have not been inserted / updated...!!!');
    }
    
    @isTest
    private static void testForAccountMandatoryFieldsCheck(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"","AccountNumber":"","AccountDescription":"","Active":"","Type":"","ParentAccount":"","FinancialBPCode":"","ExternalId":"","BillingStreet":"24111 GROESBECK HWY.","BillingCity":"WARREN","BillingState":"Michigan","BillingPostalCode":"48089","BillingCountry":"US","ShippingStreet":"","ShippingCity":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-01-06"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-06-04"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"","ActiveFrom":"2020-05-06"}]}],"BusinessCategoryUnit":"","MarkUpPercent":"-1","Email":"","customerCurrency":"","Region":"","CustomerGroup":"","AccountGroup":"","PriceGroup":"","ExchangeRateType":"","AdjustmentFactor":"","Performance":"","DistanceIndicator":"","ActiveDate":"","InActiveDate":"","RMAExempt":""}]}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
    }
    
    @isTest
    private static void testForidentifierValidationCheck(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        String jsonMsg = '{"Account":[{"identifier":"","AccountName":"","AccountNumber":"","AccountDescription":"","Active":"","Type":"","ParentAccount":"","FinancialBPCode":"","ExternalId":"","BillingStreet":"24111 GROESBECK HWY.","BillingCity":"WARREN","BillingState":"Michigan","BillingPostalCode":"48089","BillingCountry":"US","ShippingStreet":"","ShippingCity":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","LaborRateDetail":[{"LaborRate":"-1","ActiveFrom":"2020-01-06"}],"DistanceRateDetails":[{"DistancePerHour":"-1","MaxTravelDist":"-1","DistanceRateDetail":[{"DistanceRate":"-1","ActiveFrom":"2020-06-04"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"-1","ActiveFrom":"2020-05-06"}]}],"BusinessCategoryUnit":"","MarkUpPercent":"","Email":"","customerCurrency":"","Region":"","CustomerGroup":"01","AccountGroup":"","PriceGroup":"","ExchangeRateType":"","AdjustmentFactor":"-1","Performance":"","DistanceIndicator":"","ActiveDate":"test","RMAExempt":"-1"},{"identifier":"2","AccountName":"","AccountNumber":"","AccountDescription":"","Active":"","Type":"","ParentAccount":"","FinancialBPCode":"","ExternalId":"","BillingStreet":"24111 GROESBECK HWY.","BillingCity":"WARREN","BillingState":"Michigan","BillingPostalCode":"48089","BillingCountry":"US","ShippingStreet":"","ShippingCity":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-01-06"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-06-04"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"0","ActiveFrom":"2020-05-06"}]}],"BusinessCategoryUnit":"","MarkUpPercent":"","Email":"","customerCurrency":"","Region":"","CustomerGroup":"","AccountGroup":"","PriceGroup":"","ExchangeRateType":"","AdjustmentFactor":"","Performance":"","DistanceIndicator":"","ActiveDate":"","RMAExempt":""},{"identifier":"2","AccountName":"","AccountNumber":"","AccountDescription":"","Active":"","Type":"","ParentAccount":"","FinancialBPCode":"","ExternalId":"","BillingStreet":"24111 GROESBECK HWY.","BillingCity":"WARREN","BillingState":"Michigan","BillingPostalCode":"48089","BillingCountry":"US","ShippingStreet":"","ShippingCity":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"2020-01-06"}],"DistanceRateDetails":[{"DistancePerHour":"15","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"5.00","ActiveFrom":"2020-06-04"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"0","ActiveFrom":"2020-05-06"}]}],"BusinessCategoryUnit":"","MarkUpPercent":"","Email":"","customerCurrency":"","Region":"","CustomerGroup":"","AccountGroup":"","PriceGroup":"","ExchangeRateType":"","AdjustmentFactor":"","Performance":"","DistanceIndicator":"","ActiveDate":"","InActiveDate":"","RMAExempt":""}]}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
    }
    
    @isTest
    private static void testForRateDetailMandatoryFieldsCheck(){
        Account acc = [SELECT Id,SAP_Id__c FROM Account LIMIT 1];
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"","Active":"Yes","Type":"Distributor","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc.SAP_Id__c+'","BillingStreet":"","BillingCity":"","BillingState":"","BillingPostalCode":"","BillingCountry":"","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"","ActiveFrom":""}],"DistanceRateDetails":[{"DistancePerHour":"-1","MaxTravelDist":"-1","DistanceRateDetail":[{"DistanceRate":"","ActiveFrom":""}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"","ActiveFrom":""}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"","Email":"","customerCurrency":"USD","Region":"91","CustomerGroup":"05","AccountGroup":"01","PriceGroup":"01","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"","InActiveDate":"","RMAExempt":"false"}]}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg);
        System.assertEquals('Failed', response.status, 'All the records have failed to insert / update...!!!');
    }
    
    
    @isTest
    private static void testForCatchBlockException(){
        List<Account> acc = [SELECT Id,SAP_Id__c FROM Account];
        Map<Id,WOD_2__Rates_Details__c> laborRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.get(0).SAP_Id__c AND RecordType.DeveloperName='ATI_Labor_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> travelRatesMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.get(0).SAP_Id__c AND RecordType.DeveloperName='ATI_Travel_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        Map<Id,WOD_2__Rates_Details__c> landingCostMap = new Map<Id,WOD_2__Rates_Details__c>([SELECT Id,WOD_2__Active_From__c,WOD_2__Active_Until__c,RecordType.DeveloperName FROM WOD_2__Rates_Details__c WHERE WOD_2__Dealer__r.SAP_Id__c=:acc.get(0).SAP_Id__c AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' ORDER BY WOD_2__Active_From__c DESC]);
        String jsonMsg = '{"Account":[{"identifier":"2","AccountName":"J. B. DLCO TRANSMISSIONS","AccountNumber":"0130500303","AccountDescription":"test","Active":"Yes","Type":"","ParentAccount":"","FinancialBPCode":"0000001305","ExternalId":"'+acc[0].SAP_Id__c+'","BillingStreet":"24111 GROESBECK HWY.","BillingCity":"WARREN","BillingState":"Michigan","BillingPostalCode":"48089","BillingCountry":"US","ShippingStreet":"24111 GROESBECK HWY.","ShippingCity":"WARREN","ShippingState":"Michigan","ShippingPostalCode":"48089","ShippingCountry":"US","LaborRateDetail":[{"LaborRate":"100.00","ActiveFrom":"'+String.valueOf(laborRatesMap.values().get(0).WOD_2__Active_From__c)+'"}],"DistanceRateDetails":[{"DistancePerHour":"5","MaxTravelDist":"500","DistanceRateDetail":[{"DistanceRate":"10.00","ActiveFrom":"'+String.valueOf(travelRatesMap.values().get(0).WOD_2__Active_From__c)+'"}]}],"LandingCostMarkupDetails":[{"LandingCostDetail":[{"LandingCostRate":"10.00","ActiveFrom":"'+String.valueOf(landingCostMap.values().get(0).WOD_2__Active_From__c)+'"}]}],"BusinessCategoryUnit":"ATI","MarkUpPercent":"0.18","Email":"test@123.com","customerCurrency":"USD","Region":"North America","CustomerGroup:"01","AccountGroup":"test","PriceGroup":"test","ExchangeRateType":"M","AdjustmentFactor":"1.00","Performance":"false","DistanceIndicator":"mi","ActiveDate":"'+Date.today()+'","InActiveDate":"'+Date.today()+'","RMAExempt":"false"}]}';
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = sendCustomerMasterRequest(jsonMsg); 
        System.assertEquals('Fail',response.status, 'RunTimeException for Bad Picklist Value...!!!');
    }
    
    private static ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse sendCustomerMasterRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestCustomerMasterSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_CustomerMasterSync.ATI_REST_CustomerMasterSyncResponse response = ATI_REST_CustomerMasterSync.doPost();
        Test.stopTest();
        return response;
    }
}