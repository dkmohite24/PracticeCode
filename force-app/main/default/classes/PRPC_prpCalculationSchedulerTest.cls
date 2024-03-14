/*
 * @Description: Test Class for PRPC_prpCalculationScheduler & PRPC_prpCalculationClass
 * Created:  10/10/2020 – Nitish Gyansys
 * */


@isTest(SeeAllData=false)
public class PRPC_prpCalculationSchedulerTest {
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
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true);
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        PRPC_TestDataFactory.insertPRPSetup('EMEA', '2020', 'Distributor', 'January');
        PRPC_TestDataFactory.insertPRPSetup('EMEA', '2020', 'Direct Dealer','January');
        PRPC_TestDataFactory.insertPRPSetup('Asia Pacific', '2020', 'Distributor', 'January');
        PRPC_TestDataFactory.insertPRPSetup('Asia Pacific', '2020', 'Direct Dealer', 'January');
        PRPC_TestDataFactory.insertPRPSetup('Latin America', '2020', 'Distributor', 'January');
        PRPC_TestDataFactory.insertPRPSetup('Latin America', '2020', 'Direct Dealer', 'January');
        PRPC_TestDataFactory.insertPRPSetup('North America', '2020', 'Distributor','January');
        
        PRPC_TestDataFactory.insertSurveySetup('CSI Parts', 'North America');
        PRPC_TestDataFactory.insertSurveySetup('CSI Service', 'North America');
        PRPC_TestDataFactory.insertSurveySetup('CSI', 'EMEA');
        List<Account> allNABranches = new List<Account>();
        allNABranches = [SELECT Id, SAP_ID__c FROM Account WHERE ParentId IN :allNADistributors];
        PRPC_TestDataFactory.insertSurveyData(allNABranches, 'Parts', 5);
        PRPC_TestDataFactory.insertSurveyData(allNABranches, 'Service', 5);
        PRPC_TestDataFactory.insertTPSdata(allNABranches[0].Id,allNABranches[0].SAP_ID__c,'TPS',Date.newInstance(2020,2,5));
        PRPC_TestDataFactory.insertTPSdata(allNABranches[0].Id,allNABranches[0].SAP_ID__c,'TPS',Date.newInstance(2019,2,5));
        PRPC_TestDataFactory.insertETCdata(allNABranches[0].Id,allNABranches[0].SAP_ID__c,Date.newInstance(2019,2,5));
        PRPC_TestDataFactory.createTat(allNADistributors[0].Id);
        System.debug('Check 32: '+[SELECT Id,month__c FROM TAT_Data__c /*WHERE Year__c = 2020 AND Month__c <=1 AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))*/]);
        
        
    }
    
    @isTest
    private static void executePRPCalculation_NA_Test(){
        System.debug('Check: ' + [select id, Customer_Dealer_Id__c,Customer_Dealer_Id__r.location_type__c from survey_data__c]);
        System.debug('ETC data '+ [select id,Customer__c,Distributor_Code__c,Date__c,Retail_Amount_ETC__c from  ETC_Data__c]);
        Date startDate = Date.newInstance(2020,1,10);
        Date endDate = Date.newInstance(2020,2,31);
        PRPC_prpCalculationScheduler executeKPICalulation = new PRPC_prpCalculationScheduler();
        
        test.StartTest();
        executeKPICalulation.executePRPCalculation(startDate, endDate);
        test.stopTest();
    }
    @isTest
    private static void executePRPCalculation_INT_Test(){
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'EMEA', 1, true, false);
        List<Account> allNABranches = [SELECT Id, SAP_ID__c FROM Account WHERE ParentId IN :allNADistributors];
        PRPC_TestDataFactory.insertSurveyData(allNABranches, 'CSI', 5);
        
        Date startDate = Date.newInstance(2020,1,1);
        Date endDate = Date.newInstance(2020,1,31);
        PRPC_prpCalculationScheduler executeKPICalulation = new PRPC_prpCalculationScheduler();
        
        
        test.StartTest();
        executeKPICalulation.executePRPCalculation(startDate, endDate);
        test.stopTest();
    }
    
    @isTest
    private static void executePRPCalculation_DDLR_Test(){
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('DDLR', 'EMEA', 1, true, false);
        List<Account> allNABranches = [SELECT Id, SAP_ID__c FROM Account WHERE ParentId IN :allNADistributors];
        PRPC_TestDataFactory.insertSurveyData(allNABranches, 'CSI', 5);
        
        Date startDate = Date.newInstance(2020,1,1);
        Date endDate = Date.newInstance(2020,1,31);
        PRPC_prpCalculationScheduler executeKPICalulation = new PRPC_prpCalculationScheduler();
        
        
        test.StartTest();
        executeKPICalulation.executePRPCalculation(startDate, endDate);
        test.stopTest();
    }
    
}