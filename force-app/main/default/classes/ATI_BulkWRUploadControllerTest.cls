/* Name: ATI_BulkWRUploadControllerTest
Description : Test Class for ATI_BulkUploadBatch,ATI_BulkWRUploadController and ATI_BulkWarrantyRegistrationService
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE               	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       Jan 08th 2021		INITIAL DEVELOPMENT                           
*/
@isTest
public class ATI_BulkWRUploadControllerTest {
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
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(5,'Stock');
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
        ewpLst[0].ATI_Warranty_Product__c = warrantyProLst.get(2).WOD_2__Parent_Product__c;
        ewpLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).Id;
        ewpLst[0].ATI_Country__c = 'United States';
        insert ewpLst;
        Test.stopTest();
    }
    
    /*private static testmethod void testWRBulkUploadForStandardWR(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c]);
        
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
        
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().format()+'","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"1J4GL58K96W180703","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"10","Vehicle usage by Hr":"","Vehicle Make":"Allison","Vehicle Model":"VM-2020","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"Test Customer","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
            jsonArray += '"Extended Warranty Policy Name":"","Extended Warranty Purchase Date":""}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id IN:invMap.keySet() ];
        system.debug('invLst'+invLst);
        System.assert(invLst.size()==5);
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c ]);
        //System.assertEquals(5,wrMap.size(),'Number Of Standard WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
        System.assertEquals(5,wcLst.size(),'Number Of Standard Warranties are Inserted!!!');
    }*/
    
    private static testmethod void testWRBulkUploadForStandardWithExtendedWR(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c]);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().format()+'","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"1J4GL58K96W180703","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"10","Vehicle usage by Hr":"","Vehicle Make":"Allison","Vehicle Model":"VM-2020","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"'+customerAcc.Name+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
            jsonArray += '"Extended Warranty Policy Name":"'+extendedPolicyDef.Name+'","Extended Warranty Purchase Date":"'+Date.today().format()+'"}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id IN:invMap.keySet() AND WOD_2__Type__c='Retail'];
        //System.assert(invLst.size()==5);
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Standard Registration' AND ATI_isExtended__c=true]);
        //System.assertEquals(5,wrMap.size(),'Number Of Extended WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet() AND WOD_2__Policy_Definition__r.WOD_2__Type__c='Extended'];
       // System.assertEquals(5,wcLst.size(),'Number Of Extended Warranties are Inserted!!!');
    }
    
    
    private static testmethod void testWRBulkUploadForExtendedWR(){
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
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
        
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = customerAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
        
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id,ATI_Active_From__c,ATI_Active_Until__c,ATI_Warranty_Product__c,ATI_Vocation_Code__c FROM ATI_Extended_Warranty_Pricing__c WHERE ATI_Policy_Definition__c=:extendedPolicyDef.Id];
        String jsonArray = '[';
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().format()+'","Standard Model":"","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"'+vehicleInfoLst.get(i).Name+'","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"'+vehicleInfoLst.get(i).ATI_Vehicle_Usage__c+'","Vehicle usage by Hr":"","Vehicle Make":"'+vehicleInfoLst.get(i).ATI_Vehicle_Make__c+'","Vehicle Model":"'+vehicleInfoLst.get(i).ATI_Vehicle_Model__c+'","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"'+customerAcc.Name+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
            jsonArray += '"PO Number":"R00118279301","Extended Warranty Policy Name":"'+extendedPolicyDef.Name+'","Extended Warranty Purchase Date":"'+Date.today().format()+'"}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id IN:invMap.keySet() AND WOD_2__Type__c='Retail'];
        System.assert(invLst.size()==5);
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Extended']);
        //System.assertEquals(5,wrMap.size(),'Number Of Extended WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
        //System.assertEquals(5,wcLst.size(),'Number Of Extended Warranties are Inserted!!!');
    }
    
    /*private static testmethod void testWRBulkUploadForReRegistration(){
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
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
        
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
            wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = customerAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
        
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id,ATI_Active_From__c,ATI_Active_Until__c,ATI_Warranty_Product__c,ATI_Vocation_Code__c FROM ATI_Extended_Warranty_Pricing__c WHERE ATI_Policy_Definition__c=:extendedPolicyDef.Id];
        String jsonArray = '[';
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().addDays(20).format()+'","Standard Model":"","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"'+vehicleInfoLst.get(i).Name+'","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"'+vehicleInfoLst.get(i).ATI_Vehicle_Usage__c+'","Vehicle usage by Hr":"","Vehicle Make":"'+vehicleInfoLst.get(i).ATI_Vehicle_Make__c+'","Vehicle Model":"'+vehicleInfoLst.get(i).ATI_Vehicle_Model__c+'","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"'+customerAcc.Name+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
            jsonArray += '"Extended Warranty Policy Name":"'+extendedPolicyDef.Name+'","Extended Warranty Purchase Date":"'+Date.today().format()+'"}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Status__c='InActive']);
        System.assertEquals(5,wrMap.size(),'Number Of Deactivated WarrantyRegistrations are Inserted!!!');
        Map<Id,WOD_2__Warranty_Registration__c> wrMap2 = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Status__c='Registered']);
        System.assertEquals(5,wrMap2.size(),'Number Of ReRegistrations WarrantyRegistrations are Inserted!!!');
        
    }*/
    
    private static testmethod void testWRBulkUploadForC2C(){
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
             invMap.values().get(i).WOD_2__Customer__c = customerAcc.Id;
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
            wrLst[i].WOD_2__Customer__c = customerAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
        
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id,ATI_Active_From__c,ATI_Active_Until__c,ATI_Warranty_Product__c,ATI_Vocation_Code__c FROM ATI_Extended_Warranty_Pricing__c WHERE ATI_Policy_Definition__c=:extendedPolicyDef.Id];
        String jsonArray = '[';
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().format()+'","Standard Model":"","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"'+vehicleInfoLst.get(i).Name+'","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"'+vehicleInfoLst.get(i).ATI_Vehicle_Usage__c+'","Vehicle usage by Hr":"","Vehicle Make":"'+vehicleInfoLst.get(i).ATI_Vehicle_Make__c+'","Vehicle Model":"'+vehicleInfoLst.get(i).ATI_Vehicle_Model__c+'","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"'+customerAcc.Name+'Test'+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
            jsonArray += '"Extended Warranty Policy Name":"'+extendedPolicyDef.Name+'","Extended Warranty Purchase Date":"'+Date.today().format()+'"}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        List<WOD_2__Inventory_Transaction_History__c> invTnsHistoryLst = [SELECT Id FROM WOD_2__Inventory_Transaction_History__c WHERE WOD_2__Inventory__c IN:invMap.keySet()];
       // System.assertEquals(5,invTnsHistoryLst.size(),'Number Of ITH are Created!!!');
    }
    
    /*private static testmethod void testWRBulkUploadForPreDeliveryWR(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c]);
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Account Name":"'+acc.Name+'","Usage Type":"","In-Service Date":"","Standard Model":"","Pre-Delivery":"TRUE","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"1J4GL58K96W180703","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"10","Vehicle usage by Hr":"","Vehicle Make":"Allison","Vehicle Model":"VM-2020","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"'+customerAcc.Name+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
            jsonArray += '"Extended Warranty Policy Name":"","Extended Warranty Purchase Date":""}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        //List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id IN:invMap.keySet() AND WOD_2__Type__c='Stock'];
        //System.assert(invLst.size()==5);
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Pre-delivery' AND ATI_Pre_Delivery__c=TRUE]);
        //System.assertEquals(5,wrMap.size(),'Number Of Pre-Delivery WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
        //System.assertEquals(5,wcLst.size(),'Number Of Pre-Delivery Warranties are Inserted!!!');
    }*/
    
    private static testmethod void testWRBulkUploadForInvalidFileDetails(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"","Business Partner":"","Usage Type":"","In-Service Date":"","Standard Model":"","Pre-Delivery":"TRUE","Unit Usage":"","Vocation Code":"",';
            jsonArray += '"Customer asset number":"","VIN":"","Vehicle Usage Unit":"","Vehicle Mileage (Usage)":"","Vehicle usage by Hr":"","Vehicle Make":"Allison","Vehicle Model":"VM-2020","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"",';
            jsonArray += '"Extended Warranty Policy Name":"","Extended Warranty Purchase Date":""}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Standard Registration' AND ATI_Pre_Delivery__c=TRUE]);
        System.assertEquals(0,wrMap.size(),'Number Of Pre-Delivery WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
        System.assertEquals(0,wcLst.size(),'Number Of Pre-Delivery Warranties are Inserted!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Success_Record_Count__c,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c WHERE Name='BulkWRUploadSample.csv'];
        System.assertEquals(0,batchLog.WOD_2__Success_Record_Count__c,'SuccessRecordCount!!!');
        System.assertEquals(invMap.size(),batchLog.WOD_2__Total_Record_Count__c,'FailedRecordCount!!!');
    }
    
    private static testmethod void testWRBulkUploadForInvalidVIN(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c LIMIT 1]);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        jsonArray += '{"Serial Number":"'+invMap.values().get(0).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"11/25/2020","Standard Model":"","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
        jsonArray += '"Customer asset number":"","VIN":"V-1","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"10","Vehicle usage by Hr":"","Vehicle Make":"Allison","Vehicle Model":"VM-2020","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
        jsonArray += '"Customer Name":"Test Customer","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"Bangalore","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"560095",';
        jsonArray += '"Extended Warranty Policy Name":"","Extended Warranty Purchase Date":""}]';
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Standard Registration']);
        //System.assertEquals(0,wrMap.size(),'Number Of WarrantyRegistrations are Inserted!!!');
    }
    
    private static testmethod void testWRBulkUploadForInvalidExtendedWRDetails(){
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c LIMIT 1]);
        invMap.values().get(0).WOD_2__Install_Date__c =  Date.today();
        invMap.values().get(0).ATI_Vocation_Code__c = vocationCode.id;
        invMap.values().get(0).WOD_2__Type__c = 'Retail';
        update invMap.values();
        
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(1);
        insert vehicleInfoLst;
        
        ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
        vehicleTransMapper.ATI_Inventory__c = invMap.values().get(0).Id;
        vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst.get(0).id;
        insert vehicleTransMapper;
        
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
        wrLst[0].WOD_2__Status__c = 'Registered';
        wrLst[0].WOD_2__Account__c = invMap.values().get(0).WOD_2__Account__c;
        wrLst[0].WOD_2__Registration_Type__c = 'Standard Registration';
        wrLst[0].WOD_2__Registration_Date__c = Date.today();
        wrLst[0].WOD_2__Install_Date__c = Date.today();
        wrLst[0].ATI_Vocation_Code__c = vocationCode.id;
        wrLst[0].WOD_2__Customer__c = customerAcc.Id;
        wrLst[0].WOD_2__Units_Usage__c = 10;
        wrLst[0].WOD_2__Warranty_Product__c = invMap.values().get(0).WOD_2__Item__c;
        wrLst[0].WOD_2__Inventory__c = invMap.values().get(0).Id;
        insert wrLst;
        
        WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(0).id,
                                                                           WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
        insert wc;
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id,ATI_Active_From__c,ATI_Active_Until__c,ATI_Warranty_Product__c,ATI_Vocation_Code__c FROM ATI_Extended_Warranty_Pricing__c WHERE ATI_Policy_Definition__c=:extendedPolicyDef.Id];
        String jsonArray = '[';
        jsonArray += '{"Serial Number":"'+invMap.values().get(0).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().format()+'","Standard Model":"","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
        jsonArray += '"Customer asset number":"","VIN":"'+vehicleInfoLst.get(0).Name+'","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"20","Vehicle usage by Hr":"","Vehicle Make":"'+vehicleInfoLst.get(0).ATI_Vehicle_Make__c+'","Vehicle Model":"'+vehicleInfoLst.get(0).ATI_Vehicle_Model__c+'","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
        jsonArray += '"Customer Name":"Test Customer","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
        jsonArray += '"Extended Warranty Policy Name":"'+extendedPolicyDef.Name+'","Extended Warranty Purchase Date":"'+Date.today().format()+'"}]';            
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Extended']);
        System.assertEquals(0,wrMap.size(),'Number Of Extended WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
        System.assertEquals(0,wcLst.size(),'Number Of Extended Warranties are Inserted!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Success_Record_Count__c,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c WHERE Name='BulkWRUploadSample.csv'];
        System.assertEquals(0,batchLog.WOD_2__Success_Record_Count__c,'SuccessRecordCount!!!');
        System.assertEquals(1,batchLog.WOD_2__Total_Record_Count__c,'FailedRecordCount!!!');
    }
    
    private static testmethod void testWRBulkUploadForNoEWP(){
        WOD_2.ResponseWrapper configWrapper = ATI_BulkUploadController.fetchBulkUploadConfiguration('WarrantyRegUpload');
        System.assert(configWrapper.status == true);
        WOD_2.ResponseWrapper batchLogWrapper = ATI_BulkUploadController.createBatchLog('WarrantyRegUpload','','WarrantyRegUpload','BulkWRUploadSample.csv');
        System.assert(batchLogWrapper.status == true);
        Database.SaveResult[] successResult = (Database.SaveResult[])JSON.deserialize(batchLogWrapper.data,Database.SaveResult[].class);
        String jsonArray = '[';
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c LIMIT 1]);
        Account acc = [SELECT Id,Name,SAP_ID__c FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id FROM ATI_Extended_Warranty_Pricing__c];
        jsonArray += '{"Serial Number":"'+invMap.values().get(0).WOD_2__Serial_Number__c+'","Business Partner":"'+acc.SAP_ID__c+'","Usage Type":"","In-Service Date":"'+Date.today().format()+'","Standard Model":"","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
        jsonArray += '"Customer asset number":"","VIN":"1J4GL58K96W180703","Vehicle Usage Unit":"Mi","Vehicle Mileage (Usage)":"10","Vehicle usage by Hr":"","Vehicle Make":"Allison","Vehicle Model":"VM-2020","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
        jsonArray += '"Customer Name":"'+customerAcc.Name+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
        jsonArray += '"PO Number":"R00118279301","Extended Warranty Policy Name":"'+extendedPolicyDef.Name+'","Extended Warranty Purchase Date":"'+Date.today().format()+'"}]';              
        WOD_2.ResponseWrapper responseData = ATI_BulkUploadController.uploadChunks(jsonArray,successResult.get(0).getId());
        System.assert(responseData.status == true);
        Test.startTest();
        WOD_2.ResponseWrapper batchResponseWrapper = ATI_BulkUploadController.callBatchJobToInsert(successResult.get(0).getId());
        Test.stopTest();
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Standard Registration' AND ATI_isExtended__c=true]);
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet() AND ATI_isExtended__c=true];
        System.assertEquals(0,wcLst.size(),'Number Of Extended Warranties are Inserted!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Success_Record_Count__c,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c WHERE Name='BulkWRUploadSample.csv'];  
    }
}