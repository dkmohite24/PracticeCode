/*
    Class Name  :   ATI_DetailPageCompControllerTest
    Description :   Test class for ATI_DetailPageCompController
*/
@isTest
public class ATI_DetailPageCompControllerTest {
    /*
        Method Name :   testSetup
        Descripion  :   Creating test data
    */
    @TestSetup
    public static void testSetUp(){
        Test.startTest();
        //create account
        List<Account> accLst = TestDataFactory.createAccount(3);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = accLst[0].id;
        accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryConfig;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        insert warrantyProLst;
        
        Id stockInvRecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByDeveloperName().get('Stock').getRecordTypeId(); 
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.RecordTypeId = stockInvRecordTypeId;
            inventory.WOD_2__Type__c = 'Stock';
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        Test.stopTest();
    }

    /*
        Method Name :   testDetailGetURL
        Description :   testing URL of detail page
    */
    private static testmethod void testDetailGetURL(){
        Test.startTest();
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        List<ATI_DetailpageConfiguration__mdt> detailPageConfigList = [SELECT DeveloperName,HeaderLabel__c,RedirectUrl__c,DetailPageValidationOverrideClass__r.WOD_2__ClassName__c,
                                                                   (SELECT DeveloperName,ATI_Section_Name__c,ATI_Order__c
                                                                    FROM SectionConfigurations__r order by ATI_Order__c)
                                                                   FROM ATI_DetailpageConfiguration__mdt WHERE DeveloperName=:'RetailInventoryDetailPage'];
        List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Account__c,WOD_2__Type__c FROM WOD_2__Inventory__c];
        responseWrapperObj = ATI_DetailPageCompController.getDetailPageConfig('RetailInventoryDetailPage',invLst[0].id);
        System.assertEquals(JSON.serialize(detailPageConfigList.get(0)), responseWrapperObj.data,'Record details are returned with passed Metadata');
        String detailPageMetadataConfigName = 'TestDetailPage';
        responseWrapperObj = ATI_DetailPageCompController.getDetailPageConfig(detailPageMetadataConfigName, invLst[0].id); 
        System.assertEquals('No matching metadata found for config :'+ detailPageMetadataConfigName, responseWrapperObj.errormessage,'Passed Metadata is not found in org');
        responseWrapperObj = ATI_DetailPageCompController.queryWithoutShare('select id from WOD_2__Inventory__c limit 1');
        System.assertEquals(true, responseWrapperObj.status,'Query return results without sharing record');
        Test.stopTest();
    }

    /*
        Method Name :   testDetailGetURL
        Description :   testing detail page for distributor
    */
    private static testmethod void testDetailForDistributor(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        Test.startTest();
        //create Portal User
        List<User> portalAccountOwner1 = TestDataFactory.createUser(1);
        portalAccountOwner1[0].UserRoleId = portalRole.Id;
        portalAccountOwner1[0].ProfileId = profile1.Id;
        Database.insert(portalAccountOwner1);
        List<Account> portalAccount1;
        List<Account> account;
        List<User> user1;
        User thisUser;
        System.runAs (portalAccountOwner1[0]) {
            //Create account
            WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
            portalAccount1 = [SELECT Id FROM Account LIMIT 1];
            portalAccount1[0].OwnerId = portalAccountOwner1[0].Id;
            
            Database.update(portalAccount1);
            
            //Create contact
            List<Contact> contact1 = TestDataFactory.createContact(1);
            contact1[0].AccountId = portalAccount1[0].id;
            Database.insert(contact1);
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile where Name = 'ATI Distributor and Dealer' Limit 1];
            user1 = TestDataFactory.createUser(1);          
            user1[0].ContactId = contact1[0].Id;
            user1[0].ProfileId = portalProfile.Id;
            Database.insert(user1);
            
            System.runAs(user1[0]) {
                account = TestDataFactory.createAccount(1);
                for(Integer i=0;i<account.size();i++){
                    account[i].Name = 'Testacc'+i;
                    account[i].Sales_RegionA__c = 'EMEA';
                    account[i].SAP_ID__c = '1223123'+i+i;
                    account[i].Location_Type__c = 'test'+i;    
                    account[i].parentId = portalAccount1[0].id;
                }
                insert account;
                
                List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
                insert busCategoryConfig;
                
                //create Account business category 
                List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
                accBusinessCategoryConfig[0].WOD_2__Account__c = account[0].id;
                accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
                insert accBusinessCategoryConfig;
                
                //create warranty product
                List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
                for(Integer i=0;i<warrantyProLst.size();i++){
                    //warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
                }
                insert warrantyProLst;
                
                Id stockInvRecordTypeId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByDeveloperName().get('Stock').getRecordTypeId(); 
                List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
                for(WOD_2__Inventory__c inventory : inventoryLst){
                    inventory.RecordTypeId = stockInvRecordTypeId;
                    inventory.WOD_2__Type__c = 'Stock';
                    inventory.WOD_2__Account__c = account[0].id;
                    inventory.WOD_2__Item__c = warrantyProLst[2].id;
                    inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
                }
                insert inventoryLst;
                List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
                insert warrantyFaultCodeLst;
                
                Id partClaimRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
                //create rejected claims
                List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(1); 
                for(WOD_2__Claim__c claimObj : claimLst){
                    claimObj.RecordTypeId = partClaimRecordTypeId;
                    claimObj.WOD_2__Claim_Status__c = 'Submitted';
                    claimObj.WOD_2__Account__c = account[0].id;
                    claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
                    claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
                    claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
                    claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
                    claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
                    claimObj.WOD_2__Date_Of_Failure__c = Date.today();
                    claimObj.WOD_2__Date_Of_Repair__c = Date.today();
                    claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
                }
                insert claimLst;
                responseWrapperObj = ATI_DetailPageCompController.hasAccessToClaim(claimLst[0].id);
                responseWrapperObj = ATI_DetailPageCompController.updateSObjects(new List<sObject>{claimLst[0]},true);
                System.assertEquals( '[{"id":"'+claimLst[0].id+'","success":true,"errors":[]}]', responseWrapperObj.data,'check whether object has updated or not?');
                responseWrapperObj = ATI_DetailPageCompController.updateSObjects(new List<sObject>{portalAccount1[0]},true);
            }
        }
        Test.stopTest();
    }
}