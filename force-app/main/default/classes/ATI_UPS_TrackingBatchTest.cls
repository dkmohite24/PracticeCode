@isTest
public class ATI_UPS_TrackingBatchTest {
	@testSetup
    public static void testSetup(){
        Test.startTest();
        //create account
        List<Account> account = TestDataFactory.createATIDistributorAccount(1);
        account[0].ATI_Customer_Group__c = '';
        account[0].ATI_Price_Group__c='';
        account[0].ATI_Account_Group__c='';
        insert account;
        
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
        List<WOD_2__Removed_Claim_Part__c> removedpartList = TestDataFactory.createRemovedClaimPart(1);
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
    }
    
    @isTest
    private static void testUPSBatch(){
        Test.setMock(HttpCalloutMock.class, new ATI_MockHttpResponseGenerator.MockHttpResponseGeneratorRestUpsShip());
        WOD_2__Removed_Claim_Part__c part = [SELECT id FROM WOD_2__Removed_Claim_Part__c Limit 1];
        List<WOD_2__Claim_Shipment__c> cShipList = new List<WOD_2__Claim_Shipment__c>();
        
        WOD_2__Shipment_Detail__c shipment = new WOD_2__Shipment_Detail__c();
        shipment.Name = 'TestShip';
        insert shipment;
        WOD_2__Claim_Shipment__c clmShipObj = new WOD_2__Claim_Shipment__c(WOD_2__Removed_Claim_Part__c=part.Id,
                                                                           WOD_2__Shipment_Detail__c=shipment.Id);
        insert clmShipObj;
        
        WOD_2__Carrier__c carr = new WOD_2__Carrier__c();
        carr.name = 'UPS';
        insert carr;
        shipment.WOD_2__Carriers__c = carr.id;
        shipment.WOD_2__Status__c = 'Shipped';
        shipment.WOD_2__Tracking_Number__c='TEST123';
        update shipment;
        Test.startTest();
        	Database.executeBatch(new ATI_UPS_TrackingBatch(),1);
            ATI_UPS_TrackingScheduler.scheduleUPSTrackingBatch();
        Test.stopTest();
        //System.assertEquals('Delivered', [SELECT Id,WOD_2__Tracking_Status__c FROM WOD_2__Shipment_Detail__c LIMIT 1].WOD_2__Tracking_Status__c);
    }
}