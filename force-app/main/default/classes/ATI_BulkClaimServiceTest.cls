/* Name: ATI_BulkClaimServiceTest
Description : Test Class for ATI_BulkClaimUploadController and ATI_BulkClaimService
Author : Tavant(MB)
History:
VERSION     AUTHOR            DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(MB)       May 17th 2021        INITIAL DEVELOPMENT                           
*/
@isTest
public class ATI_BulkClaimServiceTest {
    @testSetup
    public static void testSetup(){
        Test.startTest();
        
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        distributorAccount[0].Country__c = 'United States';
        distributorAccount[0].BillingCountry = 'United States';
        distributorAccount[0].ATI_Currency__c = 'USD';
        distributorAccount[0].CurrencyIsoCode = 'USD';
        
        distributorAccount[0].ATI_Price_Group__c = '01';
        insert distributorAccount;
        
        List<WOD_2__Rates_Details__c> rateDetailsLst = new List<WOD_2__Rates_Details__c>();
        //Labor RateDetails
        List<WOD_2__Rates_Details__c> laborRateDetails = TestDataFactory.createLaborRateDetails(1);
        laborRateDetails[0].WOD_2__Dealer__c = distributorAccount[0].id;
        laborRateDetails[0].WOD_2__Active_From__c = System.today().addDays(-365);
        laborRateDetails[0].WOD_2__Active_Until__c = System.today().addDays(365);
        rateDetailsLst.add(laborRateDetails[0]);
        insert rateDetailsLst;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        customerAccount[0].Country__c = 'India';
        customerAccount[0].BillingCountry = 'India';
        customerAccount[0].ATI_Currency__c = 'INR';
        customerAccount[0].CurrencyIsoCode = 'INR';
        insert customerAccount;
        
        //BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        
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
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(1);
        Integer count=1;
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
            wp.Name = 'R29545503'+count;
            wp.WOD_2__Units_Of_Measure__c = 'ea';
            count++;
        }
        insert warrantyProPartLst;
        
        //Create WarrantyProductPriceBook
        Id partCostRTId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Price').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,warrantyProPartLst[0].Id);
        wpPbLst[0].RecordTypeId = partCostRTId;
        wpPbLst[0].WOD_2__Price__c = 100;
        wpPbLst[0].WOD_2__Valid_From__c = System.today().addDays(-100);
        wpPbLst[0].WOD_2__Valid_Until__c = System.today().addDays(100);
        wpPbLst[0].ATI_Active__c = true;
        wpPbLst[0].ATI_Price_Group__c = '01';
        insert wpPbLst;
        
        //Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(2,'Stock');
        for(Integer i=0;i<invLst.size();i++){
            invLst[i].WOD_2__Account__c = distributorAccount.get(0).Id;
            invLst[i].WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
            invLst[i].WOD_2__Item__c = warrantyProLst.get(2).Id;
            invLst[i].Wod_2__Manufacturing_Date__c = Date.today();
        }
        insert invLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(3);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-365);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Type__c = 'Standard';
        }
        policyDefLst[1].WOD_2__Type__c = 'Extended';
        policyDefLst[2].WOD_2__Sub_Type__c = '01';
        insert policyDefLst;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(3,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
        applicabilityTermsLst[0].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        applicabilityTermsLst[1].WOD_2__Policy_Definition__c = policyDefLst[1].Id;
        applicabilityTermsLst[1].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        applicabilityTermsLst[2].WOD_2__Policy_Definition__c = policyDefLst[2].Id;
        insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(2,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;
        
        standardCriteriaLst[1].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        standardCriteriaLst[1].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        standardCriteriaLst[1].WOD_2__Field_Type__c = 'BOOLEAN';
        standardCriteriaLst[1].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[1].WOD_2__Criteria_Value__c =  'FALSE';
        standardCriteriaLst[1].WOD_2__Sequence__c = 2;
        insert standardCriteriaLst;
        
        //Extended ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> extendedCriteriaLst = TestDataFactory.createApplicabilityCriterias(2,applicabilityTermsLst.get(1));
        extendedCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        extendedCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        extendedCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        extendedCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        extendedCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        extendedCriteriaLst[0].WOD_2__Sequence__c = 1;
        
        extendedCriteriaLst[1].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        extendedCriteriaLst[1].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        extendedCriteriaLst[1].WOD_2__Field_Type__c = 'BOOLEAN';
        extendedCriteriaLst[1].WOD_2__Operator__c = 'EQUALS';
        extendedCriteriaLst[1].WOD_2__Criteria_Value__c =  'FALSE';
        extendedCriteriaLst[1].WOD_2__Sequence__c = 2;
        insert extendedCriteriaLst; 
        //..
        list<WOD_2__Warranty_Code__c> vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c LIMIT 1]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode[0].id;
            invMap.values().get(i).WOD_2__Type__c = 'Retail';
        }
        update invMap.values();
        
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='01'];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode[0].id;
            wrLst[i].WOD_2__Customer__c = customerAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_Pre_Delivery__c = true;
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
        
        //create Warranty Code
        List<WOD_2__Warranty_Code__c> warCodeLst = new List<WOD_2__Warranty_Code__c>();
        //create Diagnostic Codes
        List<WOD_2__Warranty_Code__c> warrantyDiagnosticCodeLst = TestDataFactory.createWarrantyCode(2,'Diagnostics Codes');
        warrantyDiagnosticCodeLst[0].Name='7437';
        warrantyDiagnosticCodeLst[1].Name='7438';
        warCodeLst.addAll(warrantyDiagnosticCodeLst);
        
        //create Labor Operation Codes
        List<WOD_2__Warranty_Code__c> warrantyJobCodeLst = TestDataFactory.createWarrantyCode(1,'Labor Operations Codes');
        warrantyJobCodeLst[0].Name='00010000';
        warrantyJobCodeLst[0].WOD_2__Standard_Labor_Hour__c = 2;
        warCodeLst.addAll(warrantyJobCodeLst);
        insert warCodeLst;
        
        List<WOD_2__Warranty_Product__c> wpList = [SELECT Id FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Model'];
        warrantyProLst[2].WOD_2__Parent_Product__c=wpList[0].Id;
        update warrantyProLst[2];
        
        List<WOD_2__Group__c> gpLst = TestDataFactory.createGroup(1);
        for(WOD_2__Group__c gpObj : gpLst){
            gpObj.WOD_2__Object_Name__c = 'WOD_2__Warranty_Product__c';
        }
        insert gpLst;
        
        List<WOD_2__Group_Member__c> gpMemLst = TestDataFactory.createGroupMember(1,gpLst[0].Id);
        gpMemLst[0].WOD_2__Warranty_Product__c = wpList[0].Id;
        insert gpMemLst;
        
        //Create FaultCodeMappers
        WOD_2__FaultCode_Mapper__c fcmObj = new WOD_2__FaultCode_Mapper__c(Name='TestFCM',WOD_2__Code__c=warrantyJobCodeLst[0].Id,
                                                                           WOD_2__Group__c=gpLst[0].Id,WOD_2__Status__c=true);
        insert fcmObj;
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeList = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeList;
        
        //create machine claim
        Id machineRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
        //Added by Susmitha ALSN-25
        Id campaignClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
        Id claimTemplateRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Claim_Template').getRecordTypeId();
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.CurrencyISOCode = 'USD';
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Account__c = invMap.values().get(0).WOD_2__Account__c;
            claimObj.WOD_2__Inventory__c = invMap.values().get(0).id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'SN001';
            claimObj.ATI_Technician_Name__c='Test';
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeList[0].id;
        }
        claimLst[0].RecordTypeId = machineRecordTypeId;
        claimLst[0].WOD_2__Claim_Type__c = 'Machine';
        claimLst[0].ATI_Tracking_Number__c = '600011531';
        claimLst[1].RecordTypeId = campaignClaimId;
        claimLst[1].WOD_2__Claim_Type__c = 'Campaign';
        insert claimLst;
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        installedClaimParts[0].WOD_2__Claim__c = claimLst[0].Id;
        installedClaimParts[0].WOD_2__Warranty_Product__c = warrantyProLst[2].Id;
        insert installedClaimParts;
        /*
        List<WOD_2__Claim_Service_Information__c> claimServices = TestDataFactory.createClaimServices(1);
        claimServices[0].WOD_2__Service_Job_Code__c = warrantyJobCodeLst[0].Id;
        claimServices[0].WOD_2__Claim__c = claimLst[0].Id; 
        claimServices[0].WOD_2__Total_Labor_Minutes__c = 20;
        insert claimServices;
        
        List<WOD_2__Other_Cost__c> otherCosts = TestDataFactory.createOtherCostCategoryItems(1);
        otherCosts[0].WOD_2__Claim__c = claimLst[0].Id;
        otherCosts[0].WOD_2__Cost_Category_Type__c = 'Overtime';
        insert otherCosts[0];
        */
        ATI_Diagnostic_Code__c diagnosticCode = new ATI_Diagnostic_Code__c();
        diagnosticCode.Claim__c = claimLst[0].id;
        diagnosticCode.Warranty_Code__c = warrantyDiagnosticCodeLst[0].id;
        insert diagnosticCode;
        
        List<twodcms__Service_Campaign__c> serviceCampaignLst = TestDataFactory.createServiceCampaign(1,busCategoryConfig.get(0).id);
        serviceCampaignLst[0].Name = 'SC001';
        insert serviceCampaignLst;
        
        //CampaignMembers
        twodcms__Campaign_Members__c campaignMembers = TestDataFactory.createCampaignMembers(invMap.values().get(0).id,serviceCampaignLst.get(0).Id);
        campaignMembers.Name = invLst.get(0).Name;
        insert campaignMembers;
        
        Id claimTempRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Claim_Template').getRecordTypeId();
        List<WOD_2__Claim__c> claimTemplateLst = TestDataFactory.createClaim(1);
        for(WOD_2__Claim__c claimObj : claimTemplateLst){
            claimObj.CurrencyISOCode = 'USD';
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.RecordTypeId = claimTempRecordTypeId;
            claimObj.WOD_2__Claim_Type__c = 'Claim Template';
            claimObj.WOD_2__Is_Template__c = true;
            }
         try{
         insert claimTemplateLst;}catch(exception e){}
       
        //create Failure Codes
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createWarrantyCode(1,'Failure Codes');
        warrantyFaultCodeLst[0].Name='AB07';
        warCodeLst.addAll(warrantyFaultCodeLst);
        
        //301 &302 Commented by susmitha ALSN-25
        //twodcms__Campaign_Claim_Template_Association__c campaignClaimTempAssc = TestDataFactory.createCampaignClaimTempAss(claimTemplateLst[0].id,serviceCampaignLst.get(0).Id,paymentDefLst.get(0).Id);
        //insert campaignClaimTempAssc; 
        
        serviceCampaignLst[0].twodcms__Status__c = 'Active';
        update serviceCampaignLst;
    }
    
     private static testmethod void testBulkClaimInsertion(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Retail']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        Account customerAccs = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Claim Type":"Machine","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Business Partner":"'+invMap.values().get(i).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
            //jsonArray += '"Causal Part Serial Number":"Test Customer","Comments":"","Complaint Code":"","Compliant Code Comments":"","Billing City":"Bangalore","Billing Street":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Customer Phone":"3453213","Customer Name":"TestCustomer","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[{"Name":"00010000","WOD_2__Total_Labor_Hours__c":"4","WOD_2__Reason_Additional_Labor_Hour__c":"Test"}],"Claim Number":"",';
            jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
            jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[{"Name":"'+warrantyPro.Name+'","WOD_2__Invoice_Quantity__c":"1"}],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
            jsonArray += '"Repair Order Number":"12343","Work Performed Comments":"Test","Tracking Number":"600011531000"}';
            //jsonArray += '}';
            if(i != invMap.size()-1){
                jsonArray+=','; 
            }
        }
        jsonArray +=']';    
        System.debug('>>>>jsonArray :  - '+jsonArray);
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        ATI_BulkClaimService bulkClaim = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        //Added by Susmitha
        //bulkClaim.processCustomerInfo(customerAccs);
        Test.stopTest();
        //List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id IN:invMap.keySet() AND WOD_2__Type__c='Retail'];
        //System.assert(invLst.size()==5);
        //Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Standard Registration']);
       // System.assertEquals(5,wrMap.size(),'Number Of Standard WarrantyRegistrations are Inserted!!!');
        //List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
       // System.assertEquals(5,wcLst.size(),'Number Of Standard Warranties are Inserted!!!');
          
       // WOD_2.ResponseWrapper configWrapper1 = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload'); // WarrantyRegUpload
        //System.assert(configWrapper.status == true);
      //  WOD_2.ResponseWrapper batchLogWrapper1 = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv'); //BulkWRUploadSample.csv
      //  System.assert(batchLogWrapper.status == true);  
      //  String jsonArray1 = '[';  
    }
    
    //ALSN-25 Start
    private static testmethod void testProcessCustomerInfo(){
        WOD_2__Claim__c claimObj = [SELECT Id,Name,WOD_2__Claim_Status__c,ATI_Tracking_Number__c FROM WOD_2__Claim__c LIMIT 1];
        WOD_2__Warranty_Registration__c wrInfoObj = [SELECT Id,Name,WOD_2__Status__c,WOD_2__Inventory__c from WOD_2__Warranty_Registration__c LIMIT 1];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Customer__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Retail']);
        Account customerInfo = [Select Id,Name,BillingCity,BillingPostalCode,ATI_Primary_Email_Id__c,BillingStreet,Phone,AccountNumber,BillingState,BillingCountry from Account where WOD_2__Warranty_Account_Type__c = 'Customer'];
        customerInfo.BillingCountry = 'CA';
        if(invMap.size()>0){
        invMap.values()[0].WOD_2__Customer__c = customerInfo.Id;
        //invMap.values()[0].WOD_2__Customer__c = NULL;
        update invMap.values()[0];}else{}
        wrInfoObj.WOD_2__Status__c = 'Draft';
        wrInfoObj.ATI_Pre_Delivery__c = true;
        try{
        ATI_BulkClaimService.processCustomerInfo(customerInfo);
        ATI_BulkClaimService.processWarrantyRegistration(claimObj,customerInfo,wrInfoObj);
        }catch(exception e){}
    }
    /*
    private static testmethod void testSaveOtherCosts(){
    List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
          accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;
            accLst[i].Public_Group_Id__c = '00G05000000v4ufEAA'+i;    
        }
        insert accLst;
    List<WOD_2__Other_Cost__c> ocList = [select id,WOD_2__Claim__c,WOD_2__Cost_Category_Type__c from WOD_2__Other_Cost__c];
    list<WOD_2__Claim__c> claimObj = [SELECT Id,Name,WOD_2__Claim_Status__c,WOD_2__Account__c,WOD_2__Account__r.Public_Group_Id__c,ATI_Tracking_Number__c FROM WOD_2__Claim__c LIMIT 1];
    claimObj[0].WOD_2__Account__r.Public_Group_Id__c = '12345678';
    claimObj[0].WOD_2__Account__c = accLst[0].Id;
    update claimObj[0];
    system.debug('claimObjPublicGroup-->'+claimObj[0].WOD_2__Account__r.Public_Group_Id__c);
    ocList[0].WOD_2__Claim__c = claimObj[0].Id;
    update ocList;
     try{   
    ATI_BulkClaimService.saveOtherCosts(ocList,claimObj[0]);}catch(exception e){}
    }*/
    //ALSN-25 End  
      
    private static testmethod void testBulkClaimUpdate(){
        WOD_2__Claim__c claimObj = [SELECT Id,Name,WOD_2__Claim_Status__c,ATI_Tracking_Number__c FROM WOD_2__Claim__c LIMIT 1]; 
        System.assertEquals(true,claimObj.Name !=NULL);
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Retail']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        jsonArray = '[';
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Claim Type":"Machine","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Business Partner":"'+invMap.values().get(i).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
            //jsonArray += '"Causal Part Serial Number":"Test Customer","Comments":"","Complaint Code":"","Compliant Code Comments":"","Billing City":"Bangalore","Billing Street":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Customer Phone":"2343212","Customer Name":"TestCustomer","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[{"Name":"00010000","WOD_2__Total_Labor_Hours__c":"4","WOD_2__Reason_Additional_Labor_Hour__c":""}],"Claim Number":"'+claimObj.Name+'",';
            jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
            jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[{"Name":"'+warrantyPro.Name+'","WOD_2__Invoice_Quantity__c":"1"}],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
            jsonArray += '"Repair Order Number":"13443","Work Performed Comments":"Test","Tracking Number":"600011531","Tracking Number":"600011531"}';
            //jsonArray += '}';
            if(i != invMap.size()-1){
                jsonArray+=','; 
            }
        }
        jsonArray +=']';  
        WOD_2.ResponseWrapper responseData1 = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData1.status == true);
        //Test.startTest();
        ATI_BulkClaimService bulkClaim1 = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper1 = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        //Test.stopTest();
    }
    
    private static testmethod void testBulkPartClaimInsert(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Retail']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        jsonArray = '[';
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Claim Type":"Part","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Business Partner":"'+invMap.values().get(i).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
            //jsonArray += '"Causal Part Serial Number":"Test Customer","Comments":"","Complaint Code":"","Compliant Code Comments":"","Billing City":"Bangalore","Billing Street":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Customer Phone":"Test Customer","Customer Name":"TestCustomer","Date of Purchase":"'+Date.today().format()+'","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[{"Name":"00010000","WOD_2__Total_Labor_Hours__c":"2","WOD_2__Reason_Additional_Labor_Hour__c":"Test"}],"Claim Number":"",';
            jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
            jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[{"Name":"'+warrantyPro.Name+'","WOD_2__Invoice_Quantity__c":"1"}],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
            jsonArray += '"Repair Order Number":"12342","Work Performed Comments":"Test","Tracking Number":"60001153100"}';
            //jsonArray += '}';
            if(i != invMap.size()-1){
                jsonArray+=','; 
            }
        }
        jsonArray +=']';  
        WOD_2.ResponseWrapper responseData1 = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData1.status == true);
        //Test.startTest();
        ATI_BulkClaimService bulkClaim1 = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper1 = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        //Test.stopTest();
    }
    
    private static testmethod void testBulkStockClaim(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Stock']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Claim Type":"Machine","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Business Partner":"'+invMap.values().get(i).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
            //jsonArray += '"Causal Part Serial Number":"Test Customer","Comments":"","Complaint Code":"","Compliant Code Comments":"","Billing City":"Bangalore","Billing Street":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Customer Phone":"3453213","Customer Name":"TestCustomer","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[{"Name":"00010000","WOD_2__Total_Labor_Hours__c":"2","WOD_2__Reason_Additional_Labor_Hour__c":"Test"}],"Claim Number":"",';
            jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
            jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[{"Name":"'+warrantyPro.Name+'","WOD_2__Invoice_Quantity__c":"1"}],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
            jsonArray += '"Repair Order Number":"12343","Work Performed Comments":"Test","Tracking Number":"60001153101"}';
            //jsonArray += '}';
            if(i != invMap.size()-1){
                jsonArray+=','; 
            }
        }
        jsonArray +=']';    
        System.debug('>>>>jsonArray :  - '+jsonArray);
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        ATI_BulkClaimService bulkClaim = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
    }
    
    private static testmethod void testBulkCampaignClaim(){
        List<WOD_2__Claim__c> claimTempalteLst = [SELECT Id,Name FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Claim Template'];
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Stock']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        //Added below If condition by Susmitha ALSN-25
        if(claimTempalteLst.size()>0){
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"TestINV-1","Claim Type":"Campaign","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Business Partner":"'+invMap.values().get(i).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
            //jsonArray += '"Causal Part Serial Number":"Test Customer","Comments":"","Complaint Code":"","Compliant Code Comments":"","Billing City":"Bangalore","Billing Street":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Customer Phone":"3453213","Customer Name":"TestCustomer","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"AB07","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[],"Claim Number":"",';
            jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
            jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
            jsonArray += '"Repair Order Number":"12343","Work Performed Comments":"Test","Claim Template Name":"'+claimTempalteLst[0].Name+'","Service Campaign Name":"SC001","Tracking Number":"6000115302"}';
            //jsonArray += '}';
            if(i != invMap.size()-1){
                jsonArray+=','; 
            }
        }
        }
        jsonArray +=']';    
        System.debug('>>>>jsonArray :  - '+jsonArray);
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        ATI_BulkClaimService bulkClaim = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
    }
     private static testmethod void testBulkCampaignClaimError(){
        List<WOD_2__Claim__c> claimTempalteLst = [SELECT Id,Name FROM WOD_2__Claim__c WHERE WOD_2__Claim_Type__c='Claim Template'];
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Stock']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        //Added below If condition by Susmitha ALSN-25
        if(claimTempalteLst.size()>0){
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(0).WOD_2__Serial_Number__c+'","Claim Type":"Campaign","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Business Partner":"'+invMap.values().get(i).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
            //jsonArray += '"Causal Part Serial Number":"Test Customer","Comments":"","Complaint Code":"","Compliant Code Comments":"","Billing City":"Bangalore","Billing Street":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Customer Phone":"3453213","Customer Name":"TestCustomer","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"AB07","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[],"Claim Number":"",';
            jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
            jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
            jsonArray += '"Repair Order Number":"12343","Work Performed Comments":"Test","Claim Template Name":"'+claimTempalteLst[0].Name+'","Service Campaign Name":"SC001","Tracking Number":"6000115302"}';
            //jsonArray += '}';
            if(i != invMap.size()-1){
                jsonArray+=','; 
            }
        }
        }
        jsonArray +=']';    
        System.debug('>>>>jsonArray :  - '+jsonArray);
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        ATI_BulkClaimService bulkClaim = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
    }
    private static testmethod void testBulkClaimSubmittalBatch(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');//ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');//ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        
        WOD_2__Claim__c claimObj = [SELECT Id,Name,WOD_2__Claim_Status__c FROM WOD_2__Claim__c LIMIT 1]; 
        ATI_BatchLogResults batchLogResultsObj = new ATI_BatchLogResults();
        batchLogResultsObj.successRecordIdsSet = new Set<Id>{claimObj.Id};
        batchLogResultsObj.failedRecords = ''; 
        
        List<ATI_Bulk_Upload_Configuration__mdt> bulkUploadConfigLst = new List<ATI_Bulk_Upload_Configuration__mdt>();
        ATI_BulkUploadConfiguration bulkUploadConfigMdt = new ATI_BulkUploadConfiguration();
        List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
        bulkUploadConfigLst =  Database.query('SELECT Id,ATI_Class_Override_Setting__r.WOD_2__ClassName__c,ATI_Object_API_Name__c,ATI_Community_Name__c,ATI_Process_Type__c,(SELECT Id,ATI_Field_API_Name__c,ATI_Object_API_Name__c,ATI_Column_Name__c,ATI_Reference_Field_API_Name__c,ATI_IsMandatory__c,ATI_Reference_Object_API_Name__c,ATI_Type__c,ATI_Display_Name__c,ATI_Reference_BU_Name__c FROM ATI_Bulk_Upload_Field_Mappings__r) FROM ATI_Bulk_Upload_Configuration__mdt WHERE ATI_Process_Type__c =\'ClaimUpload\'');
            if(!bulkUploadConfigLst.isEmpty() && !bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r.isEmpty()){ //&& !Test.isRunningTest()
                bulkUploadConfigMdt.classOverrideName = bulkUploadConfigLst[0].ATI_Class_Override_Setting__r.WOD_2__ClassName__c;
                bulkUploadConfigMdt.objectApiNameStr = bulkUploadConfigLst[0].ATI_Object_API_Name__c;
                bulkUploadConfigMdt.communityName = bulkUploadConfigLst[0].ATI_Community_Name__c;
                bulkUploadConfigMdt.processType   = bulkUploadConfigLst[0].ATI_Process_Type__c;
                for(ATI_Bulk_Upload_Field_Mapping__mdt objBulkUploadFieldMap : bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r) {
                    ATI_BulkUploadFieldMapping objFieldMapping = new ATI_BulkUploadFieldMapping();
                    objFieldMapping.fieldAPIName = objBulkUploadFieldMap.ATI_Field_API_Name__c;
                    objFieldMapping.objectAPIName = objBulkUploadFieldMap.ATI_Object_API_Name__c;
                    objFieldMapping.columnName = objBulkUploadFieldMap.ATI_Column_Name__c;
                    objFieldMapping.isMandatory = objBulkUploadFieldMap.ATI_IsMandatory__c;
                    objFieldMapping.referenceFieldAPIName = objBulkUploadFieldMap.ATI_Reference_Field_API_Name__c;
                    objFieldMapping.referenceObjectAPIName = objBulkUploadFieldMap.ATI_Reference_Object_API_Name__c;
                    objFieldMapping.type = objBulkUploadFieldMap.ATI_Type__c;
                    objFieldMapping.displayName = objBulkUploadFieldMap.ATI_Display_Name__c;
                    objFieldMapping.referenceBUName = objBulkUploadFieldMap.ATI_Reference_BU_Name__c;
                    bulkUploadFieldMappingLst.add(objFieldMapping);
                } 
            }   
        
        ATI_BulkClaimUploadSubmittalBatch validateClaimSubmittalBatch =
            new ATI_BulkClaimUploadSubmittalBatch(successResult[0].Id,batchLogResultsObj,bulkUploadConfigMdt,
                                                  new List<String>{'test','test1'},bulkUploadFieldMappingLst);
        Test.startTest();
        Database.executeBatch(validateClaimSubmittalBatch,1); 
        Test.stopTest();
    }
    
    private static testmethod void testBulkClaimUpdateErrors(){
        WOD_2__Claim__c claimObj = [SELECT Id,Name,WOD_2__Claim_Status__c,ATI_Tracking_Number__c FROM WOD_2__Claim__c LIMIT 1]; 
        System.assertEquals(true,claimObj.Name !=NULL);
        claimObj.WOD_2__Claim_Status__c = 'Approved';
        update claimObj;
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('ClaimUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        
        WOD_2.ResponseWrapper batchLogWrapper1 = ATI_BulkUploadController.createBatchLog('ClaimUpload','','ClaimUpload','BulkClaimUploadSample.csv');
        System.assert(batchLogWrapper1.status == true);
        Database.SaveResult[] successResult1 = (Database.SaveResult[])JSON.deserialize(batchLogWrapper1.data,Database.SaveResult[].class);
        
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c,WOD_2__Account__c,WOD_2__Account__r.SAP_ID__c FROM WOD_2__Inventory__c WHERE WOD_2__Type__c='Retail']);
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invMap.values().size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invMap.values().get(i).Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(i).id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c LIMIT 1];
        WOD_2__Warranty_Product__c warrantyPro = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c='Part' LIMIT 1];
        jsonArray = '[';
        jsonArray += '{"Serial Number":"'+invMap.values().get(0).WOD_2__Serial_Number__c+'","Claim Type":"Machine","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
        jsonArray += '"Business Partner":"'+invMap.values().get(0).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
        jsonArray += '"Customer Phone":"2343212","Customer Name":"TestCustomer","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[],"Claim Number":"'+claimObj.Name+'",';
        jsonArray += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
        jsonArray += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[{"Name":"'+warrantyPro.Name+'","WOD_2__Invoice_Quantity__c":"1"}],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
        jsonArray += '"Repair Order Number":"13443","Work Performed Comments":"Test","Tracking Number":"600011531"}';
        jsonArray +=']';
        
        String jsonArray1 = '[';
        jsonArray1 += '{"Serial Number":"'+invMap.values().get(0).WOD_2__Serial_Number__c+'","Claim Type":"Machine","Last Labor Applied Date":"'+Date.today().format()+'","In-Service Date":"'+Date.today().format()+'","Repair Order Open Date":"'+Date.today().format()+'","Primary Failed Part":"'+warrantyPro.Name+'","Vocation Code":"'+vocationCode.Name+'",';
        jsonArray1 += '"Business Partner":"'+invMap.values().get(0).WOD_2__Account__r.SAP_ID__c+'","Vehicle Mileage (Usage)":"10","VIN":"1J4GL58K96W180703","Vehicle Make":"Allison","Vehicle Model":"VM-2020",';
        jsonArray1 += '"Customer Phone":"2343212","Billing Country":"","Customer Name":"TestCustomer","Transmission Replaced?":"true","Date of Purchase":"","DiagnosticCode":[{"Warranty_Code__c":"7437"}],"Failure Code":"","Failure Code Comments":"","Failure Location":"","Host-NonHost":"","Labor":[],"Claim Number":"'+claimObj.Name+'",';
        jsonArray1 += '"OtherCost":[{"WOD_2__Cost_Category_Type__c":"Duty","WOD_2__Rate_PerUnit__c":"10","WOD_2__UnitsUsage__c":"1","WOD_2__Comments__c":"Test"}],"Part Number":"","Part Serial Number":"","Pre-Authorization Comments":"","Pre-Authorization Required":"","Pre-Delivery":"","Technician Name":"Test",';
        jsonArray1 += '"Units Usage":"10","Usage Type":"","Customer asset number":"","Parts":[{"Name":"'+warrantyPro.Name+'","WOD_2__Invoice_Quantity__c":"1"}],"Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"","Vehicle usage by Hr":"",';
        jsonArray1 += '"Repair Order Number":"13443","Work Performed Comments":"Test","Tracking Number":"600011532"}';
        jsonArray1 +=']';
        
        WOD_2.ResponseWrapper responseData1 = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData1.status == true);
        WOD_2.ResponseWrapper responseData2 = ATI_BulkUploadController.uploadChunks(jsonArray1,successResult1.get(0).getId());
        System.assert(responseData2.status == true);
        
        Test.startTest();
        ATI_BulkClaimService bulkClaim1 = New ATI_BulkClaimService();
        WOD_2.ResponseWrapper batchResponseWrapper1 = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        WOD_2.ResponseWrapper batchResponseWrapper2 = ATI_BulkUploadController.callBatchJobToInsert(successResult1.get(0).getId());
        Test.stopTest();
    }
}