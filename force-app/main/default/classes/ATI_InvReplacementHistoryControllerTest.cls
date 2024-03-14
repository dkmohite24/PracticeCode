/* Name: ATI_InvReplacementHistoryControllerTest
Description : ATI_InvReplacementHistoryControllerTest - Test Class for ATI_InvReplacementHistoryController
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      19-FEB-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_InvReplacementHistoryControllerTest {

    @testSetup
    static void testSetup(){
        
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        
        List<WOD_2__Warranty_Product__c> warrantyProductList = TestDataFactory.createWarrantyProduct(4);
        warrantyProductList[2].WOD_2__Type__c = 'Item';
        warrantyProductList[2].WOD_2__Item_Type__c = 'Machine';
        warrantyProductList[2].WOD_2__Track_Type__c = 'Serialized';
        warrantyProductList[3].WOD_2__Type__c = 'Item';
        warrantyProductList[3].WOD_2__Item_Type__c = 'Part';
        warrantyProductList[3].WOD_2__Track_Type__c = 'Non-Serialized';
      	insert warrantyProductList;
        
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
        
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        //viList[0].ATI_Inventory__c = inventoryList[0].Id;
        insert viList;
        
        
        /** Created as part of VIN Transmission Mapper*/
        List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = TestDataFactory.createVinMappers(1,viList[0].Id);
        vinMapperLst[0].ATI_Inventory__c= inventoryList[0].Id;
        insert vinMapperLst;

        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='ReplacementClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today()-1,
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  ATI_Replacement_Claims__c=true,ATI_Replaced_Model__c=warrantyProductList[1].Id, ATI_Replaced_Inventory__c=inventoryList[1].Id,
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id );
        insert claim;
        
        ATI_Inventory_Replacement_History__c irh = new ATI_Inventory_Replacement_History__c();
        irh.ATI_Claim__c = claim.Id;
        irh.ATI_Account__c = claim.WOD_2__Account__c;
        irh.ATI_Failed_Inventory__c = claim.WOD_2__Inventory__c;
        irh.ATI_Replaced_Inventory__c = claim.ATI_Replaced_Inventory__c;
        irh.ATI_Replacement_Date__c = claim.WOD_2__Date_Of_Repair__c;
        irh.ATI_Replacement_Type__c	= claim.ATI_Replacement_Type__c;
        irh.ATI_Vehicle_Information__c = viList[0].Id;
        insert irh;
    }
    
    @isTest
    static void testFetchReplacementHistoryByInvId(){
        WOD_2__Inventory__c inv = [select id from WOD_2__Inventory__c where WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
    	Test.startTest();
        WOD_2.ResponseWrapper response = ATI_InvReplacementHistoryController.fetchReplacementHistory(inv.Id, getObjectFieldsAPINames());
        Test.stopTest();
        System.assertEquals(true, response.status, 'Response status is not true !!!!');
        List<ATI_Inventory_Replacement_History__c> irhList = (List<ATI_Inventory_Replacement_History__c>) JSON.deserialize(response.data, List<ATI_Inventory_Replacement_History__c>.class);
        System.assertEquals(1, irhList.size(), 'Vehicle History not found !!!!');
    }
    
    @isTest
    static void testFetchReplacementHistoryByVehicleInfoId(){
        //Commented for VIN transmission Mapper Implementation ATI_Vehicle_Information__c vi = [select id from ATI_Vehicle_Information__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
    	ATI_VIN_Transmission_Mapper__c vi = [select id,ATI_Inventory__c,ATI_Vehicle_Information__c from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
        
        Test.startTest();
        WOD_2.ResponseWrapper response = ATI_InvReplacementHistoryController.fetchReplacementHistory(vi.ATI_Vehicle_Information__c, getObjectFieldsAPINames());
        Test.stopTest();
        System.assertEquals(true, response.status, 'Response status is not true !!!!');
        List<ATI_Inventory_Replacement_History__c> irhList = (List<ATI_Inventory_Replacement_History__c>) JSON.deserialize(response.data, List<ATI_Inventory_Replacement_History__c>.class);
        System.assertEquals(1, irhList.size(), 'Vehicle History not found !!!!');
    }
    
    @isTest
    static void testFetchReplacementHistoryError(){
        WOD_2__Warranty_Product__c wp = [select id from WOD_2__Warranty_Product__c limit 1];
    	Test.startTest();
        WOD_2.ResponseWrapper res = ATI_InvReplacementHistoryController.fetchReplacementHistory(wp.Id,getObjectFieldsAPINames());
        Test.stopTest();
        System.assertEquals(false, res.status, 'Response status is not false !!!!');
    }
    
    @isTest
    static void testshowAddClaimButton(){
        //Commented for VIN transmission Mapper Implementation  ATI_Vehicle_Information__c vi = [select id,ATI_Inventory__c from ATI_Vehicle_Information__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
		ATI_VIN_Transmission_Mapper__c vi = [select id,ATI_Inventory__c,ATI_Vehicle_Information__c from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];

        Test.startTest();
        WOD_2.ResponseWrapper res = ATI_InvReplacementHistoryController.showAddClaimButton(vi.ATI_Vehicle_Information__c);
        WOD_2.ResponseWrapper res1 = ATI_InvReplacementHistoryController.showAddClaimButton(vi.ATI_Inventory__c);
        Test.stopTest();        
        System.assertEquals(true, JSON.deserializeUntyped(res.data), 'Show Claim Add Button should be true !!!!');
        System.assertEquals(false, JSON.deserializeUntyped(res1.data), 'Show Claim Add Button should be false !!!!');
    }
    
    @isTest
    static void testCreateZeroDollarClaim(){
        WOD_2__Claim__c existingClaim = [select id from WOD_2__Claim__c]; 
        List<WOD_2__Inventory__c> invList = [select id, WOD_2__Serial_Number__c from WOD_2__Inventory__c]; 
        //Commented for VIN transmission Mapper Implementation-- ATI_Vehicle_Information__c vi = [select id,ATI_Inventory__c from ATI_Vehicle_Information__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
        ATI_VIN_Transmission_Mapper__c vi = [select id,ATI_Inventory__c,ATI_Vehicle_Information__c from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
        
        Id replacedSerialNumber = invList[0].Id == vi.ATI_Inventory__c ? invList[1].Id : invList[0].Id;
        WOD_2__Claim__c claim = new WOD_2__Claim__c();
        claim.WOD_2__Inventory__c = vi.ATI_Inventory__c;
        claim.ATI_Replaced_Inventory__c = replacedSerialNumber;
        claim.ATI_Replacement_Claims__c = true;
		claim.WOD_2__Date_Of_Repair__c = System.today();
        claim.ATI_Replacement_Type__c = 'SWING';
        Test.startTest(); 
		ATI_InvReplacementHistoryController.createZeroDollarClaim(vi.ATI_Vehicle_Information__c, JSON.serialize(claim));
		Test.stopTest();
		List<WOD_2__Claim__c> claimList = [select Id, WOD_2__Inventory__c, ATI_Replacement_Claims__c, ATI_Replacement_Type__c from WOD_2__Claim__c 
                                           where RecordType.DeveloperName = 'ATI_Zero_Dollar_Claim'];
		System.assertEquals(1, claimList.size(), 'Zero Dollar Claim is not created !!!!');        
    }
    
     @isTest
    static void testCreateZeroDollarClaimException(){
        WOD_2__Claim__c existingClaim = [select id from WOD_2__Claim__c]; 
        List<WOD_2__Inventory__c> invList = [select id, WOD_2__Serial_Number__c from WOD_2__Inventory__c]; 
        //Commented for VIN transmission Mapper Implementation-- ATI_Vehicle_Information__c vi = [select id,ATI_Inventory__c from ATI_Vehicle_Information__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
        ATI_VIN_Transmission_Mapper__c vi = [select id,ATI_Inventory__c,ATI_Vehicle_Information__c from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];

        Id replacedSerialNumber = invList[0].Id == vi.ATI_Inventory__c ? invList[1].Id : invList[0].Id;
        WOD_2__Claim__c claim = new WOD_2__Claim__c();
        claim.WOD_2__Inventory__c = replacedSerialNumber;
        claim.ATI_Replaced_Inventory__c = vi.ATI_Inventory__c;
        claim.ATI_Replacement_Claims__c = true;
		claim.WOD_2__Date_Of_Repair__c = System.today();
        claim.ATI_Replacement_Type__c = 'SWING';
        Test.startTest();
		ATI_InvReplacementHistoryController.createZeroDollarClaim(vi.ATI_Vehicle_Information__c,JSON.serialize(claim));
		Test.stopTest();
		List<WOD_2__Claim__c> claimList = [select Id, WOD_2__Inventory__c, ATI_Replacement_Claims__c, ATI_Replacement_Type__c from WOD_2__Claim__c 
                                           where RecordType.DeveloperName = 'ATI_Zero_Dollar_Claim'];
		System.assertEquals(1, claimList.size(), 'Zero Dollar Claim is created which is not expected !!!!');        
    }
    
    private static List<String> getObjectFieldsAPINames(){
        return new List<String>{'ATI_Claim__c',
                'ATI_Account__c','ATI_Failed_Inventory__c','ATI_Replaced_Inventory__c','ATI_Replacement_Date__c',
                'ATI_Replacement_Type__c','ATI_Vehicle_Information__c'};
    }
}