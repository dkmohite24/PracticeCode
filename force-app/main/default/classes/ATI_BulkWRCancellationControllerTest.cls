/* Name: ATI_BulkWRCancellationControllerTest
   Description : Test class for ATI_BulkWRCancellationController
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                 DATE               DETAIL                          UserStory/Req#
   1.0 -       Tavant (Akshatha S)    04/01/2020         INITIAL DEVELOPMENT
*/
@isTest
public class ATI_BulkWRCancellationControllerTest {
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
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        insert warrantyProductList;
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(30);
        integer j=0;
        for(WOD_2__Inventory__c invRec : invList){
            invRec.WOD_2__Business_Unit__c = bcc.Id;
            invRec.WOD_2__Account__c = accountList[0].Id;
            invRec.WOD_2__Install_Date__c=system.today();
            invRec.WOD_2__Item__c = warrantyProductList[2].Id;
            invRec.WOD_2__Serial_Number__c = 'INV-'+j;
            j++;
        }
        invList[2].WOD_2__Install_Date__c=system.today().addDays(-5000);
        insert invList;
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(30);
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Customer__c = accountList[1].Id;
            wrRec.WOD_2__Account__c = invList[0].WOD_2__Account__c;
            wrRec.WOD_2__Status__c='Registered';
        }
        wrList[1].WOD_2__Inventory__c=invList[1].Id;
        wrList[2].WOD_2__Inventory__c=invList[2].Id;
        wrList[5].WOD_2__Inventory__c=invList[4].Id;
        for(integer i=6;i<wrList.size();i++){
            wrList[i].WOD_2__Inventory__c=invList[i-1].Id;
        }
        insert wrList;
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        policyDefLst[0].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
        policyDefLst[0].WOD_2__Type__c = 'Extended';
        insert policyDefLst;
        List<WOD_2__Warranty_Coverages__c> warCovList = TestDataFactory.createWarrantyCoverage(25);
        for(WOD_2__Warranty_Coverages__c warCovRec : warCovList){
            warCovRec.WOD_2__Policy_Definition__c=policyDefLst[0].Id;
            warCovRec.WOD_2__Warranty_Registration__c=wrList[0].Id;
            warCovRec.WOD_2__Is_Active__c=true;
        }
        warCovList[1].WOD_2__Warranty_Registration__c=wrList[2].Id;
        warCovList[2].WOD_2__Warranty_Registration__c=wrList[5].Id;
        for(integer i=3;i<warCovList.size();i++){
            warCovList[i].WOD_2__Warranty_Registration__c=wrList[i+3].Id;
        }
        insert warCovList;
        List<WOD_2__Transaction_Memo_History__c> transacMemoList = TestDataFactory.createTransactionMemo(20);
        for(integer i=0;i<transacMemoList.size();i++){
            transacMemoList[i].ATI_Warranty_Registration__c=wrList[i+5].Id;
            transacMemoList[i].WOD_2__Settlement_Category__c='EWP';
            transacMemoList[i].ATI_Type__c='EWP';
            transacMemoList[i].WOD_2__Transaction_Status__c='Paid';
            transacMemoList[i].WOD_2__Transaction_Type__c='Debit';
        }
        insert transacMemoList;
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = TestDataFactory.createTransactionMemoLineItem(20);
        for(integer i=0;i<lineItemList.size();i++){
            lineItemList[i].WOD_2__Transaction_Memo_History__c=transacMemoList[i].Id;
            lineItemList[i].ATI_Handling_Fee__c=10;
            lineItemList[i].ATI_Late_Fee__c=20;
            lineItemList[i].WOD_2__Unit_Amount__c=300;
        }
        insert lineItemList;
        
        List<WOD_2__Batch_Log__c> batchLogList = TestDataFactory.createBatchLog(1);
        for(WOD_2__Batch_Log__c batchLogRec : batchLogList){
            batchLogRec.Name='BulkCancellationFile.csv';
            batchLogRec.ATI_Related_Record_Id__c = 'WRCancellationUpload';
            batchLogRec.WOD_2__Process_Type__c='WRCancellationUpload';
        }
        insert batchLogList;
    }
    /*
        Method Name :   wrBulkCancelTest
        Description :   Method to test bulk warranty registration cancellation
    */
  /*  @isTest
    public static void wrBulkCancelTest(){
        List<WOD_2__Inventory__c> invList=[SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c];
        WOD_2__Batch_Log__c batchLogObj=[SELECT Id FROM WOD_2__Batch_Log__c LIMIT 1];
        Test.startTest();
          String strSerialNumArray='[{"Serial Number":""},{"Serial Number":"Test-3"}';
          for(WOD_2__Inventory__c invRec: invList){
                strSerialNumArray+=',{"Serial Number":"';
                strSerialNumArray+=invRec.WOD_2__Serial_Number__c;
                strSerialNumArray+='"}';
            }
          strSerialNumArray+=']';
          ATI_BulkUploadController.uploadChunks(strSerialNumArray,batchLogObj.id);
          ATI_BulkUploadController.callBatchJobToInsert(batchLogObj.id);
        Test.stopTest();
        
        batchLogObj = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Success_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c where Id=:batchLogObj.Id];
        system.assertEquals(32, batchLogObj.WOD_2__Total_Record_Count__c,'Total');
        //system.assertEquals(20, batchLogObj.WOD_2__Success_Record_Count__c,'Success');
        system.assertEquals(12, batchLogObj.WOD_2__Failure_Record_Count__c,'Failure');
    }*/
    
    /*
        Method Name :   wrBulkCancelFailureTest
        Description :   Method to test bulk warranty registration cancellation
    */
    @isTest
    public static void wrBulkCancelFailureTest(){
        List<WOD_2__Inventory__c> invList=[SELECT Id,WOD_2__Serial_Number__c FROM WOD_2__Inventory__c LIMIT 5];
        List<Account> accList=[SELECT Id,WOD_2__Warranty_Account_Type__c FROM Account Where WOD_2__Warranty_Account_Type__c = 'Customer'];
        accList[0].WOD_2__Warranty_Account_Type__c = 'Dealer';
        update accList;
        WOD_2__Batch_Log__c batchLogObj=[SELECT Id FROM WOD_2__Batch_Log__c LIMIT 1];
        Test.startTest();
          String strSerialNumArray='[';
          for(WOD_2__Inventory__c invRec: invList){
                strSerialNumArray+='{"Serial Number":"';
                strSerialNumArray+=invRec.WOD_2__Serial_Number__c;
                strSerialNumArray+='"},';
            }
          strSerialNumArray=strSerialNumArray.removeEnd(',');
          strSerialNumArray+=']';
          ATI_BulkUploadController.uploadChunks(strSerialNumArray,batchLogObj.id);
          ATI_BulkUploadController.callBatchJobToInsert(batchLogObj.id);
        Test.stopTest();
        
        batchLogObj = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Success_Record_Count__c,WOD_2__Failure_Record_Count__c FROM WOD_2__Batch_Log__c where Id=:batchLogObj.Id];
        system.assertEquals(5, batchLogObj.WOD_2__Total_Record_Count__c,'Total');
        system.assertEquals(0, batchLogObj.WOD_2__Success_Record_Count__c,'Success');
        system.assertEquals(5, batchLogObj.WOD_2__Failure_Record_Count__c,'Failure');
    }
}