@isTest
public class PRPC_rewardSummaryDisClassTest {
    @testSetup static void setup(){
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        Account acc = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, true).get(0);
        PRPC_TestDataFactory.createKPI(acc);
        PRPC_TestDataFactory.insertKPISetupAndRange('North America', '2020', 'Distributor');
        PRPC_TestDataFactory.insertKPISetupAndRange('North America', '2023', 'Distributor');
        PRPC_TestDataFactory.insertKPISetupAndRange('North America', '2024', 'Distributor');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2020', 'Distributor', 'January');
        PRPC_TestDataFactory.insertPRPSetupAndRange('Latin America', '2020', 'Distributor', 'February');
        PRPC_TestDataFactory.insertPRPSetupAndRange('Latin America', '2020', 'Distributor', 'March');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2023', 'Distributor', 'January');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2024', 'Distributor', 'January');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2023', 'Distributor', 'February');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2024', 'Distributor', 'February');
        
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2023', 'Distributor', 'March');
        PRPC_TestDataFactory.insertPRPSetupAndRange('North America', '2024', 'Distributor', 'March');
        Account acc1 = PRPC_TestDataFactory.createAccount('DDLR', 'Latin America', 1, true, true).get(0);
        PRPC_TestDataFactory.createKPI(acc1);
        PRPC_TestDataFactory.insertKPISetupAndRange('Latin America', '2020', 'Direct Dealer');
        PRPC_TestDataFactory.insertPRPSetupAndRange('Latin America', '2020', 'Direct Dealer', 'January');
    }
    static testMethod void testMethod1() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;         
        
        List<Account> distributor = new List<Account>();
        distributor = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account limit 1];
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='Latin America' LIMIT 1];
        User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                  LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT Id,SAP_ID__c FROM Account WHERE Parent.Id = :u.Contact.AccountId LIMIT 1];
        List<String> regionListToAdd = new List<String>();
        regionListToAdd.add('North America');
        regionListToAdd.add('Latin America');
        regionListToAdd.add('Asia Pacific');
        regionListToAdd.add('EMEA');
        KPI__c kpiInst = new KPI__c();
        Id idToInsert = branch.Id;
        List<KPI__c> kpiList = new List<KPI__c>();
        kpiList.add(kpiInst);
        PRPC_TestDataFactory.createKPI(branch);
        kpiInst = PRPC_TestDataFactory.insertKpiRec(idToInsert,Double.valueOf(branch.SAP_ID__c),'GOLD','North America');
        PRPC_rewardSummaryDisClass.generateIncentiveFile('2022','2');
        PRPC_rewardSummaryDisClass.executePRPCalculation(date.today(),date.today(),regionListToAdd);
        PRPC_rewardSummaryDisClass.getName();
        insert kpiList;
        PRPC_rewardSummaryDisClass.updateKPIsForRelease('2022','2',regionListToAdd);
        System.runAs(u){
            PRPC_rewardSummaryDisClass.profileCheck();    
        }
        PRPC_rewardSummaryDisClass.getAllBranches(distributor[0].id,'Distributor');
        PRPC_rewardSummaryDisClass.getAllBranches(distributor1.id,'Direct Dealer');
        //PRPC_rewardSummaryDisClass.getAllValue(distributor[0].id,distributor[0].CitySAPField__c,'Distributor','North America');
        // PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Direct Dealer','EMEA');
    }
    static testMethod void testMethod2() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> distributor = new List<Account>();
        distributor = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account limit 1];
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='Latin America' LIMIT 1];
        User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                  LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT Id,SAP_ID__c FROM Account WHERE Parent.Id = :u.Contact.AccountId LIMIT 1];
        KPI__c kpiInst = new KPI__c();
        Id idToInsert = branch.Id;
        List<KPI__c> kpiList = new List<KPI__c>();
        kpiList.add(kpiInst);
        PRPC_TestDataFactory.createKPI(branch);
        kpiInst = PRPC_TestDataFactory.insertKpiRec(idToInsert,Double.valueOf(branch.SAP_ID__c),'GOLD','North America');
        
        insert kpiList;
        
        
        PRPC_rewardSummaryDisClassAdmin.getAllValue(String.valueOf(distributor[0].id),distributor[0].CitySAPField__c,'Distributor','2020','January');
        PRPC_rewardSummaryDisClassAdmin.getAllValue(String.valueOf(distributor1.id),distributor1.CitySAPField__c,'Direct Dealer','2020','January');
        PRPC_rewardSummaryDisClassAdmin.getName(distributor[0].id);
        //PRPC_rewardSummaryAdminClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Direct Dealer');
    }
    static testMethod void testMethod3() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> distributor = new List<Account>();
        distributor = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account where SAP_ID__c!=NULL limit 1];
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='Latin America' LIMIT 1];
        User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                  LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account WHERE Parent.Id = :u.Contact.AccountId LIMIT 1];
        KPI__c kpiInst = new KPI__c();
        kpiInst.Year__c=2024;
        kpiInst.Month__c=2;
        kpiInst.Period__c='YTD';
        kpiInst.isPartOfPRP__c=True;
        kpiInst.Released__c='X';
        kpiInst.Region__c='North America';
        Id idToInsert = branch.Id;
        List<KPI__c> kpiList = new List<KPI__c>();
        kpiList.add(kpiInst);
        PRPC_TestDataFactory.createKPI(branch);
        kpiInst = PRPC_TestDataFactory.insertKpiRec(idToInsert,Double.valueOf(branch.SAP_ID__c),'GOLD','North America');
        insert kpiList;
        PRPC_rewardSummaryDisClass.getRange(kpiInst,'Distributor');
        PRPC_rewardSummaryDisClass.profileCheck();
        PRPC_rewardSummaryDisClass.getPickListValuesIntoList();
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2024;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=2;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        
        Insert kpiInst1;
        
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Direct Dealer','Latin America');
    }
    static testMethod void testMethodExceptionDirectDealer() {
        
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='Latin America' LIMIT 1];
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2024;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=2;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        Insert kpiInst1;
        
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Direct Dealer','Latin America');
    }
    static testMethod void testMethodDistributor() {
        
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='North America' LIMIT 1];
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2024;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=3;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        Insert kpiInst1;
        
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Distributor','North America');
    }
    static testMethod void testMethodExceptionDistributor() {
        
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='North America' LIMIT 1];
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2024;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=2;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        Insert kpiInst1;
        
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Distributor','North America');
    }
    static testMethod void testMethodDistributorONA() {
        
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='North America' LIMIT 1];
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2024;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=2;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        Insert kpiInst1;
        
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Distributor','Latin America');
    }
    static testMethod void testMethodExceptionDistributorONA() {
        
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='North America' LIMIT 1];
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2024;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=2;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        Insert kpiInst1;
        
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Distributor','Latin America');
    }
    static testMethod void testMethod4() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> distributor = new List<Account>();
        distributor = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account where SAP_ID__c!=NULL limit 1];
        Account distributor1 = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account Where Sales_RegionA__c='Latin America' LIMIT 1];
        User u = [SELECT Alias, Email, Contact.AccountId, EmailEncodingKey, LastName, LanguageLocaleKey, IsActive,
                  LocaleSidKey, ProfileId, TimeZoneSidKey, UserName FROM User WHERE Profile.Name = 'PRP Partner' 
                  AND Contact.AccountId = :distributor[0].Id Limit 1];
        Account branch = [SELECT Id,SAP_ID__c,CitySAPField__c FROM Account WHERE Parent.Id = :u.Contact.AccountId LIMIT 1];
        KPI__c kpiInst = new KPI__c();
        kpiInst.Year__c=2023;
        kpiInst.Month__c=2;
        kpiInst.Period__c='YTD';
        kpiInst.isPartOfPRP__c=True;
        kpiInst.Released__c='X';
        kpiInst.Region__c='North America';
        Id idToInsert = branch.Id;
        List<KPI__c> kpiList = new List<KPI__c>();
        kpiList.add(kpiInst);
        PRPC_TestDataFactory.createKPI(branch);
        kpiInst = PRPC_TestDataFactory.insertKpiRec(idToInsert,Double.valueOf(branch.SAP_ID__c),'GOLD','North America');
        insert kpiList;
        PRPC_rewardSummaryDisClass.getRange(kpiInst,'Distributor');
        PRPC_rewardSummaryDisClass.profileCheck();
        PRPC_rewardSummaryDisClass.getPickListValuesIntoList();
        KPI__c kpiInst1 = new KPI__c();
        kpiInst1.Year__c=2023;
        kpiInst1.Customer__c=distributor1.id;
        kpiInst1.Month__c=2;
        kpiInst1.Period__c='YTD';
        kpiInst1.isPartOfPRP__c=True;
        kpiInst1.Released__c='X';
        kpiInst1.Region__c='North America';
        
        Insert kpiInst1;
        PRPC_rewardSummaryDisClass.getRange(kpiInst1,'Distributor');
        PRPC_rewardSummaryDisClass.getAllValue(distributor1.id,distributor1.CitySAPField__c,'Direct Dealer','Latin America');
    }
    
}