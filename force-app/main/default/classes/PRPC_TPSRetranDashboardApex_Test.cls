@isTest(seeAllData = false)
private class PRPC_TPSRetranDashboardApex_Test {
    @testSetup static void setup() {
        // Create common test data that will be used across the test class
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
    }
    
    @isTest static void Test_ScheduleDataMovementClassOna() {
        
        list<Account> accListOna = PRPC_TestDataFactory.createAccount('D','EMEA',1,True,False);
        contact conOna = new contact();
        conOna.AccountId = accListOna[0].Id;
        conOna.LastName = 'testcon2';
        insert conOna;
        Account DistlistOna = PRPC_TestDataFactory.createBranch(accListOna[0],True,12346);
        PRPC_TestDataFactory.insertKpiRec(DistlistOna.Id,Double.valueOf(DistlistOna.SAP_ID__C),'Gold','EMEA');
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-01-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-02-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-03-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-04-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-05-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-06-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-07-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-08-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-09-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-10-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-11-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2020-12-01'));
        
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2021-01-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-02-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-03-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-04-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-05-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-06-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-07-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-08-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-09-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-10-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-11-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2019-12-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-02-02'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-03-03'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-04-04'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-05-05'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-06-06'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-07-07'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-08-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-09-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-10-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-11-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-12-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2018-01-01'));
        PRPC_TestDataFactory.insertTPSdata(DistlistOna.Id,DistlistOna.SAP_ID__C,'TPS',Date.valueof('2017-01-01'));
        
        
        //KPI__C kp= [select id,Customer__c,isPartOfPRP__c,Year__c,Month__c,Period__c from KPI__C];
        KPI__C kp= [select id,Customer__c,isPartOfPRP__c,Year__c,Month__c,Period__c from KPI__C where Region__c = 'EMEA'];
        KPI__C kp1 = new KPI__C();
        kp1.Customer__c = kp.Customer__c;
        kp1.isPartOfPRP__c = kp.isPartOfPRP__c;
        kp1.Year__c = 2019;
        kp1.Month__c=kp.Month__c;
        kp1.Period__c=kp.Period__c;
        insert kp1;
        list<TPS_Data__c> tpslist = new list<TPS_Data__c>();
        list<TPS_Data__c> tpsLst = new list<TPS_Data__c>([select id,Invoice_Amount__c,Customer__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c]);
        for(TPS_Data__c tp1:tpsLst){
            tp1.Invoice_Amount__c = 11234;
            tpslist.add(tp1);
        }
        update tpslist;
        list<Account> acclistOna1 = new list<Account>([select id from Account where Type = 'Distributor' and id=:tpsLst[0].Customer__r.ParentId]);
        //system.debug('test17: '+[Select Id,Invoice_Amount__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c]);
        //system.debug('test18: '+string.valueof(acclist[0].Id));
        Test.startTest();
        PRPC_TPSRetranDashboardApex.getDistributors('EMEA','Distributor');
        PRPC_TPSRetranDashboardApex.returnDashboardDetails(2021, string.valueof(acclistOna1[0].Id), 'TPS', 'EMEA','Distributor');
        Test.stopTest();
        
    }
    
    
    @isTest static void Test_ScheduleDataMovementClassForRET() {
    	list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,True,False);
        contact con = new contact();
        con.AccountId = accList[0].Id;
        con.LastName = 'testcon';
        insert con;
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);

		PRPC_TestDataFactory.insertKpiRec(Distlist.Id,Double.valueOf(Distlist.SAP_ID__C),'Gold','North America');
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-01-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-02-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-03-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-04-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-05-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-06-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-07-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-08-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-09-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-10-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-11-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2020-12-01'));
        
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2021-01-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-02-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-03-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-04-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-05-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-06-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-07-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-08-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-09-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-10-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-11-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2019-12-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-02-02'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-03-03'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-04-04'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-05-05'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-06-06'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-07-07'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-08-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-09-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-10-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-11-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-12-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2018-01-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'RET',Date.valueof('2017-01-01'));

     
        //KPI__C kp= [select id,Customer__c,isPartOfPRP__c,Year__c,Month__c,Period__c from KPI__C];
        KPI__C kp= [select id,Customer__c,isPartOfPRP__c,Year__c,Month__c,Period__c from KPI__C where Region__c = 'North America'];
        KPI__C kp1 = new KPI__C();
        kp1.Customer__c = kp.Customer__c;
        kp1.isPartOfPRP__c = kp.isPartOfPRP__c;
        kp1.Year__c = 2019;
        kp1.Month__c=kp.Month__c;
        kp1.Period__c=kp.Period__c;
        insert kp1;
        list<TPS_Data__c> tps2 = new list<TPS_Data__c>();
        list<TPS_Data__c> tps = new list<TPS_Data__c>([select id,Invoice_Amount__c,Customer__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c]);
        for(TPS_Data__c tp:tps){
            tp.Invoice_Amount__c = 123;
            tps2.add(tp);
        }
        update tps2;
        list<Account>acclst = new list<Account>([select id from Account where Type = 'Distributor' and id=:tps[0].Customer__r.ParentId]);
        //system.debug('test17: '+[Select Id,Invoice_Amount__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c]);
        //system.debug('test18: '+string.valueof(acclist[0].Id));
        Test.startTest();
        PRPC_TPSRetranDashboardApex.getDistributors('North America','Distributor');
        PRPC_TPSRetranDashboardApex.returnDashboardDetails(2020, string.valueof(acclst[0].Id), tps[0].Parts_Sold_Type__c, 'North America','Distributor');
        Test.stopTest();
        
    }
     
    
    @isTest static void Test_ScheduleDataMovementClassFoSelectedYear() {
    	list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,True,False);
        contact con = new contact();
        con.AccountId = accList[0].Id;
        con.LastName = 'testcon';
        insert con;
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);

		PRPC_TestDataFactory.insertKpiRec(Distlist.Id,Double.valueOf(Distlist.SAP_ID__C),'Gold','North America');
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-01-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-02-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-03-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-04-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-05-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-06-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-07-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-08-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-09-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-10-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-11-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2020-12-01'));
        
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-01-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-02-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-03-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-04-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-05-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-06-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-07-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-08-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-09-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-10-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-11-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-12-01'));
        /*PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-02-02'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-03-03'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-04-04'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-05-05'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-06-06'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-07-07'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-08-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-09-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-10-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-11-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-12-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2018-01-01'));
        PRPC_TestDataFactory.insertTPSdata(Distlist.Id,Distlist.SAP_ID__C,'TPS',Date.valueof('2017-01-01'));*/

     
        //KPI__C kp= [select id,Customer__c,isPartOfPRP__c,Year__c,Month__c,Period__c from KPI__C];
        KPI__C kp= [select id,Customer__c,isPartOfPRP__c,Year__c,Month__c,Period__c from KPI__C where Region__c = 'North America'];
        KPI__C kp1 = new KPI__C();
        kp1.Customer__c = kp.Customer__c;
        kp1.isPartOfPRP__c = kp.isPartOfPRP__c;
        kp1.Year__c = 2019;
        kp1.Month__c=kp.Month__c;
        kp1.Period__c=kp.Period__c;
        insert kp1;
        list<TPS_Data__c> tps2 = new list<TPS_Data__c>();
        list<TPS_Data__c> tps = new list<TPS_Data__c>([select id,Invoice_Amount__c,Customer__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c]);
        for(TPS_Data__c tp:tps){
            tp.Invoice_Amount__c = 0;
            tps2.add(tp);
        }
        update tps2;
        
        list<TPS_Data__c> tps3 = new list<TPS_Data__c>();
        list<TPS_Data__c> tpscheck = new list<TPS_Data__c>([select id,Invoice_Amount__c,Customer__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c where Year__c = 2020]);
        for(TPS_Data__c tp1:tpscheck){
            tp1.Invoice_Amount__c = 123;
            tps3.add(tp1);
        }
        update tps3;
        list<Account>acclst = new list<Account>([select id from Account where Type = 'Distributor' and id=:tps[0].Customer__r.ParentId]);
        //system.debug('test17: '+[Select Id,Invoice_Amount__c,Customer__r.ParentId,Month__c,Year__c,Parts_Sold_Type__c from TPS_Data__c]);
        //system.debug('test18: '+string.valueof(acclist[0].Id));
        Test.startTest();
        PRPC_TPSRetranDashboardApex.getDistributors('North America','Distributor');
        PRPC_TPSRetranDashboardApex.returnDashboardDetails(2020, string.valueof(acclst[0].Id), tps[0].Parts_Sold_Type__c, 'North America','Distributor');
        Test.stopTest();
        
    }
    
    
    @isTest static void RestrictedTabTest3() {
        
        Date myDate = Date.today().addYears(-2);
        Integer sectDate = Integer.valueOf(Date.today().year());
        Integer sectMon = Integer.valueOf(Date.today().month());
        Date myDate1 = Date.today().addYears(-1);
        Date myDate2 = Date.today().addYears(-3);
        Test.startTest();
        //PRPC_TPSRetranDashboardApex.fakeMethod();String myDate = string.valueOf
        PRPC_TPSRetranDashboardApex.returnYearCount(myDate,sectMon,sectDate);
        PRPC_TPSRetranDashboardApex.returnYearCount(myDate1,sectMon,sectDate);
        PRPC_TPSRetranDashboardApex.returnYearCount(myDate2,sectMon,sectDate);
        Test.stopTest();
    }
}