@isTest(seeAllData = false)
private class EndCustTrigger_Test {
    @testSetup static void setup() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
         List<Disable_Rules__c> disableRules2 = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules2) {
            if(rule.Name== 'EndCustTrigger') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
       
        // Create common test data that will be used across the test class
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
         Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        
        End_Customer_Staging_Data__c tat = new End_Customer_Staging_Data__c();
        
            
            tat.Distributor_Ship_To__c=acclistBranch.SAP_ID__c;
            tat.Language__c = 'English';
            tat.Type__c = 'service';
            tat.Error_Log__c='';
            
            insert tat;
        
    }
    
    @isTest static void EndCustTrigg1() {
        
        list<End_Customer_Staging_Data__c>tatstage = new list<End_Customer_Staging_Data__c>([select id,Distributor_Ship_To__c,Language__c,Date_Of_Submission__c,Error_Log__c from End_Customer_Staging_Data__c]);
        PRPCO_Facility_Audit__c fac = new PRPCO_Facility_Audit__c();
        Test.startTest();
        for(End_Customer_Staging_Data__c tt :tatstage){
            End_Customer_Staging_Data__c tts = new End_Customer_Staging_Data__c();
            tts.Id = tt.Id;
            tts.Language__c = '';
            update tts;
        }
        Test.stopTest();
        
    }
    @isTest static void EndCustTrigg2() {
        
        list<End_Customer_Staging_Data__c>tatstage = new list<End_Customer_Staging_Data__c>([select id,Distributor_Ship_To__c,Language__c,Date_Of_Submission__c,Error_Log__c from End_Customer_Staging_Data__c]);
        PRPCO_Facility_Audit__c fac = new PRPCO_Facility_Audit__c();
        Test.startTest();
        for(End_Customer_Staging_Data__c tt :tatstage){
            End_Customer_Staging_Data__c tts = new End_Customer_Staging_Data__c();
            tts.Id = tt.Id;
            tts.Language__c = 'English';
            update tts;
        }
        Test.stopTest();
        
    }
   
}