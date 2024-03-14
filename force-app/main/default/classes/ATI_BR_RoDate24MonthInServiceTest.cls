@isTest
public class ATI_BR_RoDate24MonthInServiceTest {
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

        List<WOD_2__Business_Category_Configuration_Setting__c> bccs = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert bccs;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Retail';
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Manufacturing_Date__c = Date.today() - 720;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
         List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        lstWR[0].WOD_2__Inventory__c = [select id from WOD_2__Inventory__c][0].id;
        lstWR[0].WOD_2__Account__c = [select id from Account where WOD_2__Warranty_Account_Type__c = 'Dealer'][0].Id;
       // lstWR[0].WOD_2__Customer__c = [select id from Account where WOD_2__Warranty_Account_Type__c = 'Customer'][0].Id;
        lstWR[0].ATI_Pre_Delivery__c = true;
        insert lstWR[0];
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        Id partClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        Id part90ClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
        //Id equipmentClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Equipment_Exchange').getRecordTypeId();
        //create rejected claims
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
            claimObj.ATI_isPreDelivery__c = True;
        }
        claimLst[0].RecordTypeId = partClaimId;
        claimLst[1].RecordTypeId = part90ClaimId;
        claimLst[1].WOD_2__Part__c = warrantyProLst[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        //claimLst[2].RecordTypeId = equipmentClaimId;
        insert claimLst;
    }
    
    @isTest
    private static void testATDrainPkgVB(){
        List<WOD_2__Claim__c> claimList = [Select Id,WOD_2__Model_Number__c,RecordTypeId from WOD_2__Claim__c];
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=claimList[0].Id;
        ATI_BR_RoDate24MonthInService month = new ATI_BR_RoDate24MonthInService();
        Boolean returnValue1 = month.checkBusinessRule(wrapperObj);
    }
    
}