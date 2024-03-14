/*
    Class Name  :   ATI_ValidateInventoryDetailAccessTest
    Description :   Test class for ATI_ValidateInventoryDetailPageAccess
*/
@isTest
public class ATI_ValidateInventoryDetailAccessTest { 
    /*
        Method Name :   CheckValidateTest
        Description :   Method to test validation
    */
    public static TestMethod void checkValidateTest(){
        List<WOD_2__Business_Category_Configuration__c> buList = testdatafactory.createBusinessCategoryConfiguration(1);
        insert buList;  
            
        List<Account> lstAcc = TestDataFactory.createAccount(1);
        lstAcc[0].Sales_RegionA__c = 'EMEA';
        lstAcc[0].SAP_ID__c = '1223123';
        lstAcc[0].Location_Type__c = 'test';    
        insert lstAcc;
        WOD_2__Inventory__c invObj = new WOD_2__Inventory__c();
        invObj.WOD_2__Account__c = lstAcc[0].id;
        invObj.WOD_2__Business_Unit__c = buList[0].id;
        insert invObj ;
        ATI_ValidateInventoryDetailPageAccess  vidpObj= new ATI_ValidateInventoryDetailPageAccess(); 
        Boolean boolvalue = vidpObj.validateDetailPage(invObj.Id);
        System.assertEquals(true, boolValue, 'Assert Failed!');
    }
}