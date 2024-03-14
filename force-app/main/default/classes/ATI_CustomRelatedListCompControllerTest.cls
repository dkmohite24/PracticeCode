/*
    Class Name  :   ATI_CustomRelatedListCompControllerTest
    Descriptin  :   Test class for ATI_CustomRelatedListCompController
*/
@isTest
private class ATI_CustomRelatedListCompControllerTest {
    /*
        Method Name :   testSetupMethod
        Description :   Testsetup method to create test data
    */
    @testSetup
    static void testSetupMethod(){
        Test.startTest();
        Integer recCount = 1;
        List<Account> accountList = TestDataFactory.createAccount(recCount);   
        for(Integer i=0;i<accountList.size();i++){
        	accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'test'+i;    
        }
        insert accountList;
        
        List<WOD_2__Business_Category_Configuration__c> bccList = TestDataFactory.createBusinessCategoryConfiguration(recCount);
        insert bccList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(4);
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        warrantyProductList[3].WOD_2__Type__c = 'Item';
        warrantyProductList[3].WOD_2__Item_Type__c = 'Part';
        warrantyProductList[3].WOD_2__Track_Type__c = 'Non-Serialized';
        insert warrantyProductList;
        
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(recCount);
        for(integer invRec=0; invRec<1; invRec++) {
            inventoryList[invRec].WOD_2__Account__c = accountList[invRec].Id;
            inventoryList[invRec].WOD_2__Business_Unit__c = bccList[invRec].Id;
        }
        insert inventoryList;
        
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        insert viList;
        
        List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = TestDataFactory.createVinMappers(1,viList[0].Id);
        vinMapperLst[0].ATI_Inventory__c= inventoryList[0].Id;
        vinMapperLst[0].Name = '1J4GL58K96W180703';
        insert vinMapperLst;
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='MachineClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today(),
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accountList[0].Id,WOD_2__Work_Performed_Comments__c='Test',
                                                  ATI_Technician_Name__c='Test',ATI_Tracking_Number__c='1000');
        claim.WOD_2__BusinessCategory__c = bccList[0].Id;
        insert claim;
        Test.stopTest();
    }
    /*
        Method Name :   testGetRelatedListData
        Description :   Testing Related list data
    */
    public static testMethod void testGetRelatedListData(){
        Test.startTest();
        List<WOD_2__Inventory__c> inventoryList = [SELECT Id FROM WOD_2__Inventory__c];
        WOD_2.ResponseWrapper response0 = ATI_CustomRelatedListCompController.getDatatableData('DT_AdvancedSearch_Claim','','NO');
        WOD_2.ResponseWrapper response00 = ATI_CustomRelatedListCompController.getDatatableData('DT_AdvancedSearch_Claim','VIN = \'1J4GL58K96W180703\'','NO');
        WOD_2.ResponseWrapper response3 = ATI_CustomRelatedListCompController.getDatatableData('InventoryTransactionHistory1','','NO');
        WOD_2.ResponseWrapper response4 = ATI_CustomRelatedListCompController.getDatatableData('DT_AdvancedSearch_Inventory','','NO');
        WOD_2.ResponseWrapper response = ATI_CustomRelatedListCompController.getRelatedListData('InventoryTransactionHistory',inventoryList[0].id,'NO');
        System.assertEquals(true,response.data != NULL , 'Related list data should be fetched');
        WOD_2.ResponseWrapper response1 = ATI_CustomRelatedListCompController.getDatatableData('InventoryTransactionHistory','','NO');
        System.assertEquals(true,response1.data != NULL , 'Related list data should be fetched');
        WOD_2.ResponseWrapper response2 = ATI_CustomRelatedListCompController.getRelatedListData('InventoryTransactionHistory1',inventoryList[0].id,'NO');
        System.assertEquals(true,response2.data != NULL , 'Related list data should be fetched');
        Test.stopTest();
    }
}