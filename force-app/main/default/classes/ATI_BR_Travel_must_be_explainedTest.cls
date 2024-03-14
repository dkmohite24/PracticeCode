/**
-------------------------------------------------------------------------------------------------
* @author         Dishari
* @created        19-July-2021
* @modified
* @description :   test class for ATI_BR_Travel_must_be_explained
* --------------------------------------------------------------------------------------------------
*/
@isTest
public class ATI_BR_Travel_must_be_explainedTest {
	/*
        Method Name :   testSetUp
        Description :   TestSetup method to create test data
    */
    @TestSetup
    public static void testSetUp(){
        Test.startTest();
        //create account
        List<Account> accLst = TestDataFactory.createAccount(1);
        for(Integer i=0;i<accLst.size();i++){
        	accLst[i].Sales_RegionA__c = 'EMEA';
            accLst[i].SAP_ID__c = '1223123'+i;
            accLst[i].Location_Type__c = 'test'+i;    
        }
        insert accLst;
        
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        List<WOD_2__Business_Category_Configuration_Setting__c> bccs = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert bccs;
        
        //create Account business category 
        List<WOD_2__Account_Business_Category_Configuration__c> accBusinessCategoryConfig = TestDataFactory.createAccountBusinessCategoryConfiguration(1);
        accBusinessCategoryConfig[0].WOD_2__Account__c = accLst[0].id;
        accBusinessCategoryConfig[0].WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryConfig;
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Stock';
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        Id partClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Machine').getRecordTypeId(); 
        Id part90ClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Part').getRecordTypeId();
        //Id equipmentClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Equipment_Exchange').getRecordTypeId();
        //create rejected claims
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(2); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Account__c = accLst[0].id;
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Date_Of_Failure__c = Date.today();
            claimObj.WOD_2__Date_Of_Repair__c = Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'testSLNo';
        }
        claimLst[0].RecordTypeId = partClaimId;
        claimLst[1].RecordTypeId = part90ClaimId;
        claimLst[1].WOD_2__Part__c = warrantyProLst[2].id;
        claimLst[1].WOD_2__Date_Of_Purchase__c = Date.today();
        //claimLst[2].RecordTypeId = equipmentClaimId;
        insert claimLst;
        Test.stopTest();
    }
    
    @isTest
    private static void testJobCode(){
        List<WOD_2__Business_Category_Configuration__c> bccs = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert bccs;
        List<WOD_2__Business_Category_Configuration__c> busCategoryList = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryList;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bccs[0]);
        insert bccsList;
        List<WOD_2__Claim_Service_Information__c> claimServices = TestDataFactory.createClaimServices(3);
		
        List<WOD_2__Warranty_Code__c> jobCodes = TestDataFactory.createWarrantyCode(3,'Labor Operations Codes');
        jobCodes[0].Name='11111111';
        jobCodes[0].WOD_2__Standard_Labor_Hour__c = 2;
        jobCodes[0].WOD_2__Standard_Labor_Minutes__c = 0;
        insert jobCodes;
        
		WOD_2__Payment_Definitions__c paymentDefinitions = TestDataFactory.createPaymentDefinition(1)[0];
        insert paymentDefinitions;
        
        WOD_2__Policy_Definition__c policyDefObj = TestDataFactory.createPolicyDefinition(1)[0];
        policyDefObj.WOD_2__Payment_Definition__c = paymentDefinitions.Id;
        policyDefObj.WOD_2__Active_From__c = Date.newInstance(Date.today().year(), Date.today().month()-1, Date.today().day());
        policyDefObj.WOD_2__Active_Until__c = Date.newInstance(Date.today().year()+2, Date.today().month(), Date.today().day());
        insert policyDefObj;
        
        WOD_2__Policy_Definition_Inventory_Usage__c polDefInvUsageObj = new WOD_2__Policy_Definition_Inventory_Usage__c();
        polDefInvUsageObj.Name = 'Policy Definition Inventory Usage';
        polDefInvUsageObj.WOD_2__Maximum_Unit__c = 12000;
        polDefInvUsageObj.WOD_2__Policy_Definition__c = policyDefObj.id;
        polDefInvUsageObj.WOD_2__Usage_Reading_Type__c = 'Machine';
        insert polDefInvUsageObj;

        WOD_2__Claim__c claim = [select id, CurrencyIsoCode from WOD_2__Claim__c Limit 1];
        String currencyCode = getCurrencyCode();
        claim.CurrencyIsoCode = currencyCode;
        claim.WOD_2__Units_Usage__c = 7000;
        claim.ATI_Special_Activity__c = '2008FA06';
        claim.WOD_2__Applicable_Policy__c = policyDefObj.Id;
        update claim;
        system.debug(' claim.WOD_2__Units_Usage__c'+ claim.WOD_2__Units_Usage__c);
        
        WOD_2__Claim_Service_Information__c csi = claimServices[0];
        csi.WOD_2__Service_Job_Code__c = jobCodes[0].Id;
        system.debug('csi.WOD_2__Service_Job_Code__c'+csi);
        system.debug('csi.WOD_2__Service_Job_Code__c'+csi.WOD_2__Service_Job_Code__c);
        system.debug('jobCodes[0].Id'+jobCodes[0].Name);
        csi.WOD_2__Claim__c = claim.Id;
        csi.WOD_2__Labor_Rate__c=100;
        csi.WOD_2__Total_Labor_Hours__c=35;
        csi.WOD_2__Standard_Labor_Hour__c=10;
        csi.WOD_2__Total_Labor_Minutes__c=20;
       // insert csi;
 
        
        Test.startTest();
        List<WOD_2__Claim__c> claimList = [Select Id,RecordTypeId from WOD_2__Claim__c];
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=claimList[0].Id;
        ATI_BR_Travel_must_be_explained checkTravel = new ATI_BR_Travel_must_be_explained();
        ATI_BR_LaborCodeAttachment laborAttachment = new ATI_BR_LaborCodeAttachment();
        ATI_BR_DistDealerProdSnROdate dis = new ATI_BR_DistDealerProdSnROdate();
        ATI_BR_DistDealerProdSnRequestDollar dealer = new ATI_BR_DistDealerProdSnRequestDollar();
        ATI_BR_ProdSnPfpROdate rodate = new ATI_BR_ProdSnPfpROdate();
        ATI_BR_DistDealNbrProdSnMkh snMKH = new ATI_BR_DistDealNbrProdSnMkh();
        ATI_BR_ProdSnPfpMkh ProdSnPfpMkh = new ATI_BR_ProdSnPfpMkh();
        ATI_BR_ProdSnPfpDistBpCode BpCode = new ATI_BR_ProdSnPfpDistBpCode();
        ATI_BR_PriorAFAHigherUsage usage = new ATI_BR_PriorAFAHigherUsage();
        ATI_BR_dupRuleInClaimUnitUsage unit = new ATI_BR_dupRuleInClaimUnitUsage();
        ATI_BR_LowerUsageDifferentPfp lowerUsage = new ATI_BR_LowerUsageDifferentPfp();
        ATI_BR_UnitUsageExcessive excUnit = new  ATI_BR_UnitUsageExcessive();
        ATI_BR_ApplicablePolicyUnitUsage appliPolicy = new ATI_BR_ApplicablePolicyUnitUsage();
        ATI_BR_LaborCodeSpecialActivity laborActivity = new ATI_BR_LaborCodeSpecialActivity();
        ATI_BR_BuildDateAndInServiceDate buildDate = new ATI_BR_BuildDateAndInServiceDate();
        ATI_BR_CheckPFPForElectricalCodes codes = new ATI_BR_CheckPFPForElectricalCodes();
        ATI_BR_PartQuantity partQuan = new ATI_BR_PartQuantity();
        ATI_BR_laborCannotBeReplace replace = new ATI_BR_laborCannotBeReplace();
        ATI_BR_laborFlatRateAmount amount = new ATI_BR_laborFlatRateAmount(); 
        ATI_BR_AdditionalCannotExceed exceed = new ATI_BR_AdditionalCannotExceed();
        ATI_BR_ActivityCodeFoundInPriorClaim activity = new ATI_BR_ActivityCodeFoundInPriorClaim();
        ATI_BR_PreDeliveryWith5000Miles preDel = new ATI_BR_PreDeliveryWith5000Miles();
        ATI_BR_ProdSnPfpDistBpROReq prodSN = new ATI_BR_ProdSnPfpDistBpROReq();
        ATI_BR_TowingDetail towing = new ATI_BR_TowingDetail();
        ATI_BR_WntyMarkupNotInCustFile markup = new ATI_BR_WntyMarkupNotInCustFile();
        ATI_BR_Drain_Pkg_VB pkg = new ATI_BR_Drain_Pkg_VB();
        ATI_BR_PFPUfCodeCheck code = new ATI_BR_PFPUfCodeCheck();
        ATI_BR_TravelRequiresReview Tarvel = new ATI_BR_TravelRequiresReview();
        ATI_BR_laborDateExceeded lab = new ATI_BR_laborDateExceeded();
        ATI_BR_Traveltimeexcessive timeexcessive = new ATI_BR_Traveltimeexcessive();
        //ATI_BR_PartOnPriorClaim prorclaim = new ATI_BR_PartOnPriorClaim();
        //ATI_BR_RoDateLessThanBuildDate rod = new ATI_BR_RoDateLessThanBuildDate();
        //Boolean returnValue = prorclaim.checkBusinessRule(wrapperObj);
        Boolean returnValue0 = timeexcessive.checkBusinessRule(wrapperObj);
        Boolean returnValue1 = checkTravel.checkBusinessRule(wrapperObj);
        Boolean returnValue2 = laborAttachment.checkBusinessRule(wrapperObj);
        Boolean returnValue3 = dis.checkBusinessRule(wrapperObj);
        Boolean returnValue4 = dealer.checkBusinessRule(wrapperObj);
        Boolean returnValue5 = rodate.checkBusinessRule(wrapperObj);
        Boolean returnValue6 = BpCode.checkBusinessRule(wrapperObj);
        Boolean returnValue7 = usage.checkBusinessRule(wrapperObj);
        Boolean returnValue8 = unit.checkBusinessRule(wrapperObj);
        Boolean returnValue9 = lowerUsage.checkBusinessRule(wrapperObj);
        Boolean returnValue10 = partQuan.checkBusinessRule(wrapperObj);
        Boolean returnValue11 = snMKH.checkBusinessRule(wrapperObj);
        Boolean returnValue12 = ProdSnPfpMkh.checkBusinessRule(wrapperObj);
        Boolean returnValue13 = excUnit.checkBusinessRule(wrapperObj);
        Boolean returnValue14 = appliPolicy.checkBusinessRule(wrapperObj);
        Boolean returnValue15 = laborActivity.checkBusinessRule(wrapperObj);
        Boolean returnValue16 = buildDate.checkBusinessRule(wrapperObj);
        Boolean returnValue17 = codes.checkBusinessRule(wrapperObj);  
         Boolean returnValue18 = replace.checkBusinessRule(wrapperObj);
        Boolean returnValue19 = amount.checkBusinessRule(wrapperObj);
        Boolean returnValue20 = exceed.checkBusinessRule(wrapperObj);
        Boolean returnValue22 = activity.checkBusinessRule(wrapperObj);
        Boolean returnValue23 = preDel.checkBusinessRule(wrapperObj);
        Boolean returnValue24 = prodSN.checkBusinessRule(wrapperObj);
        Boolean returnValue25 = towing.checkBusinessRule(wrapperObj);
        Boolean returnValue26 = markup.checkBusinessRule(wrapperObj);
        Boolean returnValue27 = pkg.checkBusinessRule(wrapperObj);
        Boolean returnValue28 = code.checkBusinessRule(wrapperObj);
        Boolean returnValue29 = Tarvel.checkBusinessRule(wrapperObj);
        Boolean returnValue30 = lab.checkBusinessRule(wrapperObj);
        //Boolean returnValue31 = rod.checkBusinessRule(wrapperObj);
        Test.stopTest();
        
    }
    
    private static String getCurrencyCode(){
        Set<String> validCurrency = new Set<String>();
        Schema.DescribeFieldResult f = Pricebook2.CurrencyIsoCode.getDescribe();
        for (Schema.PicklistEntry pick:f.getPicklistValues()){
            if(pick.getValue() != 'USD'){
                return pick.getValue(); 
            }
        }
        return 'USD';
    } 
}