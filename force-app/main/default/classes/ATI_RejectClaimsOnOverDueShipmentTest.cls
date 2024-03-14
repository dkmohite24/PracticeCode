/*
	Class Name	:	ATI_RejectClaimsOnOverDueShipmentTest
	Description	:	Test class for ATI_RejectClaimsOnOverDueShipment
*/
@isTest
public class ATI_RejectClaimsOnOverDueShipmentTest {
	@testSetup
    public static void testSetup(){
        Test.startTest();
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = new List<WOD_2__Business_Category_Configuration_Setting__c>();
        WOD_2__Business_Category_Configuration_Setting__c bccs = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs.Name = 'Shipment Overdue Additional days';
        bccs.WOD_2__Value__c = '1';
        bccsList.add(bccs);
        
        WOD_2__Business_Category_Configuration_Setting__c bccs1 = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs1.Name = 'Claim Status On Shipment Over Due';
        bccs1.WOD_2__Value__c = 'Submitted';
        bccsList.add(bccs1);
        
        insert bccsList;
            
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<Account> accList = TestDataFactory.createAccount(1);
        insert accList;
        WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
        casualPart.WOD_2__Business_Unit__c = bcc.Id;
        casualPart.External_Product_Code__c = 'Test';
        casualPart.WOD_2__Item_Type__c = 'Machine';
        casualPart.WOD_2__Track_Type__c = 'Non-Serialized';
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
        whLst[0].WOD_2__IsInactive__c = false;
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
        claim.WOD_2__Claim_Type__c = 'Machine';
        claim.WOD_2__BusinessCategory__c = bcc.id;
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
            removedpart.WOD_2__Return_Location__c = whLst[0].Id;
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
        Test.stopTest();
    }
    
    @isTest
    public static void testRejectClaimOnShipmentOverdue(){
        Test.startTest();
        ATI_RejectClaimsOnOverDueShipmentSchdl shedulerObj = new ATI_RejectClaimsOnOverDueShipmentSchdl();
        String sch = '0 0 23 * * ?'; system.schedule('Test', sch, shedulerObj);
        shedulerObj.execute(null);
        WOD_2__Claim__c claim =[Select Id from WOD_2__Claim__c limit 1];  
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(claim.Id);       
        req.setProcessDefinitionNameOrId('ATI_Claim_Manual_Approval_Latest_V1');
        ATI_RejectClaimsOnOverDueShipment chck = new ATI_RejectClaimsOnOverDueShipment();
        Database.executeBatch(chck);
        Test.stopTest();
    }
}