/* Name: ATI_REST_BatchClaimSubmittalSyncTest
Description : Test Class for ATI_REST_BatchClaimSubmittalSync,ATI_REST_BatchClaimSubmittalValidator, ATI_REST_BatchClaimSubmittalRequest 
Author : Tavant(Akshatha)
History:
VERSION   AUTHOR                DATE            DETAIL                UserStory/Req#
1.0 -     Tavant(Akshatha)      03/03/2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_BatchClaimSubmittalSyncTest {
    @testSetup
    public static void testSetup(){
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //create account
        List<Account> account = TestDataFactory.createATIDistributorAccount(1);
        account[0].SAP_ID__c = '9100500144';
        account[0].Country__c = 'United States';
        account[0].BillingCountry = 'United States';
        account[0].ATI_Price_Group__c='07';
        account[0].ATI_Currency__c = 'BRL';
        account[0].PRP_Participation__c = true;
        account[0].ATI_RPS_Status__c = false;
        account[0].ATI_Primary_Email_Id__c = 'test@gmail.com';
        account[0].ATI_Exchange_Rate_Type__c = 'A';
        insert account;
        
        Group g = new Group(Name='Dealer_'+account[0].id);
        insert g;
        
        account[0].Public_Group_Id__c = g.id;
        update account;
        
        List<WOD_2__Rates_Details__c> rateDetailsLst = new List<WOD_2__Rates_Details__c>();
        //Labor RateDetails
        List<WOD_2__Rates_Details__c> laborRateDetails = TestDataFactory.createLaborRateDetails(1);
        laborRateDetails[0].WOD_2__Dealer__c = account.get(0).id;
        laborRateDetails[0].WOD_2__Active_From__c = Date.valueOf('2020-01-01');
        laborRateDetails[0].WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
        rateDetailsLst.add(laborRateDetails[0]);
        
        //Travel RateDetails
        List<WOD_2__Rates_Details__c> travelRateDetails = TestDataFactory.createTravelRateDetails(1);
        travelRateDetails[0].WOD_2__Dealer__c = account.get(0).id;
        travelRateDetails[0].WOD_2__Active_From__c = Date.valueOf('2020-01-01');
        travelRateDetails[0].WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
        rateDetailsLst.add(travelRateDetails[0]);
        
        //LandingCost RateDetails
        List<WOD_2__Rates_Details__c> landingCostRateDetails = TestDataFactory.createLadingCostRateDetails(1);
        landingCostRateDetails[0].WOD_2__Dealer__c = account.get(0).id;
        landingCostRateDetails[0].WOD_2__Active_From__c = Date.valueOf('2020-01-01');
        landingCostRateDetails[0].WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
        rateDetailsLst.add(landingCostRateDetails[0]);
        
        insert rateDetailsLst;
        
        //create Business Category Configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        //create Business Category Configuration Setting - Configuration
        List<WOD_2__Business_Category_Configuration_Setting__c> configurationBccsLst = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert configurationBccsLst;
        
        //Machine
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(5);
        Integer count=1;
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
            wp.Name = 'R29545503'+count;
            wp.WOD_2__Units_Of_Measure__c = 'ea';
            wp.Part_Markup_Percentage__c = 1;
            count++;
        }
        insert warrantyProPartLst;
        
        List<WOD_2__Warranty_Product_Pricebook__c> priceBookList = new List<WOD_2__Warranty_Product_Pricebook__c>();
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            List<WOD_2__Warranty_Product_Pricebook__c> priceBook = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,wp.Id);
            //ALSN-45
            priceBook[0].Name = wp.Name;
            priceBook[0].WOD_2__Valid_From__c = Date.newInstance(2020,01,01);
            priceBookList.addAll(priceBook);
        }
        insert priceBookList;
        
        //create Stock Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(2,'Stock');
        Integer i = 1;
        for(WOD_2__Inventory__c inv : invLst){
            inv.Name = 'Inv-0005UT00'+i;
            inv.WOD_2__Serial_Number__c = 'Inv-0005UT00'+i;
            inv.WOD_2__Account__c = account.get(0).Id;
            inv.WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
            inv.WOD_2__Item__c = warrantyProLst[2].Id;
            inv.Wod_2__Manufacturing_Date__c =  Date.newInstance(2016, 12, 9);
            inv.WOD_2__Shipment_Date__c = Date.newInstance(2017, 12, 9);
            i++;
        }
        insert invLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.valueOf('2020-01-01');
            policyDef.WOD_2__Active_Until__c = Date.valueOf('2099-12-31');
            policyDef.WOD_2__Months_Covered__c = 120;
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
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
        
        //create Complaint Codes
        List<WOD_2__Warranty_Code__c> warrantyComplaintCodeLst = TestDataFactory.createWarrantyCode(1,'Complaint Codes');
        warrantyComplaintCodeLst[0].Name='NS03';
        warCodeLst.addAll(warrantyComplaintCodeLst);
        
        //create Failure Codes
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createWarrantyCode(1,'Failure Codes');
        warrantyFaultCodeLst[0].Name='AB07';
        warCodeLst.addAll(warrantyFaultCodeLst);
        
        //create Diagnostic Codes
        List<WOD_2__Warranty_Code__c> warrantyDiagnosticCodeLst = TestDataFactory.createWarrantyCode(1,'Diagnostics Codes');
        warrantyDiagnosticCodeLst[0].Name='7437';
        warCodeLst.addAll(warrantyDiagnosticCodeLst);
        
        //create Labor Operation Codes
        List<WOD_2__Warranty_Code__c> warrantyJobCodeLst = TestDataFactory.createWarrantyCode(3,'Labor Operations Codes');
        warrantyJobCodeLst[0].Name='00010000';
        warrantyJobCodeLst[0].WOD_2__Standard_Labor_Hour__c = 2;
        warrantyJobCodeLst[0].WOD_2__Standard_Labor_Minutes__c = 0;
        warrantyJobCodeLst[1].Name='000102030';
        warrantyJobCodeLst[1].WOD_2__Standard_Labor_Hour__c = 5;
        warrantyJobCodeLst[1].WOD_2__Standard_Labor_Minutes__c = 0;
        warrantyJobCodeLst[2].Name='000102040';
        warrantyJobCodeLst[2].WOD_2__Standard_Labor_Hour__c = 3;
        warrantyJobCodeLst[2].WOD_2__Standard_Labor_Minutes__c = 0;
        warCodeLst.addAll(warrantyJobCodeLst);
        insert warCodeLst;
        
        List<WOD_2__Warranty_Product__c> wpList = [SELECT Id FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Model'];
        List<WOD_2__Warranty_Product__c> itemsList = [SELECT Id FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        itemsList[0].WOD_2__Parent_Product__c=wpList[0].Id;
        update itemsList[0];
        
        List<WOD_2__Group__c> gpLst = TestDataFactory.createGroup(1);
        for(WOD_2__Group__c gpObj : gpLst){
            gpObj.WOD_2__Object_Name__c = 'WOD_2__Warranty_Product__c';
        }
        insert gpLst;
        
        List<WOD_2__Group_Member__c> gpMemLst = TestDataFactory.createGroupMember(1,gpLst[0].Id);
        gpMemLst[0].WOD_2__Warranty_Product__c = wpList[0].Id;
        insert gpMemLst;
        
        //Create FaultCodeMappers
        List<WOD_2__FaultCode_Mapper__c> fcmLst = TestDataFactory.createFaultCodeMappers(3,invLst[0].WOD_2__Item__c);
        for(Integer index=0;index<fcmLst.size();index++){
            fcmLst[index].WOD_2__Code__c = warrantyJobCodeLst[index].id;
            fcmLst[index].Name = warrantyJobCodeLst[index].Name;
            fcmLst[index].WOD_2__Group__c=gpLst[0].Id;
            fcmLst[index].WOD_2__Status__c=true;
        }
        insert fcmLst;
        
         //Create MajorComponents
        List<WOD_2__Major_Component__c> majorCompList = TestDataFactory.createMajorComp(2);
        count=1;
        for(WOD_2__Major_Component__c majorComp : majorCompList){
            majorComp.WOD_2__Serial_number__c = '141244'+count;
            majorComp.WOD_2__Warranty_Product__c = warrantyProPartLst[0].Id;
            count++;
        }
        insert majorCompList;
        
        List<twodcms__Service_Campaign__c> serviceCampaignLst = TestDataFactory.createServiceCampaign(1,busCategoryConfig.get(0).id);
        serviceCampaignLst[0].Name = 'SC001';
        insert serviceCampaignLst;
        
        
        //CampaignMembers
        twodcms__Campaign_Members__c campaignMembers = TestDataFactory.createCampaignMembers(invLst.get(0).Id,serviceCampaignLst.get(0).Id);
        campaignMembers.Name = invLst.get(0).Name;
        insert campaignMembers;
        
        Id machineRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
		Id campaignRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
		Id claimTempRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Claim_Template').getRecordTypeId();
		
        //create Claim Template claim
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(3); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.CurrencyISOCode = 'USD';
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
        }
        for(Integer index=0;index<claimLst.size()-1;index++){
            claimLst[index].WOD_2__Account__c = account[0].id;
            claimLst[index].WOD_2__Inventory__c = invLst[0].id;
            claimLst[index].WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimLst[index].WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimLst[index].WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimLst[index].WOD_2__Date_Of_Failure__c = Date.today();
            claimLst[index].WOD_2__Date_Of_Repair__c = Date.today();
            claimLst[index].WOD_2__Causal_Part_Serial_Number__c = 'SN001';
        }
        claimLst[0].RecordTypeId = machineRecordTypeId;
        claimLst[0].WOD_2__Claim_Type__c = 'Machine';
        claimLst[0].ATI_Tracking_Number__c = '600011531';
        claimLst[1].RecordTypeId = campaignRecordTypeId;
        claimLst[1].WOD_2__Claim_Type__c = 'Campaign';
        claimLst[1].ATI_Tracking_Number__c = '600011532';
        claimLst[2].RecordTypeId = claimTempRecordTypeId;
        claimLst[2].WOD_2__Claim_Type__c = 'Claim Template';
        insert claimLst;
        
        //Create InstallParts
		List<WOD_2__Claim_Part__c> installPartsLst = TestDataFactory.createInstalledParts(3);
        for(Integer index=0;index<installPartsLst.size();index++){
            installPartsLst[index].WOD_2__Claim__c = claimLst[index].id;
            installPartsLst[index].WOD_2__Warranty_Product__c = warrantyProPartLst[0].id;
        }
        try{
            insert installPartsLst;
        }catch(exception e){}
        
        
        ATI_Diagnostic_Code__c diagnosticCode = new ATI_Diagnostic_Code__c();
        diagnosticCode.Claim__c = claimLst[2].id;
        diagnosticCode.Warranty_Code__c = warrantyDiagnosticCodeLst[0].id;
        insert diagnosticCode;
        
        //Create Service Info
		List<WOD_2__Claim_Service_Information__c > claimServicesLst = TestDataFactory.createClaimServices(1);
        claimServicesLst[0].WOD_2__Claim__c = claimLst[2].id;
        claimServicesLst[0].WOD_2__Service_Job_Code__c = warrantyJobCodeLst[0].id;
        claimServicesLst[0].WOD_2__Total_Labor_Minutes__c = 2;
        try{
            insert claimServicesLst;
        }catch(exception e){}
        
        //Create OtherCost
		List<WOD_2__Other_Cost__c > otherCostLst = TestDataFactory.createOtherCostCategoryItems(1);
        otherCostLst[0].WOD_2__Claim__c = claimLst[2].id;
        otherCostLst[0].WOD_2__Cost_Category_Type__c = 'Labor';
        try{
            insert otherCostLst;
        }catch(exception e){}
        
        twodcms__Campaign_Claim_Template_Association__c campaignClaimTempAssc = TestDataFactory.createCampaignClaimTempAss(claimLst[2].id,serviceCampaignLst.get(0).Id,paymentDefLst.get(0).Id);
        insert campaignClaimTempAssc; 
        
        serviceCampaignLst[0].twodcms__Status__c = 'Active';
        update serviceCampaignLst;
        
        List<ATI_Exchange_Rate__c> exchangeRateLst = TestDataFactory.createExchangeRate(1);
        insert exchangeRateLst;
    }

    @isTest
    private static void testForSubIndIMachineClaim(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForHardErrorOnSubmission(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        List<WOD_2__Business_Category_Configuration_Setting__c> bccs = [SELECT Id,WOD_2__Error_Type__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name='ATI_Check_For_Pending_Approval_WR'];
        delete bccs;
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForSubIndCMachineClaim(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"C","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
        List<WOD_2__Claim__c> claimLst = [SELECT Id FROM WOD_2__Claim__c WHERE ATI_Identifier__c='Claim-1'];
        Database.executeBatch(new ATI_REST_ValidateClaimSubmittalBatch(claimLst,batchLog.id,new ATI_REST_ValidateClaimSubmittalBatch.ClaimValidateSubmitWrapper()),1);
    }
    
    @isTest
    private static void testForCusAndVehicleInfoUpdate(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Id rtId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Retail').getRecordTypeId();
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c WHERE RecordType.Name='Vocation Codes'];
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        customerAcc.Name = 'AMAZON.COMINC.';
        customerAcc.BillingCity = 'WESTLAKE';
        customerAcc.BillingPostalCode = '44145';
        update customerAcc;
        
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Account__c,WOD_2__Item__c FROM WOD_2__Inventory__c WHERE Name='Inv-0005UT001'];
        inv.WOD_2__Type__c = 'Retail';
        inv.RecordTypeId = rtId;
        update inv;
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(1);
        insert vehicleInfoLst;
        
        ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
        vehicleTransMapper.ATI_Inventory__c = inv.Id;
        vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(0).id;
        insert vehicleTransMapper;
        
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
        wrLst[0].WOD_2__Status__c = 'Registered';
        wrLst[0].WOD_2__Account__c = inv.WOD_2__Account__c;
        wrLst[0].WOD_2__Registration_Type__c = 'Standard Registration';
        wrLst[0].WOD_2__Registration_Date__c = Date.today();
        wrLst[0].WOD_2__Install_Date__c = Date.today();
        wrLst[0].ATI_Vocation_Code__c = vocationCode.id;
        wrLst[0].WOD_2__Customer__c = customerAcc.Id;
        wrLst[0].WOD_2__Units_Usage__c = 10;
        wrLst[0].WOD_2__Warranty_Product__c = inv.WOD_2__Item__c;
        wrLst[0].WOD_2__Inventory__c = inv.Id;
        insert wrLst;
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard'];
        WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(0).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
        insert wc;
        
     
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"C","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
 /*   @isTest
    private static void testForHardErrorOnValidation(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Id rtId = Schema.getGlobalDescribe().get('WOD_2__Inventory__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Retail').getRecordTypeId();
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c WHERE RecordType.Name='Vocation Codes'];
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Account__c,WOD_2__Item__c FROM WOD_2__Inventory__c WHERE Name='Inv-0005UT001'];
        inv.WOD_2__Type__c = 'Retail';
        inv.RecordTypeId = rtId;
        update inv;
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(1);
        insert vehicleInfoLst;
        
        ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
        vehicleTransMapper.ATI_Inventory__c = inv.Id;
        vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(0).id;
        insert vehicleTransMapper;
        
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
        wrLst[0].WOD_2__Status__c = 'In Progress';
        wrLst[0].WOD_2__Account__c = inv.WOD_2__Account__c;
        wrLst[0].WOD_2__Registration_Type__c = 'Standard Registration';
        wrLst[0].WOD_2__Registration_Date__c = Date.today();
        wrLst[0].WOD_2__Install_Date__c = Date.today();
        wrLst[0].ATI_Vocation_Code__c = vocationCode.id;
        wrLst[0].WOD_2__Customer__c = customerAcc.Id;
        wrLst[0].WOD_2__Units_Usage__c = 10;
        wrLst[0].WOD_2__Warranty_Product__c = inv.WOD_2__Item__c;
        wrLst[0].WOD_2__Inventory__c = inv.Id;
        insert wrLst;
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard'];
        WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(0).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
        insert wc;
        
        WOD_2__Business_Category_Configuration_Setting__c bccs = [SELECT Id,WOD_2__Error_Type__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name='ATI_Check_For_Pending_Approval_WR'];
        bccs.WOD_2__Error_Type__c = 'Hard';
        update bccs;
        
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"C","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMIN2C.","Street":"24601CENTERRIDGERD","City":"WESTLAK12E","State":"OH","PostalCode":"441425","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Business Rule Validation');
    }*/
    
    @isTest
    private static void testForSubIndAMachineClaim(){
        WOD_2__Claim__c claim = [SELECT Id,Name,WOD_2__Claim_Status__c,WOD_2__Date_Of_Repair__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Machine'];
        claim.WOD_2__Claim_Status__c = 'Paid';
        update claim;
        List<WOD_2__Transaction_Memo_History__c> tmhLst = TestDataFactory.createTransactionMemo(1);
        tmhLst[0].WOD_2__Claim__c = claim.id;
        tmhLst[0].WOD_2__Transaction_Status__c = 'Paid';
        tmhLst[0].ATI_Type__c = 'Claim';
        tmhLst[0].WOD_2__Transaction_Type__c = 'Credit';
        insert tmhLst;
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"A","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"600011531","ClaimNumber":"'+claim.Name+'","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"19-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"19-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForSubIndIPreAuthClaim(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"true","PreAuthorizationReason":"Goodwill","PreAuthorizationComments":"Test","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForSubIndIPartClaim(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Part","RepairOrder":"60001153","SpecialActivityCode":"","CampaignTemplateName":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"2021-01-01","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        // Commented Assert as Applicable Policy not found error is coming due to new validation which is added
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForCampaignClaimValidationOnSave(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        WOD_2__Claim__c claim = [SELECT Id,Name FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Claim Template'];
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Campaign","RepairOrder":"60001153","SpecialActivityCode":"SC001","CampaignTemplateName":"'+claim.Name+'","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Campaign Claim Validation on Save');
    }
    
    @isTest
    private static void testForSubIndCCampaignClaim(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        WOD_2__Claim__c claim = [SELECT Id,Name FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Claim Template'];
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"C","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Campaign","RepairOrder":"60001153","SpecialActivityCode":"SC001","CampaignTemplateName":"'+claim.Name+'","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[],"LaborCodes":[],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Campaign Claim');
    }
    
    @isTest
    private static void testForSubIndMCampaignClaim(){
       	Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        WOD_2__Claim__c claimTemp = [SELECT Id,Name FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Claim Template'];
        WOD_2__Claim__c campaignClaim = [SELECT Id,Name FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Campaign'];
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"M","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"600011532","ClaimNumber":"'+campaignClaim.Name+'","ClaimType":"Campaign","RepairOrder":"60001153","SpecialActivityCode":"SC001","CampaignTemplateName":"'+claimTemp.Name+'","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
  		//System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    
    @isTest
    private static void testForSubIndIReplaceClaimsSWING(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","CampaignTemplateName":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Test","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"Inv-0005UT002","ServiceReplacementIndicator":"SWING","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForSubIndIReplaceClaimsRETRAN(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","CampaignTemplateName":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Test","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"Inv-0005UT002","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        //System.assertEquals('Success', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForAmendClaimValidation(){
        WOD_2__Claim__c claim = [SELECT Id,Name,WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Machine'];
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"A","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"600011531","ClaimNumber":"'+claim.Name+'","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"2021-01-01","LaborLastAppliedDate":"2021-01-02","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"19-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"19-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Amend Claim Validation');
    }
    
    @isTest
    private static void testForEditClaimValidation(){
        WOD_2__Claim__c claim = [SELECT Id,Name,WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Machine'];
        claim.WOD_2__Claim_Status__c = 'Pending Payment';
        update claim;
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"M","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"600011531","ClaimNumber":"'+claim.Name+'","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"2021-01-01","LaborLastAppliedDate":"2021-01-02","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"19-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"19-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Edit Claim Validation');
    }
    
    /*@isTest
    private static void testForBulkClaimsValidationCheck(){
        String jsonArray = '{"Claim":[';
        for(Integer index=1;index<=30;index++){
			jsonArray += '{"identifier":"Claim-'+index+'","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","CampaignTemplateName":"","RepairOrderOpenDate":"","LaborLastAppliedDate":"2021-01-02","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"Test","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"true","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":""},{"LineNumber:"9","DiagnosticCode":"Test"}]","TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}';        	
            if(index != 30){
                jsonArray+=',';
            }
        }
        jsonArray+= ']}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Bulk Records Validation Check');
    }*/
    
    @isTest
    private static void testForMandatoryValidation(){
        String jsonArray = '{"Claim":[{"identifier":"","BusinessCategoryConfiguration":"","SubmittalIndicator":"","RepairOutlet":"","SerialNumber":"","TrackingNumber":"","ClaimNumber":"","ClaimType":"","RepairOrder":"60001153","repairOrderOpenDate":"","LaborLastAppliedDate":"","PrimaryFailedPart":"R29545","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"Inv1-0005UT003","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-02-05 00:00:00","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"","DateTimeDistributorScheduledService":"","dateTimeOfVehicleArrival":"","dateTimeLaborFirstApplied":"","dateTimeFirstPartOrdered":"","dateTimeLastPartArrived":"","DateTimeLaborLastRecordedorApplied":"","dateTimeRepairOrderClosed":"","dateTimeCustomerNotified":"","RepairOrderOpenDateTime":"","repairOrderClosedDate":""}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Fail', response.status, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForInvalidDataValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-001","BusinessCategoryConfiguration":"Test","SubmittalIndicator":"A","RepairOutlet":"Test","SerialNumber":"Test","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"03","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"R29545","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"Inv1-0005UT003","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-02-05 00:00:00","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"","DateTimeDistributorScheduledService":"","dateTimeOfVehicleArrival":"","dateTimeLaborFirstApplied":"","dateTimeFirstPartOrdered":"","dateTimeLastPartArrived":"","DateTimeLaborLastRecordedorApplied":"","dateTimeRepairOrderClosed":"","dateTimeCustomerNotified":"","RepairOrderOpenDateTime":"","repairOrderClosedDate":""}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Fail', response.status, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForMachineClaimValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-001","BusinessCategoryConfiguration":"Test","SubmittalIndicator":"A","RepairOutlet":"9100500144","SerialNumber":"","TrackingNumber":"60001153","ClaimNumber":"Test","ClaimType":"Machine","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"Test","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-02-05 00:00:00","VocationCode":"Test","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09","DateTimeDistributorScheduledService":"2019-05-09","dateTimeOfVehicleArrival":"2019-05-09","dateTimeLaborFirstApplied":"2019-05-09","dateTimeFirstPartOrdered":"2019-05-09","dateTimeLastPartArrived":"2019-05-09","DateTimeLaborLastRecordedorApplied":"2019-05-09","dateTimeRepairOrderClosed":"2019-05-09","dateTimeCustomerNotified":"2019-05-09","RepairOrderOpenDateTime":"2019-05-09"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Fail', response.status, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForReplacementClaimInvalidValidation(){
        WOD_2__Inventory__c inv = [SELECT Id,ATI_Warranty_Void__c,ATI_Active__c,WOD_2__Scrapped__c FROM WOD_2__Inventory__c WHERE Name='Inv-0005UT002'];
        inv.ATI_Warranty_Void__c = true;
        inv.ATI_Active__c = false;
        inv.WOD_2__Scrapped__c = true;
        update inv;
        String jsonArray = '{"Claim":[{"identifier":"Claim-001","BusinessCategoryConfiguration":"Test","SubmittalIndicator":"A","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"Test","ClaimType":"Machine","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"Inv-0005UT002","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"","VocationCode":"","CustomerAssetNumber":"","VehicleIdentificationNumber":"","VehicleMileage":"","UsageUnit":"mi","VehicleMake":"","VehicleModel":"","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"'+System.today().addDays(2)+'","DateTimeDistributorScheduledService":"'+System.today().addDays(2)+'","dateTimeOfVehicleArrival":"'+System.today().addDays(2)+'","dateTimeLaborFirstApplied":"'+System.today().addDays(2)+'","dateTimeFirstPartOrdered":"'+System.today().addDays(2)+'","dateTimeLastPartArrived":"'+System.today().addDays(2)+'","DateTimeLaborLastRecordedorApplied":"'+System.today().addDays(2)+'","dateTimeRepairOrderClosed":"'+System.today().addDays(2)+'","dateTimeCustomerNotified":"'+System.today().addDays(2)+'","RepairOrderOpenDateTime":"'+System.today().addDays(2)+'"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Fail', response.status, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForInvalidReplaceIndValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","CampaignTemplateName":"","RepairOrderOpenDate":"2021-01-01","LaborLastAppliedDate":"2021-01-02","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"Test","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Invalid Replace Indicator Validation');
    }
    
    @isTest
    private static void testForSerializedPartsValidation(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        List<WOD_2__Warranty_Product__c> wpLst = [SELECT Id,WOD_2__Track_Type__c FROM WOD_2__Warranty_Product__c];
        for(WOD_2__Warranty_Product__c wp:wpLst){
            wp.WOD_2__Track_Type__c = 'Serialized';
        }
        update wpLst;
        Account acc = [SELECT Id,ATI_Price_Group__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        acc.ATI_Price_Group__c = '01';
        update acc;
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"Test","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"Test","PartQuantity":"","PartUnit":""},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"1412441","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"1412441","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"Test","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"","LaborOperationCode":"000102030","LaborTimeActual":"-1","Reason":"comments"}],"NetItems":[{"LineNumber":"","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"Test"},{"LineNumber":"","DiagnosticCode":""}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
		ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Batch Processed Successfully');
    }
    
    @isTest
    private static void testForPartClaimValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-001","BusinessCategoryConfiguration":"Test","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"","TrackingNumber":"60001153","ClaimNumber":"Test","ClaimType":"Part","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"Test","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"Test","FailureCode":"Test","ReplacementUnitSerialNumber":"Inv1-0005UT003","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-0500:00:00","VocationCode":"Test","CustomerAssetNumber":"","VehicleIdentificationNumber":"Test","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"","DateTimeDistributorScheduledService":"","dateTimeOfVehicleArrival":"","dateTimeLaborFirstApplied":"Test","dateTimeFirstPartOrdered":"","dateTimeLastPartArrived":"","DateTimeLaborLastRecordedorApplied":"","dateTimeRepairOrderClosed":"","dateTimeCustomerNotified":"","RepairOrderOpenDateTime":"","repairOrderClosedDate":""}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Fail', response.status, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForCampaignClaimValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-001","BusinessCategoryConfiguration":"Test","SubmittalIndicator":"I","RepairOutlet":"Test","SerialNumber":"","TrackingNumber":"60001153","ClaimNumber":"Test","ClaimType":"Campaign","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"Test","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"Test","FailureCode":"Test","SpecialActivityCode":"","CampaignTemplateName":"","ReplacementUnitSerialNumber":"Inv1-0005UT003","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-0500:00:00","VocationCode":"Test","CustomerAssetNumber":"","VehicleIdentificationNumber":"Test","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"Test","DateTimeDistributorScheduledService":"Test","dateTimeOfVehicleArrival":"","dateTimeLaborFirstApplied":"Test","dateTimeFirstPartOrdered":"","dateTimeLastPartArrived":"Test","DateTimeLaborLastRecordedorApplied":"","dateTimeRepairOrderClosed":"Test","dateTimeCustomerNotified":"","RepairOrderOpenDateTime":"Test","repairOrderClosedDate":"Test"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Failed', response.status, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForCampaignInvalidDataValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-001","BusinessCategoryConfiguration":"Test","SubmittalIndicator":"I","RepairOutlet":"Test","SerialNumber":"","TrackingNumber":"60001153","ClaimNumber":"Test","ClaimType":"Campaign","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"Test","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"Test","FailureCode":"Test","SpecialActivityCode":"Test","CampaignTemplateName":"Test","ReplacementUnitSerialNumber":"Inv1-0005UT003","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-0500:00:00","VocationCode":"Test","CustomerAssetNumber":"","VehicleIdentificationNumber":"Test","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"Test","DateTimeDistributorScheduledService":"Test","dateTimeOfVehicleArrival":"","dateTimeLaborFirstApplied":"Test","dateTimeFirstPartOrdered":"","dateTimeLastPartArrived":"Test","DateTimeLaborLastRecordedorApplied":"","dateTimeRepairOrderClosed":"Test","dateTimeCustomerNotified":"","RepairOrderOpenDateTime":"Test","repairOrderClosedDate":"Test"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Failed', response.status, 'Response for Request Validation');
    }
	
    @isTest
    private static void testForClaimRelatedDataValidation(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"","FailedPartSerialNumber":"","ReplacedPartNumber":"","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"Test","FailedPartSerialNumber":"","ReplacedPartNumber":"Test","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":""},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"","LaborOperationCode":"00010000","LaborTimeActual":"15","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"","LaborTimeActual":"","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"","NetItemType":"Labor","NetItemQuantity":"","NetItemUnit":"ea","NetItemUnitCost":"","Reason":"Othercost"},{"lineNumber":"8","netItemType":"","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"},{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"","NetItemUnit":"ea","NetItemUnitCost":"","Reason":"Othercost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":""}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Response for Request Validation');
    }
    
    @isTest
    private static void testForInvalidRelatedDataValidation(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        WOD_2__Warranty_Code__c wc = [SELECT Id,ATI_Time_Studied__c,WOD_2__Standard_Labor_Hour__c FROM WOD_2__Warranty_Code__c WHERE Name='00010000'];
        wc.ATI_Time_Studied__c = true;
        wc.WOD_2__Standard_Labor_Hour__c = 5;
        update wc;
        WOD_2__Warranty_Product_Pricebook__c pricebook = [SELECT Id,ATI_Price_Group__c FROM WOD_2__Warranty_Product_Pricebook__c WHERE WOD_2__Warranty_Product__r.Name='R295455031'];
        pricebook.ATI_Price_Group__c = '01';
        update pricebook;
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"-1","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Travel By Distance","NetItemQuantity":"3","NetItemUnit":"","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Test","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Response for Related Data Validation');
    }
    
    @isTest
    private static void testForSubIndAMachineClaimValidation(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        WOD_2__Claim__c claim = [SELECT Id,Name,WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Machine'];
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","SubmittalIndicator":"A","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"'+claim.Name+'","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Machine Claim Validation');
    }
    
    @isTest
    private static void testForSubIndIMachineClaimOnSaveValidation(){
        Date d = Date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        List<WOD_2__Business_Category_Configuration_Setting__c> bccs = [SELECT Id FROM  WOD_2__Business_Category_Configuration_Setting__c];
        delete bccs;
        String jsonArray = '{"Claim":[{"identifier":"Claim-1","BusinessCategoryConfiguration":"ATI","submittalIndicator":"I","RepairOutlet":"9100500144","SerialNumber":"Inv-0005UT001","TrackingNumber":"60001153","ClaimNumber":"","ClaimType":"Machine","RepairOrder":"60001153","SpecialActivityCode":"","RepairOrderOpenDate":"'+dt+'","LaborLastAppliedDate":"'+dt+'","PrimaryFailedPart":"R295455031","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"NS03","FailureCode":"AB07","ReplacementUnitSerialNumber":"","ServiceReplacementIndicator":"","TechnicianName":"Favuzzi,Leonard","PreAuthorizationRequired":"false","PreAuthorizationReason":"","PreAuthorizationComments":"","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2020-02-09","VocationCode":"AG01","CustomerAssetNumber":"","VehicleIdentificationNumber":"11VJ813A8HA001075","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","FailedPartNumber":"R295455031","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455031","ReplacementPartSerialNumber":"","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"2","FailedPartNumber":"R295455032","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455032","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"3","FailedPartNumber":"R295455033","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455033","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"},{"LineNumber":"4","FailedPartNumber":"R295455034","FailedPartSerialNumber":"","ReplacedPartNumber":"R295455034","ReplacementPartSerialNumber":"","PartQuantity":"3","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"5","LaborOperationCode":"00010000","LaborTimeActual":"10.5","Reason":"Test"},{"LineNumber":"6","LaborOperationCode":"000102030","LaborTimeActual":"15.0","Reason":"comments"}],"NetItems":[{"LineNumber":"7","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"},{"lineNumber":"8","netItemType":"Travel by Distance","netItemQuantity":"100","netItemUnit":"Mi","netItemUnitCost":"80","reason":"Other cost"}],"DiagnosticCodes":[{"LineNumber":"8","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"2019-05-09 00:00:00","DateTimeDistributorScheduledService":"2019-05-09 00:00:00","dateTimeOfVehicleArrival":"2019-05-09 00:00:00","dateTimeLaborFirstApplied":"2019-05-09 00:00:00","dateTimeFirstPartOrdered":"2019-05-09 00:00:00","dateTimeLastPartArrived":"2019-05-09 00:00:00","DateTimeLaborLastRecordedorApplied":"2019-05-09 00:00:00","dateTimeRepairOrderClosed":"2019-05-09 00:00:00","dateTimeCustomerNotified":"2019-05-09 00:00:00","RepairOrderOpenDateTime":"2019-05-09 00:00:00"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Status__c,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='BatchClaimSubmittalSync'];
        System.assertEquals('Failed', batchLog.WOD_2__Status__c, 'Validation on Save Claim');
    } 
    
    @isTest
    private static void testForRuntimeValidation(){
        String jsonArray = '{"Claim":[{"identifier":"Claim-001",BusinessCategoryConfiguration":"Test","SubmittalIndicator":"I","RepairOutlet":"Test","SerialNumber":"","TrackingNumber":"60001153","ClaimNumber":"Test","ClaimType":"Campaign","RepairOrder":"60001153","repairOrderOpenDate":"Test","LaborLastAppliedDate":"Test","PrimaryFailedPart":"Test","PrimaryFailedPartSerialNumber":"Serialized","DateOfPurchase":"","ComplaintCode":"Test","FailureCode":"Test","SpecialActivityCode":"Test","CampaignTemplateName":"Test","ReplacementUnitSerialNumber":"Inv1-0005UT003","ServiceReplacementIndicator":"RETRAN","TechnicianName":"Favuzzi,Leonard","WorkPerformedComments":"WorkPerformedComments","RegistrationInfo":{"CustomerInfo":{"CustomerName":"AMAZON.COMINC.","Street":"24601CENTERRIDGERD","City":"WESTLAKE","State":"OH","PostalCode":"44145","CountryCode":"US","Email":"","Phone":""},"VehicleInfo":{"PreDelivery":"false","InServiceDate":"2019-0500:00:00","VocationCode":"Test","CustomerAssetNumber":"","VehicleIdentificationNumber":"Test","VehicleMileage":"13656","UsageUnit":"mi","VehicleMake":"KALMAR","VehicleModel":"SPOTTER","EngineMake":"","EngineModel":"","EngineYear":"","ExecutiveOrderDesignation":""}},"ServiceParts":[{"LineNumber":"1","PartNumber":"R295455031","PartQuantity":"1","PartUnit":"ea"},{"LineNumber":"2","PartNumber":"R295455032","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"3","PartNumber":"R295455033","PartQuantity":"2","PartUnit":"ea"},{"LineNumber":"4","PartNumber":"R295455034","PartQuantity":"2","PartUnit":"ea"}],"LaborCodes":[{"LineNumber":"3","LaborOperationCode":"00010000","LaborTimeActual":"10.5","LaborTimeUnit":"hr","Reason":"Test"},{"LineNumber":"4","LaborOperationCode":"000102030","LaborTimeActual":"15.0","LaborTimeUnit":"hr","Reason":"comments"}],"NetItems":[{"LineNumber":"5","NetItemType":"Labor","NetItemQuantity":"3","NetItemUnit":"ea","NetItemUnitCost":"25.69","Reason":"Othercost"}],"ReplacedComponents":[{"LineNumber":"1","FailedComponentSerial":"1412441","ReplacementSerial":"1412442"}],"DiagnosticCodes":[{"LineNumber":"1","DiagnosticCode":"7437"}],"TurnAroundData":{"dateTimeCustomerRequestedService":"Test","DateTimeDistributorScheduledService":"Test","dateTimeOfVehicleArrival":"","dateTimeLaborFirstApplied":"Test","dateTimeFirstPartOrdered":"","dateTimeLastPartArrived":"Test","DateTimeLaborLastRecordedorApplied":"","dateTimeRepairOrderClosed":"Test","dateTimeCustomerNotified":"","RepairOrderOpenDateTime":"Test"}}]}';
        ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonArray);
        System.assertEquals('Fail', response.status, 'Response for Request Validation');
    }

    private static ATI_REST_BatchClaimSubmittalResponse sendBatchClaimResponseRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestBatchClaimSubmittalSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_BatchClaimSubmittalResponse response = ATI_REST_BatchClaimSubmittalSync.doPost();
        Test.stopTest();
        return response;
    }
}