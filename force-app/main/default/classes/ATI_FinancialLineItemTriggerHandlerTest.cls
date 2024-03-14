@isTest
public class ATI_FinancialLineItemTriggerHandlerTest {
	/*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
	@testSetup
    public static void testSetup(){
        //create account
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        accLst[0].Type='Service Dealer';
        insert accLst;
        
        //LandingCost RateDetails
        List<WOD_2__Rates_Details__c> landingCostRateDetailsLst = TestDataFactory.createLadingCostRateDetails(2);
        landingCostRateDetailsLst[0].WOD_2__Dealer__c = accLst[0].id;
        landingCostRateDetailsLst[0].WOD_2__Active_From__c = System.today().addDays(-365);
        landingCostRateDetailsLst[0].WOD_2__Active_Until__c = System.today().addDays(365);
        landingCostRateDetailsLst[0].ATI_Landed_Cost_Markup__c = 5;
        insert landingCostRateDetailsLst;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = TestDataFactory.createBccs(busCategoryConfig.get(0));
        insert bccsLst;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = accLst[0].id;
        accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryConfig;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(4);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        warrantyProLst[3].Part_Markup_Percentage__c = 10;
        warrantyProLst[3].WOD_2__Item_Type__c = 'Part';
        insert warrantyProLst;
        
        //Create WarrantyProductPriceBook
        Id partCostRTId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,warrantyProLst[2].Id);
        wpPbLst[0].RecordTypeId = partCostRTId;
        wpPbLst[0].WOD_2__Price__c = 100;
        insert wpPbLst;
        
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
 
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-365);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Type__c = 'Standard';
            policyDef.WOD_2__Sub_Type__c = '01';
            policyDef.ATI_Part_Covered__c = 50;
            policyDef.ATI_Labor_Covered__c = 100;
        }
        insert policyDefLst;
        
        
        Id partClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        Id part90ClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Pending Approval';
            claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
            claimObj.WOD_2__Applicable_Policy__c = policyDefLst[0].Id;
            claimObj.ATI_Exchange_Rate__c=1;
        }
        claimLst[0].RecordTypeId = partClaimId;
        claimLst[1].RecordTypeId = part90ClaimId;
        claimLst[1].WOD_2__Part__c = warrantyProLst[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        insert claimLst;
    }
    
    @isTest
    private static void testBeforeUpdate(){
        WOD_2__Business_Category_Configuration__c buConfigObj = [SELECT Id FROM WOD_2__Business_Category_Configuration__c LIMIT 1];
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Model_Number__c FROM WOD_2__Claim__c LIMIT 1 ];
        
        WOD_2__Warranty_Product__c partObj = [SELECT Id,Name,Part_Markup_Percentage__c FROM WOD_2__Warranty_Product__c WHERE WOD_2__Item_Type__c = 'Part'];
        //creating part cost
        Id partCostId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
        WOD_2__Warranty_Product_Pricebook__c pbObj = new WOD_2__Warranty_Product_Pricebook__c(WOD_2__Warranty_Product__c=partObj.Id,WOD_2__Price__c=200,
                                                                                              WOD_2__Valid_From__c=System.today().addDays(-365),
                                                                                              WOD_2__Valid_Until__c=System.today().addDays(365),
                                                                                              ATI_Active__c=true,RecordTypeId=partCostId);
        insert pbObj;
        Id partRecId = Schema.SObjectType.WOD_2__Claim_Part__c.getRecordTypeInfosByName().get('OEM Installed Parts').getRecordTypeId();
        WOD_2__Claim_Part__c installedClaimPartObj = new WOD_2__Claim_Part__c(Name=partObj.Name,WOD_2__Warranty_Product__c=partObj.Id,WOD_2__Claim__c=claimObj.Id,
                                                                     		  WOD_2__Invoice_Quantity__c=1,WOD_2__Unit_Price__c=10,RecordTypeId=partRecId,WOD_2__Serial_Number__c='1231');
    	insert installedClaimPartObj;
        System.assertEquals(11.5, [SELECT Id,WOD_2__Total_Requested_Amount__c FROM WOD_2__Financial_Line_Item__c
                                     	WHERE WOD_2__Installed_Claim_Part__c=:installedClaimPartObj.Id].WOD_2__Total_Requested_Amount__c,
                           'Total requested amount should be calculated!');
        Test.startTest();
        	installedClaimPartObj.WOD_2__Unit_Price__c = 100;
        	ATI_FinancialLineItemTriggerHandler.skipQueryExecution= false;
        	update installedClaimPartObj;
			WOD_2__Financial_Line_Item__c fliObj = [SELECT Id,ATI_Markup__c FROM WOD_2__Financial_Line_Item__c 
                                                     	WHERE WOD_2__Installed_Claim_Part__c=:installedClaimPartObj.Id AND 
                                                    		WOD_2__Cost_Category_Type__c='OEM Parts'];
        	fliObj.WOD_2__Approved_Amount__c = 11.5;
        	fliObj.ATI_Markup__c = 20;
        	update fliObj;
        Test.stopTest();
    }
}