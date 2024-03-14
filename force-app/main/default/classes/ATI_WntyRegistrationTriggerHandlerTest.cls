/* Name: ATI_WntyRegistrationTriggerHandlerTest
Description : ATI_WntyRegistrationTriggerHandlerTest - Test Class for ATI_WntyRegistrationTriggerHandler.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      27-JAN-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_WntyRegistrationTriggerHandlerTest {
    
    @testSetup    
    static void testSetup(){
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[0].ATI_RPS_Status__c = true;
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProductList.size();i++){
            //warrantyProductList[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
      	insert warrantyProductList;
        
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(1);
        inventoryList[0].WOD_2__Business_Unit__c = busCategoryList[0].Id;
        inventoryList[0].WOD_2__Account__c = accList[0].Id;
        inventoryList[0].WOD_2__Item__c = warrantyProductList[2].Id;
        insert inventoryList;
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(inventoryList.size());
        insert vehicleInfoLst;
         List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
   
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = inventoryList[0].Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst[0].id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
         insert vinTransmissionMapperLst;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(2);
        policyDefList.get(0).WOD_2__Type__c = 'Extended';
		policyDefList.get(0).WOD_2__Months_Covered__c = 24;
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        policyDefList.get(1).WOD_2__Type__c = 'Standard';
        policyDefList.get(1).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
    }

    @isTest
    static void testAccuralForStdWarrantyCreation(){
        Test.startTest();
		WOD_2__Warranty_Registration__c wr = createWntyRegistration();   
        insert wr;
        WOD_2__Warranty_Coverages__c coverage = createWarrantyCoverage(false);
        coverage.WOD_2__Warranty_Registration__c = wr.Id;
        insert coverage;
        Test.stopTest();
        List<ATI_Ext_Warranty_Accrual__c> accrualList = [select id from ATI_Ext_Warranty_Accrual__c];
        System.assert(accrualList.isEmpty(), 'Accrual Created, which is not expected !!!');
    }

    // Below test covers the case when the STd. and Ext. coverages are registered together.
    @isTest
    static void testAccuralForStdAndExtWarrantyCreation(){
		WOD_2__Warranty_Registration__c wr = createWntyRegistration();
        wr.WOD_2__Registration_Type__c = 'Standard Registration';
        wr.ATI_isExtended__c = true;
        wr.WOD_2__Status__c = 'Draft';
        insert wr;
        List<WOD_2__Warranty_Coverages__c> coverageList = new List<WOD_2__Warranty_Coverages__c>();
        coverageList.add(createWarrantyCoverage(false));
        coverageList.add(createWarrantyCoverage(true));
        for(WOD_2__Warranty_Coverages__c coverage : coverageList){
        	coverage.WOD_2__Warranty_Registration__c = wr.Id;    
        }
        insert coverageList;
        WOD_2__Transaction_Memo_History__c tmh = createTransactionForEWP(wr);
        insert tmh;
        WOD_2__Transaction_Memo_History_Line_Item__c tmhli = createTMHLIForEWP();
        tmhli.WOD_2__Transaction_Memo_History__c=tmh.Id;
        insert tmhli;
        Test.startTest();
        wr.WOD_2__Status__c = 'In Progress';
        update wr;
        wr.WOD_2__Status__c = 'Registered';
        update wr;
        
        Map<Id, WOD_2__Warranty_Coverages__c> coverages = new Map<Id, WOD_2__Warranty_Coverages__c>([
                    select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c = :wr.Id
                    and ATI_is_Extended_Enabled__c = true
                ]);
        ATI_ExtWntyAccrualsQueueable enqueueJobObj = new ATI_ExtWntyAccrualsQueueable(new List<Id>(coverages.keySet()));
        System.enqueueJob(enqueueJobObj); 
        Test.stopTest();
        List<ATI_Ext_Warranty_Accrual__c> accrualList = [select id, ATI_Amount__c, ATI_Is_Active__c, ATI_Accrual_Date__c  from ATI_Ext_Warranty_Accrual__c];
        System.assert(!accrualList.isEmpty(), 'Accruals not Created!!!');
        System.assertEquals(12, accrualList.size(), 'Expected number of accrual records not created');
        System.assertEquals(30, accrualList.get(0).ATI_Amount__c, 'Amount is not diveded properly');
        System.assertEquals(System.today().addYears(1).addMonths(1), accrualList.get(0).ATI_Accrual_Date__c, 'Start month of the accrual is not correct');
        //System.assertEquals(accrualList.get(11).ATI_Accrual_Date__c, System.today().addMonths(24), 'End month of the accrual is not correct');
        Decimal amount = 0;
        for(ATI_Ext_Warranty_Accrual__c a : accrualList){
            amount += a.ATI_Amount__c;
        }
        System.assertEquals(360, amount, 'Total amount of all the accruals are not correct');
    }
    

    // Below test covers the case when the STd. and Ext. coverages are registered separately.
	@isTest
    static void testAccuralForStdExtWarrantyCreatedSeparately(){
		WOD_2__Warranty_Registration__c wr = createWntyRegistration();
        wr.WOD_2__Registration_Type__c = 'Standard Registration';
        insert wr;
        WOD_2__Warranty_Coverages__c stdCoverage = createWarrantyCoverage(false);
        stdCoverage.WOD_2__Warranty_Registration__c = wr.Id;
        insert stdCoverage;
		WOD_2__Warranty_Registration__c extWR = createWntyRegistration();   
        extWR.Name = 'Extended Warranty Reg';
        extWR.ATI_isExtended__c = true;
        extWR.WOD_2__Status__c = 'Draft';
        extWR.WOD_2__Registration_Date__c = System.today();
        extWR.WOD_2__Registration_Type__c = 'Extended';
        insert extWR;
        WOD_2__Warranty_Coverages__c extCoverage = createWarrantyCoverage(true);
        extCoverage.WOD_2__Warranty_Registration__c = extWR.Id;
        insert extCoverage;
        WOD_2__Transaction_Memo_History__c tmh = createTransactionForEWP(extWR);
        insert tmh;
        WOD_2__Transaction_Memo_History_Line_Item__c tmhli = createTMHLIForEWP();
        tmhli.WOD_2__Transaction_Memo_History__c=tmh.Id;
        insert tmhli;
        Test.startTest();
        extWR.WOD_2__Status__c = 'In Progress';
        update extWR;
        extWR.WOD_2__Status__c = 'Registered';
        update extWR;
        Map<Id, WOD_2__Warranty_Coverages__c> coverages = new Map<Id, WOD_2__Warranty_Coverages__c>([
                    select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c = :extWR.Id
                    and ATI_is_Extended_Enabled__c = true
                ]);
        ATI_ExtWntyAccrualsQueueable enqueueJobObj = new ATI_ExtWntyAccrualsQueueable(new List<Id>(coverages.keySet()));
        System.enqueueJob(enqueueJobObj); 
        Test.stopTest();
        List<ATI_Ext_Warranty_Accrual__c> accrualList = [select id, ATI_Amount__c, ATI_Is_Active__c, ATI_Accrual_Date__c  from ATI_Ext_Warranty_Accrual__c order by ATI_Accrual_Date__c];
        System.assert(!accrualList.isEmpty(), 'Accruals not Created!!!');
        System.assertEquals(12, accrualList.size(), 'Expected number of accrual records not created');
        System.assertEquals(30, accrualList.get(0).ATI_Amount__c, 'Amount is not diveded properly');
        System.assertEquals(System.today().addYears(1).addMonths(1), accrualList.get(0).ATI_Accrual_Date__c, 'Start month of the accrual is not correct');
        //System.assertEquals(accrualList.get(11).ATI_Accrual_Date__c, System.today().addMonths(24), 'End month of the accrual is not correct');
        Decimal amount = 0;
        for(ATI_Ext_Warranty_Accrual__c a : accrualList){
            amount += a.ATI_Amount__c;
        }
        System.assertEquals(360, amount, 'Total amount of all the accruals are not correct');
    }
    

    //Below test covers scenario where the Ext. Warranty is Cancelled or De-Registered.
    @isTest
    static void testAccuralForEWPDegistration(){
		WOD_2__Warranty_Registration__c wr = createWntyRegistration();
        wr.WOD_2__Registration_Type__c = 'Standard Registration';
        insert wr;
        WOD_2__Warranty_Coverages__c stdCoverage = createWarrantyCoverage(false);
        stdCoverage.WOD_2__Warranty_Registration__c = wr.Id;
        insert stdCoverage;
        WOD_2__Warranty_Registration__c extWR = createWntyRegistration();   
        extWR.Name = 'Extended Warranty Reg';
        extWR.ATI_isExtended__c = true;
        extWR.WOD_2__Status__c = 'Draft';
        extWR.WOD_2__Registration_Date__c = System.today();
        extWR.WOD_2__Registration_Type__c = 'Extended';
        insert extWR;
        WOD_2__Warranty_Coverages__c extCoverage = createWarrantyCoverage(true);
        extCoverage.WOD_2__Warranty_Registration__c = extWR.Id;
        insert extCoverage;
        WOD_2__Transaction_Memo_History__c tmh = createTransactionForEWP(extWR);
        insert tmh;
        WOD_2__Transaction_Memo_History_Line_Item__c tmhli = createTMHLIForEWP();
        tmhli.WOD_2__Transaction_Memo_History__c=tmh.Id;
        insert tmhli;
        Test.startTest();
        extWR.WOD_2__Status__c = 'In Progress';
        update extWR;
        extWR.WOD_2__Status__c = 'Registered';
        update extWR;
        Map<Id, WOD_2__Warranty_Coverages__c> coverages = new Map<Id, WOD_2__Warranty_Coverages__c>([
                    select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c = :extWR.Id
                    and ATI_is_Extended_Enabled__c = true
                ]);
        ATI_ExtWntyAccrualsQueueable enqueueJobObj = new ATI_ExtWntyAccrualsQueueable(new List<Id>(coverages.keySet()));
		System.enqueueJob(enqueueJobObj); 
        
        extWR.WOD_2__Status__c = 'De-Registered';
        update extWR;
        
        enqueueJobObj.wrIdToDeleteList = new List<Id>{extWR.Id};
        System.enqueueJob(enqueueJobObj); 
        Test.stopTest();
        List<ATI_Ext_Warranty_Accrual__c> accrualList = [select id, ATI_Amount__c, ATI_Is_Active__c, ATI_Accrual_Date__c  from ATI_Ext_Warranty_Accrual__c where ATI_Is_Active__c = false order by ATI_Accrual_Date__c];
        System.debug(accrualList);
        System.assert(!accrualList.isEmpty(), 'Accruals not Created!!!');
        System.assertEquals(12, accrualList.size(), 'Expected number of accrual records not updated');
        Decimal amount = 0;
        for(ATI_Ext_Warranty_Accrual__c a : accrualList){
            amount += a.ATI_Amount__c;
        }
        System.assertEquals(360, amount, 'Total amount of all the accruals are not correct');
	}

	private static WOD_2__Warranty_Registration__c createWntyRegistration(){
        List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        lstWR[0].WOD_2__Inventory__c = [select id from WOD_2__Inventory__c][0].id;
        lstWR[0].WOD_2__Account__c = [select id from Account where WOD_2__Warranty_Account_Type__c = 'Dealer'][0].Id;
        lstWR[0].WOD_2__Customer__c = [select id from Account where WOD_2__Warranty_Account_Type__c = 'Customer'][0].Id;
        return lstWR[0];
    }
    
    private static WOD_2__Transaction_Memo_History_Line_Item__c createTMHLIForEWP(){
        List<WOD_2__Transaction_Memo_History_Line_Item__c>tmhliList = TestDataFactory.createTransactionMemoLineItem(1);
        //tmhliList[0].WOD_2__Transaction_Memo_History__c=transctnHistory.Id;
        tmhliList[0].Name= [select Id, Name from WOD_2__Policy_Definition__c where WOD_2__Type__c = 'Extended'][0].Name;
        tmhliList[0].WOD_2__Total_Amount__c= 360;
        tmhliList[0].WOD_2__Unit_Amount__c= 300;
        tmhliList[0].ATI_Handling_Fee__c= 40;
        tmhliList[0].ATI_Late_Fee__c= 20;
        tmhliList[0].WOD_2__Transaction_Type__c= 'Debit';
		tmhliList[0].WOD_2__Quantity__c=1;        
        return tmhliList[0];
    }    
    
    private static WOD_2__Warranty_Coverages__c createWarrantyCoverage(Boolean isExtended){
        List<WOD_2__Warranty_Coverages__c> wcList = TestDataFactory.createWarrantyCoverage(1);
        String policyType = isExtended ? 'Extended' : 'Standard';
        WOD_2__Policy_Definition__c pd = [select Id, WOD_2__Months_Covered__c from WOD_2__Policy_Definition__c where WOD_2__Type__c = :policyType];
        wcList[0].ATI_isExtended__c = isExtended;
        wcList[0].WOD_2__Is_Active__c = true;
        wcList[0].WOD_2__Policy_Definition__c = pd.Id;
        wcList[0].WOD_2__Warranty_Start_Date__c = Date.today();
        wcList[0].WOD_2__Warranty_End_Date__c = Date.today().addMonths(Integer.valueOf(pd.WOD_2__Months_Covered__c));
		return wcList[0];        
    }
    
    
    private static WOD_2__Transaction_Memo_History__c createTransactionForEWP(WOD_2__Warranty_Registration__c wr){
        List<WOD_2__Transaction_Memo_History__c> tmhList = TestDataFactory.createTransactionMemo(1);
		tmhList[0].ATI_Type__c='EWP';
        tmhList[0].Name= wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c;
        tmhList[0].WOD_2__Amount__c = 360;
        tmhList[0].WOD_2__Transaction_Type__c ='Debit';
        tmhList[0].WOD_2__Transaction_Status__c ='Paid';
        tmhList[0].WOD_2__Settlement_Category__c ='EWP';
        tmhList[0].ATI_Warranty_Registration__c = wr.Id;        
        return tmhList[0];
    }
    
}