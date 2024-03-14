/*
    Class Name  :   ATI_InventoryPageUrlLocatorCntrlTest
    Description :   Test class for ATI_InventoryPageUrlLocatorController
*/
@isTest
public class ATI_InventoryPageUrlLocatorCntrlTest {
    /*
        Method Name :   testSetup
        Description :   Method to create test data
    */
    @testSetup
    static void testSetup(){
        List<Account> accountList = TestDataFactory.createAccount(1);   
        for(Integer i=0;i<accountList.size();i++){
        	accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'test'+i;    
        }
        insert accountList;
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(2);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.RecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Retail').getRecordTypeId();
            inventory.WOD_2__Account__c = accountList[0].id;
        }
        inventoryLst[0].WOD_2__Type__c = 'Retail';
        inventoryLst[1].WOD_2__Type__c = 'Stock';
        inventoryLst[1].RecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByName().get('Stock').getRecordTypeId();
        insert inventoryLst;
    }
    /*
        Method Name :   testGetUrl
        Description :   Method to test URL
    */
    @isTest
    private static void testGetUrl(){
        Test.startTest();
        List<WOD_2__Inventory__c> invObj = [SELECT Id FROM WOD_2__Inventory__c];
        String str = ATI_InventoryPageUrlLocatorController.getURL(invObj[0].id);
        System.assertEquals('/dealer/s/inventorydetailpage?page=RetailInventoryDetailPage&id='+invObj[0].id, str, 'URL Should be same');
        String str1 = ATI_InventoryPageUrlLocatorController.getURL(invObj[1].id); 
        System.assertEquals('/dealer/s/inventorydetailpage?page=StockInventoryDetailPage&id='+invObj[1].id, str1, 'URL Should be same');
        Test.stopTest();
    }
}