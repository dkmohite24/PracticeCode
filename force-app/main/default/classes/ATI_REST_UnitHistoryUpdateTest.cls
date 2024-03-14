/* Name: ATI_REST_UnitHistoryUpdateTest
Description : Test Class for ATI_REST_UnitHistoryUpdateBatch,ATI_REST_UnitHistoryUpdate and ATI_REST_UnitHistoryUpdateRequest 
Author : Tavant(TY)
History:
VERSION   AUTHOR             DATE            DETAIL                UserStory/Req#
1.0 -     Tavant(TY)      29/03/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_UnitHistoryUpdateTest {
    @testSetup
    static void testSetupMethod(){
        Test.startTest();
        //create account
        List<Account> accountLst = TestDataFactory.createATIDistributorAccount(1);
        insert accountLst;
        
         //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //create Business Category Configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        //create Business Category Configuration Setting - Configuration
        List<WOD_2__Business_Category_Configuration_Setting__c> configurationBccsLst = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert configurationBccsLst;
        
        //Create Warranty Product
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(1);
        warrantyProPartLst[0].Name = 'R650045783';
        warrantyProPartLst[0].WOD_2__Item_Type__c = 'Part';
        warrantyProPartLst[0].WOD_2__Type__c = 'Item';
        warrantyProPartLst[0].WOD_2__Track_Type__c = 'Serialized';
        insert warrantyProPartLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-364);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Description__c = 'Test';
            policyDef.WOD_2__Type__c = 'Standard';
        }
        insert policyDefLst;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(2,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
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
        
        //create Warranty Code
        List<WOD_2__Warranty_Code__c> warCodeLst = new List<WOD_2__Warranty_Code__c>();
        
        //create Vocation Codes
        List<WOD_2__Warranty_Code__c> warrantyVocationCodeLst = TestDataFactory.createWarrantyCode(1,'Vocation Codes');
        warrantyVocationCodeLst[0].Name='AG01';
        warrantyVocationCodeLst[0].ATI_IsActive__c=true;
        warCodeLst.addAll(warrantyVocationCodeLst);
        
        //create Failure Codes
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createWarrantyCode(1,'Failure Codes');
        warCodeLst.addAll(warrantyFaultCodeLst);
        
        //create Vocation Codes
        List<WOD_2__Warranty_Code__c> warrantyDispositionCodeLst = TestDataFactory.createWarrantyCode(1,'Vocation Codes');
        warrantyVocationCodeLst[0].Name = '000101';
        warrantyVocationCodeLst[0].ATI_IsActive__c = true;
        warCodeLst.addAll(warrantyDispositionCodeLst);
        insert warCodeLst;
        
        //create Retail Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(1,'Retail');
        invLst[0].WOD_2__Account__c = accountLst.get(0).Id;
        invLst[0].WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
        invLst[0].WOD_2__Item__c = warrantyProLst[2].Id;
        invLst[0].Wod_2__Manufacturing_Date__c = Date.today();
        invLst[0].Wod_2__Manufacturing_Date__c = Date.today();
        invLst[0].ATI_Vocation_Code__c = warrantyVocationCodeLst[0].id;
        invLst[0].WOD_2__Customer__c = customerAccount[0].id;
        insert invLst;
        
        /*List<ATI_Disposition_Code_Mapper__c> disCodeMapperLst = TestDataFactory.createDispositionCodeMappers(1);
        disCodeMapperLst[0].ATI_Inventory__c = invLst.get(0).Id;
        disCodeMapperLst[0].ATI_Warranty_Code__c = warrantyDispositionCodeLst.get(0).id;
        insert disCodeMapperLst; */
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(1);
        //vehicleInfoLst[0].ATI_Inventory__c = invLst.get(0).Id;
        vehicleInfoLst[0].ATI_Customer_asset_number__c = '12345';
        insert vehicleInfoLst;
        
        //Create VehicleTransMapper
        List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = TestDataFactory.createVinMappers(1,vehicleInfoLst.get(0).id);
        vehicleTransMapperLst[0].ATI_Inventory__c = invLst.get(0).Id;
        insert vehicleTransMapperLst;
        
        //create WarrantyRegistration
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
        wrLst[0].WOD_2__Status__c = 'Registered';
        wrLst[0].WOD_2__Account__c = invLst.get(0).WOD_2__Account__c;
        wrLst[0].WOD_2__Registration_Type__c = 'Standard Registration';
        wrLst[0].WOD_2__Registration_Date__c = Date.today();
        wrLst[0].WOD_2__Install_Date__c = Date.today();
        wrLst[0].ATI_Vocation_Code__c = warrantyVocationCodeLst.get(0).id;
        wrLst[0].WOD_2__Customer__c = customerAccount.get(0).Id;
        wrLst[0].WOD_2__Units_Usage__c = 10;
        wrLst[0].WOD_2__Warranty_Product__c = warrantyProLst.get(2).id;
        wrLst[0].WOD_2__Inventory__c = invLst.get(0).id;
        insert wrLst;
        
        //Create WarrantyCoverage
        WOD_2__Warranty_Coverages__c warrantyCov = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c = policyDefLst[0].id,WOD_2__Warranty_Registration__c=wrLst.get(0).id,
                                                                           WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(policyDefLst[0].WOD_2__Months_Covered__c)));
        insert warrantyCov;
        
        //Create MajorComponent
        List<WOD_2__Major_Component__c> majorCmpLst = TestDataFactory.createMajorComp(1);
        majorCmpLst.get(0).WOD_2__Serial_number__c = 'BK5536N19260014E';
        majorCmpLst.get(0).ATI_Type__c = 'ECU';
        majorCmpLst.get(0).WOD_2__Warranty_Product__c = warrantyProPartLst.get(0).id;
        majorCmpLst.get(0).WOD_2__Inventory__c = invLst[0].id;
        insert majorCmpLst;
        
        Id machineRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        Id campaignRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
        
        //create Draft claims
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.CurrencyISOCode = 'USD';
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Account__c = accountLst[0].id;
            claimObj.WOD_2__Inventory__c = invLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'SN001';
        }
        claimLst[0].RecordTypeId = machineRecordTypeId;
        claimLst[0].WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
        claimLst[0].WOD_2__Units_Usage__c = 12;
        claimLst[1].RecordTypeId = campaignRecordTypeId;
        claimLst[1].WOD_2__Claim_Type__c = 'Campaign';
        insert claimLst;
        
        //Create InstallParts
		List<WOD_2__Claim_Part__c> installPartsLst = TestDataFactory.createInstalledParts(1);
        installPartsLst[0].WOD_2__Claim__c = claimLst[0].id;
        installPartsLst[0].WOD_2__Warranty_Product__c = warrantyProPartLst[0].id;
        installPartsLst[0].WOD_2__Serial_Number__c = 'BK5536N19260014E';
        insert installPartsLst;
        
        claimLst[0].WOD_2__Claim_Status__c = 'Approved';
        update claimLst;
        
        List<twodcms__Service_Campaign__c> serviceCampaignLst = TestDataFactory.createServiceCampaign(1,busCategoryConfig.get(0).id);
        insert serviceCampaignLst;
        serviceCampaignLst[0].twodcms__Status__c = 'Active';
        serviceCampaignLst[0].twodcms__Campaign_Description__c = 'Test';
        update serviceCampaignLst;
        
        //CampaignMembers
        twodcms__Campaign_Members__c campaignMembers = new twodcms__Campaign_Members__c();
        campaignMembers.Name = invLst.get(0).Name;
        campaignMembers.twodcms__Inventory__c = invLst.get(0).Id;
        campaignMembers.twodcms__Service_Campaign__c = serviceCampaignLst.get(0).Id;
        insert campaignMembers;
        
        List<ATI_Accounts_Receivable_Interface__c> customSettingList = new List<ATI_Accounts_Receivable_Interface__c>();
        ATI_Accounts_Receivable_Interface__c customSet1 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '200',Name='Status Code');
		customSettingList.add(customSet1);
		insert customSettingList;
        
        Test.stopTest();
    }
    
    @isTest
    private static void testUnitHistoryUpdateBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ATI_MockHttpResponseGenerator.UnitHistoryUpdateMockResp());
        ATI_REST_UnitHistoryUpdateSchedulable unitHistoryUpdateBatchSch = new ATI_REST_UnitHistoryUpdateSchedulable();
        unitHistoryUpdateBatchSch.execute(null);
        Test.stopTest();
        ATI_REST_UnitHistoryUpdate.unitHistoryUpdateForMasterData(DateTime.now().addDays(7*(-1)));
        List<WOD_2__Batch_Log__c> batchLogLst = [SELECT Id,WOD_2__Status__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='UnitHistoryUpdate'];
        System.assertEquals(2,batchLogLst.size(),'Unit History Update');
    }
}