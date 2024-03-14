/* Name: ATI_REST_BatchETCSubmittalSyncTest
Description : Test Class for ATI_REST_BatchETCSubmittalSync,ATI_REST_BatchETCSubmittal_Validator, ATI_REST_BatchETCSubmittalRequest 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             DATE              DETAIL                UserStory/Req#
1.0 -     Tavant(Punam)      10/02/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_BatchETCSubmittalSyncTest {
    @testSetup
    public static void testSetup(){
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        distributorAccount[0].Country__c = 'United States';
        distributorAccount[0].BillingCountry = 'United States';
        distributorAccount[0].SAP_ID__c='214565';
        distributorAccount[0].ATI_Financial_BP_Code__c='21456500000';
        insert distributorAccount;
        
        //BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = TestDataFactory.createBccs(busCategoryConfig.get(0));
        insert bccsLst;
        
        //VocationCode
        List<WOD_2__Warranty_Code__c> vocantionCodeLst = TestDataFactory.createVocationCode(1,false);
        insert vocantionCodeLst;
        vocantionCodeLst[0].Name='AG01';
        update vocantionCodeLst;
        
        //WarrantyProduct
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(WOD_2__Warranty_Product__c wp : warrantyProLst){
            wp.WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
        }
        insert warrantyProLst;
        warrantyProLst[1].WOD_2__Type__c='Model';
        warrantyProLst[2].WOD_2__Parent_Product__c=warrantyProLst[1].Id;
        warrantyProLst[2].WOD_2__Type__c = 'Item';
        warrantyProLst[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProLst[2].WOD_2__Track_Type__c = 'Serialized';
        update warrantyProLst;
        
        //Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(100,'Stock');
        for(WOD_2__Inventory__c inv : invLst){
            inv.WOD_2__Account__c = distributorAccount.get(0).Id;
            inv.WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
            inv.WOD_2__Item__c = warrantyProLst[2].Id;
            inv.Wod_2__Manufacturing_Date__c = Date.today();
            inv.WOD_2__Install_Date__c = Date.Today();
            inv.ATI_Vocation_Code__c= vocantionCodeLst.get(0).Id;
            inv.ATI_Program_Level__c = 'O';
        }
        invLst[0].WOD_2__Serial_Number__c='Inv-0005UT003';
        insert invLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(2);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-364);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Type__c = 'Standard';
            policyDef.WOD_2__Sub_Type__c = '01';
            
        }
        policyDefLst[1].Name='3 year extend policy';
        policyDefLst[1].WOD_2__Type__c = 'Extended';
        insert policyDefLst;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(2,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
        applicabilityTermsLst[1].WOD_2__Policy_Definition__c = policyDefLst[1].Id;
        insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(1,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;
        insert standardCriteriaLst;
        
        //Extended ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> extendedCriteriaLst = TestDataFactory.createApplicabilityCriterias(1,applicabilityTermsLst.get(1));
        extendedCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        extendedCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        extendedCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        extendedCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        extendedCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        extendedCriteriaLst[0].WOD_2__Sequence__c = 1;
        insert extendedCriteriaLst;
        
        List<ATI_Extended_Warranty_Pricing__c> ewpLst = TestDataFactory.createExtendedWarrantyPricing(1);
        ewpLst[0].ATI_Active_From__c = Date.today().addDays(-364);
		ewpLst[0].ATI_Active_Until__c = Date.today();
        ewpLst[0].ATI_Policy_Definition__c = policyDefLst[1].Id;
        ewpLst[0].ATI_Program_Level__c = 'O';
        ewpLst[0].ATI_Warranty_Product__c = warrantyProLst.get(1).Id;
        ewpLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).Id;
        ewpLst[0].ATI_Country__c = '';
        insert ewpLst;
        
        system.debug('ewpLst**'+ewpLst[0].ATI_Vocation_Code__r.Name+ewpLst[0].ATI_Policy_Definition__r.Name+ewpLst[0].ATI_Warranty_Product__r.Name);
    
    }
    
    @isTest
    private static void testForAtiRestBatchETCSubmittalSyncTest(){
    	String jsonMsg = '{"ETCPurchase": [{"BusinessPartnerCode": "214565","BusinessCategoryConfiguration": "ATI","TrackingNumber": "123456","RepairOutlet": "214565","AgreementDate": "2020-12-01","SubmittalIndicator": "I","SubmitterName": "JEANETTE LONG","SubmitterPhone": "6109440451","PurchaseOrderNumber": "R232902K","ETCRegistrationNumber": "","ETCCoverageCode": "13 year extend policy","CENumber": "","VehicleInfo": {"SerialNumber": "Inv-0005U00r","preDelivery": "true","VocationCode": "AG01","CustomerAssetNumber": "9900123","inServiceDate": "","VehicleIdentificationNumber": "1NPXX4EX3LD641849","VehicleMileage": "10","UsageUnit": "10","VehicleMake": "PETERBILT","VehicleModel": "389","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "401 Trucksource Inc.","Street": "4293 County Road 46","City": "Maidstone","State": "ON","PostalCode": "N0R 1K0","CountryCode": "Canada","Email": "","Phone": ""}}]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestBatchETCSubmittalSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        	 
        	ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse response6 = ATI_REST_BatchETCSubmittalSync.doPost();
        	System.assertEquals('Failed', response6.status, 'All the records have inserted or updated...!!!');
        	/*List<WOD_2__Warranty_Registration__c> wRegList = [Select Id,Name,WOD_2__Status__c,WOD_2__Inventory__r.WOD_2__Type__c From WOD_2__Warranty_Registration__c Where ATI_Unique_WR_No__c!= null limit 1];
       		
        	jsonMsg = '{"ETCPurchase": [{"identifier": "12345","BusinessPartnerCode": "214565","BusinessCategoryConfiguration": "ATI","TrackingNumber": "123456","RepairOutlet": "214890","AgreementDate": "2020-12-01","SubmittalIndicator": "M","SubmitterName": "JEANETTE LONG","SubmitterPhone": "6109440451","PurchaseOrderNumber": "R872902K","ETCRegistrationNumber": "'+wRegList[0].Name+'","ETCCoverageCode": "3 year extend policy","CENumber": "","VehicleInfo": {"SerialNumber": "Inv-0005UT003","preDelivery": "false","VocationCode": "AG01","CustomerAssetNumber": "9900123","inServiceDate": "2020-09-27","VehicleIdentificationNumber": "1NPXX4EX3LD641849","VehicleMileage": "10","UsageUnit": "10","VehicleMake": "PETERBILT","VehicleModel": "389","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "401 Trucksource Inc.","Street": "4293 County Road 46","City": "Maidstone","State": "ON","PostalCode": "N0R 1K0","CountryCode": "Canada","Email": "","Phone": ""}}]}';    
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse response5 = ATI_REST_BatchETCSubmittalSync.doPost();
        	system.debug('response5.'+response5.data[0].message);
        	System.assertEquals('Failed', response5.status, 'All the records have failed to update...!!!');*/
        
        	jsonMsg = '{"ETCPurchase": [{"identifier": "12345","BusinessPartnerCode": "214565","BusinessCategoryConfiguration": "ATI","TrackingNumber": "123456","RepairOutlet": "214890","AgreementDate": "2020-12-01","SubmittalIndicator": "I","SubmitterName": "JEANETTE LONG","SubmitterPhone": "6109440451","PurchaseOrderNumber": "R872902K","ETCRegistrationNumber": "","ETCCoverageCode": "3 year extend policy","CENumber": "","VehicleInfo": {"SerialNumber": "Inv-0005UT003","preDelivery": "false","VocationCode": "AG01","CustomerAssetNumber": "9900123","inServiceDate": "2020-09-27","VehicleIdentificationNumber": "1NPXX4EX3LD641849","VehicleMileage": "10","UsageUnit": "10","VehicleMake": "PETERBILT","VehicleModel": "389","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "401 Trucksource Inc.","Street": "4293 County Road 46","City": "Maidstone","State": "ON","PostalCode": "N0R 1K0","CountryCode": "Canada","Email": "","Phone": ""}}]}';    
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse response4 = ATI_REST_BatchETCSubmittalSync.doPost();
        
        	
        	jsonMsg = '{"ETCPurchase": [{"identifier": "12345","BusinessPartnerCode": "214565","BusinessCategoryConfiguration": "ATI","TrackingNumber": "123456","RepairOutlet": "214565","AgreementDate": "2020-12-01","SubmittalIndicator": "I","SubmitterName": "JEANETTE LONG","SubmitterPhone": "6109440451","PurchaseOrderNumber": "R872902K","ETCRegistrationNumber": "","ETCCoverageCode": "3 year extend policy","CENumber": "","VehicleInfo": {"SerialNumber": "Inv-0005UT003","preDelivery": "false","VocationCode": "AG000","CustomerAssetNumber": "9900123","inServiceDate": "2020-09-27","VehicleIdentificationNumber": "1NPXX4EX3LD641849","VehicleMileage": "10","UsageUnit": "10","VehicleMake": "PETERBILT","VehicleModel": "389","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "401 Trucksource Inc.","Street": "4293 County Road 46","City": "Maidstone","State": "ON","PostalCode": "N0R 1K0","CountryCode": "Canada","Email": "","Phone": ""}}]}';    
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse response8 = ATI_REST_BatchETCSubmittalSync.doPost();
        	System.assertEquals('Failed', response8.status, 'All the records have failed to update...!!!');
        
        	jsonMsg = '{"ETCPurchase": [{"identifier": "","BusinessPartnerCode": "214565","BusinessCategoryConfiguration": "Test","TrackingNumber": "123456","RepairOutlet": "214565","AgreementDate": "2020-12-01","SubmittalIndicator": "I","SubmitterName": "JEANETTE LONG","SubmitterPhone": "6109440451","PurchaseOrderNumber": "R232902K","ETCRegistrationNumber": "WR-0001","ETCCoverageCode": "3 year extend policy","CENumber": "","VehicleInfo": {"SerialNumber": "Inv-0005UT003","preDelivery": "false","VocationCode": "AG01","CustomerAssetNumber": "9900123","inServiceDate": "2020-09-27","VehicleIdentificationNumber": "1NPXX4EX3LD641849","VehicleMileage": "10","UsageUnit": "10","VehicleMake": "PETERBILT","VehicleModel": "389","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "401 Trucksource Inc.","Street": "4293 County Road 46","City": "Maidstone","State": "ON","PostalCode": "N0R 1K0","CountryCode": "Canada","Email": "","Phone": ""}}]}';
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse response3 = ATI_REST_BatchETCSubmittalSync.doPost();
        	System.assertEquals('Failed', response3.status, 'All the records have failed to update...!!!');
        
        	List<WOD_2__Batch_Log__c> batchLogList = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchEtcSubmittal'];
        	
        	jsonMsg = '{"ETCPurchase": [{"identifier": "","BusinessPartnerCode": "","BusinessCategoryConfiguration": "","TrackingNumber": "123456","RepairOutlet": "","AgreementDate": "","SubmittalIndicator": "","SubmitterName": "","SubmitterPhone": "","PurchaseOrderNumber": "","ETCRegistrationNumber": "","ETCCoverageCode": "","CENumber": "","VehicleInfo": {"SerialNumber": "","preDelivery": "","VocationCode": "","CustomerAssetNumber": "9900123","inServiceDate": "","VehicleIdentificationNumber": "","VehicleMileage": "","UsageUnit": "10","VehicleMake": "","VehicleModel": "","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "","Street": "","": "Maidstone","State": "","PostalCode": "","CountryCode": "","Email": "","Phone": ""}}]}';
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse response2 = ATI_REST_BatchETCSubmittalSync.doPost();
        	System.assertEquals('Failed', response2.status, 'All the records have failed to update...!!!');
			
			jsonMsg = '{"ETCPurchase": [{"BusinessPartnerCode": "214565","BusinessCategoryConfiguration": "ATI","TrackingNumber": "123456","RepairOutlet": "214565","AgreementDate": "' + DateTime.now().format('yyyy-MM-dd') +'","SubmittalIndicator": "I","SubmitterName": "JEANETTE LONG","SubmitterPhone": "6109440451","PurchaseOrderNumber": "R872902K","ETCRegistrationNumber": "","ETCCoverageCode": "3 year extend policy","CENumber": "","VehicleInfo": {"SerialNumber": "Inv-0005UT003","preDelivery": "false","VocationCode": "AG01","CustomerAssetNumber": "9900123","inServiceDate": "' + DateTime.now().format('yyyy-MM-dd') + '","VehicleIdentificationNumber": "1NPXX4EX3LD641849","VehicleMileage": "50","UsageUnit": "mi","VehicleMake": "PETERBILT","VehicleModel": "389","EngineMake": "","EngineModel": "","EngineYear": "2018","ExecutiveOrderDesignation": ""},"CustomerInfo": {"CustomerName": "401 Trucksource Inc.","Street": "4293 County Road 46","City": "Maidstone","State": "ON","PostalCode": "N0R 1K0","CountryCode": "Canada","Email": "","Phone": ""}}]}';    
            req.requestBody = Blob.valueof(jsonMsg);	
            RestContext.request = req;
            ATI_REST_BatchETCSubmittalSync.ATI_REST_BatchETCSubmittalResponse successResponse1 = ATI_REST_BatchETCSubmittalSync.doPost();
			System.assertEquals('Success', successResponse1.status, 'All the records have failed to update...!!!');
        	
        Test.stopTest();
    }
}