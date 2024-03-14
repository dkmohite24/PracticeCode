/* 
 	Name: ATI_WR_RegistrationHandlerTest
	Description : Test Class for ATI_WR_RegistrationHandler
*/
@isTest
public class ATI_WR_RegistrationHandlerTest {
	@testSetup    
    static void testSetup(){
        List<WOD_2__Business_Category_Configuration__c> bccLst = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert bccLst;
        
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[0].ATI_RPS_Status__c = true;
        accList[0].SAP_ID__c = '1231912392';
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
        inventoryList[0].WOD_2__Install_Date__c = System.today().addDays(-20);
        inventoryList[0].WOD_2__Business_Unit__c = bccLst[0].Id;
        insert inventoryList;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(1);
        policyDefList.get(0).WOD_2__Type__c = 'Standard';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
        //Vocation Code 
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createVocationCode(1,false);
        insert wcLst;
    }
    
    @isTest
    private static void testSaveWarrantyRegistration(){
        WOD_2__Inventory__c invData = [SELECT Id,WOD_2__Install_Date__c, WOD_2__Scrapped__c, ATI_Vocation_Code__c,WOD_2__Business_Unit__c
                                       FROM WOD_2__Inventory__c LIMIT 1];
        
        Account customerAccObj = [SELECT Id FROM Account WHERE WOD_2__Warranty_Account_Type__c = 'Customer'];
        Account dealerAccObj = [SELECT Id FROM Account WHERE WOD_2__Warranty_Account_Type__c = 'Dealer'];
        List<WOD_2__Warranty_Code__c> wcLst = [SELECT Id FROM WOD_2__Warranty_Code__c];
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        WOD_2__Warranty_Registration__c wrRec = new WOD_2__Warranty_Registration__c();
        wrRec.WOD_2__Inventory__c=invData.Id;
        wrRec.WOD_2__Account__c = dealerAccObj.Id; 
        wrRec.WOD_2__Customer__c = customerAccObj.Id;
        wrRec.WOD_2__Status__c='Draft';
        wrRec.WOD_2__Install_Date__c = System.today().addDays(-10);
        wrRec.ATI_Vocation_Code__c = wcLst.get(0).id;
        wrRec.WOD_2__Registration_Comments__c='Test Comments';
        
        WOD_2.WR_InventoryRegistrationWrapper wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
        
        Test.startTest();
        	ATI_WR_RegistrationHandler wrHandlerObj = new ATI_WR_RegistrationHandler();
			wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);        	
        Test.stopTest();
        
        System.assertEquals(1,[SELECT Id FROM WOD_2__Warranty_Registration__c
                              	WHERE WOD_2__Registration_Type__c='Standard Registration'].size(),'Warranty registration must have been created');
        
        System.assertEquals(1,[SELECT Id FROM WOD_2__Inventory__c
                             	WHERE WOD_2__Install_Date__c=:wrRec.WOD_2__Install_Date__c
                             	AND ATI_Vocation_Code__c=:wrRec.ATI_Vocation_Code__c].size(),'Inventory vocation code and install date should be updated');
    }
    
    @isTest
    private static void testCoverExceptions(){ 
       	Test.startTest();
            WOD_2__Inventory__c invData = [SELECT Id,WOD_2__Install_Date__c, WOD_2__Scrapped__c, ATI_Vocation_Code__c,WOD_2__Business_Unit__c
                                           FROM WOD_2__Inventory__c LIMIT 1];
			invData.WOD_2__Install_Date__c = NULL;
        	update invData;
        
            Account customerAccObj = [SELECT Id FROM Account WHERE WOD_2__Warranty_Account_Type__c = 'Customer'];
            Account dealerAccObj = [SELECT Id FROM Account WHERE WOD_2__Warranty_Account_Type__c = 'Dealer'];
            List<WOD_2__Warranty_Code__c> wcLst = [SELECT Id FROM WOD_2__Warranty_Code__c];
            List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
            WOD_2__Warranty_Registration__c wrRec = new WOD_2__Warranty_Registration__c();
            wrRec.WOD_2__Inventory__c=invData.Id;
            wrRec.WOD_2__Account__c = dealerAccObj.Id; 
            wrRec.WOD_2__Customer__c = customerAccObj.Id;
            wrRec.WOD_2__Status__c='Draft';
            //wrRec.WOD_2__Install_Date__c = System.today().addDays(-10);
            wrRec.ATI_Vocation_Code__c = wcLst.get(0).id;
            wrRec.WOD_2__Registration_Comments__c='Test Comments';
            
            WOD_2.WR_InventoryRegistrationWrapper wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
            ATI_WR_RegistrationHandler wrHandlerObj = new ATI_WR_RegistrationHandler();
            WOD_2.ResponseWrapper response = wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);    
        	System.assertEquals(Label.ATI_WR_InstallDateMandatory, response.errormessage, 'Error message should be there');
        
        	//comments code is blank
        	wrRec.WOD_2__Install_Date__c = System.today().addDays(-10);
        	wrRec.WOD_2__Registration_Comments__c = NULL;
         	//wrRec.WOD_2__Registration_Comments__c = 'test comment';
        	wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
        	WOD_2.ResponseWrapper response0 = wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);    
        	//System.assertEquals(Label.ATI_WR_commentMandatory, response0.errormessage, 'Error message should be there');
        
        	//vocation code is blank
        	wrRec.ATI_Vocation_Code__c = NULL;
        	wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
        	WOD_2.ResponseWrapper response1 = wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);    
        	System.assertEquals(Label.ATI_WR_vcMandatory, response1.errormessage, 'Error message should be there');
        
        	//acc is blank
        	wrRec.WOD_2__Account__c = NULL;
        	wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
        	WOD_2.ResponseWrapper response2 = wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);    
        	System.assertEquals(Label.ATI_Mandatory_Account, response2.errormessage, 'Error message should be there');
        
        	//predelivery true and install date present
        	wrRec.ATI_Pre_Delivery__c = true;
        	wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
        	WOD_2.ResponseWrapper response3 = wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);    
        	System.assertEquals(Label.ATI_WR_installDEmptyCheck, response3.errormessage, 'Error message should be there');
        
        	//scrapped inventory error
        	invData.WOD_2__Scrapped__c = true;
        	update invData;
        	wrInvWrapperObj = new WOD_2.WR_InventoryRegistrationWrapper(invData,wrRec);
        	WOD_2.ResponseWrapper response4 = wrHandlerObj.saveWarrantyRegistration(wrInvWrapperObj);    
        	System.assertEquals(false, response4.status, 'Error message should be there');
        Test.stopTest();
    }
}