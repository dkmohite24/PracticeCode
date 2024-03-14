/* Name: ATI_ClaimTriggerHandlerTest
   Description : Test class for ATI_ClaimTriggerHandler
   Author : Tavant (Akshatha S)
   History :
   VERSION     AUTHOR                  DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Akshatha S)    01/12/2020          INITIAL DEVELOPMENT
*/

@isTest
public with sharing class ATI_ClaimTriggerHandlerTest {
    /*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
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
        Test.stopTest();
    }
    /*
        Method Name :   claimSharingTest
        Description :   Method to test claim sharing with account's group on claim creation
    */
    @isTest
    public static void claimSharingTest(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
       List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        
        Test.startTest();
            WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c= casulaPart.get(0).id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
            //ClaimBaseController.saveClaimInformation(JSON.serialize(claim),'Machine');
            claim.WOD_2__Claim_Status__c='Pending Approval';
            insert claim;
        Test.stopTest();
        
        List<WOD_2__Claim__Share> claimShareList = new  List<WOD_2__Claim__Share>();
        claimShareList = [SELECT Id FROM WOD_2__Claim__Share WHERE rowcause='Manual' AND ParentId = :claim.Id];
        //system.assertEquals(1, claimShareList.size(),'Success');
    }
    
    @isTest
    private static void testAfterUpdate(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        List<WOD_2__Business_Category_Configuration__c> bus = [select id from WOD_2__Business_Category_Configuration__c];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id, WOD_2__BusinessCategory__c=bus.get(0).Id);
        claim.WOD_2__Claim_Status__c='Pending Approval';
        insert claim;
 
        WOD_2__Financial__c fl=new WOD_2__Financial__c(Name='Financial',WOD_2__Final_Requested_Amount__c= 751,WOD_2__Total_Claim_Approved_Amount__c=2,WOD_2__Total_Labor_Approved_Amount__c=1,
                                                           WOD_2__Total_Other_Approved_Amount__c=2,WOD_2__Total_Parts_Approved_Amount__c=2,WOD_2__Claim__c=claim.Id);
		insert fl;
		WOD_2__Financial_Line_Item__c fli = new WOD_2__Financial_Line_Item__c(Name='TestFLI', WOD_2__Financial__c=fl.Id, 
															WOD_2__Claim__c=claim.Id,WOD_2__Total_Requested_Amount__c=10,
															WOD_2__Type__c='Part', WOD_2__Cost_Category_Type__c='OEM Parts',
															ATI_Factory_Cost__c=10.0,ATI_Factory_Price__c=20.0,ATI_Landed_Part_Markup__c=10.0,ATI_Markup__c=10.0);
        insert fli;
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        claimObj.WOD_2__Claim_Status__c = 'Paid';
        update claimObj;
        Test.startTest();
            claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = 'Reopened';
        	update claimObj;
        Test.stopTest();
        claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        claimObj.WOD_2__Claim_Status__c = 'Rejected';
        update claimObj;
    }
      /*
        Method Name :   testbeforeUpdate
        Description :   Method to test validateAndCreateWR
    */
      @isTest
    private static void testbeforeUpdate(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        List<WOD_2__Policy_Definition__c> policyList = [select Id from WOD_2__Policy_Definition__c]; 
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(
            Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,
            WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),
            WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id,
        	WOD_2__Applicable_Policy__c = policyList[0].Id);
        claim.WOD_2__Claim_Status__c='Draft';
        insert claim;
        claim.WOD_2__Claim_Status__c='Additional Information Required';
        update claim;
        Test.startTest();
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = '';
            claimObj.ATI_Additional_Info_statusDate__c = claimObj.LastModifiedDate.date();
        Test.stopTest();
    }
     /*
        Method Name :   claimvalidateAndCreateWRTest
        Description :   Method to test validateAndCreateWR
    */
    @isTest
    public static void claimvalidateAndCreateWRTest(){
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
            invMap.values().get(i).WOD_2__Type__c = 'Retail';
        }
        update invMap.values();
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        /*for(Integer i=0;i<invMap.values().size();i++){
            vehicleInfoLst[i].ATI_Inventory__c = invMap.values().get(i).Id;
        }*/
        insert vehicleInfoLst;
        
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
           // wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = customerAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
        Account acc = [SELECT Id,Name FROM Account WHERE WOD_2__Warranty_Account_Type__c='Dealer'];
        WOD_2__Policy_Definition__c extendedPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Extended'];
        ATI_Extended_Warranty_Pricing__c ewp = [SELECT Id,ATI_Active_From__c,ATI_Active_Until__c,ATI_Warranty_Product__c,ATI_Vocation_Code__c FROM ATI_Extended_Warranty_Pricing__c WHERE ATI_Policy_Definition__c=:extendedPolicyDef.Id];
        Date inserviceDate = Date.today();
        String jsonArray = '[';
        for(Integer i=0;i<invMap.size();i++){
            jsonArray += '{"Serial Number":"'+invMap.values().get(i).WOD_2__Serial_Number__c+'","Account Name":"'+acc.Name+'","Usage Type":"","In-Service Date":"'+DateTime.newInstance(inserviceDate.year(),inserviceDate.month(),inserviceDate.day()).format('MM/DD/YYYY')+'","Pre-Delivery":"","Unit Usage":"","Vocation Code":"'+vocationCode.Name+'",';
            jsonArray += '"Customer asset number":"","VIN":"'+vehicleInfoLst.get(i).Name+'","Vehicle Mileage (Usage)":"'+vehicleInfoLst.get(i).ATI_Vehicle_Mileage_Usage__c+'","Vehicle usage by Hr":"","Vehicle Make":"'+vehicleInfoLst.get(i).ATI_Vehicle_Make__c+'","Vehicle Model":"'+vehicleInfoLst.get(i).ATI_Vehicle_Model__c+'","Engine Make":"","Engine Model":"","Engine Year":"","Executive order Designation":"",';
            jsonArray += '"Customer Name":"'+customerAcc.Name+'","Customer Number":"","Customer Phone":"","Customer Primary Email Id":"","Billing Street":"","Billing City":"'+customerAcc.BillingCity+'","Billing State/Province":"","Billing Country":"","Billing Zip/Postal Code":"'+customerAcc.BillingPostalCode+'",';
            jsonArray += '"Exteneded Warranty Policy name":"'+extendedPolicyDef.Name+'"}';
            if(i != invMap.size()-1){
                jsonArray+=',';
            }
        }
        jsonArray +=']';                 
        List<WOD_2__Inventory__c> invLst = [SELECT Id,WOD_2__Type__c FROM WOD_2__Inventory__c WHERE Id IN:invMap.keySet() AND WOD_2__Type__c='Retail'];
        //System.assert(invLst.size()==10);
        Map<Id,WOD_2__Warranty_Registration__c> wrMap = new Map<Id,WOD_2__Warranty_Registration__c>([SELECT Id,WOD_2__Status__c,WOD_2__Registration_Type__c FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Registration_Type__c='Extended']);
       // System.assertEquals(10,wrMap.size(),'Number Of Extended WarrantyRegistrations are Inserted!!!');
        List<WOD_2__Warranty_Coverages__c> wcLst = [SELECT Id,WOD_2__Policy_Definition__r.WOD_2__Type__c FROM WOD_2__Warranty_Coverages__c WHERE WOD_2__Warranty_Registration__c IN:wrMap.keySet()];
        //System.assertEquals(10,wcLst.size(),'Number Of Extended Warranties are Inserted!!!');
    }
     @isTest
    private static void testGoodwillClaim(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List< WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        List<WOD_2__Policy_Definition__c> policyList = [select Id from WOD_2__Policy_Definition__c]; 
        policyList[0].WOD_2__Sub_Type__c ='03';
        update policyList;
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
        claim.WOD_2__Is_Pre_Authorization_Required__c = True;
        claim.WOD_2__Pre_Authorization_Comments__c = 'Test';
        claim.WOD_2__Pre_Authorization_Reason__c = 'Goodwill';
        claim.WOD_2__Applicable_Policy__c = policyList[0].Id;
        insert claim;
        claim.WOD_2__Applicable_Policy__c = policyList[1].Id;
        update claim;
        Test.startTest();
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = 'Additional Information Required';           
        Test.stopTest();
    }
       @isTest
    private static void testAutoApproved(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
        claim.WOD_2__Claim_Status__c = 'Draft';
        insert claim;
        claim.WOD_2__Claim_Status__c = 'Pending Approval';
        update claim;
         WOD_2__Claim__c claim2 = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
        claim2.WOD_2__Claim_Status__c = 'Draft';
        insert claim2;
        claim2.WOD_2__Chatter_Comments__c='[{"u":"00505000000SjymAAC","t":"C","ind":"EC","i":"9f22","d":"2021-10-27T12:44:38.428Z","c":"Rejected"}]';
        update claim2;
        claim2.WOD_2__Chatter_Comments__c='[{"u":"00505000000SjymAAC","t":"C","ind":"EC","i":"9f22","d":"2021-10-27T12:44:38.428Z","c":"Rejected"},{"u":"00505000000SjymAAC","t":"C","ind":"IC","i":"684e","d":"2021-10-27T10:50:06.873Z","c":"Need more Information"}]';
        claim2.WOD_2__Claim_Status__c = 'Rejected';
        update claim2;
        Test.startTest();
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = '';
        Test.stopTest();
    }   
     @isTest
    private static void testrecallClaimFromApproval(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
        claim.WOD_2__Is_Pre_Authorization_Required__c = True;
        claim.WOD_2__Pre_Authorization_Comments__c = 'Test';
        claim.WOD_2__Pre_Authorization_Reason__c = 'Goodwill';
        insert claim;
        Test.startTest();
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = '';
        Test.stopTest();
    }
    
    @isTest
    private static void testWRDtailsOnClaim(){
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        WOD_2__Warranty_Code__c vocationCode = [SELECT Id,Name FROM WOD_2__Warranty_Code__c];
        Map<Id,WOD_2__Inventory__c> invMap = new Map<Id,WOD_2__Inventory__c>([SELECT Id,WOD_2__Account__c,WOD_2__Serial_Number__c,WOD_2__Item__c,ATI_Vocation_Code__c,WOD_2__Install_Date__c,WOD_2__Type__c FROM WOD_2__Inventory__c]);
        for(Integer i=0;i<invMap.values().size();i++){
            invMap.values().get(i).WOD_2__Install_Date__c =  Date.today();
            invMap.values().get(i).ATI_Vocation_Code__c = vocationCode.id;
            invMap.values().get(i).WOD_2__Type__c = 'Retail';
        }
        update invMap.values();
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invMap.size());
        /*for(Integer i=0;i<invMap.values().size();i++){
            vehicleInfoLst[i].ATI_Inventory__c = invMap.values().get(i).Id;
        }*/
        insert vehicleInfoLst;
        
        Account customerAcc = [SELECT Id,Name,BillingCity,BillingPostalCode FROM Account WHERE WOD_2__Warranty_Account_Type__c='Customer'];
        WOD_2__Policy_Definition__c standardPolicyDef = [SELECT Id,Name,WOD_2__Active_From__c,WOD_2__Active_Until__c,WOD_2__Months_Covered__c FROM WOD_2__Policy_Definition__c WHERE WOD_2__Type__c='Standard' AND WOD_2__Sub_Type__c!='Stock' LIMIT 1];
        List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(invMap.size());
        for(Integer i=0;i<wrLst.size();i++){
            wrLst[i].WOD_2__Status__c = 'Registered';
            wrLst[i].WOD_2__Account__c = invMap.values().get(i).WOD_2__Account__c;
           // wrLst[i].WOD_2__Registration_Type__c = 'Standard Registration';
            wrLst[i].WOD_2__Registration_Date__c = Date.today();
            wrLst[i].WOD_2__Install_Date__c = Date.today();
            wrLst[i].ATI_Vocation_Code__c = vocationCode.id;
            wrLst[i].WOD_2__Customer__c = customerAcc.Id;
            wrLst[i].WOD_2__Units_Usage__c = 10;
            wrLst[i].WOD_2__Warranty_Product__c = invMap.values().get(i).WOD_2__Item__c;
            wrLst[i].WOD_2__Inventory__c = invMap.values().get(i).Id;
        }
        insert wrLst;
        
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wrLst.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=standardPolicyDef.id,WOD_2__Warranty_Registration__c=wrLst.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(standardPolicyDef.WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        insert warrantyCoverageLst;
        
        ATI_WarrantyService.WRDetailsWrapper wrWrapper = new ATI_WarrantyService.WRDetailsWrapper();
        wrWrapper.ATI_Pre_Delivery_c = true;
        wrWrapper.ATI_Vocation_Code_c = wrLst[0].ATI_Vocation_Code__c;
        //wrWrapper.WOD_2_Install_Date_c = invMap.values()[0].WOD_2__Install_Date__c;
        wrWrapper.WOD_2_Units_Usage_c = 200;
        wrWrapper.WOD_2_Customer_c = wrLst[0].WOD_2__Customer__c;
        
        List<ATI_Vehicle_Information__c> vehiclesLst = TestDataFactory.createVehicleInformation(1);
        wrWrapper.vehicleInfo = vehiclesLst[0];
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',WOD_2__Claim_Type__c='Machine',WOD_2__Account__c =invMap.values()[0].WOD_2__Account__c,WOD_2__Inventory__c=invMap.values()[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id );
        claim.ATI_WR_Details__c = JSON.serialize(wrWrapper);
        try{
            insert claim;
        }catch(Exception e){
            System.debug('e-->'+e.getMessage());
        }
        Test.startTest();
        //WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c LIMIT 1];
        //claimObj.WOD_2__Claim_Status__c = 'Additional Information Required';
        
        Test.stopTest();
    }
    
    @isTest
    private static void testReopenFromPendingPaymentSubmission(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        List<WOD_2__Policy_Definition__c> policyList = [select Id from WOD_2__Policy_Definition__c]; 
        policyList[0].WOD_2__Sub_Type__c = '09';
        update policyList;
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        List<WOD_2__Business_Category_Configuration__c> bus = [select id from WOD_2__Business_Category_Configuration__c];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id, WOD_2__BusinessCategory__c=bus.get(0).Id);
        claim.WOD_2__Claim_Status__c='Draft';
        claim.WOD_2__Applicable_Policy__c = policyList[0].Id;
        insert claim;
        WOD_2__Financial__c fl=new WOD_2__Financial__c(Name='Financial',WOD_2__Final_Requested_Amount__c= 751,WOD_2__Total_Claim_Approved_Amount__c=2,WOD_2__Total_Labor_Approved_Amount__c=1,
                                                           WOD_2__Total_Other_Approved_Amount__c=2,WOD_2__Total_Parts_Approved_Amount__c=2,WOD_2__Claim__c=claim.Id);
		insert fl;
		WOD_2__Financial_Line_Item__c fli = new WOD_2__Financial_Line_Item__c(Name='TestFLI', WOD_2__Financial__c=fl.Id, 
															WOD_2__Claim__c=claim.Id,WOD_2__Total_Requested_Amount__c=10,
															WOD_2__Type__c='Part', WOD_2__Cost_Category_Type__c='OEM Parts',
															ATI_Factory_Cost__c=10.0,ATI_Factory_Price__c=20.0,ATI_Landed_Part_Markup__c=10.0,ATI_Markup__c=10.0);
        insert fli;
        Test.startTest();
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
            claimObj.WOD_2__Claim_Status__c = 'Pending Approval';
            update claimObj;
            claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = 'Reopened';
        	update claimObj;
        Test.stopTest();
    }
    @isTest
    private static void testRepairDateUpdate(){
		List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product_Pricebook__c> wppList = [SELECT Id,WOD_2__Warranty_Product__c FROM WOD_2__Warranty_Product_Pricebook__c];
        List<WOD_2__Policy_Definition__c> policyList = [select Id from WOD_2__Policy_Definition__c];
        policyList[0].WOD_2__Sub_Type__c ='08';
        update policyList;
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        List<WOD_2__Business_Category_Configuration__c> bus = [select id from WOD_2__Business_Category_Configuration__c];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',CurrencyISOCode='USD',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=wppList[0].WOD_2__Warranty_Product__c,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=wppList[0].WOD_2__Warranty_Product__c, WOD_2__BusinessCategory__c=bus.get(0).Id);
        claim.WOD_2__Claim_Status__c='Draft';
        insert claim;        
        claim.WOD_2__Applicable_Policy__c = policyList[0].Id;
        update claim;
        List<WOD_2__Claim_Service_Information__c> claimServices = TestDataFactory.createClaimServices(1);
        Id jobCodeRecType = Schema.SObjectType.WOD_2__Warranty_Code__c.getRecordTypeInfosByDeveloperName().get('Job_Code').getRecordTypeId();
        List<WOD_2__Warranty_Code__c > jobCodeLst = TestDataFactory.createWarrantyCode(1, 'Labor Operations Codes');
        jobCodeLst[0].ATI_Time_Studied__c = false;
        insert jobCodeLst;
       	claimServices[0].WOD_2__Service_Job_Code__c = jobCodeLst[0].Id;
        claimServices[0].WOD_2__Claim__c = claim.Id;
        claimServices[0].WOD_2__Standard_Labor_Hour__c = 10;
        claimServices[0].WOD_2__Total_Labor_Hours__c = 10;
        claimServices[0].WOD_2__Additional_Labor_Hour__c = 0;
        claimServices[0].WOD_2__Total_Labor_Minutes__c = 600;
        claimServices[0].WOD_2__LaborRate__c = 200;
        claimServices[0].WOD_2__Labor_Rate__c = 200;
        insert claimServices; 
		Test.startTest();
        List<WOD_2__Financial_Line_Item__c> fliList = [select Id, Name, WOD_2__Requested_Per_Unit_Amt__c, WOD_2__Requested_Quantity__c,WOD_2__Total_Requested_Amount__c,ATI_Total_Requested_Amount_In_USD__c from WOD_2__Financial_Line_Item__c where WOD_2__Claim__c = :claim.Id];
        System.debug('fliList Before ---> ' + fliList);
        claim.WOD_2__Date_Of_Failure__c = Date.today().addDays(-325);
        claim.WOD_2__Date_Of_Repair__c = Date.today().addDays(-320);
        claim.Shipment_Status__c = 'Shipment Completed';
        update claim;
        fliList = [select Id, Name, WOD_2__Requested_Per_Unit_Amt__c, WOD_2__Requested_Quantity__c,WOD_2__Total_Requested_Amount__c,ATI_Total_Requested_Amount_In_USD__c from WOD_2__Financial_Line_Item__c where WOD_2__Claim__c = :claim.Id];
        System.debug('fliList After ---> ' + fliList);
        WOD_2__Financial_Line_Item__c laborFLI = fliList[0].Name != 'TestPartNumber1' ?  fliList[0] : fliList[1];
        System.assertEquals(100, laborFLI.WOD_2__Requested_Per_Unit_Amt__c, 'Labor Unit Amount is not changed as expected !!!');
        System.assertEquals(1000, laborFLI.WOD_2__Total_Requested_Amount__c, 'Labor Total Amount is not changed as expected !!!');
		Test.stopTest();        
    }
    
    @isTest
    private static void testClaimAppeal(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        List<WOD_2__Policy_Definition__c> policyList = [select Id from WOD_2__Policy_Definition__c]; 
        policyList[0].WOD_2__Sub_Type__c = '04';
        update policyList;
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        List<WOD_2__Business_Category_Configuration__c> bus = [select id from WOD_2__Business_Category_Configuration__c];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id, WOD_2__BusinessCategory__c=bus.get(0).Id);
        claim.WOD_2__Claim_Status__c='Pending Approval';
        claim.WOD_2__Applicable_Policy__c = policyList[0].Id;
        insert claim;
        WOD_2__Financial__c fl=new WOD_2__Financial__c(Name='Financial',WOD_2__Final_Requested_Amount__c= 751,WOD_2__Total_Claim_Approved_Amount__c=10,WOD_2__Total_Labor_Approved_Amount__c=1,
                                                           WOD_2__Total_Other_Approved_Amount__c=2,WOD_2__Total_Parts_Approved_Amount__c=10,WOD_2__Claim__c=claim.Id);
		insert fl;
		WOD_2__Financial_Line_Item__c fli = new WOD_2__Financial_Line_Item__c(Name='TestFLI', WOD_2__Financial__c=fl.Id,WOD_2__Approved_Amount__c=10, 
															WOD_2__Claim__c=claim.Id,WOD_2__Total_Requested_Amount__c=10,WOD_2__Requested_Per_Unit_Amt__c=10,WOD_2__Requested_Quantity__c=1,
															WOD_2__Type__c='Part', WOD_2__Cost_Category_Type__c='OEM Parts',WOD_2__Approved_Quantity__c=1,WOD_2__Total_Approved_Amt__c=10,
															ATI_Factory_Cost__c=10.0,ATI_Factory_Price__c=20.0,ATI_Landed_Part_Markup__c=10.0,ATI_Markup__c=10.0);
        insert fli;
        WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        claimObj.WOD_2__Claim_Status__c = 'Paid';
        update claimObj;
        Test.startTest();
            claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = 'Appeal';
        	update claimObj;
        Test.stopTest();
        System.assertEquals(1,[SELECT Id,WOD_2__Approved_Quantity__c FROM WOD_2__Financial_Line_Item__c WHERE WOD_2__Approved_Quantity__c=NULL].size());
    }
    @isTest
    private static void testClaim(){
        List<Account> accountList =[SELECT Id FROM Account];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Product__c> casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        List<WOD_2__Policy_Definition__c> policyList = [select Id from WOD_2__Policy_Definition__c]; 
        policyList[0].WOD_2__Sub_Type__c ='02';
        update policyList;
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(
            Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,
            WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart[0].Id,WOD_2__Date_Of_Failure__c=system.today(),
            WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casulaPart[0].Id,
        	WOD_2__Applicable_Policy__c = policyList[0].Id);
        claim.WOD_2__Claim_Status__c='Pending Approval';
        insert claim;
        claim.WOD_2__Claim_Status__c = 'Paid';
        claim.ATI_is_Claim_Rejected__c = true;
        update claim;
        Test.startTest();
            WOD_2__Claim__c claimObj = [SELECT Id,WOD_2__Claim_Status__c,LastModifiedDate,ATI_Additional_Info_statusDate__c FROM WOD_2__Claim__c LIMIT 1];
        	claimObj.WOD_2__Claim_Status__c = '';
            claimObj.ATI_Additional_Info_statusDate__c = claimObj.LastModifiedDate.date();
        Test.stopTest();
    }
}