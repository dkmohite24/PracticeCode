@isTest
public class ATI_SHP_InspectShipmentOverrideTest {
	@testSetup
    public static void testSetup(){
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = new List<WOD_2__Business_Category_Configuration_Setting__c>();
        WOD_2__Business_Category_Configuration_Setting__c bccs = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs.Name = 'Reject Claims After Shipment Due In Days';
        bccs.WOD_2__Value__c = '1';
        bccsList.add(bccs);
        
        insert bccsList;
            
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<Account> accList = TestDataFactory.createAccount(1);
        insert accList;
        WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
        casualPart.WOD_2__Business_Unit__c = bcc.Id;
        casualPart.External_Product_Code__c = 'Test';
        casualPart.WOD_2__Item_Type__c='Part';
        casualPart.WOD_2__Track_Type__c='Non-Serialized';
        insert casualPart;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accList[0].Id;
        insert invList;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(200);
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
        }
        insert warrantyProPartLst;
        
        //create warehouse
        List<WOD_2__Warehouse__c> whLst = TestDataFactory.createWarehouse(1);
        insert whLst;
        
        TriggerHandler.bypass('ATI_ClaimTriggerHandler');
        WOD_2__Claim__c claim = new WOD_2__Claim__c();
        claim.name = 'testClaim';
        claim.WOD_2__Account__c = accList[0].id;
        claim.WOD_2__Claim_Status__c = 'Approved';
        claim.WOD_2__Model_Number__c = casualPart.id;
        claim.WOD_2__Date_Of_Failure__c=system.today();
        claim.WOD_2__Causal_Part_Number__c=casualPart.Id;
        claim.WOD_2__Date_Of_Repair__c=system.today();
        claim.WOD_2__Inventory__c = invList[0].id;
        claim.WOD_2__Submit_Date__c = System.today().addDays(-10);
        insert claim;
        
        //create partreturnconfiguration
        List<WOD_2__Part_Return_Configuration__c> prcLst = TestDataFactory.createPartReturnConfiguration(1);
        for(WOD_2__Part_Return_Configuration__c prc : prcLst){
            prc.WOD_2__Return_Location__c = whLst[0].Id;
            prc.WOD_2__Days_Due_Within__c = 1;
        }
        insert prcLst;
        
        //create Removed ClaimPart
        List<WOD_2__Removed_Claim_Part__c> removedpartList = TestDataFactory.createRemovedClaimPart(1);
        Integer i = 0;
        for(WOD_2__Removed_Claim_Part__c removedpart : removedpartList) {
            removedpart.WOD_2__Claim__c = claim.Id;
            removedpart.WOD_2__Is_Auto_PRC__c = true;
            removedpart.WOD_2__Warranty_Product__c =  warrantyProPartLst[i].id;
            removedpart.WOD_2__Part_Return_Requested__c = true;
            removedpart.WOD_2__Is_Shipped__c = true;
            removedpart.WOD_2__Is_Returned__c = true;
            removedpart.WOD_2__Is_Inspected__c = true;
            removedpart.WOD_2__Part_Return_Configuration__c = prcLst[0].id;
            removedpart.WOD_2__Invoice_Quantity__c = 1;
            i++;
        }
        insert removedpartList;
        
        List<WOD_2__Shipment_Detail__c> shipmentsLst = TestDataFactory.createShipments(1); 
        shipmentsLst[0].WOD_2__Claim__c = claim.Id;
        shipmentsLst[0].WOD_2__Status__c = 'Draft';
        insert shipmentsLst;
        
        WOD_2__Claim_Shipment__c claimShipmentObj = new WOD_2__Claim_Shipment__c(WOD_2__Removed_Claim_Part__c=removedpartList[0].Id,
                                                                                 WOD_2__Shipment_Detail__c=shipmentsLst[0].Id);
        insert claimShipmentObj;
    }
  
    @isTest
    public static void testPerformShipmentInspectionSubmission(){
        Test.startTest();
        	WOD_2__Shipment_Detail__c shipObj = [SELECT Id,WOD_2__Inspection_Comments_Internal__c,WOD_2__Status__c,WOD_2__Inspection_Date__c,WOD_2__Inspection_Comments__c,
                                                 		WOD_2__Inspected_By__c
                                                 	FROM WOD_2__Shipment_Detail__c LIMIT 1];
        	List<WOD_2__Claim_Shipment__c> claimShipLst = [SELECT Id,WOD_2__Inspection_Comments__c,WOD_2__Inspection_Comments_Internal__c,WOD_2__Removed_Claim_Part__c,
                                                           		  WOD_2__Inspected_Quantity__c,WOD_2__Removed_Claim_Part__r.WOD_2__Invoice_Quantity__c,
                                                           		  WOD_2__Inspection_Status__c,WOD_2__Shipment_Detail__c,WOD_2__Received_Quantity__c
                                                           	FROM WOD_2__Claim_Shipment__c];
        	
        	WOD_2.ResponseWrapper response = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        	System.assertEquals(System.Label.ATI_Internal_Inspection_Comments_for_shipment_is_mandatory,response.errorMessage);
        	
        	shipObj.WOD_2__Inspection_Comments_Internal__c = 'Testing';
        	WOD_2.ResponseWrapper response0 = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        	System.assertEquals(System.Label.ATI_Inspection_Comments_for_shipment_is_mandatory,response0.errorMessage);
        	
        	shipObj.WOD_2__Inspection_Comments__c = 'Testing';
        	WOD_2.ResponseWrapper response1 = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        	System.assertEquals(System.Label.ATI_Inspection_Comments_for_Parts_is_mandatory,response1.errorMessage);
        
        	claimShipLst[0].WOD_2__Inspection_Comments__c = 'Testing';
        	WOD_2.ResponseWrapper response2 = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        	System.assertEquals(System.Label.ATI_Internal_Inspection_Comments_for_Parts_is_mandatory,response2.errorMessage);
        
        	claimShipLst[0].WOD_2__Inspection_Comments_Internal__c = 'Testing';
        	claimShipLst[0].WOD_2__Inspected_Quantity__c = 2;
        	WOD_2.ResponseWrapper response3 = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        	System.assertEquals(System.Label.ATI_Inspected_Quantity_for_Parts_should_be_valid_and_cannot_be_greater_than_actu,response3.errorMessage);
        
        	claimShipLst[0].WOD_2__Inspected_Quantity__c = 1;
        	claimShipLst[0].WOD_2__Inspection_Status__c = NULL;
        	WOD_2.ResponseWrapper response4 = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        	System.assertEquals(System.Label.ATI_Inspection_Status_for_Parts_is_mandatory,response4.errorMessage);
        
        	claimShipLst[0].WOD_2__Inspection_Status__c = 'Approved';
        	WOD_2.ResponseWrapper response5 = ATI_SHP_InspectShipmentOverride.performShipmentInspectionSubmission(shipObj,claimShipLst);
        
        	ATI_SHP_InspectShipmentOverride.performShipmentInspectionInitialValidation('');
        Test.stopTest();
    }
}