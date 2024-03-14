/* Name: ATI_CLM_ReplacementServiceTest
Description : ATI_CLM_ReplacementServiceTest - Test class for ATI_CLM_ReplacementService.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      14-FEB-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_CLM_ReplacementServiceTest {

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
        lstWR[0].WOD_2__Inventory__c = inventoryList[0].id;
        lstWR[0].WOD_2__Account__c = accList[0].Id;
        lstWR[0].WOD_2__Customer__c = accList[1].Id;
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
        
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='ReplacementClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today()-1,
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),
                                                  ATI_Replacement_Claims__c=true,ATI_Replaced_Model__c=warrantyProductList[1].Id, ATI_Replaced_Inventory__c=inventoryList[1].Id,
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id );
        insert claim;
    }
    
	@isTest
    static void testSwingReplacement(){
		WOD_2__Claim__c claim = [select id, ATI_Replacement_Type__c from WOD_2__Claim__c];
        claim.ATI_Replacement_Type__c = 'SWING';
        update claim;
        Test.startTest();
        ATI_CLM_ReplacementService.handleSwingReplacement(claim.Id);
        Test.stopTest();
        WOD_2__Inventory__c failedInv = [select Id, WOD_2__Scrapped__c, ATI_Active__c from WOD_2__Inventory__c where Name = 'FailedInvSerialNumber'];
        WOD_2__Inventory__c replacedInv = [select Id, WOD_2__Scrapped__c, WOD_2__Type__c,WOD_2__Account__c,WOD_2__Install_Date__c,ATI_Vocation_Code__c,
                                           WOD_2__Warranty_Start_Date__c, WOD_2__Warranty_End_Date__c from WOD_2__Inventory__c where Name = 'ReplacedInvSerialNumber'];
		System.assertEquals(false, failedInv.ATI_Active__c, 'Failed Inventory is not marked as In Active');
        System.assertEquals('Retail', replacedInv.WOD_2__Type__c, 'Replaced Inventory is not Retailed !!!!');
        System.assertNotEquals(null, replacedInv.WOD_2__Account__c, 'Replaced Inventory\'s account is not updated!!' );
        System.assertNotEquals(null, replacedInv.WOD_2__Install_Date__c, 'Replaced Inventory\'s Install Date is not updated!!' );
        System.assertNotEquals(null, replacedInv.WOD_2__Warranty_Start_Date__c, 'Replaced Inventory\'s Warranty Start Date is not updated!!' );
        System.assertNotEquals(null, replacedInv.WOD_2__Warranty_End_Date__c, 'Replaced Inventory\'s Warranty End Date is not updated!!' );
		WOD_2__Warranty_Registration__c wr = [select id, WOD_2__Status__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :replacedInv.Id];      
        System.assertEquals(true, wr != null, 'WR is not created on replaced inventory');
        List<WOD_2__Warranty_Coverages__c> wcList = [select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c = :wr.Id];
        System.assertEquals(2, wcList.size(), 'Coverages are not created on replaced inventory');
        List<ATI_VIN_Transmission_Mapper__c> vhList = [select id, ATI_Inventory__c from ATI_VIN_Transmission_Mapper__c];
        System.assertEquals(replacedInv.Id, vhList[0].ATI_Inventory__c, 'Inventory is not updated to replaced inv on Vehicle Information');
		List<ATI_Inventory_Replacement_History__c> irhList = [select id, ATI_Claim__c,ATI_Failed_Inventory__c,ATI_Replaced_Inventory__c,ATI_Replacement_Type__c,ATI_Vehicle_Information__c from ATI_Inventory_Replacement_History__c];        
        System.assertEquals(1, irhList.size(), 'Replacement history is not created');
        System.assertEquals(failedInv.Id, irhList[0].ATI_Failed_Inventory__c, 'Failed Inv in Replacement history is not correct');
        System.assertEquals(replacedInv.Id, irhList[0].ATI_Replaced_Inventory__c, 'Replaced Inv in Replacement history is not correct');
        System.assertEquals('SWING', irhList[0].ATI_Replacement_Type__c, 'Type in Replacement history is not correct');
		WOD_2__Warranty_Registration__c failedInvWR = [select id, WOD_2__Status__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :failedInv.Id];      
        System.assertEquals('InActive', failedInvWR.WOD_2__Status__c, 'WR is not deactivated on failed inventory');
        ATI_CLM_ReplacementService.updateReplacement(claim.Id,failedInv.Id);
        ATI_CLM_ReplacementService.deleteReplacement(claim.Id,failedInv.Id,replacedInv.Id);
        ATI_CLM_ReplacementService.handleReplacementForStringCorrection(claim.Id);
    }
    
@isTest
    static void testRetranReplacement(){
		WOD_2__Claim__c claim = [select id, ATI_Replacement_Type__c from WOD_2__Claim__c];
        claim.ATI_Replacement_Type__c = 'RETRAN';
        update claim;
        Test.startTest();
        ATI_CLM_ReplacementService.handleRetranReplacement(claim.Id);
        Test.stopTest();
        WOD_2__Inventory__c failedInv = [select Id, WOD_2__Scrapped__c, ATI_Active__c from WOD_2__Inventory__c where Name = 'FailedInvSerialNumber'];
        WOD_2__Inventory__c replacedInv = [select Id, WOD_2__Scrapped__c, WOD_2__Type__c,WOD_2__Account__c,WOD_2__Install_Date__c,ATI_Vocation_Code__c,
                                           WOD_2__Warranty_Start_Date__c, WOD_2__Warranty_End_Date__c from WOD_2__Inventory__c where Name = 'ReplacedInvSerialNumber'];
		System.assertEquals(true, failedInv.WOD_2__Scrapped__c, 'Failed Inventory is not marked as Scrapped');
        System.assertEquals('Retail', replacedInv.WOD_2__Type__c, 'Replaced Inventory is not Retailed !!!!');
        System.assertNotEquals(null, replacedInv.WOD_2__Account__c, 'Replaced Inventory\'s account is not updated!!' );
        System.assertNotEquals(null, replacedInv.WOD_2__Install_Date__c, 'Replaced Inventory\'s Install Date is not updated!!' );
        System.assertNotEquals(null, replacedInv.WOD_2__Warranty_Start_Date__c, 'Replaced Inventory\'s Warranty Start Date is not updated!!' );
        System.assertNotEquals(null, replacedInv.WOD_2__Warranty_End_Date__c, 'Replaced Inventory\'s Warranty End Date is not updated!!' );
		WOD_2__Warranty_Registration__c wr = [select id, WOD_2__Status__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :replacedInv.Id];      
        System.assertEquals(true, wr != null, 'WR is not created on replaced inventory');
        List<WOD_2__Warranty_Coverages__c> wcList = [select id from WOD_2__Warranty_Coverages__c where WOD_2__Warranty_Registration__c = :wr.Id];
        System.assertEquals(2, wcList.size(), 'Coverages are not created on replaced inventory');
        List<ATI_VIN_Transmission_Mapper__c> vhList = [select id, ATI_Inventory__c from ATI_VIN_Transmission_Mapper__c];
        System.assertEquals(replacedInv.Id, vhList[0].ATI_Inventory__c, 'Inventory is not updated to replaced inv on Vehicle Information');
		List<ATI_Inventory_Replacement_History__c> irhList = [select id, ATI_Claim__c,ATI_Failed_Inventory__c,ATI_Replaced_Inventory__c,ATI_Replacement_Type__c,ATI_Vehicle_Information__c from ATI_Inventory_Replacement_History__c];        
        System.assertEquals(1, irhList.size(), 'Replacement history is not created');
        System.assertEquals(failedInv.Id, irhList[0].ATI_Failed_Inventory__c, 'Failed Inv in Replacement history is not correct');
        System.assertEquals(replacedInv.Id, irhList[0].ATI_Replaced_Inventory__c, 'Replaced Inv in Replacement history is not correct');
        System.assertEquals('RETRAN', irhList[0].ATI_Replacement_Type__c, 'Type in Replacement history is not correct');
		WOD_2__Warranty_Registration__c failedInvWR = [select id, WOD_2__Status__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c = :failedInv.Id];      
        System.assertEquals('InActive', failedInvWR.WOD_2__Status__c, 'WR is not deactivated on failed inventory');
    }    
}