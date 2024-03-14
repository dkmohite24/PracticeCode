@isTest
public class ATI_BR_ETCDeniedSerialNumberTest {
    @TestSetup
    public static void testSetUp(){
        Test.startTest();
        //create account
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = accLst[0].id;
        accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryConfig;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Stock';
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(2);
        policyDefList.get(0).WOD_2__Type__c = 'Extended';
		policyDefList.get(0).WOD_2__Months_Covered__c = 24;
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        policyDefList.get(1).WOD_2__Type__c = 'Standard';
        policyDefList.get(1).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
        List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        lstWR[0].WOD_2__Inventory__c = inventoryLst[0].id;
        lstWR[0].WOD_2__Account__c = accLst[0].Id;
        //lstWR[0].WOD_2__Customer__c = accLst[1].Id;
        insert lstWR;
        
        List<WOD_2__Warranty_Coverages__c> wcList = TestDataFactory.createWarrantyCoverage(2);
        wcList[0].ATI_isExtended__c = policyDefList[0].WOD_2__Type__c == 'Extended';
        wcList[0].WOD_2__Is_Active__c = true;
        wcList[0].WOD_2__Policy_Definition__c = policyDefList[0].Id;
        wcList[0].WOD_2__Warranty_Start_Date__c = Date.today();
        wcList[0].WOD_2__Warranty_End_Date__c = Date.today().addMonths(Integer.valueOf(policyDefList[0].WOD_2__Months_Covered__c));
        wcList[0].WOD_2__Warranty_Registration__c = lstWR[0].Id;

        wcList[1].ATI_isExtended__c = policyDefList[1].WOD_2__Type__c == 'Extended';
        wcList[1].WOD_2__Is_Active__c = true;
        wcList[1].WOD_2__Policy_Definition__c = policyDefList[1].Id;
        wcList[1].WOD_2__Warranty_Start_Date__c = Date.today();
        wcList[1].WOD_2__Warranty_End_Date__c = Date.today().addMonths(Integer.valueOf(policyDefList[1].WOD_2__Months_Covered__c));
        wcList[1].WOD_2__Warranty_Registration__c = lstWR[0].Id;
        insert wcList;
        
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        //viList[0].ATI_Inventory__c = inventoryList[0].Id;
        insert viList;
        /** Created as part of VIN Transmission Mapper*/
        List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = TestDataFactory.createVinMappers(1,viList[0].Id);
        vinMapperLst[0].ATI_Inventory__c= inventoryLst[0].Id;
        insert vinMapperLst;
    }
    
    @isTest
    private static void etcdeniedSerialNumber(){
        List<WOD_2__Warranty_Registration__c> wrList = [Select Id,WOD_2__Registration_Type__c,WOD_2__Inventory__c From WOD_2__Warranty_Registration__c];
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=wrList[0].Id;
        ATI_BR_ETCDeniedSerialNumber denied = new ATI_BR_ETCDeniedSerialNumber();
        Boolean returnValue1 = denied.checkBusinessRule(wrapperObj);
    }
    
}