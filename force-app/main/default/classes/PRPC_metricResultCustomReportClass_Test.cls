@isTest(seeAllData = false)
private class PRPC_metricResultCustomReportClass_Test {
    @testSetup static void setup() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        /*UserRole ur = new UserRole(Name = 'CEO');
insert ur;
Profile pf = [SELECT Id FROM Profile WHERE Name = 'PRP Partner'];

PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);
list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,False);
PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);*/
        //PRPC_TestDataFactory.createPartnerUser(cont.Id,pf.id,ur.id,true);
    }
    
    @isTest static void getALLPickListValuesTest() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);
        
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'North America','EMEA','Asia Pacific','Latin America'};
            list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
                list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        system.debug('check37: '+[select id,customer__C from kpi__C]);
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        Test.startTest();
        PRPC_metricResultCustomReportClass.onLoadValue(rp[0].Name,rp[0].Report_Region__c,rp[0].Partner_Type__c);
        PRPC_metricResultCustomReportClass.fetchDistributors(selectedRegion);
        PRPC_metricResultCustomReportClass.fetchDirectDealer(selectedRegion);
        PRPC_metricResultCustomReportClass.FetchDistBranch(DistributorList);
        PRPC_metricResultCustomReportClass.FetchDealerLocation(SelectDealer);
        PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'YTD');
        PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'YTD');
        PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'YTD');
        PRPC_metricResultCustomReportClass.MetricDetail();
        PRPC_metricResultCustomReportClass.ReportList();
        PRPC_metricResultCustomReportClass.regionList();
        PRPC_metricResultCustomReportClass.profileCheck();
        //PRPC_metricResultCustomReportClass.fakeMethod();
        Test.stopTest();
        
    }
    @isTest static void RestrictedTabTest() {
        user u = PRPC_TestDataFactory.createUser('Minimum Access - Salesforce');
        System.runAs(u) {
            Test.startTest();
            PRPC_metricResultCustomReportClass.CommunityTabReport();    
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest2() {
        user u = PRPC_TestDataFactory.createUser('PRP Admin');
        System.runAs(u) {
            Test.startTest();
            
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest3() {
        user u = PRPC_TestDataFactory.createUser('System Administrator');
        System.runAs(u) {
            Test.startTest();
            
            PRPC_metricResultCustomReportClass.CommunityTabReport();
            Test.stopTest();
        }
        
    }
    @isTest static void RestrictedTabTest6() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'North America','EMEA','Asia Pacific','Latin America'};
            list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
                list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        //Profile pf = [SELECT Id FROM Profile WHERE Name = 'PRP Partner'];
        user u = [select id from user where user.profile.name = 'PRP Partner' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.profileCheck();
        }
    }
    @isTest static void RestrictedTabTest7() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','EMEA',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12341);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','EMEA',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        //PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Bronze', Distlist.Sales_RegionA__C);
        
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'EMEA','Asia Pacific','Latin America'};
        list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
        list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        user u = [select id from user where user.profile.name = 'PRP Partner' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.profileCheck();
        }
    }
    @isTest static void RestrictedTabTest8() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','EMEA',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12341);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','EMEA',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        //PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Bronze', Distlist.Sales_RegionA__C);
        
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'EMEA','Asia Pacific','Latin America'};
        list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
        list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        user u = [select id from user where user.profile.name = 'System Administrator' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2020-01-04', '2020-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.profileCheck();
        }
    }
    
    //ETC Data Change
    @isTest static void RestrictedTabTest9() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'North America','EMEA','Asia Pacific','Latin America'};
            list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
                list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];        
        user u = [select id from user where user.profile.name = 'PRP Partner' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2024-01-04', '2024-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2024-01-04', '2024-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2024-01-04', '2024-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
        }
    }
    @isTest static void RestrictedTabTest10() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'North America','EMEA','Asia Pacific','Latin America'};
            list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
                list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];        
        user u = [select id from user where user.profile.name = 'PRP Partner' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2023-01-04', '2023-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2023-01-04', '2023-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2023-01-04', '2023-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');           
        }
    }
    
    @isTest static void RestrictedTabTest11() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','North America',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12345);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        PRPC_TestDataFactory.insertKpiRec(Distlist.Id, integer.valueof(Distlist.SAP_ID__c), 'Gold', Distlist.Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'North America','EMEA','Asia Pacific','Latin America'};
            list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
                list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        user u = [select id from user where user.profile.name = 'PRP Partner' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2023-01-04', '2024-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2023-01-04', '2024-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2023-01-04', '2024-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Distributor', 'MTH');          
        }
    }
    @isTest static void RestrictedTabTestddlr12() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','EMEA',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12341);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','EMEA',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'EMEA','Asia Pacific','Latin America'};
        list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
        list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        user u = [select id from user where user.profile.name = 'System Administrator' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2024-01-04', '2024-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2024-01-04', '2024-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
            
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2024-01-04', '2024-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
    }
    @isTest static void RestrictedTabTestddlr13() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','EMEA',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12341);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','EMEA',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'EMEA','Asia Pacific','Latin America'};
        list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
        list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        user u = [select id from user where user.profile.name = 'System Administrator' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2023-01-04', '2023-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2023-01-04', '2023-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2023-01-04', '2023-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
    }
    @isTest static void RestrictedTabTestddlr14() {
        PRPC_TestDataFactory.insertReport('Metrics Total','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Period__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Metric Comparison Summary','KPI__C','Customer__r.Name,Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        PRPC_TestDataFactory.insertReport('Performance Comparison Summary Report','KPI__C','Customer__r.Name,Customer__r.Sold_To_Code__c,Customer__r.Sales_RegionA__c,Customer_SAP_Id__c,Customer__r.ShippingCity,Month_String__c,Metric_Detail__c,Period__c,Branch_Score__c,Distributor_Avg__c,Region_Avg__c','North America','Distributor');
        list<Account>accList = PRPC_TestDataFactory.createAccount('D','EMEA',1,false,false);
        Contact cont = PRPC_TestDataFactory.createContact(accList[0], True);
        Account Distlist = PRPC_TestDataFactory.createBranch(accList[0],True,12341);
        list<Account>accListDDLR = PRPC_TestDataFactory.createAccount('DDLR','EMEA',1,False,False);
        PRPC_TestDataFactory.insertKpiRec(accList[0].Id, integer.valueof(accList[0].SAP_ID__c), 'Gold', accList[0].Sales_RegionA__C);
        
        list<string>DistributorList = new list<string>();
        list<string>blanklist = new list<string>();
        list<string>BranchList = new list<string>();
        list<string>SelectDealer = new list<string>();
        list<string>selectedRegion = new list<string>{'EMEA','Asia Pacific','Latin America'};
        list<string>MetricDetail = new list<string>{'CSI_Parts__c','CSI_Service__c','Turnaround_Time_I__c','Turnaround_Time_M__c','Turnaround_Time_O__c','Training__c','Total_Parts_Sold_ReTran__c','TPS__c'};
        list<Account>DistAcc = new list<Account>([select id,Type,CitySAPField__c from Account]);
        for(Account acc :DistAcc){
            if(acc.Type == 'Distributor' ){
                DistributorList.add(acc.Id);
            }else if(acc.Type == 'Direct Dealer'){
                SelectDealer.add(acc.Id);
            }else if(acc.Type == 'Distributor Branch'){
                BranchList.add(acc.CitySAPField__c);
            }
        }
        
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c,Partner_Type__c,Report_Region__c, Report_Columns__c FROM Reporting_Type__c];
        user u = [select id from user where user.profile.name = 'System Administrator' and isActive = true limit 1];
        system.debug('user: '+u);
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(MetricDetail, DistributorList, BranchList, selectedRegion, rp[0].Report_Columns__c, 'KPI__c', '2023-01-04', '2024-12-04', rp[0].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[1].Report_Columns__c, 'KPI__c', '2023-01-04', '2024-12-04', rp[1].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');
        }
        system.runAs(u){
            PRPC_metricResultCustomReportClass.FetchRecordsforTable(blanklist, DistributorList, BranchList, selectedRegion, rp[2].Report_Columns__c, 'KPI__c', '2023-01-04', '2024-12-04', rp[2].Name, SelectDealer, SelectDealer, 'Direct Dealer', 'MTH');            
        }
    }
    
    @isTest
    static void testMetricDetailForDate() {
        Date validFromDate = Date.newInstance(2023, 1, 1);
        Date validToDate = Date.newInstance(2024, 1, 1);
        PRPC_metricResultCustomReportClass.MetricDetailForDate(validFromDate, validToDate);
        Date invalidFromDate = Date.newInstance(2024, 1, 1);
        Date invalidToDate = Date.newInstance(2025, 1, 1);
        PRPC_metricResultCustomReportClass.MetricDetailForDate(invalidFromDate, invalidToDate);
    }
    
}