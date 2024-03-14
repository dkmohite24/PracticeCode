@isTest(seeAllData = false)
private class PRPC_dataMovementForPartsOrder_Test {
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
        List<Disable_Rules__c> disableRules3 = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules3 ) {
            if(rule.Name== 'TatTurntTrigger') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        
        list<Account>acclist = PRPC_TestDataFactory.createAccount('D','North America',1,False,false);
        Account acclistBranch = PRPC_TestDataFactory.createBranch(acclist[0],True,12345);
        
        Parts_Order_Staging__c PO = new Parts_Order_Staging__c();
        PO.Delivery_Priority__c='3';
        PO.Line_Item__c='30';
        PO.Material_Entered__c='29539579';
        PO.Order_Type__c='OR';
        PO.Report_Execution_Date__c='08/08/2020';
        PO.Sales_Order__c='1354970';
        PO.Distributor_Ship_To__c=acclistBranch.SAP_ID__C;
        insert PO;
        Parts_Order_International_Staging__c POint = new Parts_Order_International_Staging__c();
        POint.Delivery_Priority__c='3';
        POint.Line_Item__c='30';
        POint.Material_Entered__c='29539579';
        POint.Order_Type__c='OR';
        POint.Report_Execution_Date__c='08/08/2020';
        POint.Sales_Order__c='1354970';
        POint.Distributor_Ship_To__c=acclistBranch.SAP_ID__C;
        insert POint;
        End_Customer_Staging_Data__c endC = new End_Customer_Staging_Data__c();
        endC.Customer_Address_1__c='TestAd';
        endC.City__c='RKL';
        endC.Company_Name__c='TestComp';
        endC.Country__c='IN';
        endC.Date_Of_Submission__c='08/08/2020';
        endC.Distributor_Ship_To__c=acclistBranch.SAP_ID__C;
        insert endC;
        End_Customer__c endCu = new End_Customer__c();
        endCu.Repair_Order_or_Parts_Invoice__c='TestAd';
        endCu.Customer__c = acclistBranch.id;
        endCu.Repair_Order_or_Parts_Invoice__c = 'test';
        endCu.Repair_Order__c = 'test2';
        endCu.Parts_Invoice__c= 'test3';
        endCu.Distributor_Ship_To__c=acclistBranch.SAP_ID__C;
        endCu.Date_Of_Submission__c=System.Today()-30;
        insert endCu;
        
        TAT_Data__C tt = New TAT_Data__C();
        tt.Extraction_Date__c=System.Today()-30;
        tt.Dealer_Id__c = acclistBranch.Id;
        tt.vin__c = 'dfxghjkndc23456789876';
        tt.Distributor_Ship_To__c = acclistBranch.SAP_ID__C;
        tt.Allison_Serial__c = '234567898';
        tt.Source_Type__c = 'Distributor';
        tt.Date_of_File_Submission__c = System.Today()-30;
        tt.Total_labor_hours__c = '5';
        insert tt;
        
    }
    
    @isTest static void getALLPickListValuesTest() {
        
        Test.startTest();
        PRPC_dataMovementForPartsOrder c = new PRPC_dataMovementForPartsOrder();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    @isTest static void getALLPickListValuesTest2() {
        
        Test.startTest();
        PRPC_dataMovementForPartsOderINT c = new PRPC_dataMovementForPartsOderINT();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    @isTest static void getALLPickListValuesTest3() {
        
        Test.startTest();
        PRPC_DataMovementForEndcustomer c = new PRPC_DataMovementForEndcustomer();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    @isTest static void getALLPickListValuesTest4() {
        
        Test.startTest();
        PRPC_DeleteDuplicateRecordFromReal.queryInclude = 'End_Customer__c';
        PRPC_DeleteDuplicateRecordFromReal c = new PRPC_DeleteDuplicateRecordFromReal();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    @isTest static void getALLPickListValuesTest5() {
        list<end_customer__C> uplist = [select id,Repair_Order_or_Parts_Invoice__c from end_customer__C];
        uplist[0].Repair_Order_or_Parts_Invoice__c = null;
        update uplist;
        Test.startTest();
        PRPC_DeleteDuplicateRecordFromReal.queryInclude = 'End_Customer__c';
        PRPC_DeleteDuplicateRecordFromReal c = new PRPC_DeleteDuplicateRecordFromReal();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    @isTest static void getALLPickListValuesTest6() {
        list<end_customer__C> uplist = [select id,Repair_Order_or_Parts_Invoice__c from end_customer__C];
        uplist[0].Repair_Order_or_Parts_Invoice__c = null;
        uplist[0].Repair_Order__c = null;
        update uplist;
        Test.startTest();
        PRPC_DeleteDuplicateRecordFromReal.queryInclude = 'End_Customer__c';
        PRPC_DeleteDuplicateRecordFromReal c = new PRPC_DeleteDuplicateRecordFromReal();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    @isTest static void getALLPickListValuesTest9() {
        
        Test.startTest();
        PRPC_DeleteDuplicateRecordFromReal.queryInclude = 'TAT_Data__C';
        PRPC_DeleteDuplicateRecordFromReal c = new PRPC_DeleteDuplicateRecordFromReal();
        Database.executeBatch(c);
        Test.stopTest();
        
    }
    
}