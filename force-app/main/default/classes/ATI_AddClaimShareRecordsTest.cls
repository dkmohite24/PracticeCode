@isTest
public class ATI_AddClaimShareRecordsTest {
    @testSetup
    private static void dataSetUp(){
        Test.startTest();
        //create account
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst;
        
        System.enqueueJob(new ATI_CreateDealerPublicGroupsQueueable(accLst, false));
        
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
        Id campaignClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
        Id claimTemplateRTId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Claim_Template').getRecordTypeId();
        //create rejected claims
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(4); 
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
        claimLst[2].RecordTypeId = campaignClaimId;
        claimLst[2].WOD_2__Claim_Type__c = 'Campaign';
        claimLst[3].RecordTypeId = claimTemplateRTId;
        claimLst[3].WOD_2__Claim_Type__c = 'Claim Template';
        claimLst[1].WOD_2__Claim_Type__c = 'Part';
        claimLst[1].WOD_2__Part_Serial_Number__c = '12312';
        claimLst[1].WOD_2__Part__c = warrantyProLst[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        //claimLst[2].RecordTypeId = equipmentClaimId;
        insert claimLst;
        Test.stopTest();
    }
    
	@isTest 
    private static void testClaimSharing(){
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Account__c FROM WOD_2__Claim__c LIMIT 1];
        Test.startTest();
        ATI_QueueableUtil.enqueueJob(new ATI_AddClaimShareRecords(new Set<String>{claimObj.WOD_2__Account__c},new Set<Id>{claimObj.Id})); 
        Test.stopTest();
    }
}