@isTest
public class TWoDGenericVirtualMethodsOverrideTest {
    
    @testSetup
    public static void testSetup(){
        Test.startTest();
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        distributorAccount[0].Country__c = 'United States';
        distributorAccount[0].BillingCountry = 'United States';
        insert distributorAccount;
        
        //Customer Account
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        //BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsLst = TestDataFactory.createBccs(busCategoryConfig.get(0));
        insert bccsLst;
        
        //VocationCode
        List<WOD_2__Warranty_Code__c > vocantionCodeLst = TestDataFactory.createVocationCode(1,false);
        insert vocantionCodeLst;
        
        //Machine
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(200);
        for (WOD_2__Warranty_Product__c wp : warrantyProPartLst){
            wp.RMA_Policy__c = true;
            wp.WOD_2__Item_Type__c = 'Part';
            wp.WOD_2__Type__c = 'Item';
            wp.WOD_2__Track_Type__c = 'Non-Serialized';
        }
        insert warrantyProPartLst;
        
        //create Inventory
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Retail'; 
            inventory.WOD_2__Serial_Number__c = 'Test001'; 
            inventory.WOD_2__Account__c = distributorAccount[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        //PolicyDefinition
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(3);
        for(WOD_2__Policy_Definition__c  policyDef : policyDefLst){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-365);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Type__c = 'Standard';
            policyDef.WOD_2__Sub_Type__c = '01';
        }
        policyDefLst[1].WOD_2__Type__c = 'Extended';
        policyDefLst[2].WOD_2__Sub_Type__c = '01';
        insert policyDefLst;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(3,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
        applicabilityTermsLst[0].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        applicabilityTermsLst[1].WOD_2__Policy_Definition__c = policyDefLst[1].Id;
        applicabilityTermsLst[1].WOD_2__Logical_Grouping__c = '(1 AND 2)';
        applicabilityTermsLst[2].WOD_2__Policy_Definition__c = policyDefLst[2].Id;
        insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(2,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;
        
        standardCriteriaLst[1].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        standardCriteriaLst[1].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        standardCriteriaLst[1].WOD_2__Field_Type__c = 'BOOLEAN';
        standardCriteriaLst[1].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[1].WOD_2__Criteria_Value__c =  'FALSE';
        standardCriteriaLst[1].WOD_2__Sequence__c = 2;
        insert standardCriteriaLst;
        
        //Extended ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> extendedCriteriaLst = TestDataFactory.createApplicabilityCriterias(2,applicabilityTermsLst.get(1));
        extendedCriteriaLst[0].WOD_2__Field_Path_Label__c ='Inventory> Business Category Configuration';
        extendedCriteriaLst[0].WOD_2__Field_Path__c = 'WOD_2__Inventory__r.WOD_2__Business_Unit__c';
        extendedCriteriaLst[0].WOD_2__Field_Type__c = 'REFERENCE';
        extendedCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        extendedCriteriaLst[0].WOD_2__Criteria_Value__c =  busCategoryConfig.get(0).Id;
        extendedCriteriaLst[0].WOD_2__Sequence__c = 1;
        
        extendedCriteriaLst[1].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        extendedCriteriaLst[1].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        extendedCriteriaLst[1].WOD_2__Field_Type__c = 'BOOLEAN';
        extendedCriteriaLst[1].WOD_2__Operator__c = 'EQUALS';
        extendedCriteriaLst[1].WOD_2__Criteria_Value__c =  'FALSE';
        extendedCriteriaLst[1].WOD_2__Sequence__c = 2;
        insert extendedCriteriaLst;
        
        
        //Pre-Delivery ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> preDeliveryCriteriaLst = TestDataFactory.createApplicabilityCriterias(1,applicabilityTermsLst.get(2));
        preDeliveryCriteriaLst[0].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        preDeliveryCriteriaLst[0].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        preDeliveryCriteriaLst[0].WOD_2__Field_Type__c = 'BOOLEAN';
        preDeliveryCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        preDeliveryCriteriaLst[0].WOD_2__Criteria_Value__c =  'TRUE';
        preDeliveryCriteriaLst[0].WOD_2__Sequence__c = 1;
        insert preDeliveryCriteriaLst;
        
        List<ATI_Extended_Warranty_Pricing__c> ewpLst = TestDataFactory.createExtendedWarrantyPricing(1);
        ewpLst[0].ATI_Active_From__c = Date.today().addDays(-365);
        ewpLst[0].ATI_Policy_Definition__c = policyDefLst.get(1).Id;
        ewpLst[0].ATI_Program_Level__c = 'Program Level 0';
        ewpLst[0].ATI_Warranty_Product__c = warrantyProLst.get(0).WOD_2__Parent_Product__c;
        ewpLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).Id;
        ewpLst[0].ATI_Country__c = 'United States';
        insert ewpLst;
        
        //Create WarrantyProductPriceBook
        Id partCostRTId = Schema.SObjectType.WOD_2__Warranty_Product_Pricebook__c.getRecordTypeInfosByDeveloperName().get('ATI_Part_Price').getRecordTypeId();
        List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = TestDataFactory.createWarrantyProductPricebookForPartPrice(2,warrantyProPartLst[0].Id);
        for(Integer i = 0; i < wpPbLst.size(); i++){
            wpPbLst[i].RecordTypeId = partCostRTId;
            wpPbLst[i].WOD_2__Price__c = 100 * (i + 1);
            wpPbLst[i].WOD_2__Unit_Price__c = 100 * (i + 1);
            wpPbLst[i].ATI_Price_Group__c = distributorAccount[0].ATI_Price_Group__c; 
        }
        wpPbLst[0].WOD_2__Valid_From__c = Date.today().addDays(-365);
        wpPbLst[0].WOD_2__Valid_Until__c = Date.today().addDays(-1);
        insert wpPbLst;
        
        List<WOD_2__Rates_Details__c> laborRates = TestDataFactory.createLaborRateDetails(2);
        for(Integer i = 0; i < laborRates.size(); i++){
            laborRates[i].WOD_2__Labor_Rate__c = 100 * (i+1);  
            laborRates[i].WOD_2__Dealer__c = distributorAccount[0].Id;
        }
        laborRates[0].WOD_2__Active_From__c = Date.today().addDays(-365);
        laborRates[0].WOD_2__Active_Until__c = Date.today().addDays(-1);
        laborRates[1].WOD_2__Active_From__c = Date.today();
        laborRates[1].WOD_2__Active_Until__c = Date.today().addDays(365);
        insert laborRates;
        
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c clm = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c= casulaPart.get(0).id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id, WOD_2__Chatter_Comments__c ='[{"u":"0051700000EROY5AAP","t":"C","ind":"EC","i":"4f4a","d":"2023-03-25T13:26:58.515Z","c":"Test comments"}]');
        insert clm;
        List<WOD_2__Warranty_Registration__c> wr = TestDataFactory.createWarrantyRegistration(1);
        wr[0].WOD_2__Inventory__c = invList[0].Id;
        insert wr;
       
        Test.stopTest();
    }
    @isTest
    private static void testConversationComponent(){
        List<WOD_2__Claim__c> clmq = [SELECT Id,WOD_2__Chatter_Comments__c FROM WOD_2__Claim__c];
        List<WOD_2__Warranty_Registration__c> wr =[Select Id from WOD_2__Warranty_Registration__c];    
        WOD_2.ResponseWrapper inputResponseWrapper = new WOD_2.ResponseWrapper('',true,'');
        WOD_2.ResponseWrapper inputResponseWrapper1 = new WOD_2.ResponseWrapper('',true,'');
        string data1 = '{' + '\"' + clmq[0].id +'\":"{\\"IC\\":[]}"}';
        string data2 = '{' + '\"' + wr[0].id +'\":"{\\"IC\\":[]}"}';
        inputResponseWrapper.data = data1;
        inputResponseWrapper1.data = data2;
        TWoDGenericVirtualMethodsOverride conComponent = new TWoDGenericVirtualMethodsOverride();
        conComponent.postProcessOverride('conversationConsolidatedComments', inputResponseWrapper);
        conComponent.postProcessOverride('conversationConsolidatedComments', inputResponseWrapper1);
    }
    
}