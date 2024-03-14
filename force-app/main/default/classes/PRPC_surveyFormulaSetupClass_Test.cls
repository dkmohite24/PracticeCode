@isTest(seeAllData = false)
private class PRPC_surveyFormulaSetupClass_Test {
    @testSetup static void setup() {
        // Create common test data that will be used across the test class
        // 
        PRPC_TestDataFactory.insertSurveySetup('CSI','EMEA');
       
    }
    
    @isTest static void getALLPickListValuesTest() {
        list<Survey_Formula_Setup__c> surData = new list<Survey_Formula_Setup__c>([select Survey_Type__c,Region_Type__c,Question_Number__c,Percentage__c from Survey_Formula_Setup__c]);
        string recVal = '[{"Question":"Q1","Percentage":"100","id":"Id1","QuestionValue":"Test"}]';
        string surveyType = surData[0].Survey_Type__c;
        String RegionType = surData[0].Region_Type__c;
        Test.startTest();
        PRPC_surveyFormulaSetupClass.getALLPickListValues();
        PRPC_surveyFormulaSetupClass.insertSurveyRecord(recVal, surveyType, RegionType,'2020');
        PRPC_surveyFormulaSetupClass.DeleteSurveyRecord(surData[0].Id);
        Test.stopTest();
        
    }
}