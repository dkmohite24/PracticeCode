@isTest
public class PRPC_StagingDataTableTest {
    @testSetup 
    private static void setUp() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'TriggerforAwaare'||rule.Name== 'PRPC_BranchCount' || rule.Name=='EndCustTrigger' || rule.Name=='TatTurntTrigger') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, true, false);
        PRPC_TestDataFactory.insertTATturnt(allNADistributors[0].sap_Id__c );
        TAT_Turnt_staging__c tat = new TAT_Turnt_staging__c();
        tat.Allison_Serial__c='29544858XX';
            tat.Distributor_Ship_To__c=allNADistributors[0].sap_Id__c;
            tat.Error_Log__c='';
            tat.repair_order_number__c='R1080166';
            tat.Repair_Payment__c='C';
            tat.Repair_Type__c='I';
            tat.Technician_Name__c='Fuller Cody';
            tat.Total_labor_hours__c='7';
            insert tat;
        PRPC_TestDataFactory.createEndCust(allNADistributors[0].sap_Id__c);
        End_Customer_Staging_Data__c endC = new End_Customer_Staging_Data__c();
        endC.Customer_Address_1__c='TestAd';
            endC.City__c='RKL';
            endC.Company_Name__c='TestComp';
            endC.Country__c='IN';
            endC.Distributor_Ship_To__c=allNADistributors[0].SAP_ID__C;
            insert endC;
    }
    static testMethod void findAllDistributorTest() {
        
        PRPC_StagingDataTable.findAllDistributor();
        PRPC_StagingDataTableCustom.findAllDistributor();
    }
    static testMethod void findAllTATDataTest() {
        Account accounts = new Account();
        List<TAT_Turnt_staging__c> TATturnt  = new List<TAT_Turnt_staging__c>();
        accounts = [SELECT Id from Account WHERE Type = 'Distributor' LIMIT 1];
        TATturnt = [SELECT Allison_Serial__c,Distributor_Ship_To__c,Error_Log__c FROM TAT_Turnt_staging__c];
        PRPC_StagingDataTable.findAllTATData(accounts.Id);
        system.debug('Line 20:'+ [SELECT count() FROM TAT_Turnt_staging__c]);
        PRPC_StagingDataTable.updateTATData(JSON.serialize(TATturnt));
        
        List<End_Customer_Staging_Data__c> EndCust = new List<End_Customer_Staging_Data__c>();
        accounts = [SELECT Id from Account WHERE Type = 'Distributor' LIMIT 1];
        EndCust = [SELECT Company_Name__c,City__c,Error_Log__c FROM End_Customer_Staging_Data__c];
        PRPC_StagingDataTableCustom.findAllTATData(accounts.Id);
        PRPC_StagingDataTableCustom.updateTATData(JSON.serialize(EndCust));
    }
    
    
}