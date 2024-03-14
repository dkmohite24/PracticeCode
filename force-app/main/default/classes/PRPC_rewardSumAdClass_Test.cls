@isTest(seeAllData = false)
private class PRPC_rewardSumAdClass_Test {
    @testSetup static void setup() {
        
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        list<Account>acclist = new list<Account>();
        acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
        Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        list<Account>acclistDDLR = PRPC_TestDataFactory.createAccount('DDLR','North America',1,False,false);
        //for(Account acc:acclist){
            //if(acc.Location_Type__c == 'DB'){
             PRPC_TestDataFactory.insertKpiRec(acclistBranch.Id,Integer.valueof(acclistBranch.SAP_ID__c),'BRONZE',acclistBranch.Sales_RegionA__c);
        PRPC_TestDataFactory.insertKpiRec(acclistDDLR[0].Id,Double.valueof(acclistDDLR[0].SAP_ID__c),'BRONZE',acclistDDLR[0].Sales_RegionA__c);
        //}
       
        //PRPC_TestDataFactory.insertKpiRec(acclist[0].Id,Integer.valueof(acclist[0].SAP_ID__c),'BRONZE',acclist[0].Sales_RegionA__c);
    }
    
    @isTest static void RewardSummAd() {
        system.debug('check: '+[select count() from Account]);
        string SelectedName;
        string SelectedLoc;
        list<Account>acclist = new list<Account>([select id,AccountSAPField__c,CitySAPField__c,Type,Location_Type__c from Account]);
        for(Account acc:acclist){
            if(acc.Location_Type__c == 'D'){
                acc.Type='Distributor';
                SelectedName=acc.AccountSAPField__c;
            }
            if(acc.Location_Type__c == 'DB'){
                acc.Type='Distributor Branch';
                SelectedLoc = acc.CitySAPField__c;
            }
            
        }
        update acclist;
        system.debug('acclist: '+acclist);
        system.debug('kpiRec: '+[SELECT Id,Customer_SAP_Id__c,Customer__r.Parent.Type, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c FROM KPI__c]);
        Test.startTest();
        PRPC_rewardSumAdClass.getType();
        //PRPC_rewardSumAdClass.getAllValues('Distributor', Date.Parse('02/02/2020'), Date.Parse('09/12/2020'), '', SelectedLoc);
        PRPC_rewardSumAdClass.getAllValues('Distributor', null, null, '', SelectedLoc);
        Test.stopTest();
        
    }
    @isTest static void RewardSummAd2() {
        system.debug('check: '+[select count() from Account]);
        string SelectedName;
        string SelectedLoc;
        list<Account>acclist = new list<Account>([select id,AccountSAPField__c,CitySAPField__c,Type,Location_Type__c from Account where Location_Type__c = 'DDLR']);
        for(Account acc:acclist){
            if(acc.Location_Type__c == 'D'){
                acc.Type='Distributor';
                SelectedName=acc.AccountSAPField__c;
            }
            if(acc.Location_Type__c == 'DDLR'){
                acc.Type='Direct Dealer';
                SelectedLoc = acc.CitySAPField__c;
            }
            
        }
        update acclist;
        system.debug('acclist: '+acclist);
        system.debug('kpiRec: '+[SELECT Id,Customer_SAP_Id__c,Customer__r.Parent.Type, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c FROM KPI__c]);
        Test.startTest();
        PRPC_rewardSumAdClass.getType();
        //PRPC_rewardSumAdClass.getAllValues('Distributor', Date.Parse('02/02/2020'), Date.Parse('09/12/2020'), '', SelectedLoc);
        PRPC_rewardSumAdClass.getAllValues('Direct Dealer', null, null, '', SelectedLoc);
        Test.stopTest();
        
    }
    @isTest static void RewardSummAd3() {
        system.debug('check: '+[select count() from Account]);
        string SelectedName;
        string SelectedLoc;
        list<Account>acclist = new list<Account>([select id,AccountSAPField__c,CitySAPField__c,Type,Location_Type__c from Account where Location_Type__c = 'DDLR']);
        for(Account acc:acclist){
            if(acc.Location_Type__c == 'D'){
                acc.Type='Distributor';
                SelectedName=acc.AccountSAPField__c;
            }
            if(acc.Location_Type__c == 'DDLR'){
                acc.Type='Direct Dealer';
                SelectedLoc = acc.CitySAPField__c;
            }
            
        }
        update acclist;
        system.debug('acclist: '+acclist);
        system.debug('kpiRec: '+[SELECT Id,Customer_SAP_Id__c,Customer__r.Parent.Type, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c FROM KPI__c]);
        Test.startTest();
        PRPC_rewardSumAdClass.getType();
        //PRPC_rewardSumAdClass.getAllValues('Distributor', Date.Parse('02/02/2020'), Date.Parse('09/12/2020'), '', SelectedLoc);
        PRPC_rewardSumAdClass.getAllValues('Direct Dealer', Date.Parse('02/02/2020'), Date.Parse('09/12/2020'), '', SelectedLoc);
        Test.stopTest();
        
    }
}