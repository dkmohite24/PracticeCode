/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        02 Sept 2022
* @modified
* @description :  Test Class for ATI_BR_TurnAroundValidation, ATI_BR_TurnAroundValidationTest_Part and ATI_BR_TurnAroundValidation_Labor 
* --------------------------------------------------------------------------------------------------
*/
@isTest
Public class ATI_BR_TurnAroundValidationTest{
@TestSetup
    public static void testSetUp(){
        //create account
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
          accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;
            accLst[i].PRP_Participation__c = true;    
        }
        insert accLst;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;

        List<WOD_2__Business_Category_Configuration_Setting__c> bccs = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert bccs;
            
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
        
        List<WOD_2__Warranty_Code__c> warCodeLst = new List<WOD_2__Warranty_Code__c>();
        //create Labor Operation Codes
        List<WOD_2__Warranty_Code__c> warrantyJobCodeLst = TestDataFactory.createWarrantyCode(1,'Labor Operations Codes');
        warrantyJobCodeLst[0].Name='00010000';
        warrantyJobCodeLst[0].WOD_2__Standard_Labor_Hour__c = 2;
        warCodeLst.addAll(warrantyJobCodeLst);
        insert warCodeLst;
        
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
        }
        claimLst[0].RecordTypeId = partClaimId;
        claimLst[1].RecordTypeId = part90ClaimId;
        claimLst[1].WOD_2__Part__c = warrantyProLst[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        //claimLst[2].RecordTypeId = equipmentClaimId;
        insert claimLst;
        /*list<WOD_2__Claim_Part__c> serviceParts = new list<WOD_2__Claim_Part__c>();
        WOD_2__Claim_Part__c clp= new WOD_2__Claim_Part__c();
        clp.Name = 'SK11099';
        clp.RecordTypeId = '012050000008UyzAAE';
        clp.WOD_2__Claim__c = claimLst[0].Id;
        clp.WOD_2__Part_Description__c = 'SUB-KIT';
        clp.WOD_2__Type__c  = 'Installed Part';
        clp.WOD_2__Invoice_Quantity__c = 1.0;
        clp.WOD_2__Quantity__c = 1.0;
        clp.WOD_2__Unit_Price__c = 100.0;    
        serviceParts.add(clp);
        insert serviceParts; */
        List<WOD_2__Claim_Part__c> installedClaimParts = TestDataFactory.createInstalledParts(1);
        installedClaimParts[0].WOD_2__Claim__c = claimLst[0].Id;
        installedClaimParts[0].WOD_2__Warranty_Product__c = warrantyProLst[2].Id;
        insert installedClaimParts;
        List<WOD_2__Claim_Service_Information__c> claimServices = TestDataFactory.createClaimServices(1);
        claimServices[0].WOD_2__Service_Job_Code__c = warrantyJobCodeLst[0].Id;
        claimServices[0].WOD_2__Claim__c = claimLst[0].Id; 
        claimServices[0].WOD_2__Total_Labor_Minutes__c = 20;
        insert claimServices;
    }
     @isTest
    private static void testTurnAroundValidation(){
        List<WOD_2__Claim__c> claimList = [Select Id,WOD_2__Model_Number__c,RecordTypeId from WOD_2__Claim__c];
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=claimList[0].Id;
        ATI_BR_TurnAroundValidation lde = new ATI_BR_TurnAroundValidation();
        Boolean returnValue1 = lde.checkBusinessRule(wrapperObj);
        ATI_BR_TurnAroundValidation_Labor lde2 = new ATI_BR_TurnAroundValidation_Labor();
        Boolean returnValue2 = lde2.checkBusinessRule(wrapperObj);
        ATI_BR_TurnAroundValidation_Part lde3 = new ATI_BR_TurnAroundValidation_Part();
        Boolean returnValue3 = lde3.checkBusinessRule(wrapperObj);
    }
    @isTest
    private static void testTurnAroundValidationNegetive(){
        List<WOD_2__Claim__c> claimList = [Select Id,WOD_2__Model_Number__c,RecordTypeId from WOD_2__Claim__c];
        claimList[0].ATI_First_Part_Ordered_Date_Time__c = System.today() + 5;
        claimList[0].ATI_Last_Part_Arrival_Date_Time__c = System.today() + 4;
        claimList[0].ATI_First_Labor_Applied_Date_Time__c = System.today() + 3;
        claimList[0].ATI_Last_Labor_Recorded_Time__c = System.today() + 2;
        update claimList[0];
        
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=claimList[0].Id;
        ATI_BR_TurnAroundValidation lde = new ATI_BR_TurnAroundValidation();
        Boolean returnValue1 = lde.checkBusinessRule(wrapperObj);
        ATI_BR_TurnAroundValidation_Labor lde2 = new ATI_BR_TurnAroundValidation_Labor();
        Boolean returnValue2 = lde2.checkBusinessRule(wrapperObj);
        ATI_BR_TurnAroundValidation_Part lde3 = new ATI_BR_TurnAroundValidation_Part();
        Boolean returnValue3 = lde3.checkBusinessRule(wrapperObj);

    }
}