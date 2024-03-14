@isTest(seeAllData = false)
private class PRPC_ScheduleDataMovementClass_Test {
    
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
         List<Disable_Rules__c> disableRules3 = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules3) {
            if(rule.Name== 'EndCustTrigger') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
    insert insertDisableRules;
        
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
        
        //list<Account>acclist2 = PRPC_TestDataFactory.createAccount('D','Latin America',1,False,false);
        Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        list<Account>acclist1 = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,false);
        //list<Account>acclist2 = PRPC_TestDataFactory.createAccount('DDLR','EMEA',1,False,false);
        PRPC_TestDataFactory.createTpsIntStage(acclist[0].SAP_ID__C);
        PRPC_TestDataFactory.createTpsRetStage(acclist[0].SAP_ID__C);
        PRPC_TestDataFactory.createTpsStage(acclist[0].SAP_ID__C);
        //system.debug('checksapId: '+acclistBranch.SAP_ID__C);
        PRPC_TestDataFactory.insertaccstage('D','01020-00000');
         PRPC_TestDataFactory.insertaccstage('D','11110-00000');
        PRPC_TestDataFactory.insertaccstage('D','02657-00098');
        PRPC_TestDataFactory.insertaccstage('DB','01020-00012');
        PRPC_TestDataFactory.insertaccstage('DB','11110-12345');
        PRPC_TestDataFactory.insertaccstage('DDLR','01120-00000');
        PRPC_TestDataFactory.insertaccstage('DDLR','06120-00007');
        PRPC_TestDataFactory.insertaccstage('DLR','91520-00205');
        PRPC_TestDataFactory.insertTATturnt(acclist[0].SAP_ID__C);
        
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
        tts.Claim_Number__c= '2345678765';
        insert tts;
        
        End_Customer_Staging_Data__c endC = new End_Customer_Staging_Data__c();
        endC.Customer_Address_1__c='TestAd';
            endC.City__c='RKL';
            endC.Company_Name__c='TestComp';
            endC.Country__c='IN';
            endC.Date_Of_Submission__c='08/08/2020';
            endC.Distributor_Ship_To__c=acclist[0].SAP_ID__C;
            insert endC;
        
        /*Survey_Staging_Data__c sur = new Survey_Staging_Data__c();
        sur.Date_Taken__c = '03/03/2020';
        sur.Error_Log__c='';
        //sur.Account__c = '2345678';
        sur.Customer_Name__c= 'Testing';
        sur.File_Submission_Date__c = '03/03/2020';
        sur.Q1_Value__c='23';
        sur.Q2_Value__c='34';
        sur.Q3_Value__c = '55';
        sur.Q4_Value__c = '11';
        sur.Ship_To__c=acclist[0].SAP_ID__C;
        sur.RO__c='1234';
        sur.Q5_Value__c = '1';
        insert sur;*/
        
        Training_Staging_Data__c trn = new Training_Staging_Data__c();
        trn.Tech_compliant__c='0.0';
            trn.Extraction_Date__c='05/05/2020';
            trn.Error_Log__c='';
            trn.Ship_to__c='0138100175';
            trn.Two_trained_tech__c='N';
        insert trn;
        
        Functional_Comp_Staging_Data__c fun = new Functional_Comp_Staging_Data__c();
        fun.Claim_Type__c='test';
            fun.Distributor__c='0138100175';
            fun.Error_Log__c='';
            fun.Extraction_Date__c	='05/05/2050';
            fun.Invoice_amount__c='1234567';
        insert fun;
        CE_Staging_Data__c CE = new CE_Staging_Data__c();
        CE.Distributor_Ship_To__c =acclist[0].SAP_ID__C;
        CE.Invoice_Amount__c = '12345';
        CE.Product_Type__c = 'CE';
        CE.Extraction_Date__c = '01/01/2021';
        insert CE;
        
        
        Account accountRec = new Account();
                accountRec.Name = 'Test ';
                accountRec.Type = 'Service Dealer';
                accountRec.Location_Type__c = 'DLR';
                accountRec.Sales_RegionA__c = 'North America';
                accountRec.ShippingCity = 'City';
                accountRec.ShippingCountry = 'Country';
                accountRec.ShippingState = 'State';
                accountRec.ShippingPostalCode = '765432';
                accountRec.ShippingStreet = 'Street';
                accountRec.PRP_Participation__c = true;
        accountRec.SAP_ID__C = '9152000205';
        insert accountRec;
    }
    
    @isTest static void Test_ScheduleDataMovementClass() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'Account_Staging__c\' And DeveloperName = \'Account\'';
        //demo
        List<account> accList= new List<account>();
         Account accountRec = new Account();
                accountRec.Name = 'Test ';
                accountRec.Type = 'Service Dealer';
                accountRec.Location_Type__c = 'DLR';
                accountRec.Sales_RegionA__c = 'Asia Pacific';
                accountRec.ShippingCity = 'City';
                accountRec.ShippingCountry = 'Country';
                accountRec.ShippingState = 'State';
                accountRec.ShippingPostalCode = '765432';
                accountRec.ShippingStreet = 'Street';
                accountRec.PRP_Participation__c = true;
        accountRec.SAP_ID__C = '9152000216';
        accList.add(accountRec);
        Account accountRec1 = new Account();
                accountRec1.Name = 'Test 1';
                accountRec1.Type = 'Distributor';
                accountRec1.Location_Type__c = 'D';
                accountRec1.Sales_RegionA__c = 'North America';
                accountRec1.ShippingCity = 'City';
                accountRec1.ShippingCountry = 'Country';
                accountRec1.ShippingState = 'State';
                accountRec1.ShippingPostalCode = '765432';
                accountRec1.ShippingStreet = 'Street';
                accountRec1.PRP_Participation__c = true;
        accountRec1.SAP_ID__C = '01020';
        
        accList.add(accountRec1);
        insert accList;
              
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        
        PRPC_returnRealObjClass.updatelistwithAddress(accList);
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass24() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'Account_Staging__c\' And DeveloperName = \'Account\'';
        //demo
        List<account> accList= new List<account>();
         Account accountRec = new Account();
                accountRec.Name = 'Test ';
                accountRec.Type = 'Service Dealer';
                accountRec.Location_Type__c = 'DLR';
                accountRec.Sales_RegionA__c = 'Asia Pacific';
                accountRec.ShippingCity = 'City';
                accountRec.ShippingCountry = 'Country';
                accountRec.ShippingState = 'State';
                accountRec.ShippingPostalCode = '765432';
                accountRec.ShippingStreet = 'Street';
                accountRec.PRP_Participation__c = true;
        accountRec.SAP_ID__C = '9152000217';
        accList.add(accountRec);
       	insert accList;
              
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        
        PRPC_returnRealObjClass.updatelistwithAddress(accList);
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass2() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'TPS_Staging_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass3() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'TAT_Turnt_staging__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass4() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'TAT_Staging_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    
    @isTest static void Test_ScheduleDataMovementClass9() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'Training_Staging_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass10() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'Functional_Comp_Staging_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
   
    @isTest static void Test_ScheduleDataMovementClass12() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'CE_Staging_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClassFunctionalComp() {
          Test.startTest();
       DataMovementBatch.fakeMethod();
         Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass13() {
        DataMovementBatch.queryInclude = ' And Real_Object_Api_Name__c =\'Survey_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass14() {
            List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        
        list<Account>acclist2 = PRPC_TestDataFactory.createAccount('D','Latin America',1,False,false);
        
        Survey_Staging_Data__c sur = new Survey_Staging_Data__c();
        sur.Date_Taken__c = '03/03/2020';
        sur.Error_Log__c='';
        //sur.Account__c = '2345678';
        sur.Customer_Name__c= 'Testing';
        sur.File_Submission_Date__c = '03/03/2020';
        sur.Q1_Value__c='23';
        sur.Q2_Value__c='34';
        sur.Q3_Value__c = '55';
        sur.Q4_Value__c = '11';
        sur.Ship_To__c=acclist2[0].SAP_ID__C;
        sur.RO__c='1234';
        sur.Q5_Value__c = '1';
        sur.Q6_Value__c = '3';
        insert sur;
        
        
        DataMovementBatch.queryInclude = ' And Real_Object_Api_Name__c =\'Survey_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    
    @isTest static void Test_ScheduleDataMovementClass15() {
            List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
              insertDisableRules.add(rule);
            }
        }
        
    insert insertDisableRules;
        
        list<Account>acclist2 = PRPC_TestDataFactory.createAccount('D','EMEA',1,False,false);
        
        
        Survey_Staging_Data__c sur = new Survey_Staging_Data__c();
        sur.Date_Taken__c = '03/03/2020';
        sur.Error_Log__c='';
        sur.Account__c = '2345678';
        sur.Customer_Name__c= 'Testing';
        sur.File_Submission_Date__c = '03/03/2020';
        sur.Q1_Value__c='23';
        sur.Q2_Value__c='34';
        sur.Q3_Value__c = '55';
        sur.Q4_Value__c = '11';
        sur.Ship_To__c=acclist2[0].SAP_ID__C;
        //sur.RO__c='1234';
        sur.Q5_Value__c = '1';
        sur.Q6_Value__c = '4';
        insert sur;
        
        
        DataMovementBatch.queryInclude = ' And Real_Object_Api_Name__c =\'Survey_Data__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClass22() {
        list<Account_Staging__c> lstAcc = new List<Account_Staging__c>();
        List<Account> acLst = New List<Account>();
        Account_Staging__c ac = New Account_Staging__c();
        ac.Location_Type__c = 'DLR';
        ac.Error_log__c = null;
        ac.Sales_RegionA__c = 'Western';
        ac.name = 'Test';
        ac.Service_Location_ID__c='12345-67890';
        lstAcc.add(ac);
        
        
        Account_Staging__c acc = New Account_Staging__c();
        acc.Location_Type__c = 'D';
        acc.Error_log__c = null;
        acc.Sales_RegionA__c = 'Western';
        acc.name = 'Test1';
        acc.Hidden__c = 'X';
        acc.Service_Location_ID__c='2345600000';
        lstAcc.add(acc);
        insert lstAcc;
        
        Account rel = New Account();
        rel.SAP_ID__c='1234567890';
        rel.PRP_Participation__c = true;
        rel.Service_Dealer_Development__c = true;
        rel.Name = 'Testing';
        rel.Sales_RegionA__c='Latin America';
        rel.Location_Type__c='DLR';
        rel.Type = 'Service Dealer';
        acLst.add(rel);
            
        Account rel1 = New Account();
        rel1.SAP_ID__c='2345600000';
        rel1.PRP_Participation__c = true;
        rel1.Service_Dealer_Development__c = true;
        rel1.Name = 'Testing service dealer';
        rel1.Sales_RegionA__c='North America';
        rel1.Location_Type__c='DB';
        rel1.Type = 'Distributor Branch';
        acLst.add(rel1);
        
        Account rel2 = New Account();
        rel2.SAP_ID__c='23456';
        rel2.PRP_Participation__c = false;
        rel2.Service_Dealer_Development__c = true;
        rel2.Name = 'Testing service dealer';
        rel2.Sales_RegionA__c='North America';
        rel2.Location_Type__c='D';
        rel2.Type = 'Distributor';
        acLst.add(rel2);
        insert acLst;
        
        DataMovementBatch.queryInclude = ' And Real_Object_Api_Name__c =\'End_Customer__c\'';
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }
    @isTest static void Test_ScheduleDataMovementClassFunctionalComp23() {
        Account rel2 = New Account();
        rel2.SAP_ID__c='23451';
        rel2.PRP_Participation__c = false;
        rel2.Service_Dealer_Development__c = true;
        rel2.Name = 'Testing service dealer';
        rel2.Sales_RegionA__c='North America';
        rel2.Location_Type__c='D';
        rel2.Type = 'Distributor';
        insert rel2;
        
        TAT_Staging_Data__c tts = new TAT_Staging_Data__c();
        tts.all_labor_ops__c='00094100 00094700 00095205 00096400 00096901 11111111';
        tts.customer_notified__c='31AUG2019:08:00:00';
        tts.date_cust_request_service__c='31AUG2019:08:00:00';
        tts.date_vehicle_first_arrived__c='31AUG2019:08:00:00';
        tts.Error_Log__c='';
        tts.Partner_Code__c=rel2.SAP_ID__c;
        tts.repair_order_number__c='PA201909001';
        tts.Transmission_serial_number__c='6330037717';
        tts.vin__c = '';
        tts.submit_date__c ='01-Jan-2025';
        insert tts;
        
        TAT_Turnt_staging__c TTTunt = new TAT_Turnt_staging__c();
        TTTunt.Date_of_File_Submission__c = '03/03/2022';
        TTTunt.Distributor_Ship_To__c = rel2.SAP_ID__c;
        TTTunt.date_vehicle_first_arrived__c = '03/03/2022';
        TTTunt.Total_labor_hours__c = '10';
		TTTunt.Repair_Payment__c = 'W';
        TTTunt.Repair_Type__c = 'I';
        TTTunt.Allison_Serial__c = '6511554148';
        TTTunt.vin__c = '1FVACWC546HV81187';
        TTTunt.Time_of_day_last_labor_applied__c = '10:00';
        TTTunt.Time_customer_notified_vehicle_available__c = '11.40.29';
        insert TTTunt;
        
        
        Test.startTest();
        PRPC_dataMovementForTTData sh1 = new PRPC_dataMovementForTTData();
        Database.executeBatch(sh1);
        Test.stopTest();
        
        
    }
    //ETC Test Method
     @isTest static void Test_ScheduleDataMovementClassEtc() {
        DataMovementBatch.queryInclude = ' And Staging_Object_Api_Name__c =\'ETC_Staging_Data__c\'';
         Account rel1 = New Account();
        rel1.SAP_ID__c='2345600000';
        rel1.PRP_Participation__c = true;
        rel1.Service_Dealer_Development__c = true;
        rel1.Name = 'Testing service dealer';
        rel1.Sales_RegionA__c='North America';
        rel1.Location_Type__c='DB';
        rel1.Type = 'Distributor Branch';
         
        Insert rel1;
         
        ETC_Staging_Data__c EtcData = new ETC_Staging_Data__c();
        EtcData.Date__c = '03/03/2023';
        EtcData.Distributor_Code__c = rel1.SAP_ID__c;
        EtcData.Retail_Amount_ETC__c='100';
        
        insert EtcData;
        Test.startTest();
        PRPC_ScheduleDataMovementClass sh1 = new PRPC_ScheduleDataMovementClass();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        
    }

}