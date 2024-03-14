/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        22-Nov-2021
* @modified
* @description :  test class for ATI_BR_ReplaceRoAndVin
* --------------------------------------------------------------------------------------------------
*/
@isTest
public class ATI_BR_ReplaceRoAndVinTest {
    @TestSetup
    public static void testSetUp(){
        Test.startTest();
        //create account
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
        
        ATI_WarrantyService.WRDetailsWrapper wrWrapper = new ATI_WarrantyService.WRDetailsWrapper();
        wrWrapper.ATI_Vocation_Code_c = lstWR[0].ATI_Vocation_Code__c;
        //wrWrapper.WOD_2_Install_Date_c = invMap.values()[0].WOD_2__Install_Date__c;
        wrWrapper.WOD_2_Units_Usage_c = 200;
        wrWrapper.WOD_2_Customer_c = lstWR[0].WOD_2__Customer__c;
        wrWrapper.vehicleInfo = viList[0];
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name='ReplacementClaim',WOD_2__Work_Order__c = '12345',
                                                  WOD_2__Claim_Type__c='Machine',WOD_2__Causal_Part_Number__c=warrantyProductList[3].Id,WOD_2__Date_Of_Failure__c= Date.today()-1,
                                                  WOD_2__Model_Number__c=warrantyProductList[1].Id,WOD_2__Date_Of_Repair__c=Date.today(),ATI_Replacement_Type__c = 'SWING',
                                                  ATI_Replacement_Claims__c=true,ATI_Replaced_Model__c=warrantyProductList[1].Id, ATI_Replaced_Inventory__c=inventoryList[1].Id,
                                                  WOD_2__Inventory__c=inventoryList[0].Id,WOD_2__Account__c=accList[0].Id );
        claim.ATI_WR_Details__c = JSON.serialize(wrWrapper);
        insert claim;
    }
    
    @isTest
    private static void testATI_BR_ReplaceRoAndVin(){
        WOD_2__Claim__c claim = [select Id, ATI_Replacement_Claims__c, ATI_Replacement_Type__c,  WOD_2__Inventory__r.WOD_2__Serial_Number__c, ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c from WOD_2__Claim__c];
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=claim.Id;
        ATI_BR_ReplaceRoAndVin Vin = new ATI_BR_ReplaceRoAndVin();
        Boolean returnValue1 = Vin.checkBusinessRule(wrapperObj);
    }
    
}