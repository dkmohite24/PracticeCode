/*
	Class Name	:	ATI_PriceDetailForWRControllerTest
	Description	:	Test class for ATI_PriceDetailForWRController
*/
@isTest
public class ATI_PriceDetailForWRControllerTest {
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
        for(Integer i=0;i<warrantyProductList.size();i++){
            warrantyProductList[i].External_Product_Code__c = 'TESTCODE'+i;
        }
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
    
    @isTest
    private static void testGetTransactionLineItems(){
        Test.startTest();
        	ATI_PriceDetailForWRController.getUserDetails(UserInfo.getUserId());
            List<WOD_2__Warranty_Registration__c> wrList = [SELECT id,WOD_2__Inventory__c,WOD_2__Customer__c,WOD_2__Status__c,WOD_2__Account__c FROM WOD_2__Warranty_Registration__c];
            List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemsLst = ATI_PriceDetailForWRController.getTransactionLineItems(wrList[0].Id);
        	System.assertEquals(1,lineItemsLst.size(),'Line Items Should be retrieved');
        	lineItemsLst[0].ATI_Handling_Fee__c = 5;
        	ATI_PriceDetailForWRController.updateTransactionLineItems(lineItemsLst);
        	System.assertEquals(5,[SELECT Id,ATI_Handling_Fee__c FROM WOD_2__Transaction_Memo_History_Line_Item__c 
                                   		WHERE Id=:lineItemsLst[0].Id].ATI_Handling_Fee__c,'Handling fee and total fee should be updated');
        Test.stopTest();
    }
}