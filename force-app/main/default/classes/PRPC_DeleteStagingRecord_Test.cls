@isTest(seeAllData = false)
private class PRPC_DeleteStagingRecord_Test {
    @testSetup static void setup() {
       List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount' || rule.Name=='EndCustTrigger' || rule.Name=='TatTurntTrigger') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        // Create common test data that will be used across the test class
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
         Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        
        End_Customer_Staging_Data__c tat2 = new End_Customer_Staging_Data__c();
        
            
            tat2.Distributor_Ship_To__c=acclistBranch.SAP_ID__c;
            tat2.Language__c = 'English';
            tat2.Date_Of_Submission__c='01/01/2030';
            tat2.Type__c = 'service';
            tat2.Error_Log__c='';
            
            insert tat2;
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
        
    }
    
    @isTest static void EndCustTrigg1() {
        
        list<End_Customer_Staging_Data__c>tatstage = new list<End_Customer_Staging_Data__c>([select id,Distributor_Ship_To__c,Language__c,Date_Of_Submission__c,Error_Log__c from End_Customer_Staging_Data__c]);
        String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() ); 
                String ss = String.valueOf(Datetime.now().second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
              
               
        Test.startTest();
         PRPC_DeleteStagingRecord s = new PRPC_DeleteStagingRecord(); 
                s.Endlist = tatstage;
                System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        
        Test.stopTest();
        
    }
   @isTest static void EndCustTrigg2() {
        
        list<TAT_Turnt_staging__c>tatstage = new list<TAT_Turnt_staging__c>([select id,vin__c,Error_Log__c,Allison_Serial__c from TAT_Turnt_staging__c]);
        String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() ); 
                String ss = String.valueOf(Datetime.now().second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
              
               
        Test.startTest();
         PRPC_DeleteStagingRecord s = new PRPC_DeleteStagingRecord(); 
                s.tatList = tatstage;
                System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        
        Test.stopTest();
        
    }
   
}