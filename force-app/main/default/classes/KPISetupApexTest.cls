@isTest
public class KPISetupApexTest {
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
          
        
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, false);
        PRPC_TestDataFactory.insertKPISetup('North America', '2020', 'Distributor');
        
        
    }
	static testMethod void allRangesTest() {
        List<KPI_Setup__c> KPIList = new List<KPI_Setup__c>();
        List<KPI_Range_Settings__c> KPIRangeList = new List<KPI_Range_Settings__c>();
        List<KPI_Date_Settings__c> KPIDateList = new List<KPI_Date_Settings__c>();
        KPIRangeList = [SELECT Id,Name,Low_Range_Value__c,High_Range_Value__c,Points__c,X2_Tech__c from KPI_Range_Settings__c];
        KPIDateList = [SELECT Id,Name,File_Submission_Date__c,KPI_Calculation_Date__c from KPI_Date_Settings__c];
        KPIList = [SELECT Region__c,Year__c,KPI_Type__c,Partner_Type__c from KPI_Setup__c];
        system.debug('line 18:'+ KPIList);
        Test.startTest();
        KPISetupApex.allRanges(JSON.serialize(KPIRangeList),JSON.serialize(KPIDateList),'North America','2020','TPS','Distributor');
        KPISetupApex.allDates(JSON.serialize(KPIDateList));
        KPISetupApex.searchDateRange('North America','2020');
       
        Test.stopTest();
    }
    
    static testMethod void sendDataTest() {
        KPI_Setup__c KPIValue = new KPI_Setup__c();
        List<KPI_Date_Settings__c> KPIDateRange = new List<KPI_Date_Settings__c>();
        KPIValue.Region__c = 'North America';
        KPIValue.Year__c = '2020';
        KPIValue.KPI_Type__c = 'TPS';
        KPIValue.Partner_Type__c = 'Distributor';
        
        KPI_Date_Settings__c KPIDateValue = new KPI_Date_Settings__c();
        KPIDateValue.Name = 'January';
        KPIDateValue.File_Submission_Date__c = date.newInstance(2020, 1, 8);
        KPIDateValue.KPI_Calculation_Date__c = date.newInstance(2020, 1, 12);
        KPIDateRange.add(KPIDateValue);
        KPISetupApex.sendData(JSON.serialize(KPIValue),JSON.serialize(KPIDateRange));
    }
}