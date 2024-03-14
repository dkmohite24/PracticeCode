/* 
   Name: ATI_WarrantyServiceTest
  Description : Test Class for ATI_WarrantyService
*/
@isTest
public class ATI_WarrantyServiceTest {
  /*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
    @testSetup
    public static void testSetup(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        //Warranty Product at Model Level for Extended Warranty Pricing
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(1);
        for(Integer i=0;i<warrantyProLst.size();i++){
          warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
            warrantyProLst[i].WOD_2__Type__c = 'Item';
            warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
            warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProLst;
        
        //Vocation Code 
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createVocationCode(1,false);
        insert wcLst;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accList[0].Id;
        invList[0].WOD_2__Install_Date__c = system.today();
        invList[0].WOD_2__Manufacturing_Date__c = system.today();
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].WOD_2__Units_Usage__c = 6000;
        insert invList;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(1);
        policyDefList.get(0).WOD_2__Type__c = 'Standard';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
        WOD_2__Policy_Definition_Inventory_Usage__c polDefInvUsageObj = new WOD_2__Policy_Definition_Inventory_Usage__c();
        polDefInvUsageObj.Name = 'Policy Definition Inventory Usage';
        polDefInvUsageObj.WOD_2__Maximum_Unit__c = 35;
        polDefInvUsageObj.WOD_2__Policy_Definition__c = policyDefList[0].id;
        polDefInvUsageObj.WOD_2__Usage_Reading_Type__c = 'Machine';
        insert polDefInvUsageObj;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(3,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefList[0].Id;
        applicabilityTermsLst[0].WOD_2__Logical_Grouping__c = '1';
        insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(1,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'BOOLEAN';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  'FALSE';
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;
        insert standardCriteriaLst;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accList[0].Id;
            wrRec.WOD_2__Customer__c = accList[1].Id;
            wrRec.WOD_2__Status__c='In Progress';
      wrRec.ATI_Vocation_Code__c = wcLst.get(0).id;
            wrRec.WOD_2__Registration_Type__c ='Standard Registration';
        }
        insert wrList;
        List<WOD_2__Warranty_Coverages__c> wcList = TestDataFactory.createWarrantyCoverage(1);
        String policyType = 'Standard';
        WOD_2__Policy_Definition__c pd = [select Id, WOD_2__Months_Covered__c from WOD_2__Policy_Definition__c where WOD_2__Type__c = :policyType];
        wcList[0].WOD_2__Is_Active__c = true;
        wcList[0].WOD_2__Policy_Definition__c = pd.Id;
        wcList[0].WOD_2__Warranty_Start_Date__c = Date.today().addDays(-365);
        wcList[0].WOD_2__Warranty_End_Date__c = Date.today().addDays(365);
        wcList[0].WOD_2__Unit_Type_1__c =  polDefInvUsageObj.WOD_2__Usage_Reading_Type__c;
        wcList[0].WOD_2__Unit_Usage_1__c = polDefInvUsageObj.WOD_2__Maximum_Unit__c;
        wcList[0].WOD_2__Warranty_Registration__c = wrList[0].Id;
        insert wcList;
    }
    
    @isTest
    private static void testReRegisterWarrantyWithStdPolicies(){
        //ALSN-2 Account field query
        List<WOD_2__Inventory__c> invList = [SELECT Id,WOD_2__Account__c,ATI_Vocation_Code__c,WOD_2__Item__c,WOD_2__Install_Date__c
                                                                                FROM WOD_2__Inventory__c];
        invList[0].WOD_2__Install_Date__c = system.today();
        update invList;
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>();
        invMap.put(invList[0].id,invList[0]);
        String inventoryListJson = JSON.serialize(invMap);     
        WOD_2__Warranty_Registration__c wrObj = [SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c LIMIT 1];
        Test.startTest();
          ATI_WarrantyService.reRegisterWarrantyWithStdPolicies(inventoryListJson, '');
          ATI_WarrantyService.reRegisterWRForBulk(inventoryListJson, '');
          wrObj = [SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c WHERE Id=:wrObj.Id LIMIT 1];
        Test.stopTest();
       // System.assertEquals('InActive', wrObj.WOD_2__Status__c,'Old WR should be deactivated!');
        System.assertEquals(1, [SELECT Id FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Status__c='Registered'].size(),'Inventory should be reregistered!');
    }
    
    @isTest
    private static void testGetInvRegWrapper(){
        List<WOD_2__Inventory__c> invList = [SELECT Id,WOD_2__Account__c,ATI_Vocation_Code__c,WOD_2__Item__c,WOD_2__Install_Date__c
                                             FROM WOD_2__Inventory__c];
        invList[0].WOD_2__Install_Date__c = system.today();
        update invList;
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>();
        invMap.put(invList[0].id,invList[0]);
        WOD_2__Policy_Definition__c pd = [select Id, WOD_2__Months_Covered__c from WOD_2__Policy_Definition__c where WOD_2__Type__c = 'Standard'];
        WOD_2__Warranty_Registration__c wrObj = [SELECT Id,WOD_2__Status__c,ATI_Vocation_Code__c,WOD_2__Customer__c,WOD_2__Account__c,WOD_2__Inventory__c,
                                                 WOD_2__Inventory__r.WOD_2__Install_Date__c FROM WOD_2__Warranty_Registration__c LIMIT 1];
        Test.startTest();
          ATI_WarrantyService.WRDetailsWrapper wrWrapper = new ATI_WarrantyService.WRDetailsWrapper();
          wrWrapper.ATI_Pre_Delivery_c = false;
          wrWrapper.ATI_Vocation_Code_c = wrObj.ATI_Vocation_Code__c;
          wrWrapper.WOD_2_Install_Date_c = invMap.values()[0].WOD_2__Install_Date__c;
          wrWrapper.WOD_2_Units_Usage_c = 200;
          wrWrapper.WOD_2_Customer_c = wrObj.WOD_2__Customer__c;
          ATI_WarrantyService.registerWarranty(new List<Id>{wrObj.WOD_2__Inventory__c});
          WOD_2.WR_InventoryRegistrationWrapper wrapperObj = ATI_WarrantyService.getInvRegWrapper(wrObj.WOD_2__Account__c,wrObj.WOD_2__Inventory__c,wrWrapper);
        Map<Id,WOD_2__Policy_Definition__c> mapOfPolDet = ATI_WarrantyService.getPolicyDetails(new List<Id>{pd.Id});
        ATI_WarrantyService.getStdWRListForInventories(invMap);
        ATI_WarrantyService.getPolicyIds(new Map<Id, List<Id>>{pd.Id => new List<Id>{pd.id}});
        List<WOD_2__Warranty_Coverages__c> coverages = ATI_WarrantyService.getCoverages(wrObj,new List<Id>{pd.id},mapOfPolDet);
        //ATI_WarrantyService.runApplicablityEngine(new Map<Id, WOD_2__Warranty_Registration__c>{wrObj.Id => wrObj},'');
        Test.stopTest();
        System.assertEquals(true, wrapperObj.inventoryData != NULL,'Inventory data should be returned');
        System.assertEquals(true, wrapperObj.registrationData != NULL,'Registration data should be returned');
    }
    
    @isTest
    private static void testDeRegisterWarranty(){
        List<WOD_2__Inventory__c> invList = [SELECT Id,WOD_2__Account__c,ATI_Vocation_Code__c,WOD_2__Item__c,WOD_2__Install_Date__c
                                                                                FROM WOD_2__Inventory__c];
        invList[0].WOD_2__Install_Date__c = system.today();
        update invList;
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>();
        invMap.put(invList[0].id,invList[0]);
        WOD_2__Warranty_Registration__c wrObj = [SELECT Id,WOD_2__Status__c,ATI_Vocation_Code__c,WOD_2__Customer__c,WOD_2__Account__c,WOD_2__Inventory__c
                                                 FROM WOD_2__Warranty_Registration__c LIMIT 1];
        Test.startTest();
      //ATI_WarrantyService.dummyMethod();getCoverages
      
          ATI_WarrantyService.registerWithStdPolicies(wrObj.Id);
          ATI_WarrantyService.deRegisterWarranty(new List<Id>{wrObj.WOD_2__Inventory__c},'');
          wrObj = [SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c WHERE Id=:wrObj.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals('InActive', wrObj.WOD_2__Status__c,'Old WR should be deactivated!');
    }

}