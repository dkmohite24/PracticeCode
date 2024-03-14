/*
    Class Name  :   ATI_SectionComponentControllerTest
    Description :   Test class for ATI_SectionComponentController
*/
@isTest
private class ATI_SectionComponentControllerTest {
    /*
        Method Name :   testSetupMethod
        Description :   Method to create test data
    */
    @testSetup static void testSetupMethod(){
        Test.startTest();
            Integer recCount = 1;
            List<Account> lstAcc = TestDataFactory.createAccount(1);
            lstAcc[0].Sales_RegionA__c = 'EMEA';
            lstAcc[0].SAP_ID__c = '1223123';
            lstAcc[0].Location_Type__c = 'test';    
        	insert lstAcc;
        	
            List<WOD_2__Business_Category_Configuration__c> lstBcc = TestDataFactory.createBusinessCategoryConfiguration(recCount);
            insert lstBcc;
            List<WOD_2__Inventory__c> lstInv = TestDataFactory.createInventory(recCount);
            for(integer i=0; i<1; i++) {
                lstInv[i].WOD_2__Account__c = lstAcc[i].Id;
                lstInv[i].WOD_2__Business_Unit__c = lstBcc[i].Id;
            }
            insert lstInv;
        Test.stopTest();
    }
    
    /*
        Method Name :   testGetSectionData
        Description :   Method to test getSectionData
    */
    public static TestMethod void testGetSectionData(){  
        Test.startTest();
        List<WOD_2__Inventory__c> lstInv = [SELECT Id FROM WOD_2__Inventory__c];
        WOD_2.ResponseWrapper response = ATI_SectionComponentController.getSectionData('Stock_Inventory_Information_Section',lstInv[0].id);
        ATI_SectionComponentController.getSectionData('Stock_Inventory_System_Info_Section',lstInv[0].id);
        ATI_SectionComponentController.getUserInformation();
        System.assertEquals(true, response.data != NULL, 'Custom metadata for Section should be created');
        Test.stopTest();
    }
}