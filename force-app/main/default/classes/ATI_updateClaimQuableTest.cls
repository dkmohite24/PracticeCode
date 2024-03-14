@isTest
public class ATI_updateClaimQuableTest {
    @testSetup
    static void testSetupMethod(){
        Test.startTest();
         //create account
        List<Account> accountLst = TestDataFactory.createATIDistributorAccount(1);
        insert accountLst;
        
        Id machineRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId();
        
        //Create Warranty Product
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //create Business Category Configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        //create Vocation Codes
        List<WOD_2__Warranty_Code__c> warrantyVocationCodeLst = TestDataFactory.createWarrantyCode(1,'Vocation Codes');
        warrantyVocationCodeLst[0].Name='AG01';
        warrantyVocationCodeLst[0].ATI_IsActive__c=true;
      //  warCodeLst.addAll(warrantyVocationCodeLst);
        
        //create Warranty Code
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //Inventory Creation
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(1,'Retail');
        invLst[0].WOD_2__Account__c = accountLst.get(0).Id;
        invLst[0].WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
        invLst[0].WOD_2__Item__c = warrantyProLst[2].Id;
        invLst[0].Wod_2__Manufacturing_Date__c = Date.today();
        invLst[0].Wod_2__Manufacturing_Date__c = Date.today();
        invLst[0].ATI_Vocation_Code__c = warrantyVocationCodeLst[0].id;
        invLst[0].WOD_2__Customer__c = customerAccount[0].id;
        insert invLst;
        
        //Claim creation
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.CurrencyISOCode = 'USD';
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Account__c = accountLst[0].id;
            claimObj.WOD_2__Inventory__c = invLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'SN001';
        }
        claimLst[0].RecordTypeId = machineRecordTypeId;
        claimLst[0].WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
        claimLst[0].WOD_2__Units_Usage__c = 12;
        insert claimLst;
        
        //WR create
         List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invLst[0].Id;
            wrRec.WOD_2__Account__c = accountLst[0].Id;
            wrRec.WOD_2__Customer__c = customerAccount[0].id;
            wrRec.WOD_2__Status__c='Registered';
        }
        insert wrList;
        
        //Transaction Memo History
        List<WOD_2__Transaction_Memo_History__c> transacMemoList = TestDataFactory.createTransactionMemo(1);
        for(WOD_2__Transaction_Memo_History__c memoRec : transacMemoList){
            memoRec.WOD_2__Settlement_Category__c='EWP';
            memoRec.WOD_2__Transaction_Status__c='Pending';
            memoRec.WOD_2__Transaction_Type__c='Debit';
            memoRec.ATI_Warranty_Registration__c=wrList[0].Id;
            memoRec.ATI_Type__c='Claim';
            memoRec.WOD_2__Claim__c= claimLst[0].Id;
        }
        insert transacMemoList;
        
        Test.stopTest();
    }
    
    @isTest
    private static void updateClaimQuable(){
        List<WOD_2__Claim__c> claimObj = [SELECT Id FROM WOD_2__Claim__c];
         System.enqueueJob(new ATI_updateClaimQuable(claimObj));
    }
    
}