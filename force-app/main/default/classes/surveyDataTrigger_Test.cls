@isTest(seeAllData = false)
public class surveyDataTrigger_Test {
    @isTest static void surveyDataTriggerMethod() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
        Survey_Staging_Data__c sur = new Survey_Staging_Data__c();
        sur.Date_Taken__c = '03/03/2020';
        sur.Error_Log__c='';
        sur.File_Submission_Date__c = '03/03/2020';
        sur.Q1_Value__c='23';
        sur.Q2_Value__c='34';
        sur.Q3_Value__c = '55';
        sur.Q4_Value__c = '11';
        sur.Ship_To__c=acclist[0].SAP_ID__C;
        sur.RO__c='1234';
        sur.Q5_Value__c = '1';
        insert sur;
    }
}