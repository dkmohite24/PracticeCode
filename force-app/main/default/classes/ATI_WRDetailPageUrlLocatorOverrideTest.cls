/*
    Class Name  :   ATI_WRDetailPageUrlLocatorOverrideTest
    Description :   Test class for ATI_WRDetailPageUrlLocatorOverride
*/
@isTest
public class ATI_WRDetailPageUrlLocatorOverrideTest{
    /*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
	@testSetup
    static void testSetup(){ 
        List<Account> accObjList = TestDataFactory.createAccount(2);
        accObjList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accObjList;
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProductList.size();i++){
            //warrantyProductList[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
      	insert warrantyProductList;
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(1);
        inventoryList[0].WOD_2__Business_Unit__c = busCategoryList[0].Id;
        inventoryList[0].WOD_2__Account__c = accObjList[0].Id;
        inventoryList[0].WOD_2__Item__c = warrantyProductList[2].Id;
        insert inventoryList;
        List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        lstWR[0].WOD_2__Inventory__c = inventoryList[0].id;
        lstWR[0].WOD_2__Customer__c = accObjList[1].Id;
        lstWR[0].WOD_2__Account__c = accObjList[0].Id;
        insert lstWR;
        
        
    }

    /*
        Method Name :   testGetUrl
        Description :   Method to test URL
    */
    @isTest
    private static void testGetUrl(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gdWilUsr', Email='pmtestuser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id, WOD_2__Business_Units__c='ATI',
        TimeZoneSidKey='America/Los_Angeles', UserName='pmtestuser@testorg.com');
        insert u;

        system.runAs(u){
            WOD_2__Warranty_Registration__c wrObj = [SELECT Id FROM WOD_2__Warranty_Registration__c];
            String str = ATI_WRDetailPageUrlLocatorOverride.getURL(wrObj.id);
            /*System.assertEquals('/dealer/s/warrantyregistrationdetailpage?page=WarrantyRegistrationDetailPage&id='+wrObj.id,
             str, 'URL should be same');*/
            Test.stopTest();
        }
    }
}