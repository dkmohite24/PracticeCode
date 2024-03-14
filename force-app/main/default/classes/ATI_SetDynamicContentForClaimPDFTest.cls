@isTest
public class ATI_SetDynamicContentForClaimPDFTest {
	@testSetup
    private static void setup(){
        List<WOD_2__Business_Category_Configuration__c> bccs = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert bccs;
        
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer'; 
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bccs[0]);
        insert bccsList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(4);
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        warrantyProductList[3].WOD_2__Type__c = 'Item';
        warrantyProductList[3].WOD_2__Item_Type__c = 'Part';
        warrantyProductList[3].WOD_2__Track_Type__c = 'Non-Serialized';
              insert warrantyProductList;

                             //Create WarrantyProductPriceBook
        Id partCostRTId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Cost').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(1,warrantyProductList[3].Id);
        wpPbLst[0].RecordTypeId = partCostRTId;
        wpPbLst[0].WOD_2__Price__c = 100;
        insert wpPbLst;
                                     
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(2);
        inventoryList[0].Name = inventoryList[0].WOD_2__Serial_Number__c = 'FailedInvSerialNumber';
        inventoryList[0].WOD_2__Install_Date__c = System.today();
        inventoryList[0].WOD_2__Warranty_Start_Date__c = System.today();
        inventoryList[1].Name = inventoryList[1].WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber';
        for(WOD_2__Inventory__c inv : inventoryList){
            inv.WOD_2__Business_Unit__c = busCategoryList[0].Id;
            inv.WOD_2__Account__c = accList[0].Id;
            inv.WOD_2__Item__c = warrantyProductList[2].Id;
        }
        insert inventoryList;
        
        //Create MajorComponent
        List<WOD_2__Major_Component__c> majorCmpLst = TestDataFactory.createMajorComp(1);
        majorCmpLst.get(0).WOD_2__Serial_number__c = 'BK5536N19260014E';
        majorCmpLst.get(0).ATI_Type__c = 'ECU';
        majorCmpLst.get(0).WOD_2__Warranty_Product__c = warrantyProductList.get(3).id;
       // majorCmpLst.get(0).WOD_2__Inventory__c = inventoryList[0].id;
        insert majorCmpLst;
        
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        //viList[0].ATI_Inventory__c = inventoryList[0].Id;
        insert viList;
        
        /** Created as part of VIN Transmission Mapper*/
        List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = TestDataFactory.createVinMappers(1,viList[0].Id);
        vinMapperLst[0].ATI_Inventory__c= inventoryList[0].Id;
        insert vinMapperLst;
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='MachineClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today(),
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id,WOD_2__Work_Performed_Comments__c='Test',
                                                  ATI_Technician_Name__c='Test',ATI_Tracking_Number__c='1000',ATI_VIN__c = vinMapperLst[0].Name);
        claim.WOD_2__BusinessCategory__c = bccs[0].Id;
        insert claim;
    }
    
    @isTest
    private static void testGetDynamicContentForPdf(){
        WOD_2__Claim__c claimObj = [SELECT Id FROM WOD_2__Claim__c LIMIT 1];
        Map<String,String> inputMap = new Map<String,String>{'recordId'=> claimObj.Id, 'type'=>'Claim'};
        Test.startTest();
        	ATI_SetDynamicContentForClaimPDF controllerObj = new ATI_SetDynamicContentForClaimPDF();
        	WOD_2.ResponseWrapper responseWrapper = controllerObj.getDynamicContentForPdf(inputMap);
        Test.stopTest();
        System.assertEquals(true,responseWrapper.status);
    }
}