@isTest(seeAllData = false)
private class PRPC_dataMovementForTTDataTest {
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
            if(rule.Name== 'TatTurntTrigger') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        insert insertDisableRules;
        
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
        Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        
        TAT_Staging_Data__c tts = new TAT_Staging_Data__c();
        tts.all_labor_ops__c='00094100 00094700 00095205 00096400 00096901 11111111';
        tts.customer_notified__c='31AUG2019:08:00:00';
        tts.date_cust_request_service__c='31AUG2019:08:00:00';
        tts.date_vehicle_first_arrived__c='31AUG2019:08:00:00';
        tts.Error_Log__c='';
        tts.Partner_Code__c=acclist[0].SAP_ID__C;
        tts.repair_order_number__c='PA201909001';
        tts.Transmission_serial_number__c='6330037717';
        tts.vin__c = '';
        tts.submit_date__c ='01-Jan-2025';
        insert tts;
        
        TAT_Turnt_staging__c TTTunt = new TAT_Turnt_staging__c();
        TTTunt.Date_of_File_Submission__c = '03/03/2022';
        TTTunt.Distributor_Ship_To__c = acclist[0].SAP_ID__C;
        TTTunt.date_vehicle_first_arrived__c = '03/03/2022';
        TTTunt.Total_labor_hours__c = '10';
		TTTunt.Repair_Payment__c = 'W';
        TTTunt.Repair_Type__c = 'I';
        TTTunt.Allison_Serial__c = '6511554148';
        TTTunt.vin__c = '1FVACWC546HV81187';
        TTTunt.Time_of_day_last_labor_applied__c = '10:00';
        insert TTTunt;
    }
    
     @isTest static void Test_DataMovementForTTTunt() {
        
        Test.startTest();
        PRPC_dataMovementForTTData sh1 = new PRPC_dataMovementForTTData();
        Database.executeBatch(sh1);
        Test.stopTest();
    }
}