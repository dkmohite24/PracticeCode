@isTest
public class PRPC_overallFileSubmissionScheduleTest {
    @testSetup 
    private static void setup() {
        
               
        UserRole roleRec = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert roleRec;
        Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1].Id;
        
        User adminUser = PRPC_TestDataFactory.createPartnerUser(null, profileId, roleRec.Id, true); 
        System.runAs(adminUser){
            
             List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;

            List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
            PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
            PRPC_TestDataFactory.insertPRPSetup('EMEA', '2020', 'Distributor', 'January');
            PRPC_TestDataFactory.insertPRPSetup('EMEA', '2020', 'Direct Dealer','January');
            PRPC_TestDataFactory.insertPRPSetup('North America', '2020', 'Distributor','January');
            
            PRPC_TestDataFactory.insertSurveySetup('CSI Parts', 'North America');
            PRPC_TestDataFactory.insertSurveySetup('CSI Service', 'North America');
            PRPC_TestDataFactory.insertSurveySetup('CSI', 'EMEA');
            List<Account> allNABranches = new List<Account>();
            allNABranches = [SELECT Id, SAP_ID__c FROM Account WHERE ParentId IN :allNADistributors];
            //PRPC_TestDataFactory.insertSurveyData(allNABranches, 'Parts', 5);
            //PRPC_TestDataFactory.insertSurveyData(allNABranches, 'Service', 5);
            
            PRPC_TestDataFactory.insertTPSdata(allNABranches[0].Id,allNABranches[0].SAP_ID__c,'TPS',Date.newInstance(2020,2,5));
            PRPC_TestDataFactory.insertTPSdata(allNABranches[0].Id,allNABranches[0].SAP_ID__c,'TPS',Date.newInstance(2019,2,5));
            PRPC_TestDataFactory.createTat(allNADistributors[0].Id);
            
            Survey_Data__c surveyRec = new Survey_Data__c();
            surveyRec.Customer_Dealer_Id__c = allNABranches[0].Id;
            surveyRec.Ship_To__c = allNABranches[0].SAP_ID__c;
            surveyRec.Survey_Type__c = 'Parts';
            surveyRec.Q1_Value__c = 10.0;
            surveyRec.Q2_Value__c = 9.0;
            surveyRec.Q3_Value__c = 9.0;
            surveyRec.Q4_Value__c = 9.0;
            surveyRec.Q5_Value__c = 9.0;
            surveyRec.Q6_Value__c = 1;
            surveyRec.Date_Taken__c = Date.newInstance(2023,5,18);
            Insert surveyRec;
            
            
            TAT_Data__c tatAwaare = new TAT_Data__c();
            TAT_Data__c tatTurnt = new TAT_Data__c();
            tatAwaare.Allison_Serial__c = 'A123';
            tatAwaare.Dealer_Id__c = allNABranches[0].Id;
            tatAwaare.Distributor_Ship_To__c = allNABranches[0].SAP_ID__c;
            tatAwaare.Claim_Number__c = '1234';
            tatAwaare.Extraction_Date__c= Date.newInstance(2020,1,10);
            tatAwaare.Repair_Order__c = '1234';
            tatAwaare.Repair_Type__c = 'I';
            tatAwaare.Partner_Code__c = allNABranches[0].SAP_ID__c;
            tatAwaare.Source_Type__c = 'AWARE';
            tatAwaare.Transmission_serial_number__c = 'A123';
            tatAwaare.vin__c = 'v123';
            tatAwaare.Repair_Payment__c= 'C';
            Insert tatAwaare;
            
            tatTurnt.Allison_Serial__c = 'A123';
            tatTurnt.Dealer_Id__c = allNABranches[0].Id;
            tatTurnt.Distributor_Ship_To__c = allNABranches[0].SAP_ID__c;
            tatTurnt.Claim_Number__c = '1234';
            tatTurnt.Extraction_Date__c= Date.newInstance(2020,1,10);
            tatTurnt.Date_of_File_Submission__c = Date.newInstance(2023,5,18);
            tatTurnt.Extraction_Date__c =  Date.newInstance(2023,5,18);
            tatTurnt.Partner_Code__c = allNABranches[0].SAP_ID__c;
            tatTurnt.Source_Type__c = 'Distributor';
            tatTurnt.Transmission_serial_number__c = 'A123';
            tatTurnt.vin__c = 'v123';
            tatTurnt.Repair_Payment__c= 'C';
            Insert tatTurnt;
            
            TPS_Data__c tpsData = New TPS_Data__c();
            tpsData.Customer__c = allNABranches[0].Id;
            tpsData.Distributor_Ship_To__c =allNABranches[0].SAP_ID__c;
            tpsData.Extraction_Date__c = Date.newInstance(2023,5,18);
            tpsData.Parts_Sold_Type__c = 'TPS';
            Insert tpsData;
            
            TPS_Data__c tpsDat = New TPS_Data__c();
            tpsDat.Customer__c = allNABranches[0].Id;
            tpsDat.Distributor_Ship_To__c =allNABranches[0].SAP_ID__c;
            tpsDat.Extraction_Date__c = Date.newInstance(2023,5,18);
            tpsDat.Parts_Sold_Type__c = 'RET';
            Insert tpsDat;
            
            Training_Data__c train = New Training_Data__c();
            train.Ship_to__c = allNABranches[0].SAP_ID__c;
            train.Customer__c = allNABranches[0].Id;
            train.Extraction_Date__c = Date.newInstance(2023,5,18);
            train.Tech_compliant__c = 0.25;
            train.Two_trained_tech__c = 'Y';
            Insert train;
            
            Parts_Ordering__c parts = New Parts_Ordering__c();
            parts.Distributor_Ship_To__c = allNABranches[0].SAP_ID__c;
            parts.Ship_To__c = allNABranches[0].Id;
            parts.Report_Execution_Date__c = Date.newInstance(2023,5,18);
            Insert parts;
            
            End_Customer__c endCus = New End_Customer__c();
            endCus.Customer__c =allNABranches[0].Id;
            endCus.Date_Of_Submission__c = Date.newInstance(2023,5,18);
            endCus.Date_Of_Type__c = Date.newInstance(2023,5,18);
            endCus.Distributor_Ship_To__c= allNABranches[0].SAP_ID__c;
            //endCus.Repair_Type__c = 'M - Maintenance';
            Insert endCus;
            
            
        }
    }
    
    @isTest
    private static void PRPC_overallFileScheduleTest(){
        test.starttest();
        PRPC_overallFileSubmissionSchedule myClass1 = new PRPC_overallFileSubmissionSchedule();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched 1', chron, myClass1);
        PRPC_overallFileSubmissionSchedule myClass2 = new PRPC_overallFileSubmissionSchedule(); 
        system.schedule('Test Sched 2', chron, myClass2);
        test.stopTest();
    }
    @isTest
    private static void PRPC_overallFileSubmissionApex_objectFieldsTest(){
        PRPC_overallFileSubmissionApex.objectFields('Distributor');
        List<String> selectedRegion = new List<String>();
        selectedRegion.add('North America');
        selectedRegion.add('EMEA');
        PRPC_overallFileSubmissionApex.fetchDistributors(selectedRegion, 'Total Parts Sold Data - International DDLR');
        PRPC_overallFileSubmissionApex.fetchDistributors(selectedRegion, 'Test');
        List<Account> distributorList = new List<Account>();
        distributorList = [select id from account where location_type__c = 'D'];
        List<String> distributorIdList = new List<String>();
        for(Account acct : distributorList) {
            distributorIdList.add(acct.Id);
        }
        List<String> monthList = new List<String>();
        monthList.add('January');
        List<Decimal> yearList = new List<Decimal>();
        yearList.add(2020);
        PRPC_overallFileSubmissionApex.FetchRecordsforTable(distributorIdList,'Distributor',monthList,yearList);
    }
}