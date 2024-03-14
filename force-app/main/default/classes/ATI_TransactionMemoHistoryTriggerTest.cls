/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        17-Feb-2021
* @modified
* @description :   Test class for ATI_TransactionMemoHistoryTriggerHandler
* --------------------------------------------------------------------------------------------------
*/
@isTest
public class ATI_TransactionMemoHistoryTriggerTest {
    @TestSetup
    private static void setUp(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accountList = TestDataFactory.createAccount(2); 
        accountList[0].Name = 'Testacc';
        accountList[0].Sales_RegionA__c = 'EMEA';
        accountList[0].SAP_ID__c = '1223123';
        accountList[0].Location_Type__c = 'Type';
        accountList[0].WOD_2__Warranty_Account_Type__c='Dealer';
        insert accountList[0];
        
        accountList[1].Name = 'Testacc Child';
        accountList[1].Sales_RegionA__c = 'North America';
        accountList[1].SAP_ID__c = '1133445';
        accountList[1].Location_Type__c = 'L';
        accountList[1].WOD_2__Warranty_Account_Type__c='Customer';
        accountList[1].ParentId = accountList[0].Id;
        insert accountList[1];
        
        insert new Group(Name='ATI_Dealer_'+accountList[0].Id);
        
        //Warranty Product at Model Level for Extended Warranty Pricing
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(1);
        for(Integer i=0;i<warrantyProLst.size();i++){
            //warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
            warrantyProLst[i].WOD_2__Type__c = 'Item';
            warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
            warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        invList[0].WOD_2__Install_Date__c = system.today();
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].WOD_2__Units_Usage__c = 6000;
        insert invList;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accountList[0].Id;
            wrRec.WOD_2__Status__c='In Progress';
            wrRec.WOD_2__Customer__c=accountList[1].Id;
        }
        insert wrList;
        
        //casual part creation
        WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
        casualPart.WOD_2__Business_Unit__c = bcc.Id;
        casualPart.External_Product_Code__c = casualPart.Name;
        casualPart.WOD_2__Item_Type__c = 'Machine';
        casualPart.WOD_2__Track_Type__c = 'Non-Serialized';
        insert casualPart;
        
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casualPart.Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casualPart.Id,WOD_2__BusinessCategory__c=bcc.Id );
        claim.WOD_2__Claim_Status__c='Approved';
        insert claim;
        //ALSN-116
        WOD_2__Financial__c fl=new WOD_2__Financial__c(Name='Financial',WOD_2__Final_Requested_Amount__c= 751,WOD_2__Total_Claim_Approved_Amount__c=2,WOD_2__Total_Labor_Approved_Amount__c=1,
                                                           WOD_2__Total_Other_Approved_Amount__c=2,WOD_2__Total_Parts_Approved_Amount__c=2,WOD_2__Claim__c=claim.Id);
        insert fl;
        WOD_2__Financial_Line_Item__c fli = new WOD_2__Financial_Line_Item__c(Name='TestFLI', WOD_2__Financial__c=fl.Id, 
                                                            WOD_2__Claim__c=claim.Id,WOD_2__Total_Requested_Amount__c=10,
                                                            WOD_2__Type__c='Part', WOD_2__Cost_Category_Type__c='OEM Parts',
                                                            ATI_Factory_Cost__c=10.0,ATI_Factory_Price__c=20.0,ATI_Landed_Part_Markup__c=10.0,ATI_Markup__c=10.0);
        insert fli;
    }
    
    @isTest
    private static void testSharingTMHRecords(){
        WOD_2__Warranty_Registration__c wrObj = [SELECT Id,WOD_2__Account__c FROM WOD_2__Warranty_Registration__c LIMIT 1];
        WOD_2__Transaction_Memo_History__c tmhObj = new WOD_2__Transaction_Memo_History__c(ATI_Warranty_Registration__c=wrObj.Id);
        Test.startTest();
        insert tmhObj;
        String nameStr = 'ATI_Dealer_'+wrObj.WOD_2__Account__c;
        Group grpObj = [SELECT Id FROM Group WHERE Name=:nameStr];
        ATI_TransactionMemoHistoryShareQueable enqueueJobObj = new ATI_TransactionMemoHistoryShareQueable(new Set<String>{nameStr},
                                                                                                          new Set<Id>{tmhObj.Id});
        System.enqueueJob(enqueueJobObj);
        Test.stopTest();
        
        System.assertEquals(1,[SELECT Id FROM WOD_2__Transaction_Memo_History__Share WHERE ParentId=:tmhObj.Id AND UserOrGroupId=:grpObj.Id].size(),'transactions should be shared to account public group');
    }
    
    //ALSN-116
    @isTest
    private static void updateTMHRecords(){
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Account__c FROM WOD_2__Claim__c LIMIT 1];
        WOD_2__Financial__c fl=new WOD_2__Financial__c(Name='Financial',WOD_2__Final_Requested_Amount__c= 751,WOD_2__Total_Claim_Approved_Amount__c=2,WOD_2__Total_Labor_Approved_Amount__c=1,
                                                           WOD_2__Total_Other_Approved_Amount__c=2,WOD_2__Total_Parts_Approved_Amount__c=2,WOD_2__Claim__c=claimObj.Id);
        insert fl;
        WOD_2__Financial_Line_Item__c fli = new WOD_2__Financial_Line_Item__c(Name='TestFLI', WOD_2__Financial__c=fl.Id, 
                                                            WOD_2__Claim__c=claimObj.Id,WOD_2__Total_Requested_Amount__c=10,
                                                            WOD_2__Type__c='Part', WOD_2__Cost_Category_Type__c='OEM Parts',
                                                            ATI_Factory_Cost__c=10.0,ATI_Factory_Price__c=20.0,ATI_Landed_Part_Markup__c=10.0,ATI_Markup__c=10.0);
        insert fli;
        List<WOD_2__Transaction_Memo_History__c> transacMemoList = TestDataFactory.createTransactionMemo(1);
        for(WOD_2__Transaction_Memo_History__c memoRec : transacMemoList){
            memoRec.WOD_2__Transaction_Status__c='Pending';
            memoRec.WOD_2__Transaction_Type__c='Credit';
            memoRec.WOD_2__Claim__c=claimObj.Id;
        }
        insert transacMemoList;
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = TestDataFactory.createTransactionMemoLineItem(1);
        for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemRec : lineItemList){
            lineItemRec.WOD_2__Transaction_Memo_History__c=transacMemoList[0].Id;
            lineItemRec.WOD_2__Unit_Amount__c=300;
            lineItemRec.WOD_2__Financial_Line_Item__c = fli.id;
        }
        insert lineItemList;
        transacMemoList[0].WOD_2__Transaction_Status__c = 'Paid';
        update transacMemoList;
    }
    
    @isTest
    private static void testSharingTMHRecordsForClaim(){
        Test.startTest();
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Account__c FROM WOD_2__Claim__c LIMIT 1];
        WOD_2__Transaction_Memo_History__c tmhObj = new WOD_2__Transaction_Memo_History__c(WOD_2__Claim__c=claimObj.Id);
        insert tmhObj;
        String nameStr = 'ATI_Dealer_'+claimObj.WOD_2__Account__c;
        Group grpObj = [SELECT Id FROM Group WHERE Name=:nameStr];
        ATI_TransactionMemoHistoryShareQueable enqueueJobObj = new ATI_TransactionMemoHistoryShareQueable(new Set<String>{nameStr},
                                                                                                          new Set<Id>{tmhObj.Id});
        System.enqueueJob(enqueueJobObj);
        Test.stopTest();        
        System.assertEquals(1,[SELECT Id FROM WOD_2__Transaction_Memo_History__Share WHERE ParentId=:tmhObj.Id AND UserOrGroupId=:grpObj.Id].size(),'transactions should be shared to account public group');
    }
}