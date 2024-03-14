@isTest
public class ATI_BulkWarrantyRegistrationServiceTest {
	
    @testSetup
    public static void testSetup(){
        Test.startTest();
        
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        distributorAccount[0].Country__c = 'United States';
        distributorAccount[0].BillingCountry = 'United States';
        distributorAccount[0].SAP_ID__c = '2198023102';
        insert distributorAccount;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
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
        
        //Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(1,'Stock');
        for(Integer i=0;i<invLst.size();i++){
            invLst[i].WOD_2__Account__c = distributorAccount.get(0).Id;
            invLst[i].WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
            invLst[i].WOD_2__Item__c = warrantyProLst.get(2).Id;
            invLst[i].Wod_2__Manufacturing_Date__c = Date.today();
            invLst[i].WOD_2__Customer__c = customerAccount.get(0).Id;
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
        
        
        //Pre-Delivery ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> preDeliveryCriteriaLst = TestDataFactory.createApplicabilityCriterias(1,applicabilityTermsLst.get(2));
        preDeliveryCriteriaLst[0].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        preDeliveryCriteriaLst[0].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        preDeliveryCriteriaLst[0].WOD_2__Field_Type__c = 'BOOLEAN';
        preDeliveryCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        preDeliveryCriteriaLst[0].WOD_2__Criteria_Value__c =  'TRUE';
        preDeliveryCriteriaLst[0].WOD_2__Sequence__c = 1;
        insert preDeliveryCriteriaLst;
        
        List<ATI_Extended_Warranty_Pricing__c> ewpLst = TestDataFactory.createExtendedWarrantyPricing(1);
        ewpLst[0].ATI_Active_From__c = Date.today().addDays(-365);
        ewpLst[0].ATI_Active_Until__c = Date.today().addDays(365);
        ewpLst[0].ATI_Policy_Definition__c = policyDefLst.get(1).Id;
        ewpLst[0].ATI_Program_Level__c = 'Program Level 0';
        ewpLst[0].ATI_Warranty_Product__c = warrantyProLst.get(0).WOD_2__Parent_Product__c;
        ewpLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).Id;
        ewpLst[0].ATI_Country__c = 'United States';
        insert ewpLst;
        Test.stopTest();
    }
    
    private static testmethod void testWRBulkUploadForExtendedWROne(){
        Account cusAcc = [SELECT Id,Name,AccountNumber,Phone,ATI_Primary_Email_Id__c,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Type='Customer'];
        WOD_2__Warranty_Product__c wp = [SELECT Id FROM WOD_2__Warranty_Product__c Limit 1];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Customer__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
            invMap.values().get(i).WOD_2__Customer__c = cusAcc.Id;
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
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = cusAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_PO_Number__c = 'R00118279301';
            wrLst[i].ATI_isExtended__c = false;
            wrLst[i].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;

        Test.startTest();
        	WOD_2.ResponseWrapper reswra = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(wrLst.get(0), vehicleInfoLst.get(0), cusAcc, warrantyCoverageLst[0], null) ;
        Test.stopTest();
    }
    private static testmethod void testWRBulkUploadForExtendedWRTwo(){
        Account cusAcc = [SELECT Id,Name,AccountNumber,Phone,ATI_Primary_Email_Id__c,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Type='Customer'];
        WOD_2__Warranty_Product__c wp = [SELECT Id FROM WOD_2__Warranty_Product__c Limit 1];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
            invMap.values().get(i).WOD_2__Customer__c = cusAcc.Id;
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
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Rejected';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Extended';
            wrLst[i].ATI_Pre_Delivery__c = true;
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = cusAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_PO_Number__c = 'R00118279301';
            wrLst[i].ATI_isExtended__c = true;
            wrLst[i].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;

        Test.startTest();
        	WOD_2.ResponseWrapper reswra = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(wrLst.get(0), vehicleInfoLst.get(0), cusAcc, warrantyCoverageLst[0], wp) ;
        Test.stopTest();
    }
    private static testmethod void testWRBulkUploadForExtendedWRThreeFutureInstallDate(){
        Account cusAcc = [SELECT Id,Name,AccountNumber,Phone,ATI_Primary_Email_Id__c,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Type='Customer'];
        WOD_2__Warranty_Product__c wp = [SELECT Id FROM WOD_2__Warranty_Product__c Limit 1];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
            invMap.values().get(i).WOD_2__Customer__c = cusAcc.Id;
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
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Rejected';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Extended';
            wrLst[i].ATI_Pre_Delivery__c = false;
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today()+1;
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = cusAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_PO_Number__c = 'R00118279301';
            wrLst[i].ATI_isExtended__c = true;
            wrLst[i].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;

        Test.startTest();
        	WOD_2.ResponseWrapper reswra = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(wrLst.get(0), vehicleInfoLst.get(0), cusAcc, warrantyCoverageLst[0], wp) ;
        Test.stopTest();
    }
    private static testmethod void testWRBulkUploadForExtendedWRFour(){
        Account cusAcc = [SELECT Id,Name,AccountNumber,Phone,ATI_Primary_Email_Id__c,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Type='Customer'];
        WOD_2__Warranty_Product__c wp = [SELECT Id FROM WOD_2__Warranty_Product__c Limit 1];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Customer__c,WOD_2__Customer__r.BillingPostalCode,WOD_2__Customer__r.Name,WOD_2__Customer__r.BillingCity,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
            invMap.values().get(i).WOD_2__Type__c = 'Retail';
            invMap.values().get(i).WOD_2__Customer__r.Name = 'TestAccount';
            invMap.values().get(i).WOD_2__Customer__r.BillingCity = 'TestCity';
            invMap.values().get(i).WOD_2__Customer__r.BillingPostalCode = '96707';
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
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = cusAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_PO_Number__c = 'R00118279301';
            wrLst[i].ATI_isExtended__c = false;
            wrLst[i].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;

        Test.startTest();
        	WOD_2.ResponseWrapper reswra = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(wrLst.get(0), vehicleInfoLst.get(0), cusAcc, warrantyCoverageLst[0], wp) ;
        Test.stopTest();
    }
    private static testmethod void testWRBulkUploadForExtendedWRFive(){
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        customerAccount[0].Name = 'TestAccount';
        customerAccount[0].BillingCity = 'TestCity';
        customerAccount[0].BillingPostalCode = '96707';
        insert customerAccount;
        Account cusAcc = [SELECT Id,Name,AccountNumber,Phone,ATI_Primary_Email_Id__c,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Type='Customer' AND Name = 'TestCustomer1'];
        WOD_2__Warranty_Product__c wp = [SELECT Id FROM WOD_2__Warranty_Product__c Limit 1];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Customer__c,WOD_2__Customer__r.BillingPostalCode,WOD_2__Customer__r.Name,WOD_2__Customer__r.BillingCity,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
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
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = cusAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_PO_Number__c = 'R00118279301';
            wrLst[i].ATI_isExtended__c = false;
            wrLst[i].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;

        Test.startTest();
        	WOD_2.ResponseWrapper reswra = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(wrLst.get(0), vehicleInfoLst.get(0), customerAccount[0], warrantyCoverageLst[0], null) ;
        Test.stopTest();
    }
        private static testmethod void testWRBulkUploadForExtendedWRSix(){
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        customerAccount[0].Name = 'TestAccount';
        customerAccount[0].BillingCity = '';
        customerAccount[0].BillingPostalCode = '';
        insert customerAccount;
                 Account cusAcc = [SELECT Id,Name,AccountNumber,Phone,ATI_Primary_Email_Id__c,BillingStreet,BillingState,BillingCity,BillingCountry,BillingPostalCode FROM Account WHERE Type='Customer' AND Name = 'TestCustomer1'];
        WOD_2__Warranty_Product__c wp = [SELECT Id FROM WOD_2__Warranty_Product__c Limit 1];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Customer__c,WOD_2__Customer__r.BillingPostalCode,WOD_2__Customer__r.Name,WOD_2__Customer__r.BillingCity,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
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
        
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = cusAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
            wrLst[i].ATI_PO_Number__c = 'R00118279301';
            wrLst[i].ATI_isExtended__c = false;
            wrLst[i].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
   
        Test.startTest();
        	WOD_2.ResponseWrapper reswra = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(wrLst.get(0), vehicleInfoLst.get(0), customerAccount[0], warrantyCoverageLst[0], null) ;
        Test.stopTest();
        }
}