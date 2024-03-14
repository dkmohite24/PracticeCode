@isTest(SeeAllData=false)
public class PRPC_DataUploadApexTest {
    @testSetup 
    private static void setup() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, false);
    }
	@isTest
    private static void findMetadataDetailsTest(){
        PRPC_DataUploadApex.findMetadataDetails('CE_DataUploadTest');
        
    }
    @isTest
    private static void insertRecordsTest(){
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        Account distributorBranch = new Account();
        distributorBranch = [SELECT Id, SAP_Id__c FROM Account WHERE Location_Type__c = 'DB' LIMIT 1];
        List<CE_Staging_Data__c> ceStagingDataList = new List<CE_Staging_Data__c>();
        CE_Staging_Data__c ceStagingData = new CE_Staging_Data__c();
        ceStagingData.Distributor_Ship_To__c = distributorBranch.SAP_Id__c;
        ceStagingData.Invoice_Amount__c = '4565.78';
        ceStagingData.Extraction_Date__c = '06/25/2020';
        ceStagingDataList.add(ceStagingData);
        
        List<PRPC_DataUploadApex.fieldDetailWrapper> fieldTypeList = new List<PRPC_DataUploadApex.fieldDetailWrapper>();
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType0 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType0.apiName = 'Extraction_Date__c';
        fieldType0.fieldLabel = 'Date';
        fieldType0.fieldType = 'DATE';
        fieldTypeList.add(fieldType0);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType1 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType1.apiName = 'Distributor_Ship_To__c';
        fieldType1.fieldLabel = 'Distributor or Dealer ship to';
        fieldType1.fieldType = 'REFERENCE';
        fieldTypeList.add(fieldType1);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType2 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType2.apiName = 'Product_Type__c';
        fieldType2.fieldLabel = 'Product Type';
        fieldType2.fieldType = 'String';
        fieldTypeList.add(fieldType2);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType3 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType3.apiName = 'Invoice_Amount__c';
        fieldType3.fieldLabel = 'Invoice Amount';
        fieldType3.fieldType = 'Currency';
        fieldTypeList.add(fieldType3);
        
        
        test.StartTest();
        PRPC_DataUploadApex.insertRecords(JSON.serialize(ceStagingDataList), 'TPS_Data__c',JSON.serialize(fieldTypeList), 'Test','CE Data Load');
        test.StopTest();
    }
    
    @isTest
    private static void insertRecordsAdminCustomerTest(){
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        Account distributorBranch = new Account();
        distributorBranch = [SELECT Id, SAP_Id__c FROM Account WHERE Location_Type__c = 'DB' LIMIT 1];
        
        
        List<End_Customer_Staging_Data__c> endCustomerList = new List<End_Customer_Staging_Data__c>();
        End_Customer_Staging_Data__c endCustomer = new End_Customer_Staging_Data__c();
        
        endCustomer.Date_Of_Submission__c = '06/25/2020';
        endCustomer.Distributor_Ship_To__c = distributorBranch.SAP_Id__c;
        endCustomer.Repair_Order__c = '98568986';
        endCustomer.Repair_Type__c = 'I';
        endCustomer.Parts_Invoice__c = 'cvyty';
        endCustomer.Customer_Name__c = 'Test Name';
        endCustomer.Customer_Address_1__c = 'Street Test';
        endCustomer.Customer_Address_2__c = 'Street Test';
        endCustomer.City__c = 'City Test';
        endCustomer.State__c = 'Indiana';
        endCustomer.Zip__c = '46037';
        endCustomer.Phone_Number__c = '75678975';
        endCustomer.Customer_Email_Adress__c = 'test@email.com';
        endCustomer.Company_Name__c = 'Test Company';
        endCustomerList.add(endCustomer);
        
        List<PRPC_DataUploadApex.fieldDetailWrapper> fieldTypeList = new List<PRPC_DataUploadApex.fieldDetailWrapper>();
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType0 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType0.apiName = 'Date_Of_Submission__c';
        fieldType0.fieldLabel = 'Date of submission';
        fieldType0.fieldType = 'DATE';
        fieldTypeList.add(fieldType0);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType1 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType1.apiName = 'Distributor_Ship_To__c';
        fieldType1.fieldLabel = 'Distributor ship to';
        fieldType1.fieldType = 'String';
        fieldTypeList.add(fieldType1);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType2 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType2.apiName = 'Repair_Order__c';
        fieldType2.fieldLabel = 'Repair Order';
        fieldType2.fieldType = 'string';
        fieldTypeList.add(fieldType2);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType3 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType3.apiName = 'Repair_Type__c';
        fieldType3.fieldLabel = 'Repair Type';
        fieldType3.fieldType = 'String';
        fieldTypeList.add(fieldType3);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType4 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType4.apiName = 'Phone_Number__c';
        fieldType4.fieldLabel = 'Phone number';
        fieldType4.fieldType = 'Phone';
        fieldTypeList.add(fieldType4);
        
        PRPC_DataUploadApex.fieldDetailWrapper fieldType5 = new PRPC_DataUploadApex.fieldDetailWrapper();
        fieldType5.apiName = 'Customer_Email_Adress__c';
        fieldType5.fieldLabel = 'Email';
        fieldType5.fieldType = 'EMAIL';
        fieldTypeList.add(fieldType5);
        
        
        
        
        test.StartTest();
        PRPC_DataUploadApex.insertRecords(JSON.serialize(endCustomerList), 'End_Customer__c',JSON.serialize(fieldTypeList), 'Test','AdminCustomer Data Load');
        test.StopTest();
    }
    
    @isTest
    private static void lookupConvertTest(){
        Set<String> sapIdSet = new Set<String>();
        for(Account acct: [SELECT Id, SAP_Id__c FROM Account]) {
            sapIdSet.add(acct.SAP_Id__c);
        }
        new PRPC_recordManupulcation().lookUpConvert(sapIdSet);
    }
    @isTest
    private static void GetFileIdTest(){
        string acc = [select id from account where Location_Type__c = 'D' limit 1].id;
        PRPC_DataUploadApex.GetFileProcessId('AdminTAT',acc);
        PRPC_DataUploadApex.GetFileIdForAdmin('AdminTAT',acc);
    }
}