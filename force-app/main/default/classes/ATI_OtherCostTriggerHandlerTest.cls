/*
	Class Name	:	ATI_OtherCostTriggerHandlerTest
	Description	:	Test class for ATI_OtherCostTriggerHandler
*/
@isTest
public class ATI_OtherCostTriggerHandlerTest {
	/*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
	@testSetup
    public static void testSetup(){
         Test.startTest();
         //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        distributorAccount[0].Country__c = 'United States';
        distributorAccount[0].BillingCountry = 'United States';
        insert distributorAccount;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = TestDataFactory.createBccs(busCategoryConfig.get(0));
        insert bccsLst;
        
        //VocationCode
        List<WOD_2__Warranty_Code__c> vocantionCodeLst = TestDataFactory.createVocationCode(1,false);
        insert vocantionCodeLst;
        
        
        //Machine
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(200);
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
        }
        insert warrantyProPartLst;
        
        //create Inventory
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Retail'; 
            inventory.WOD_2__Serial_Number__c = 'Test001'; 
            inventory.WOD_2__Account__c = distributorAccount[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(3);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-365);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Type__c = 'Standard';
            policyDef.WOD_2__Sub_Type__c = '01';
        }
        policyDefLst[1].WOD_2__Type__c = 'Extended';
        policyDefLst[2].WOD_2__Sub_Type__c = '02';
        insert policyDefLst;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(3,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
        applicabilityTermsLst[0].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        applicabilityTermsLst[1].WOD_2__Policy_Definition__c = policyDefLst[1].Id;
        applicabilityTermsLst[1].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        applicabilityTermsLst[2].WOD_2__Policy_Definition__c = policyDefLst[2].Id;
        insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(2,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;
    }
    
    @isTest
    private static void testATI_OtherCostTriggerHandler(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Business_Category_Configuration__c bccsObj = [SELECT Id FROM WOD_2__Business_Category_Configuration__c LIMIT 1];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,
                                                    WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c= casulaPart.get(0).id,
                                                    WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,
                                                    WOD_2__Causal_Part_Number__c=casulaPart[0].Id,WOD_2__BusinessCategory__c=bccsObj.Id );
        claim.WOD_2__Claim_Status__c='Draft';
        insert claim;
        WOD_2__Other_Cost__c otherCostObj = new WOD_2__Other_Cost__c(WOD_2__Cost_Category_Type__c='Sublet',WOD_2__Claim__c=claim.Id,
                                                                     WOD_2__UnitsUsage__c=1,WOD_2__Rate_PerUnit__c=10);
        insert otherCostObj;
        otherCostObj.WOD_2__Rate_PerUnit__c = 30;
        Update otherCostObj;
    }
}