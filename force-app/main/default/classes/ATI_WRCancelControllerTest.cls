/* Name: ATI_WRCancelControllerTest
   Description : Test class for ATI_WRCancelController
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Akshatha S)    23/12/2020          INITIAL DEVELOPMENT
*/
@isTest
public with sharing class ATI_WRCancelControllerTest {
	/*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
	@testSetup
    public static void testSetup(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accountList = TestDataFactory.createAccount(2); 
        for(Integer i=0;i<accountList.size();i++){
        	accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'Type'+i;
            accountList[i].WOD_2__Warranty_Account_Type__c='Dealer';
        }
        accountList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accountList;
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(3);
        /*for(Integer i=0;i<warrantyProductList.size();i++){
            warrantyProductList[i].External_Product_Code__c = 'TESTCODE'+i;
        }*/
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        insert warrantyProductList;
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        invList[0].WOD_2__Install_Date__c=system.today();
        invList[0].WOD_2__Item__c = warrantyProductList[2].Id;
        insert invList;
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accountList[0].Id;
            wrRec.WOD_2__Customer__c = accountList[1].Id;
            wrRec.WOD_2__Status__c='Registered';
        }
        insert wrList;
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        policyDefLst[0].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
        policyDefLst[0].WOD_2__Type__c = 'Extended';
        insert policyDefLst;
        List<WOD_2__Warranty_Coverages__c> warCovList = TestDataFactory.createWarrantyCoverage(1);
        for(WOD_2__Warranty_Coverages__c warCovRec : warCovList){
            warCovRec.WOD_2__Policy_Definition__c=policyDefLst[0].Id;
            warCovRec.WOD_2__Warranty_Registration__c=wrList[0].Id;
        }
        insert warCovList;
        List<WOD_2__Transaction_Memo_History__c> transacMemoList = TestDataFactory.createTransactionMemo(1);
        for(WOD_2__Transaction_Memo_History__c memoRec : transacMemoList){
            memoRec.WOD_2__Settlement_Category__c='EWP';
            memoRec.WOD_2__Transaction_Status__c='Paid';
            memoRec.WOD_2__Transaction_Type__c='Debit';
            memoRec.ATI_Warranty_Registration__c=wrList[0].Id;
        }
        insert transacMemoList;
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = TestDataFactory.createTransactionMemoLineItem(1);
        for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemRec : lineItemList){
            lineItemRec.ATI_Handling_Fee__c=10;
            lineItemRec.ATI_Late_Fee__c=20;
            lineItemRec.WOD_2__Transaction_Memo_History__c=transacMemoList[0].Id;
            lineItemRec.WOD_2__Unit_Amount__c=300;
        }
        insert lineItemList;
    }
    /*
        Method Name :   wrCancelTest
        Description :   Method to test warranty registration cancellation
    */
    @isTest
    public static void wrCancelTest(){
        List<WOD_2__Inventory__c> invList =[SELECT Id,WOD_2__Install_Date__c FROM WOD_2__Inventory__c];
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = [SELECT Id,Name,WOD_2__Unit_Amount__c,ATI_Handling_Fee__c,ATI_Late_Fee__c,WOD_2__Transaction_Memo_History__c FROM WOD_2__Transaction_Memo_History_Line_Item__c];
        WOD_2__Business_Category_Configuration_Setting__c bccsRec =[SELECT Id FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name='ATI_CancelExtendedWRWithinDays'];
        Test.startTest();
        	WOD_2.ResponseWrapper wrRes=ATI_WRCancelController.getWRInfo(invList[0].Id);
        	List<WOD_2__Warranty_Registration__c> wrList = (List<WOD_2__Warranty_Registration__c>)JSON.deserialize(wrRes.data, List<WOD_2__Warranty_Registration__c>.class);
        	ATI_WRCancelController.getReasonPickListValues();
            ATI_WRCancelController.getDaysAddedDate(invList[0].WOD_2__Install_Date__c);
            ATI_WRCancelController.getBCCSVal();
            ATI_WRCancelController.getTransactionLineItems(wrList[0].Id);
            ATI_WRCancelController.updateWR(wrList[0].Id,true,'Reason',JSON.serialize(lineItemList));
        	ATI_WRCancelController.getDaysAddedDate(null);
        	ATI_WRCancelController.updateWR(wrList[0].Id,true,'Reason',JSON.serialize(''));
        	bccsRec.Name='test';
        	update bccsRec;
        	ATI_WRCancelController.getBCCSVal();
        	ATI_WRCancelController.getDaysAddedDate(invList[0].WOD_2__Install_Date__c);
        Test.stopTest();
        
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemNewList = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
        lineItemNewList = [SELECT Id FROM WOD_2__Transaction_Memo_History_Line_Item__c where WOD_2__Transaction_Type__c= 'Credit'];
        system.assertEquals(1, lineItemNewList.size(),'Success');
    }
}