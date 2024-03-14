/* Name: ATI_RemovedClaimPartTriggerHandlerTest
Description : Test Class for ATI_RemovedClaimPartTriggerHandler
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL              UserStory/Req#
1.0 -     Tavant(TY)      01-Mar-2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_RemovedClaimPartTriggerHandlerTest{
    @testSetup
    public static void testSetup(){
        Test.startTest();
        //create account
        List<Account> account = TestDataFactory.createATIDistributorAccount(1);
        insert account;
        
        //insert group for above account
        insert new Group(Name='ATI_Dealer_'+account[0].Id);
        
        //create Business Category Configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create Business Category Configuration Setting - Configuration
        List<WOD_2__Business_Category_Configuration_Setting__c> configurationBccsLst = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert configurationBccsLst;
        
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
            inventory.WOD_2__Account__c = account[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        //create Warranty Code
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        
        //create claim
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createMachineClaim(1); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Approved';
            claimObj.WOD_2__Account__c = account[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
        }
        insert claimLst;
        
        //create warehouse
        List<WOD_2__Warehouse__c> whLst = TestDataFactory.createWarehouse(1);
        insert whLst;
        
        //create partreturnconfiguration
        List<WOD_2__Part_Return_Configuration__c> prcLst = TestDataFactory.createPartReturnConfiguration(1);
        for(WOD_2__Part_Return_Configuration__c prc : prcLst){
            prc.WOD_2__Return_Location__c = whLst[0].Id;
        }
        insert prcLst;
        
        //create Removed ClaimPart
        List<WOD_2__Removed_Claim_Part__c> removedpartList = TestDataFactory.createRemovedClaimPart(200);
        Integer i = 0;
        for(WOD_2__Removed_Claim_Part__c removedpart : removedpartList) {
            removedpart.WOD_2__Claim__c = claimLst[0].Id;
            removedpart.WOD_2__Is_Auto_PRC__c = true;
            removedpart.WOD_2__Warranty_Product__c =  warrantyProPartLst[i].id;
            removedpart.WOD_2__Part_Return_Requested__c = true;
            removedpart.WOD_2__Is_Shipped__c = true;
            removedpart.WOD_2__Is_Returned__c = true;
            removedpart.WOD_2__Is_Inspected__c = true;
            removedpart.WOD_2__Part_Return_Configuration__c = prcLst[0].id;
            i++;
        }
        insert removedpartList;
        
        //create ApplicabilityTerm
        List<WOD_2__Applicability_Term__c> atInclusionObjectLst = TestDataFactory.createApplicabilityTerms(1,'Inclusion');
        for(WOD_2__Applicability_Term__c atInclusionObject : atInclusionObjectLst){
            atInclusionObject.WOD_2__isValidExpression__c = true;
            atInclusionObject.WOD_2__Logical_Grouping__c = '1';
            atInclusionObject.WOD_2__Part_Return_Configuration__c = prcLst[0].id;
            atInclusionObject.WOD_2__Functionality__c = 'Claim Part Returns';
            atInclusionObject.WOD_2__Rule_Object_API_Name__c = 'WOD_2__Removed_Claim_Part__c';
        }
        insert atInclusionObjectLst;
        
        //create ApplicabilityCriteria
        List<WOD_2__Applicability_Criteria__c> acObjectLst = TestDataFactory.createApplicabilityCriterias(1,atInclusionObjectLst.get(0));
        for(WOD_2__Applicability_Criteria__c acObject : acObjectLst){
            acObject.WOD_2__Applicability_Term__c = atInclusionObjectLst[0].id;
            acObject.WOD_2__Criteria_Value__c = 'TRUE';
            acObject.WOD_2__Field_Path_Label__c = 'Warranty Product> RMA Policy';
            acObject.WOD_2__Field_Path__c = 'WOD_2__Warranty_Product__r.RMA_Policy__c';
            acObject.WOD_2__Field_Type__c = 'STRING';
            acObject.WOD_2__Operator__c = 'Equals';
            acObject.WOD_2__Sequence__c = 1;
        }
        insert acObjectLst;
        //delete removedpartList;
        Test.stopTest();
    }
    
    private static testmethod void testPRCRollupFieldUpdate(){
        WOD_2__Claim__c claim = [SELECT Id,ATI_No_of_Requested_Parts__c,ATI_No_of_Shipped_Parts__c,ATI_No_of_Received_Parts__c,ATI_No_of_Inspected_Parts__c FROM WOD_2__Claim__c];
        System.assertEquals(200,claim.ATI_No_of_Requested_Parts__c,'Number Of Parts has been triggered for PRC');
        System.assertEquals(200,claim.ATI_No_of_Shipped_Parts__c,'Number Of Parts has been shipped');
        System.assertEquals(200,claim.ATI_No_of_Received_Parts__c,'Number Of Parts has been received');
        System.assertEquals(200,claim.ATI_No_of_Inspected_Parts__c,'Number Of Parts has been inspected'); 
        List<WOD_2__Removed_Claim_Part__c> removedClaimPartLst = [SELECT Id FROM WOD_2__Removed_Claim_Part__c];
        if(removedClaimPartLst.size() > 0){
            delete removedClaimPartLst;
            undelete removedClaimPartLst;
        }
    }
    
    private static testmethod void testRejectRCP(){
        List<WOD_2__Removed_Claim_Part__c> removedClaimPartLst = [SELECT Id,WOD_2__Inspection_Status__c,WOD_2__Claim__c
                                                                  FROM WOD_2__Removed_Claim_Part__c];
        WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE Id=:removedClaimPartLst[0].WOD_2__Claim__c];
        System.assertEquals(true,claim.WOD_2__Claim_Status__c != 'Pending Approval','Claim is not in pending approval state');
        for(WOD_2__Removed_Claim_Part__c removedpart : removedClaimPartLst) {
            removedpart.WOD_2__Inspection_Status__c = 'Rejected';
        }
        Test.startTest();
            Update removedClaimPartLst;
        Test.stopTest();
        WOD_2__Claim__c claimAfterUpdate = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE Id=:removedClaimPartLst[0].WOD_2__Claim__c];
    }
    
    private static testmethod void testbackUpdateClaimPRCStatus(){
        List<WOD_2__Removed_Claim_Part__c> removedClaimPartLst = [SELECT Id,WOD_2__Payment_Condition__c,Inspected_Quantity__c,WOD_2__Shipped_Quantity__c,WOD_2__Is_Inspected__c,WOD_2__Inspection_Status__c,WOD_2__Claim__c
                                                                  FROM WOD_2__Removed_Claim_Part__c];
        WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c WHERE Id=:removedClaimPartLst[0].WOD_2__Claim__c];
         for(WOD_2__Removed_Claim_Part__c removedpart : removedClaimPartLst) {
            removedpart.WOD_2__Payment_Condition__c = 'Pay After Inspection';
            removedpart.WOD_2__Is_Inspected__c = true;
        }
        Test.startTest();
        Update removedClaimPartLst;
        Test.stopTest();
    }
}