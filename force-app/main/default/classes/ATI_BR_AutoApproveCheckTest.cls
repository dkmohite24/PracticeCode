@isTest
public class ATI_BR_AutoApproveCheckTest {
	/*
        Method Name :   testSetUp
        Description :   TestSetup method to create test data
    */
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
        Test.stopTest();
    }
    
    @isTest
    private static void testCheckOtherCostLimitBURule(){
        WOD_2__Business_Category_Configuration__c buConfigObj = [SELECT Id FROM WOD_2__Business_Category_Configuration__c LIMIT 1];
        WOD_2__Claim__c claimObj = [SELECT Id,ATI_Total_Requested_Amount__c FROM WOD_2__Claim__c LIMIT 1 ];
        claimObj.ATI_Total_Requested_Amount__c = 100;
        update claimObj;
        String buConfigRTId = Schema.SObjectType.WOD_2__Business_Category_Configuration_Setting__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId();
        WOD_2__Business_Category_Configuration_Setting__c buConfigSettingThresholdAmtObj =  new WOD_2__Business_Category_Configuration_Setting__c(Name='ATI_CLM_ThresholdAmountForAutoApproval', RecordTypeId=buConfigRTId, WOD_2__Module__c='Claim',WOD_2__Unique_Rule_Name__c = 'ATI_CLM_ThresholdAmountForAutoApproval',
                                                                           WOD_2__Overridden__c=true,WOD_2__Business_Category_Configuration__c=buConfigObj.Id,WOD_2__Rule_Object__c = 'WOD_2__Claim__c',WOD_2__Value__c='2000',
                                                                           WOD_2__Parent_Object_API_Name__c='WOD_2__Claim__c', WOD_2__isActive__c=true, WOD_2__Sub_Module__c='Claim Action',WOD_2__Sub_Type__c='Field Set');
        insert buConfigSettingThresholdAmtObj;
        String recordId = Schema.SObjectType.WOD_2__Business_Category_Configuration_Setting__c.getRecordTypeInfosByName().get('Rule').getRecordTypeId();
        WOD_2__Business_Category_Configuration_Setting__c buConfigSettingObj =  new WOD_2__Business_Category_Configuration_Setting__c(Name='ATI_Check_For_Auto_Approval', RecordTypeId=recordId, WOD_2__Module__c='Claim',WOD_2__Unique_Rule_Name__c = 'ATI_Check_For_Auto_Approval',
                                                                           WOD_2__Overridden__c=true,WOD_2__Business_Category_Configuration__c=buConfigObj.Id, WOD_2__Class_Override__c='ATI_BR_AutoApproveCheck',WOD_2__Rule_Object__c = 'WOD_2__Claim__c',
                                                                           WOD_2__Parent_Object_API_Name__c='WOD_2__Claim__c', WOD_2__isActive__c=true, WOD_2__Sub_Module__c='Claim UI - Other Cost',WOD_2__Sub_Type__c='Field Set',
                                                                           WOD_2__Display_Message__c ='Claim will go for auto approval',WOD_2__Error_Type__c ='soft');
        insert buConfigSettingObj;
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.businessCategoryConfigurationSettingObj = buConfigSettingObj;
        wrapperObj.ruleObjectId = claimObj.Id;
        
        Test.startTest();
        	ATI_BR_AutoApproveCheck controllerObj = new ATI_BR_AutoApproveCheck();
        	Boolean returnValue = controllerObj.checkBusinessRule(wrapperObj);
        Test.stopTest();
        System.assertEquals(true, returnValue,'True should be returned');
        WOD_2__Business_Rule__c buRuleObj = new WOD_2__Business_Rule__c(WOD_2__Claim__c=claimObj.Id,WOD_2__Message__c='Test');
        insert buRuleObj;
        Boolean returnValue1 = controllerObj.checkBusinessRule(wrapperObj);
    }
}