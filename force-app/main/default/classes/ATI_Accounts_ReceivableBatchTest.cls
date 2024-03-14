@isTest
public class ATI_Accounts_ReceivableBatchTest{
    @testSetup
    public static void testSetup(){
        Test.startTest();
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
            accountList[i].Type='Service Dealer';
        }
        accountList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accountList;
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(3);
        
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
        
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(2);
        policyDefLst[0].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
        policyDefLst[0].WOD_2__Type__c = 'Extended';
        policyDefLst[1].WOD_2__Type__c = 'Standard';
        policyDefLst[1].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
        insert policyDefLst;
        
        List<WOD_2__Warranty_Coverages__c> warCovList = TestDataFactory.createWarrantyCoverage(1);
        for(WOD_2__Warranty_Coverages__c warCovRec : warCovList){
            warCovRec.WOD_2__Policy_Definition__c=policyDefLst[0].Id;
            warCovRec.WOD_2__Warranty_Registration__c=wrList[0].Id;
        }
        insert warCovList;
        
         //create Warranty Code
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
       
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(1);
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
        }
        insert warrantyProPartLst;
        //DB
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst1 = TestDataFactory.createWarrantyProductItem(1);
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst1){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            //wp.WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProPartLst1;
        //DB end
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invList.size());
        insert vehicleInfoLst;
        
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invList.size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invList[i].Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst[i].id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        
      //create claim
        /*List<WOD_2__Claim__c> claimLst = TestDataFactory.createMachineClaim(1); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Approved';
            claimObj.WOD_2__Account__c = accountList[0].id;
            claimObj.ATI_Submittal_Indicator__c = 'I';
            claimObj.WOD_2__Inventory__c = invList[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProductList[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = bcc.id;
            claimObj.WOD_2__Model_Number__c = warrantyProductList[2].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
            claimObj.ATI_Tracking_Number__c = 'Y023434987';
            claimObj.WOD_2__Work_Order__c = 'Test';
            claimObj.ATI_Disposition_Code__c = '101-Claim Type is missing or not valid';
            claimObj.WOD_2__Applicable_Policy__c=policyDefLst[1].Id;
            claimObj.WOD_2__Is_Pre_Authorization_Required__c= true;
            claimObj.WOD_2__Pre_Authorization_Comments__c='Test';
            
            
        }
        insert claimLst;*/
        
        Id partClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        Id part90ClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Paid';
            claimObj.WOD_2__Account__c = accountList[0].id;
            claimObj.WOD_2__Inventory__c = invList[0].id;
            //claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst1[0].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = bcc.id;
            claimObj.WOD_2__Model_Number__c = warrantyProductList[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
            claimObj.WOD_2__Applicable_Policy__c = policyDefLst[0].Id;
        }
        claimLst[0].RecordTypeId = partClaimId;
        claimLst[1].RecordTypeId = part90ClaimId;
        claimLst[1].WOD_2__Part__c = warrantyProductList[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        insert claimLst[0];
        insert claimLst[1];
        TriggerHandler.clearBypass('ATI_ClaimTriggerHandler');

        
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
       // installedClaimParts[0].WOD_2__Warranty_Product__c = warrantyProPartLst[0].Id;
        installedClaimParts[0].WOD_2__Warranty_Product__c = warrantyProPartLst1[0].Id;
        installedClaimParts[0].WOD_2__Claim__c = claimLst[0].Id;
        
        //insert installedClaimParts;
        
       ATI_Part_Markup__c partMarkupObj = new ATI_Part_Markup__c(ATI_Customer_Group_Type__c='01',ATI_Claim_Type__c='01',
                                                                  ATI_Part_Markup_Percentage__c=5,ATI_Active_From__c = System.today().addDays(-365),
                                                                  ATI_Active_Until__c = System.today().addDays(365),ATI_Active__c=true);
        insert partMarkupObj;
        
        WOD_2__Other_Cost__c otherCostObj = new WOD_2__Other_Cost__c(WOD_2__Cost_Category_Type__c='Sublet',WOD_2__Claim__c=claimLst[0].Id,
                                                                     WOD_2__UnitsUsage__c=1,WOD_2__Rate_PerUnit__c=10);
        insert otherCostObj;
        
       List<WOD_2__Transaction_Memo_History__c> transacMemoList = TestDataFactory.createTransactionMemo(1);
        for(WOD_2__Transaction_Memo_History__c memoRec : transacMemoList){
            memoRec.WOD_2__Settlement_Category__c='EWP';
            memoRec.WOD_2__Transaction_Status__c='Pending';
            memoRec.WOD_2__Transaction_Type__c='Debit';
            memoRec.ATI_Type__c='Claim';
            memoRec.WOD_2__Claim__c= claimLst[0].Id;
        }
        insert transacMemoList;
        List<WOD_2__Transaction_Memo_History__c> transacMemoList1 = TestDataFactory.createTransactionMemo(1);
        for(WOD_2__Transaction_Memo_History__c memoRec : transacMemoList1){
            memoRec.WOD_2__Settlement_Category__c='EWP';
            memoRec.WOD_2__Transaction_Status__c='Pending';
            memoRec.WOD_2__Transaction_Type__c='Debit';
            memoRec.ATI_Warranty_Registration__c=wrList[0].Id;
            memoRec.ATI_Type__c='EWP';
        }
        insert transacMemoList1;
        
        List<WOD_2__Financial_Line_Item__c> financialLineItemList =[Select WOD_2__Claim__c,Id,ATI_Factory_Price__c,WOD_2__Financial__c,ATI_Factory_Cost__c,WOD_2__Approved_Amount__c,WOD_2__Approved_Quantity__c,WOD_2__System_PerUnit_Price__c,ATI_Landed_Part_Markup__c,WOD_2__Installed_Claim_Part__c From WOD_2__Financial_Line_Item__c];
        WOD_2__Financial_Line_Item__c fli = new WOD_2__Financial_Line_Item__c(Name='TestFLI', WOD_2__Financial__c = financialLineItemList[0].WOD_2__Financial__c,
                                                                              WOD_2__Claim__c=claimLst[0].Id,WOD_2__Total_Requested_Amount__c=10,
                                                                              WOD_2__Type__c='Part', WOD_2__Cost_Category_Type__c='OEM Parts',
                                                                              ATI_Factory_Cost__c=10.0,ATI_Factory_Price__c=20.0,ATI_Landed_Part_Markup__c=10.0,ATI_Markup__c=10.0,
                                                                              WOD_2__Approved_Amount__c=10,WOD_2__Approved_Quantity__c=1);
        insert fli;
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = TestDataFactory.createTransactionMemoLineItem(3);
            lineItemList[0].ATI_Handling_Fee__c=10;
            lineItemList[0].ATI_Late_Fee__c=20;
            lineItemList[0].WOD_2__Transaction_Memo_History__c=transacMemoList[0].Id;
            lineItemList[0].WOD_2__Unit_Amount__c=300;
        	lineItemList[0].WOD_2__Quantity__c= 2;
        	lineItemList[0].WOD_2__Financial_Line_Item__c = financialLineItemList[0].Id;
        	
        	lineItemList[1].ATI_Handling_Fee__c=20;
            lineItemList[1].ATI_Late_Fee__c=10;
            lineItemList[1].WOD_2__Transaction_Memo_History__c=transacMemoList[0].Id;
            lineItemList[1].WOD_2__Unit_Amount__c=10;
        	lineItemList[1].WOD_2__Quantity__c= 1;
        	lineItemList[1].WOD_2__Financial_Line_Item__c = fli.Id;
        
        	lineItemList[2].ATI_Handling_Fee__c=30;
            lineItemList[2].ATI_Late_Fee__c=20;
            lineItemList[2].WOD_2__Transaction_Memo_History__c=transacMemoList1[0].Id;
            lineItemList[2].WOD_2__Unit_Amount__c=350;
        	lineItemList[2].WOD_2__Quantity__c= 2;
        insert lineItemList;

        List<ATI_Accounts_Receivable_Interface__c> customSettingList = new List<ATI_Accounts_Receivable_Interface__c>();
        ATI_Accounts_Receivable_Interface__c customSet1= new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '-7',Name='Days');
       	ATI_Accounts_Receivable_Interface__c customSet2 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Accounts Receivable',Name='Log Name');
    	ATI_Accounts_Receivable_Interface__c customSet3 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '01',Name='Claim Type 1');
        ATI_Accounts_Receivable_Interface__c customSet4 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '02',Name='Claim Type 2');
        ATI_Accounts_Receivable_Interface__c customSet5 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '03',Name='Claim Type 3');
        ATI_Accounts_Receivable_Interface__c customSet6 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '53',Name='Claim Type 53');
        ATI_Accounts_Receivable_Interface__c customSet7 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '05',Name='Claim Type 5');
        ATI_Accounts_Receivable_Interface__c customSet8 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '04',Name='Claim Type 4');
        ATI_Accounts_Receivable_Interface__c customSet9 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '17',Name='Claim Type 17');
        ATI_Accounts_Receivable_Interface__c customSet10 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Freight',Name='Cost Category Freight');
        ATI_Accounts_Receivable_Interface__c customSet11 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Duty',Name='Cost Category Duty');
        ATI_Accounts_Receivable_Interface__c customSet12 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Labor',Name='Cost Category Labor');
        ATI_Accounts_Receivable_Interface__c customSet13 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Misc Material',Name='Cost Category Misc');
        ATI_Accounts_Receivable_Interface__c customSet14 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'OEM Parts',Name='Cost Category OEM');
        ATI_Accounts_Receivable_Interface__c customSet15 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Overtime',Name='Cost Category Overtime');
        ATI_Accounts_Receivable_Interface__c customSet16 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Parts',Name='Cost Category Parts');
        ATI_Accounts_Receivable_Interface__c customSet17 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Sublet',Name='Cost Category Sublet');
        ATI_Accounts_Receivable_Interface__c customSet18 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Tax',Name='Cost Category Tax');
        ATI_Accounts_Receivable_Interface__c customSet19 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Towing',Name='Cost Category Towing');
        ATI_Accounts_Receivable_Interface__c customSet20 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Unit',Name='Cost Category Unit');
        ATI_Accounts_Receivable_Interface__c customSet21 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = '200',Name='Status Code');
		ATI_Accounts_Receivable_Interface__c customSet22 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'ATI',Name='Business Unit');
        ATI_Accounts_Receivable_Interface__c customSet23 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Part Markup',Name='TLI Type Markup');
        ATI_Accounts_Receivable_Interface__c customSet24 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Parts Expense',Name='TLI Type Expense');
        ATI_Accounts_Receivable_Interface__c customSet25 = new ATI_Accounts_Receivable_Interface__c(ATI_Values__c = 'Parts Factory Cost',Name='TLI Type Factory');
        
        customSettingList.add(customSet1);
        customSettingList.add(customSet2);
        customSettingList.add(customSet3);
        customSettingList.add(customSet4);
        customSettingList.add(customSet5);
        customSettingList.add(customSet6);
        customSettingList.add(customSet7);
        customSettingList.add(customSet8);
        customSettingList.add(customSet9);
        customSettingList.add(customSet10);
        customSettingList.add(customSet11);
        customSettingList.add(customSet12);
        customSettingList.add(customSet13);
        customSettingList.add(customSet14);
        customSettingList.add(customSet15);
        customSettingList.add(customSet16);
        customSettingList.add(customSet17);
        customSettingList.add(customSet18);
        customSettingList.add(customSet19);
        customSettingList.add(customSet20);
        customSettingList.add(customSet21);
        customSettingList.add(customSet22);
        customSettingList.add(customSet23);
        customSettingList.add(customSet24);
        customSettingList.add(customSet25);
    	insert customSettingList;
        
		financialLineItemList[0].WOD_2__Approved_Amount__c=100;
        financialLineItemList[0].WOD_2__Approved_Quantity__c=1;
        financialLineItemList[0].ATI_Factory_Cost__c=200;
        financialLineItemList[0].ATI_Factory_Price__c=200;
      //  financialLineItemList[0].ATI_Landed_Part_Markup__c = 10;
      //  financialLineItemList[0].ATI_Markup__c = 10;
        
      //  financialLineItemList[1].WOD_2__Approved_Amount__c=10;
      //  financialLineItemList[1].WOD_2__Approved_Quantity__c=1;
        update financialLineItemList;
        
        System.assertEquals(claimLst[0].Id,financialLineItemList[0].WOD_2__Claim__c);
        Test.stopTest();
    }
    
    @isTest
    private static void testForPartsMasterValidatorAndSync(){
        //system.debug('***'+[Select WOD_2__Transaction_Memo_History__r.LastModifiedDate,WOD_2__Transaction_Memo_History__r.WOD_2__Transaction_Status__c,WOD_2__Transaction_Memo_History__r.ATI_Warranty_Registration__c,WOD_2__Unit_Amount__c,WOD_2__Quantity__c From WOD_2__Transaction_Memo_History_Line_Item__c]);
    	//Database.executeBatch(new ATI_Accounts_ReceivableBatch(), 200);
    	system.debug('***'+[Select Id,WOD_2__Approved_Amount__c,WOD_2__Approved_Quantity__c,WOD_2__System_PerUnit_Price__c,ATI_Landed_Part_Markup__c,WOD_2__Installed_Claim_Part__c From WOD_2__Financial_Line_Item__c]);
        Test.setMock(HttpCalloutMock.class, new ATI_MockCallout_TestClass()); 
        ATI_Accounts_Receivable_Scheduled sc = new ATI_Accounts_Receivable_Scheduled();
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, sc);
        Database.executeBatch(new ATI_Accounts_ReceivableBatch(), 200);
       // ATI_LogService.createLogForAccess('TestProcess','Error');
    }
    @isTest
    private static void testLogService(){
        ATI_LogServiceWrapper logServiceWarraperObj = new ATI_LogServiceWrapper();
        logServiceWarraperObj.statusText = 'Failed';
        logServiceWarraperObj.errortext = 'errortext';
        logServiceWarraperObj.processName = 'processName';
        logServiceWarraperObj.identifier ='["T2100XFE32300160Machine","450070300117Machine","450070300128Machine","T375_R70300144Machine","T2100XFE32300160Machine","450070300117Machine","450070300128Machine","T375_R70300144Machine","T2100XFE32300160Machine","450070300117Machine","450070300128Machine","T375_R70300144Machine"]';
        ATI_LogService.logRecord(logServiceWarraperObj);
    }
    @isTest
    private static void testGetDollarType(){
        ATI_Accounts_ReceivableBatch.getDollarType('Freight');
        ATI_Accounts_ReceivableBatch.getDollarType('Duty');
        ATI_Accounts_ReceivableBatch.getDollarType('Labor');
        ATI_Accounts_ReceivableBatch.getDollarType('Misc Material');
        ATI_Accounts_ReceivableBatch.getDollarType('OEM Parts');
        ATI_Accounts_ReceivableBatch.getDollarType('Overtime');
        ATI_Accounts_ReceivableBatch.getDollarType('Parts');
        ATI_Accounts_ReceivableBatch.getDollarType('Tax');
        ATI_Accounts_ReceivableBatch.getDollarType('Sublet');
        ATI_Accounts_ReceivableBatch.getDollarType('Unit');
        ATI_Accounts_ReceivableBatch.getDollarType('Towing');
        ATI_Accounts_ReceivableBatch.getDollarType('Travel By Distance');
    }
    
    @isTest
    private static void testForcreateLogForAccess(){
        Test.startTest();
        ATI_LogService.createLogForAccess('AccountReceivable','Insufficient Read Access');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='AccountReceivable'];
        ATI_LogService.createOrUpdateLogForAccess('AccountReceivable','Insufficient Read Access',batchLog.id);
            //System.assert(batchLog.ATI_Error_Message__c.contains('Insufficient WarrantyProduct Read Access'),'Part Number Validation Check...!!!');
        Test.stopTest();
    }
    
    @isTest
    private static void testForcreateLogForCatchException(){
        Test.startTest();
        ATI_LogService.createLogForCatchException('AccountReceivable','Insufficient Read Access','Test Data');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,ATI_Error_Message__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='AccountReceivable'];
        //System.assert(batchLog.ATI_Error_Message__c.contains('Insufficient WarrantyProduct Read Access'),'Part Number Validation Check...!!!');
        Test.stopTest();
    }
    
}