@isTest(seeAllData = false)
private class TatTurntTrigger_Test {
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
       
        // Create common test data that will be used across the test class
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
         Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        
        TAT_Turnt_staging__c tat = new TAT_Turnt_staging__c();
        tat.Allison_Serial__c='29544858XX';
            tat.date_cust_request_service__c='06/25/2020';
            tat.customer_notified__c='06/25/2020';
            tat.Date_Distributor_schedules_for_service__c='06/25/2020';
            tat.Date_first_labor_applied__c='06/25/2020';
            tat.Date_First_Part_Ordered__c='06/25/2020';
            tat.Date_last_labor_applied__c='06/25/2020';
            tat.Date_of_File_Submission__c='02/28/2025';
            tat.PART_ARRIVAL_DATE__c='06/25/2020';
            tat.date_vehicle_first_arrived__c='06/25/2020';
            tat.Distributor_Ship_To__c=acclistBranch.SAP_ID__c;
            tat.Error_Log__c='';
            tat.repair_order_number__c='R1080166';
            tat.Repair_Order_closed_date__c='06/25/2020';
            tat.Repair_Order_closed_time_of_day__c='09:28';
            tat.Repair_Order_open_date__c='06/25/2020';
            tat.Repair_Order_open_time_of_day__c='09:28';
            tat.Repair_Payment__c='C';
            tat.Repair_Type__c='I';
            tat.Technician_Name__c='Fuller Cody';
            tat.Time_customer_desires_service_to_begin__c='09:28';
            tat.Time_customer_notified_vehicle_available__c='09:28';
            tat.Time_Distributor_schedules_for_service__c ='09:28';
            tat.Time_of_day_first_labor_applied__c='09:28';
            tat.Time_of_day_last_labor_applied__c='09:28';
            tat.Time_of_day_vehicle_first_arrived__c='09:28';
            tat.Total_labor_hours__c='7';
            tat.vin__c='314606XXXXXXXXXXX';
            insert tat;
        
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
        
    }
    
    @isTest static void Tatstagetrigg1() {
        
        list<TAT_Turnt_staging__c>tatstage = new list<TAT_Turnt_staging__c>([select id,vin__c,Error_Log__c,Allison_Serial__c from TAT_Turnt_staging__c]);
        PRPCO_Facility_Audit__c fac = new PRPCO_Facility_Audit__c();
        Test.startTest();
        for(TAT_Turnt_staging__c tt :tatstage){
            TAT_Turnt_staging__c tts = new TAT_Turnt_staging__c();
            tts.Id = tt.Id;
            tts.Allison_Serial__c = '';
            update tts;
        }
        Test.stopTest();
        
    }
    @isTest static void Tatstagetrigg2() {
        
        list<TAT_Turnt_staging__c>tatstage = new list<TAT_Turnt_staging__c>([select id,vin__c,Error_Log__c,Allison_Serial__c from TAT_Turnt_staging__c]);
        PRPCO_Facility_Audit__c fac = new PRPCO_Facility_Audit__c();
        Test.startTest();
        for(TAT_Turnt_staging__c tt :tatstage){
            TAT_Turnt_staging__c tts = new TAT_Turnt_staging__c();
            tts.Id = tt.Id;
            tts.Allison_Serial__c = '';
            update tts;
        }
        Test.stopTest();
        
    }
    
}