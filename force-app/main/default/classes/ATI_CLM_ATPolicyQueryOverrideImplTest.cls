/*
	Class Name	:	ATI_CLM_ATPolicyQueryOverrideImplTest
	Description	:	Test class for ATI_CLM_ATPolicyQueryOverrideImpl
*/
@isTest
public class ATI_CLM_ATPolicyQueryOverrideImplTest {
	/*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
    @testSetup
    public static void testSetup(){
        List<WOD_2__Business_Category_Configuration__c> bccLst = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert bccLst;
        
		List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<Account> accList = TestDataFactory.createAccount(1);
        accList.get(0).Name = 'Test';
        insert accList;
        
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(1);
            warrantyProPartLst.get(0).RMA_Policy__c = true;
            warrantyProPartLst.get(0).WOD_2__Item_Type__c = 'Machine';
            warrantyProPartLst.get(0).WOD_2__Type__c = 'Item';
            warrantyProPartLst.get(0).WOD_2__Track_Type__c = 'Serialized';
        insert warrantyProPartLst;
        
        List<WOD_2__Inventory__c> invList =TestDataFactory.createInventory(1);
        invList.get(0).WOD_2__Account__c = accList.get(0).Id;
        invList.get(0).WOD_2__Item__c =warrantyProPartLst.get(0).Id;
        insert invList;
        
        List<WOD_2__Warranty_Registration__c> wrList =TestDataFactory.createWarrantyRegistration(1);
        wrList.get(0).ATI_Pre_Delivery__c = true;
        wrList.get(0).WOD_2__Status__c = 'Registered';
        wrList.get(0).WOD_2__Inventory__c = invList.get(0).Id;
        insert wrList;
       
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(1);
        policyDefList.get(0).WOD_2__Type__c = 'Standard';
        policyDefList.get(0).WOD_2__Sub_Type__c = '01';
        policyDefList.get(0).WOD_2__Status__c = 'Active';
        policyDefList.get(0).WOD_2__Business_Units__c = 'ATI';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
        List<WOD_2__Warranty_Coverages__c> wrtycvrgLst = TestDataFactory.createWarrantyCoverage(1);
        wrtycvrgLst.get(0).WOD_2__Warranty_Registration__c = wrList.get(0).Id;
        wrtycvrgLst.get(0).WOD_2__Policy_Definition__c =  policyDefList.get(0).Id;
        insert wrtycvrgLst;
        
        WOD_2__Applicability_Term__c atObj = new WOD_2__Applicability_Term__c(WOD_2__isValidExpression__c=true,
                                                                              WOD_2__Applicability_Term_Type__c='Inclusion',
                                                                              WOD_2__Policy_Definition__c=policyDefList.get(0).Id);
        insert atObj;
        
    }
    
    @isTest
    private static void testFetchApplicabilityTerm(){
        Test.startTest();
        	List<WOD_2__Policy_Definition__c> policyDefList = [SELECT Id,WOD_2__Sub_Type__c FROM WOD_2__Policy_Definition__c];
            List<WOD_2__Inventory__c> invList = [Select Id from WOD_2__Inventory__c];
        	List<WOD_2__Business_Category_Configuration__c> bccLst = [SELECT Id FROM WOD_2__Business_Category_Configuration__c];
        	ATI_CLM_ATPolicyQueryOverrideImpl controllerObj = new ATI_CLM_ATPolicyQueryOverrideImpl();
        	ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim = true;
        	ATI_CLM_ATPolicyQueryOverrideImpl.buId = bccLst[0].Id;
        	//pre auth
        	List<WOD_2__Applicability_Term__c> atLst = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',
                                                                new List<String>{'WOD_2__Policy_Definition__c'},'','');
        	//System.assertEquals(1, atLst.size(),'One AT should be returned');
        
        	//Retail
        	ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim = false;
        	WOD_2.CLM_UnmanagedUtility.type = 'Retail';
       	 	WOD_2.CLM_UnmanagedUtility.policyIdsSet = new Set<Id>{policyDefList[0].Id};
        	List<WOD_2__Applicability_Term__c> atReatilLst = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',
                                                                new List<String>{'WOD_2__Policy_Definition__c'},'','');
        	System.assertEquals(1, atReatilLst.size(),'One AT should be returned');
        
        	//Stock
        	WOD_2.CLM_UnmanagedUtility.type = 'Stock';
        	policyDefList[0].WOD_2__Sub_Type__c = 'Stock';
        	update policyDefList[0];
        	List<WOD_2__Applicability_Term__c> atStockLst = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',
                                                                new List<String>{'WOD_2__Policy_Definition__c'},'','');
        	System.assertEquals(1, atStockLst.size(),'One AT should be returned');
        
        	//Part
        	WOD_2.CLM_UnmanagedUtility.type = 'Part';
        	policyDefList[0].WOD_2__Sub_Type__c = 'Part';
        	update policyDefList[0];
        	List<WOD_2__Applicability_Term__c> atPartLst = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',
                                                                new List<String>{'WOD_2__Policy_Definition__c'},'','');
        	System.assertEquals(1, atPartLst.size(),'One AT should be returned');
        
            //Goodwill 
        	WOD_2.CLM_UnmanagedUtility.type = 'Goodwill';
        	policyDefList[0].WOD_2__Sub_Type__c = '04';
        	update policyDefList[0];
        	List<WOD_2__Applicability_Term__c> atGoodwillLst = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',            
                                                                                                    new List<String>{'WOD_2__Policy_Definition__c'},'','');
            ATI_CLM_ATPolicyQueryOverrideImpl.businessUnitId = bccLst.get(0).Id;
            ATI_CLM_ATPolicyQueryOverrideImpl.preDelivery = true;
            ATI_CLM_ATPolicyQueryOverrideImpl.isPreAuthClaim = false;
            ATI_CLM_ATPolicyQueryOverrideImpl.inventoryId = invList[0].Id;
            List<WOD_2__Applicability_Term__c> testt = controllerObj.fetchApplicabilityTerm('SELECT Id FROM WOD_2__Applicability_Term__c WHERE WOD_2__isValidExpression__c = true',
                                                                new List<String>{'WOD_2__Policy_Definition__c'},'','');              
        Test.stopTest();
    }
}