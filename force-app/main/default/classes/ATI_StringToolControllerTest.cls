/* Name: ATI_StringToolControllerTest
Description : ATI_StringToolControllerTest - Test class for ATI_StringToolController.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      18-NOV-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_StringToolControllerTest {

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
        
        List<WOD_2__Inventory__c> inventoryList = TestDataFactory.createInventory(3);
        inventoryList[0].Name = inventoryList[0].WOD_2__Serial_Number__c = 'FailedInvSerialNumber';
        inventoryList[0].WOD_2__Type__c = 'Retail';
        inventoryList[0].WOD_2__Install_Date__c = System.today();
        inventoryList[0].WOD_2__Warranty_Start_Date__c = System.today();
        inventoryList[1].Name = inventoryList[1].WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber';
        inventoryList[1].Name = inventoryList[2].WOD_2__Serial_Number__c = 'NewReplacementSerialNumber';
        for(WOD_2__Inventory__c inv : inventoryList){
            inv.WOD_2__Business_Unit__c = busCategoryList[0].Id;
            inv.WOD_2__Account__c = accList[0].Id;
            inv.WOD_2__Item__c = warrantyProductList[2].Id;
        }
        insert inventoryList;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(2);
        policyDefList.get(0).WOD_2__Type__c = 'Extended';
		policyDefList.get(0).WOD_2__Months_Covered__c = 24;
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        policyDefList.get(1).WOD_2__Type__c = 'Standard';
        policyDefList.get(1).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
        List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        for(integer i = 0; i < lstWR.size(); i++){
            lstWR[i].WOD_2__Inventory__c = inventoryList[i].id;
            lstWR[i].WOD_2__Account__c = accList[0].Id;
            lstWR[i].WOD_2__Customer__c = accList[1].Id;
        }
        //lstWR[0].WOD_2__Status__c = 'InActive';
        insert lstWR;
        
        List<WOD_2__Warranty_Coverages__c> wcList = TestDataFactory.createWarrantyCoverage(2);
        wcList[0].ATI_isExtended__c = policyDefList[0].WOD_2__Type__c == 'Extended';
        wcList[0].WOD_2__Is_Active__c = true;
        wcList[0].WOD_2__Policy_Definition__c = policyDefList[0].Id;
        wcList[0].WOD_2__Warranty_Start_Date__c = Date.today();
        wcList[0].WOD_2__Warranty_End_Date__c = Date.today().addMonths(Integer.valueOf(policyDefList[0].WOD_2__Months_Covered__c));
        wcList[0].WOD_2__Warranty_Registration__c = lstWR[0].Id;

        wcList[1].ATI_isExtended__c = policyDefList[1].WOD_2__Type__c == 'Extended';
        wcList[1].WOD_2__Is_Active__c = true;
        wcList[1].WOD_2__Policy_Definition__c = policyDefList[1].Id;
        wcList[1].WOD_2__Warranty_Start_Date__c = Date.today();
        wcList[1].WOD_2__Warranty_End_Date__c = Date.today().addMonths(Integer.valueOf(policyDefList[1].WOD_2__Months_Covered__c));
        wcList[1].WOD_2__Warranty_Registration__c = lstWR[0].Id;

        insert wcList;
        
        List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
        //viList[0].ATI_Inventory__c = inventoryList[0].Id;
        insert viList;
        /** Created as part of VIN Transmission Mapper*/
        List<ATI_VIN_Transmission_Mapper__c> vinMapperLst = TestDataFactory.createVinMappers(1,viList[0].Id);
        vinMapperLst[0].ATI_Inventory__c= inventoryList[0].Id;
        insert vinMapperLst;
        
        ATI_WarrantyService.WRDetailsWrapper wrDetails = new ATI_WarrantyService.WRDetailsWrapper();
        wrDetails.WOD_2_Type_c = 'Retail';
        wrDetails.ATI_Pre_Delivery_c=false;
        wrDetails.WOD_2_Units_Usage_c=100;
        wrDetails.WOD_2_Install_Date_c= Date.today();
        wrDetails.WOD_2_Customer_c=accList[1].Id;
        wrDetails.vehicleInfo = viList[0];
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='ReplacementClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today()-1,
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),ATI_Replacement_Type__c = 'SWING',
                                                  ATI_Replacement_Claims__c=true,ATI_Replaced_Model__c=warrantyProductList[1].Id, ATI_Replaced_Inventory__c=inventoryList[1].Id,
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id, ATI_WR_Details__c=JSON.serialize(wrDetails) );
        insert claim;
        
        WOD_2__Claim__c claim1 = new WOD_2__Claim__c(Name='MachineClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today()-1,
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id, ATI_WR_Details__c=JSON.serialize(wrDetails) );
        insert claim1;
        
    }

    @isTest
    static void testGetClaimDetailsSuccess(){
        WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = true];
        Test.startTest();
        WOD_2.ResponseWrapper response = ATI_StringToolController.getClaimDetails(claim.Id);
        Test.stopTest();
        System.assert(response.status, 'Success Expected!!!');
        ATI_StringToolController.ReplacementInfo replacementInfo = (ATI_StringToolController.ReplacementInfo)JSON.deserialize(response.data, ATI_StringToolController.ReplacementInfo.class);
        System.assert(replacementInfo.originalSNId == claim.WOD_2__Inventory__c, 'Failed Inventory is different !!');
        System.assert(replacementInfo.replacementSNId == claim.ATI_Replaced_Inventory__c, 'Failed Inventory is different !!');
    }

    @isTest
    static void testGetClaimDetailsFailure(){
        Test.startTest();
        WOD_2.ResponseWrapper response = ATI_StringToolController.getClaimDetails('231231241241241');
        Test.stopTest();
        System.assert(!response.status, 'Failure Expected!!!');
    }
 

    @isTest
    static void testValidateReplacement(){
        WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = true];
        WOD_2__Inventory__c inv = [SELECT id, Name, WOD_2__Serial_Number__c, WOD_2__Type__c FROM WOD_2__Inventory__c where WOD_2__Serial_Number__c = 'NewReplacementSerialNumber'];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        inv.WOD_2__Type__c = 'Retail';
        update inv;
        replacementInfo.replacementSNId = null;
        replacementInfo.transmissionReplaced = false;
        Test.startTest();
        WOD_2.ResponseWrapper response = ATI_StringToolController.validateReplacement(claim.Id, JSON.serialize(replacementInfo));
		System.assert(response.status, 'Success expected!!');
		System.assert(String.isNotBlank(response.errormessage) && response.errormessage.startsWith('Original Serial Number') , 'Original Serial Number error is not thrown!!');
        replacementInfo.transmissionReplaced = true;
        replacementInfo.replacementSNId = inv.Id;
        WOD_2.ResponseWrapper response2 = ATI_StringToolController.validateReplacement(claim.Id, JSON.serialize(replacementInfo));
		System.assert(response2.status, 'Success expected!!');
		System.assert(String.isNotBlank(response2.errormessage) && response2.errormessage.startsWith('Replacement Serial Number') , 'Replacement Serial Number error is not thrown!!');
        Test.stopTest();
    }

    
    @isTest
    static void testAddSwingReplacement(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'SWING');
        Test.stopTest();
        System.assert(response.status, 'Add Swing Replacement Failed');
        List<WOD_2__Warranty_Registration__c> wrList = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
        System.assert(wrList[0].WOD_2__Status__c == 'InActive','WR Status of Failed inventory is not changed to InActive');
        System.assert(wrList[0].WOD_2__Inventory__r.WOD_2__Type__c == 'Stock','Failed inventory Type is not moved to Stock');
        System.assert(!wrList[0].WOD_2__Inventory__r.ATI_Active__c,'Failed inventory Active flag not set correctly');
        System.assert(!wrList[0].WOD_2__Inventory__r.WOD_2__Scrapped__c,'Failed inventory Scrapped flag not set correctly');
        System.assert(wrList[0].WOD_2__Inventory__r.WOD_2__Pre_Owned__c,'Failed inventory Pre-Owned flag not set correctly');
        wrList = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];
        System.assert(wrList[0].WOD_2__Status__c == 'Registered','Coverages are not transfered to replaced inventory');
        System.assert(wrList[0].WOD_2__Inventory__r.WOD_2__Type__c == 'Retail','Replaced Inventory Type is not moved to Retail');
    }

    @isTest
    static void testAddRetranReplacement(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'RETRAN');
        Test.stopTest();
        System.assert(response.status, 'Add RETRAN Replacement Failed');
        List<WOD_2__Warranty_Registration__c> wrList = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber'];
        System.assert(wrList[0].WOD_2__Status__c == 'InActive','WR Status of Failed inventory is not changed to InActive');
        System.assert(wrList[0].WOD_2__Inventory__r.WOD_2__Type__c == 'Stock','Failed inventory Type is not moved to Stock');
        System.assert(!wrList[0].WOD_2__Inventory__r.ATI_Active__c,'Failed inventory Active flag not set correctly');
        System.assert(wrList[0].WOD_2__Inventory__r.WOD_2__Scrapped__c,'Failed inventory Scrapped flag not set correctly');
        System.assert(!wrList[0].WOD_2__Inventory__r.WOD_2__Pre_Owned__c,'Failed inventory Pre-Owned flag not set correctly');
        wrList = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];
        System.assert(wrList[0].WOD_2__Status__c == 'Registered','Coverages are not transfered to replaced inventory');
        System.assert(wrList[0].WOD_2__Inventory__r.WOD_2__Type__c == 'Retail','Replaced Inventory Type is not moved to Retail');
    }
    
    
    @isTest
    static void testChangeSwingReplacement(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'SWING');
        System.assert(response.status, 'Add Swing Replacement Failed');
        WOD_2__Claim__c replacementClaim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where id = :claim.Id];
        WOD_2__Inventory__c inv = [SELECT id, Name, WOD_2__Serial_Number__c, WOD_2__Type__c, WOD_2__Item__r.Name FROM WOD_2__Inventory__c where WOD_2__Serial_Number__c = 'NewReplacementSerialNumber'];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        replacementInfo.replacementSNId = inv.Id;
        replacementInfo.replacementModelId = inv.WOD_2__Item__c;
        replacementInfo.replacementComments = 'Updating Replacement';
        response = ATI_StringToolController.handleReplacement(claim.Id, JSON.serialize(replacementInfo));
        Test.stopTest();
        System.assert(response.status, 'Updation of replaced serial number Failed on SWING claim');
        WOD_2__Warranty_Registration__c oldReplacedWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];    
        System.assert(oldReplacedWR.WOD_2__Status__c == 'InActive','Old Replacement WR Status of Failed inventory is not changed to InActive');
        System.assert(oldReplacedWR.WOD_2__Inventory__r.WOD_2__Type__c == 'Stock','Old Replacement inventory Type is not moved to Stock');
        System.assert(!oldReplacedWR.WOD_2__Inventory__r.ATI_Active__c,'Old Replacement inventory Active flag not set correctly');
        System.assert(!oldReplacedWR.WOD_2__Inventory__r.WOD_2__Scrapped__c,'Old Replacement inventory Scrapped flag not set correctly');
        System.assert(oldReplacedWR.WOD_2__Inventory__r.WOD_2__Pre_Owned__c,'Old Replacement inventory Pre-Owned flag not set correctly');
        WOD_2__Warranty_Registration__c newReplacedWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'NewReplacementSerialNumber'];
        System.assert(newReplacedWR.WOD_2__Status__c == 'Registered','Coverages are not transfered to new replaced inventory');
        System.assert(newReplacedWR.WOD_2__Inventory__r.WOD_2__Type__c == 'Retail','New Replaced Inventory Type is not moved to Retail');
    }

    
    @isTest
    static void testChangeRetranReplacement(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'RETRAN');
        System.assert(response.status, 'Add RETRAN Replacement Failed');
        WOD_2__Claim__c replacementClaim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where id = :claim.Id];
        WOD_2__Inventory__c inv = [SELECT id, Name, WOD_2__Serial_Number__c, WOD_2__Type__c, WOD_2__Item__r.Name FROM WOD_2__Inventory__c where WOD_2__Serial_Number__c = 'NewReplacementSerialNumber'];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        replacementInfo.replacementSNId = inv.Id;
        replacementInfo.replacementModelId = inv.WOD_2__Item__c;
        replacementInfo.replacementComments = 'Updating Replacement';
        response = ATI_StringToolController.handleReplacement(claim.Id, JSON.serialize(replacementInfo));
        Test.stopTest();
        System.assert(response.status, 'Updation of replaced serial number Failed on RETRAN claim');
        WOD_2__Warranty_Registration__c oldReplacedWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];    
        System.assert(oldReplacedWR.WOD_2__Status__c == 'InActive','Old Replacement WR Status of Failed inventory is not changed to InActive');
        System.assert(oldReplacedWR.WOD_2__Inventory__r.WOD_2__Type__c == 'Stock','Old Replacement inventory Type is not moved to Stock');
        System.assert(!oldReplacedWR.WOD_2__Inventory__r.ATI_Active__c,'Old Replacement inventory Active flag not set correctly');
        System.assert(!oldReplacedWR.WOD_2__Inventory__r.WOD_2__Scrapped__c,'Old Replacement inventory Scrapped flag not set correctly');
        System.assert(!oldReplacedWR.WOD_2__Inventory__r.WOD_2__Pre_Owned__c,'Old Replacement inventory Pre-Owned flag not set correctly');
        WOD_2__Warranty_Registration__c newReplacedWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'NewReplacementSerialNumber'];
        System.assert(newReplacedWR.WOD_2__Status__c == 'Registered','Coverages are not transfered to new replaced inventory');
        System.assert(newReplacedWR.WOD_2__Inventory__r.WOD_2__Type__c == 'Retail','New Replaced Inventory Type is not moved to Retail');
    
    }


    @isTest
    static void testRemoveSwingReplacement(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'SWING');
        System.assert(response.status, 'Add Swing Replacement Failed');
        WOD_2__Claim__c replacementClaim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where id = :claim.Id];
        WOD_2__Inventory__c inv = [SELECT id, Name, WOD_2__Serial_Number__c, WOD_2__Type__c, WOD_2__Item__r.Name FROM WOD_2__Inventory__c where WOD_2__Serial_Number__c = 'NewReplacementSerialNumber'];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        replacementInfo.replacementSNId = null;
        replacementInfo.replacementModelId = null;
        replacementInfo.replacementType = null;
        replacementInfo.transmissionReplaced = false;
        replacementInfo.replacementComments = 'Removed Replacement';
        response = ATI_StringToolController.handleReplacement(claim.Id, JSON.serialize(replacementInfo));
        Test.stopTest();
        System.assert(response.status, 'Removal of replaced serial number Failed on SWING claim');
        WOD_2__Warranty_Registration__c replacedInvWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];    
        System.assert(replacedInvWR.WOD_2__Status__c == 'InActive','Old Replacement WR Status of Failed inventory is not changed to InActive');
        System.assert(replacedInvWR.WOD_2__Inventory__r.WOD_2__Type__c == 'Stock','Old Replacement inventory Type is not moved to Stock');
        System.assert(replacedInvWR.WOD_2__Inventory__r.ATI_Active__c,'Old Replacement inventory Active flag not set correctly');
        System.assert(!replacedInvWR.WOD_2__Inventory__r.WOD_2__Scrapped__c,'Old Replacement inventory Scrapped flag not set correctly');
        System.assert(!replacedInvWR.WOD_2__Inventory__r.WOD_2__Pre_Owned__c,'Old Replacement inventory Pre-Owned flag not set correctly');
        List<WOD_2__Warranty_Registration__c> failedInvWRList = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber' order by createddate desc];
        System.assert(failedInvWRList[0].WOD_2__Status__c == 'Registered','Coverages are not transfered to failed inventory');
        System.assert(failedInvWRList[0].WOD_2__Inventory__r.WOD_2__Type__c == 'Retail','Failed Inventory Type is not moved to Retail');
        System.assert(failedInvWRList[0].WOD_2__Inventory__r.ATI_Active__c,'Failed inventory Active flag not set correctly');
        System.assert(!failedInvWRList[0].WOD_2__Inventory__r.WOD_2__Scrapped__c,'Failed inventory Scrapped flag not set correctly');
    }

    
    @isTest
    static void testRemoveRetranReplacement(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'RETRAN');
        System.assert(response.status, 'Add RETRAN Replacement Failed');
        WOD_2__Claim__c replacementClaim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where id = :claim.Id];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        replacementInfo.replacementSNId = null;
        replacementInfo.replacementModelId = null;
        replacementInfo.replacementType = null;
        replacementInfo.transmissionReplaced = false;
        replacementInfo.replacementComments = 'Removed Replacement';
        response = ATI_StringToolController.handleReplacement(claim.Id, JSON.serialize(replacementInfo));
        Test.stopTest();
        System.assert(response.status, 'Removal of replaced serial number Failed on RETRAN claim');
        WOD_2__Warranty_Registration__c replacedInvWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];    
        System.assert(replacedInvWR.WOD_2__Status__c == 'InActive','Old Replacement WR Status of Failed inventory is not changed to InActive');
        System.assert(replacedInvWR.WOD_2__Inventory__r.WOD_2__Type__c == 'Stock','Old Replacement inventory Type is not moved to Stock');
        System.assert(replacedInvWR.WOD_2__Inventory__r.ATI_Active__c,'Old Replacement inventory Active flag not set correctly');
        System.assert(!replacedInvWR.WOD_2__Inventory__r.WOD_2__Scrapped__c,'Old Replacement inventory Scrapped flag not set correctly');
        List<WOD_2__Warranty_Registration__c> failedInvWRList = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber' order by createddate desc];
        System.assert(failedInvWRList[0].WOD_2__Status__c == 'Registered','Coverages are not transfered to failed inventory');
        System.assert(failedInvWRList[0].WOD_2__Inventory__r.WOD_2__Type__c == 'Retail','Failed Inventory Type is not moved to Retail');
        System.assert(failedInvWRList[0].WOD_2__Inventory__r.ATI_Active__c,'Failed inventory Active flag not set correctly');
        System.assert(!failedInvWRList[0].WOD_2__Inventory__r.WOD_2__Scrapped__c,'Failed inventory Scrapped flag not set correctly');
    }


    @isTest
    static void testWCTransfer(){
    	WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where ATI_Replacement_Claims__c = false];
        Test.startTest();
        WOD_2.ResponseWrapper response = addReplacementSNToMachineClaim(claim, 'RETRAN');
        System.assert(response.status, 'Add RETRAN Replacement Failed');
        WOD_2__Claim__c replacementClaim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c where id = :claim.Id];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        WOD_2__Warranty_Registration__c failedInvWR = [SELECT id, Name, WOD_2__Status__c, WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Type__c,
                                                        WOD_2__Inventory__r.ATI_Active__c, WOD_2__Inventory__r.WOD_2__Scrapped__c,WOD_2__Inventory__r.WOD_2__Pre_Owned__c
                                                        from WOD_2__Warranty_Registration__c where WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'FailedInvSerialNumber' order by createddate desc];
        List<WOD_2__Policy_Definition__c> policyDefList = [select id,WOD_2__Type__c,WOD_2__Months_Covered__c from WOD_2__Policy_Definition__c];
        List<WOD_2__Warranty_Coverages__c> wcList = TestDataFactory.createWarrantyCoverage(1);
        wcList[0].ATI_isExtended__c = policyDefList[0].WOD_2__Type__c == 'Extended';
        wcList[0].WOD_2__Is_Active__c = true;
        wcList[0].WOD_2__Policy_Definition__c = policyDefList[0].Id;
        wcList[0].WOD_2__Warranty_Start_Date__c = Date.today();
        wcList[0].WOD_2__Warranty_End_Date__c = Date.today().addMonths(60);
        wcList[0].WOD_2__Warranty_Registration__c = failedInvWR.Id;
        insert wcList;
        response = ATI_StringToolController.handleReplacement(claim.Id, JSON.serialize(replacementInfo));
        List<WOD_2__Warranty_Coverages__c> wc1List = [select id, Name, WOD_2__Warranty_Registration__c from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber']; 
        System.assert(wc1List.size() == 3, 'New Policy is not trasferred as expected!!');
        Test.stopTest();
    }
    
    static WOD_2.ResponseWrapper addReplacementSNToMachineClaim(WOD_2__Claim__c claim, String replacementType){
        WOD_2__Inventory__c inv = [SELECT id, Name, WOD_2__Serial_Number__c, WOD_2__Type__c, WOD_2__Item__r.Name FROM WOD_2__Inventory__c where WOD_2__Serial_Number__c = 'ReplacedInvSerialNumber'];
        ATI_StringToolController.ReplacementInfo replacementInfo = ATI_StringToolController.getReplacementInfo(claim.Id);
        replacementInfo.transmissionReplaced = true;
        replacementInfo.replacementSNId = inv.Id;
        replacementInfo.replacementModelId = inv.WOD_2__Item__c;
        replacementInfo.replacementType = replacementType;
        replacementInfo.replacementComments = 'Adding Replacement';
		return ATI_StringToolController.handleReplacement(claim.Id, JSON.serialize(replacementInfo)); 		        
        
    }

    

}