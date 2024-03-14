/*
	Class Name	:	ATI_CustomListViewControllerTest
	Description	:	Test class for ATI_CustomListViewController
*/
@isTest
public class ATI_CustomListViewControllerTest {
    @TestSetup
    static void makeData(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accountList = TestDataFactory.createAccount(3); 
        accountList[0].Name = 'Testacc';
        accountList[0].Sales_RegionA__c = 'EMEA';
        accountList[0].SAP_ID__c = '1223123';
        accountList[0].Location_Type__c = 'Type';
        accountList[0].WOD_2__Warranty_Account_Type__c='Dealer';
        insert accountList[0];
        
        accountList[1].Name = 'Testacc Child';
        accountList[1].Sales_RegionA__c = 'North America';
        accountList[1].SAP_ID__c = '1133445';
        accountList[1].Location_Type__c = 'L';
        accountList[1].WOD_2__Warranty_Account_Type__c='Dealer';
        accountList[1].twodcms__Primary_Email_Id__c='test@test.com';
        accountList[1].ParentId = accountList[0].Id;
        insert accountList[1];
        
        accountList[2].Name = 'Test Customer';
        accountList[2].Sales_RegionA__c = 'North America';
        accountList[2].SAP_ID__c = '2435';
        accountList[2].Location_Type__c = 'ds';
        accountList[2].WOD_2__Warranty_Account_Type__c='Customer';
        insert accountList[2];
        
        insert new Group(Name='ATI_Warranty_Approver_'+accountList[0].Id);
        
        //Warranty Product at Model Level for Extended Warranty Pricing
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(1);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
            warrantyProLst[i].WOD_2__Type__c = 'Item';
            warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
            warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        invList[0].WOD_2__Manufacturing_Date__c = system.today().addYears(-3);
        invList[0].WOD_2__Install_Date__c = system.today();
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].WOD_2__Units_Usage__c = 6000;
        invList[0].WOD_2__Type__c = 'Retail';
        invList[0].Name = 'TEST001';
        invList[0].ATI_Warranty_Status__c = 'Pending Distributor Approval';
        insert invList;
    }
 
    @isTest
    private static void testGetListViews(){
        Test.startTest();
            List<ATI_Custom_List_Views__mdt> mdtLst = ATI_CustomListViewController.getListViews('WOD_2__Inventory__c');
        Test.stopTest();
        System.assertEquals(true,mdtLst.size() > 0,'List views for inventory should be returned');
    }
    
    @isTest
    private static void testGetListViewDataOnLoad(){
        Test.startTest();
            WOD_2.ResponseWrapper response = ATI_CustomListViewController.getListViewDataOnLoad('WOD_2__Inventory__c');
        Test.stopTest();
        System.assertEquals(true,response.status,'return status should be true');
    }
    
    @isTest
    private static void testGetListViewOnChange(){
        System.assertEquals('Retail', [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c LIMIT 1].WOD_2__Type__c);
        List<ATI_Custom_List_Views__mdt> mdtLst = ATI_CustomListViewController.getListViews('WOD_2__Inventory__c');
        Test.startTest();
        	List<String> existingIdLst = new List<String>();
            WOD_2.ResponseWrapper response = 
                ATI_CustomListViewController.getListViewOnChange('WOD_2__Inventory__c',JSON.serialize(mdtLst[1]),
                                                                 25,0,JSON.serialize(existingIdLst),'Name','ASC','');
        Test.stopTest();
        System.assertEquals(true,response.status,'return status should be true');
    }
    
    @isTest
    private static void testGetListViewOnChangeOtherConditions(){
        System.assertEquals('Retail', [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c LIMIT 1].WOD_2__Type__c);
        List<ATI_Custom_List_Views__mdt> mdtLst = ATI_CustomListViewController.getListViews('WOD_2__Inventory__c');
        Test.startTest();
        	List<String> existingIdLst = new List<String>();
            WOD_2.ResponseWrapper response = 
                ATI_CustomListViewController.getListViewOnChange('WOD_2__Inventory__c',JSON.serialize(mdtLst[1]),
                                                                 25,0,JSON.serialize(existingIdLst),'Name','DESC','TEST');
        Test.stopTest();
        System.assertEquals(true,response.status,'return status should be true');
    }
}