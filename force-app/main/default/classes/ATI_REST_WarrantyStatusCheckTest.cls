/* Name: ATI_REST_WarrantyStatusCheckTest
Description : Test Class for ATI_REST_WarrantyStatusCheck,ATI_REST_WarrantyStatusCheckValidator and ATI_REST_WarrantyStatusCheckRequest 
Author : Tavant(TY)
History:
VERSION     AUTHOR          DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)      01/02/2021        INITIAL DEVELOPMENT                               
*/
@isTest
public class ATI_REST_WarrantyStatusCheckTest {
	@testSetup
    public static void testSetup(){
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        insert distributorAccount;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //BCCS
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = TestDataFactory.createBccs(busCategoryConfig.get(0));
        insert bccsLst;
        
        //VocationCode
        List<WOD_2__Warranty_Code__c> vocantionCodeLst = TestDataFactory.createVocationCode(1,false);
        insert vocantionCodeLst;
        
        //WarrantyProduct
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(WOD_2__Warranty_Product__c wp : warrantyProLst){
            wp.WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
        }
        insert warrantyProLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(3);
        Decimal priority = 1;
        for(WOD_2__Policy_Definition__c policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-5);
            policyDef.WOD_2__Active_Until__c = Date.today().addYears(5);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Months_Covered__c = (priority * 12);
            policyDef.WOD_2__Description__c = 'Test';
            policyDef.WOD_2__Priority__c = priority++;
            policyDef.WOD_2__Type__c = 'Standard';
        }
        policyDefLst[2].WOD_2__Type__c = 'Extended';
        insert policyDefLst;
        
        List<WOD_2__Policy_Definition_Inventory_Usage__c> policyDefInvUsageLst = TestDataFactory.createPolicyDefUsage(1);
        policyDefInvUsageLst[0].WOD_2__Policy_Definition__c = policyDefLst.get(0).Id;
        insert policyDefInvUsageLst;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(1,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
        applicabilityTermsLst[0].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(1,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;

        //create Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(1,'Retail');
        invLst[0].Name = '9830004936';
        invLst[0].WOD_2__Serial_Number__c = '9830004936';
        invLst[0].WOD_2__Account__c = distributorAccount.get(0).Id;
        invLst[0].WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
        invLst[0].WOD_2__Units_Usage__c = 12;
        invLst[0].WOD_2__Item__c = warrantyProLst.get(2).Id;
        invLst[0].WOD_2__Install_Date__c = Date.today();
        invLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).Id;
        insert invLst;
		
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        insert viList;
        
        List<WOD_2__Warranty_Code__c> vocationCodes = TestDataFactory.createVocationCode(1, false);
        vocationCodes[0].Name = 'AG01';
        insert vocationCodes;
        
        //Create VehicleTransMapper
        List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = TestDataFactory.createVinMappers(1,viList.get(0).id);
        vehicleTransMapperLst[0].ATI_Inventory__c = invLst.get(0).Id;
        insert vehicleTransMapperLst;
        
        //WarrantyRegistration        
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
        wrLst[0].WOD_2__Status__c = 'Registered';
        wrLst[0].WOD_2__Account__c = invLst.get(0).WOD_2__Account__c;
        wrLst[0].WOD_2__Registration_Type__c = 'Standard Registration';
        wrLst[0].WOD_2__Registration_Date__c = Date.today();
        wrLst[0].WOD_2__Install_Date__c = Date.today();
        wrLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).id;
        wrLst[0].WOD_2__Customer__c = customerAccount.get(0).Id;
        wrLst[0].WOD_2__Units_Usage__c = 10;
        wrLst[0].WOD_2__Warranty_Product__c = invLst.get(0).WOD_2__Item__c;
        wrLst[0].WOD_2__Inventory__c = invLst.get(0).Id;
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCovLst = new List<WOD_2__Warranty_Coverages__c>();
        //WarrantyCoverages
        WOD_2__Warranty_Coverages__c warrantyCoverage = new WOD_2__Warranty_Coverages__c();
		warrantyCoverage.WOD_2__Policy_Definition__c = policyDefLst.get(0).id;
        warrantyCoverage.WOD_2__Warranty_Registration__c = wrLst.get(0).id;
        warrantyCoverage.WOD_2__Warranty_Start_Date__c = Date.today();
        warrantyCoverage.WOD_2__Warranty_End_Date__c = Date.today().addYears(1);
        warrantyCovLst.add(warrantyCoverage);
        
        WOD_2__Warranty_Coverages__c warrantyCoverage1 = new WOD_2__Warranty_Coverages__c();
		warrantyCoverage1.WOD_2__Policy_Definition__c = policyDefLst.get(1).id;
        warrantyCoverage1.WOD_2__Warranty_Registration__c = wrLst.get(0).id;
        warrantyCoverage1.WOD_2__Warranty_Start_Date__c = Date.today();
        warrantyCoverage1.WOD_2__Warranty_End_Date__c = Date.today().addYears(2);
		warrantyCovLst.add(warrantyCoverage1);
        
        WOD_2__Warranty_Coverages__c warrantyCoverage2 = new WOD_2__Warranty_Coverages__c();
		warrantyCoverage2.WOD_2__Policy_Definition__c = policyDefLst.get(2).id;
        warrantyCoverage2.WOD_2__Warranty_Registration__c = wrLst.get(0).id;
        warrantyCoverage2.WOD_2__Warranty_Start_Date__c = Date.today();
        warrantyCoverage2.WOD_2__Warranty_End_Date__c = Date.today().addYears(3);
		warrantyCovLst.add(warrantyCoverage2);
        
        insert warrantyCovLst;
        
        //ServiceCampaign
        List<twodcms__Service_Campaign__c> serviceCampaignLst = TestDataFactory.createServiceCampaign(1,busCategoryConfig.get(0).id);
        insert serviceCampaignLst;
        serviceCampaignLst[0].twodcms__Status__c = 'Active';
        update serviceCampaignLst;
        
        //CampaignMembers
        twodcms__Campaign_Members__c campaignMembers = new twodcms__Campaign_Members__c();
        campaignMembers.Name = invLst.get(0).Name;
        campaignMembers.twodcms__Inventory__c = invLst.get(0).Id;
        campaignMembers.twodcms__Service_Campaign__c = serviceCampaignLst.get(0).Id;
        insert campaignMembers;
    }
    
     
    @isTest
    private static void testForStandardIsSelectedCheck(){
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "9830004936","repairOrderOpenDate": "' + Datetime.now().addDays(10).format('yyyy-MM-dd') + '","vehicleUsageValue": "","vehicleUsageUnit": "","inServiceDate": "","vocationCode": ""}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Success','WarrantyStatusCheck Data has been retrieved successfully...!!!');
        ATI_REST_WarrantyStatusCheck.ResponseData responseData = response.data;
        List<ATI_REST_WarrantyStatusCheck.WarrantyInformation> coveragesData = responseData.WarrantyStatusCheckResponse.coverages;
        //System.assert(3 == coveragesData.size(),'Total Number of Coverages applicable for Inventory');
        //System.assertEquals(true,coveragesData[0].selected,'selected flag check if Standard and Extended both are Active');
	}
    
    @isTest
    private static void testForStandardIsSelectedCheck2(){
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "9830004936","repairOrderOpenDate": "' + Datetime.now().addDays(10).addYears(1).format('yyyy-MM-dd') + '","vehicleUsageValue": "12","vehicleUsageUnit": "mi","inServiceDate": "","vocationCode": ""}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Success','WarrantyStatusCheck Data has been retrieved successfully...!!!');
        ATI_REST_WarrantyStatusCheck.ResponseData responseData = response.data;
        List<ATI_REST_WarrantyStatusCheck.WarrantyInformation> coveragesData = responseData.WarrantyStatusCheckResponse.coverages;
        //System.assert(3 == coveragesData.size(),'Total Number of Coverages applicable for Inventory');
        //System.assertEquals(true,coveragesData[1].selected,'selected flag check if Standard and Extended both are Active');
    }
    
    @isTest
    private static void testForExtendedIsSelectedCheck(){
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "9830004936","repairOrderOpenDate": "' + Datetime.now().addDays(10).addYears(2).format('yyyy-MM-dd') + '","vehicleUsageValue": "12","vehicleUsageUnit": "mi","inServiceDate": "2021-08-10","vocationCode": "AG01"}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Success','WarrantyStatusCheck Data has been retrieved successfully...!!!');
         ATI_REST_WarrantyStatusCheck.ResponseData responseData = response.data;
        List<ATI_REST_WarrantyStatusCheck.WarrantyInformation> coveragesData = responseData.WarrantyStatusCheckResponse.coverages;
        //System.assert(3 == coveragesData.size(),'Total Number of Coverages applicable for Inventory');
        //System.assertEquals(true,coveragesData[2].selected,'selected flag check if Standard and Extended both are Active');
    }
    
    @isTest
    private static void testForWarrantyStatusCheck(){
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "9830004936","repairOrderOpenDate": "2023-03-14","vehicleUsageValue": "","vehicleUsageUnit": "","inServiceDate": "","vocationCode": ""}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Success','WarrantyStatusCheck Data has been retrieved successfully...!!!');
	}
    
    @isTest
    private static void testForStockInventory(){
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c];
        inv.WOD_2__Type__c = 'Stock';
        update inv;
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "9830004936","repairOrderOpenDate": "'+DateTime.now().format('yyyy-MM-dd')+ '","vehicleUsageValue": "10","vehicleUsageUnit": "km","inServiceDate": "'+DateTime.now().format('yyyy-MM-dd')+ '","vocationCode": "AG01"}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Success','Stock Inventory Coverage fetch failed');
	}
    
    @isTest
    private static void testForMandatoryFieldsCheck(){
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "","repairOrderOpenDate": "12023-03-14","vehicleUsageValue": "-1","vehicleUsageUnit": "miles","inServiceDate": "08-21-20999","vocationCode": "AG003"}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Failed','Mandatory Validation Check');   
    }
    
    @isTest
    private static void testForInvalidDataCheck(){
        String jsonMsg = '{"WarrantyStatusCheck": {"serialNumber": "","repairOrderOpenDate": "2023-03-14","vehicleUsageValue": "","vehicleUsageUnit": "","inServiceDate": "","vocationCode": ""}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Failed','InvalidDate and SerialNumber Validation Check');     
    }
    
    @isTest
    private static void testForRuntimeError(){
        String jsonMsg = '"WarrantyStatusCheck": {"serialNumber": "9830004936","repairOrderOpenDate": "2023-03-14","vehicleUsageValue": "","vehicleUsageUnit": "test","inServiceDate": "","vocationCode": ""}}';
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = sendWarrantyStatusCheckRequest(jsonMsg);
        //System.assert(response.status == 'Fail','Runtime Exception');     
    } 
    
    private static ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse sendWarrantyStatusCheckRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestWarrantyStatusCheck/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_WarrantyStatusCheck.ATI_REST_WarrantyStatusCheckResponse response = ATI_REST_WarrantyStatusCheck.doPost();
        System.debug('Response From Service -> ' + JSON.serialize(response));
        Test.stopTest();
        return response;
    }
}