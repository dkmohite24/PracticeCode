/*
	Class Name	:	ATI_CLM_WRDetailsControllerTest
	Description	:	Test class for ATI_CLM_WRDetailsController
*/
@isTest
public class ATI_CLM_WRDetailsControllerTest {
	@testSetup    
    static void testSetup(){
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProductList.size();i++){
            warrantyProductList[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
      	insert warrantyProductList;
        
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(1);
        inventoryList[0].WOD_2__Business_Unit__c = busCategoryList[0].Id;
        inventoryList[0].WOD_2__Account__c = accList[0].Id;
        inventoryList[0].WOD_2__Item__c = warrantyProductList[2].Id;
        insert inventoryList;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=inventoryList[0].Id;
            wrRec.WOD_2__Account__c = accList[0].Id;
            wrRec.WOD_2__Customer__c = accList[1].Id;
            wrRec.WOD_2__Status__c='In Progress';
        }
        insert wrList;
        
        /*ATI_Vehicle_Information__c vehicleInfoRec = new ATI_Vehicle_Information__c(
                                                                                   ATI_Vehicle_Make__c='make',ATI_Vehicle_Model__c='model',
                                                                                   Name='abcdefgh4jk123457'//,ATI_Inventory__c=inventoryList[0].Id
                                                                                  );
        insert vehicleInfoRec;*/
    }
    
    @isTest
    private static void testFetchInvAndVIDetails(){
        WOD_2__Inventory__c invObj = [SELECT Id FROM WOD_2__Inventory__c LIMIT 1];
        Test.startTest();
        	ATI_CLM_WRDetailsController.isLoggedInUserAsDistributor();
        	ATI_CLM_WRDetailsController.VehiclePicklistUnit();
        	WOD_2.ResponseWrapper responseObj = ATI_CLM_WRDetailsController.fetchInvAndVIDetails(invObj.Id);
        Test.stopTest();
        System.assertEquals(true,responseObj.Status,'Invetory data must be returned');
    }
}