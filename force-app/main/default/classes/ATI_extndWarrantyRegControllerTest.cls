/* Name: ATI_extndWarrantyRegControllerTest
Description : Test Class for ATI_extndWarrantyRegController 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             		DATE                  DETAIL                 UserStory/Req#
1.0 -     Tavant(Punam)         12/16/2020         INITIAL DEVELOPMENT                              
*/

@isTest
public class ATI_extndWarrantyRegControllerTest {
	@testSetup
    public static void testSetup(){
    	Test.startTest();
        	//Business Category Configuration
            List<WOD_2__Business_Category_Configuration__c> businessCategoryConfigLst = TestDataFactory.createBusinessCategoryConfiguration(1);
            insert businessCategoryConfigLst;

			List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(businessCategoryConfigLst[0]);        
        	insert bccsList;
        	//Payment Definition
            List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
            insert paymentDefLst;
            //Policy Definition - Extended
            List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
            policyDefLst[0].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
            policyDefLst[0].WOD_2__Type__c = 'Extended';
            insert policyDefLst;
        
            //ApplicabilityTerms
            List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(3,'Inclusion');
            applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefLst[0].Id;
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
        
        
        	//Warranty Product at Model Level for Extended Warranty Pricing
            List<WOD_2__Warranty_Product__c> wpLst = TestDataFactory.createWarrantyProduct(1);
            insert wpLst;
            
            //Vocation Code for Extended Warranty Pricing
        	//Account Creation
            List<Account> accountList = TestDataFactory.createAccount(2); 
            for(Integer i=0;i<accountList.size();i++){
                accountList[i].Sales_RegionA__c = 'EMEA';
                accountList[i].SAP_ID__c = '1223123'+i;
                accountList[i].Location_Type__c = 'Type'+i;
                accountList[i].WOD_2__Warranty_Account_Type__c='Dealer';
                accountList[i].Country__c='USA';
               
            }
            accountList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
            
            insert accountList;
        	
            List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
            for(Integer i=0;i<warrantyProLst.size();i++){
                //warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
                warrantyProLst[i].WOD_2__Type__c = 'Item';
                warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
                warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
            }
            insert warrantyProLst;
        
        	List<WOD_2__Warranty_Code__c> vocantionCodeLst = TestDataFactory.createVocationCode(1,false);
        	insert vocantionCodeLst;
        
        	//Inventory Creation
        	List<WOD_2__Inventory__c> inventoryList= TestDataFactory.createInventory(1);
        	inventoryList[0].WOD_2__Account__c = accountList[0].Id;
        	inventoryList[0].WOD_2__Item__c = warrantyProLst[2].Id;
        	inventoryList[0].WOD_2__Install_Date__c = Date.today();
        	inventoryList[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).Id;
        	inventoryList[0].WOD_2__Business_Unit__c = businessCategoryConfigLst[0].Id; 
        	insert inventoryList;
        
        	//Warranty Registration Creation
        	List<WOD_2__Warranty_Registration__c> lstWarrantyRegistration = TestDataFactory.createWarrantyRegistration(1);
        	lstWarrantyRegistration[0].WOD_2__Inventory__c	=inventoryList[0].Id;
        	lstWarrantyRegistration[0].WOD_2__Account__c = accountList[0].Id;
            lstWarrantyRegistration[0].WOD_2__Customer__c = accountList[1].Id;
            lstWarrantyRegistration[0].ATI_Extended_Warranty_Purchase_Date__c = Date.today();
            lstWarrantyRegistration[0].ATI_PO_Number__c = '100';
            
        	insert lstWarrantyRegistration;
            
              
                
            //Extended Warranty Pricing
            List<ATI_Extended_Warranty_Pricing__c> ewpLst = TestDataFactory.createExtendedWarrantyPricing(1);
        	ewpLst[0].ATI_Base_Price__c = 100.0;
            ewpLst[0].ATI_Vocation_Code__c = vocantionCodeLst.get(0).id;
            ewpLst[0].ATI_Warranty_Product__c = inventoryList[0].WOD_2__Item__r.WOD_2__Parent_Product__c;
            ewpLst[0].ATI_Policy_Definition__c = policyDefLst.get(0).id;
        	ewpLst[0].ATI_Country__c = 'USA';
        	ewpLst[0].ATI_Program_Level__c = null;
            insert ewpLst;
        
             List<WOD_2__Transaction_Memo_History__c> transacMemoList = TestDataFactory.createTransactionMemo(1);
        for(WOD_2__Transaction_Memo_History__c memoRec : transacMemoList){
            memoRec.WOD_2__Settlement_Category__c='EWP';
            memoRec.WOD_2__Transaction_Status__c='Paid';
            memoRec.WOD_2__Transaction_Type__c='Debit';
            memoRec.ATI_Warranty_Registration__c=lstWarrantyRegistration[0].Id;
        }
        insert transacMemoList;
        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemList = TestDataFactory.createTransactionMemoLineItem(1);
        for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemRec : lineItemList){
            lineItemRec.ATI_Handling_Fee__c=10;
            lineItemRec.ATI_Late_Fee__c=20;
            lineItemRec.WOD_2__Transaction_Memo_History__c=transacMemoList[0].Id;
            lineItemRec.WOD_2__Unit_Amount__c=300;
        }
        insert lineItemList;
       
        List<Account> customerAccount = TestDataFactory.createATICustomerAccount(1);
        insert customerAccount;
        
        Test.stopTest();
    }
    @isTest
    private static void testGetPolicyDetails(){
        ATI_extndWarrantyRegController.getPolicyDetails();
       // WOD_2.ResponseWrapper policyWrapper = 
        List<WOD_2__Inventory__c> inv = [SELECT id,ATI_Vocation_Code__c,RecordType.Name,WOD_2__Install_Date__c 
                                   FROM WOD_2__Inventory__c];
        inv[0].WOD_2__Install_Date__c = Date.today();
        update inv;
        List<WOD_2__Warranty_Registration__c> wr =[Select Id,WOD_2__Inventory__r.WOD_2__Install_Date__c,WOD_2__Inventory__r.ATI_Vocation_Code__c,WOD_2__Inventory__r.WOD_2__Account__r.Country__c,
                                                  WOD_2__Status__c,WOD_2__Inventory__r.WOD_2__Item__r.WOD_2__Parent_Product__c,WOD_2__Inventory__r.WOD_2__Business_Unit__c,
                                                  WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Registration_Date__c From WOD_2__Warranty_Registration__c];
        wr[0].WOD_2__Install_Date__c= Date.today();
        update wr;
        List<WOD_2__Policy_Definition__c> policyDef =[Select Id,Name,WOD_2__Months_Covered__c From WOD_2__Policy_Definition__c];
        List<String> policyIds= new List<String>{policyDef[0].Id};
        List<WOD_2__Warranty_Coverages__c> warrantyCoverageLst = new List<WOD_2__Warranty_Coverages__c>();
        for(Integer i=0;i<wr.size();i++){
            WOD_2__Warranty_Coverages__c wc = new WOD_2__Warranty_Coverages__c(WOD_2__Policy_Definition__c=policyDef[0].id,WOD_2__Warranty_Registration__c=wr.get(i).id,
                                                                               WOD_2__Warranty_Start_Date__c=Date.today(),WOD_2__Warranty_End_Date__c=Date.today().addDays(Integer.valueOf(policyDef[0].WOD_2__Months_Covered__c)));
            warrantyCoverageLst.add(wc);
        }
        List<String> policyIdString = new List<String> {policyDef[0].Id};
        String wcString = String.valueOf(warrantyCoverageLst[0]);
        ATI_extndWarrantyRegController.ExtendedWRWrapper wp = new ATI_extndWarrantyRegController.ExtendedWRWrapper();
        //wp.policyName = 'policytest';
        wp.policyName = 'PD1';
        wp.basePrice = 111.11;
        wp.handlingFee = 222.22;
        wp.lateFee = 333.33;
        wp.finalPrice = 444.44;
        wp.finalPriceInLocalCurrency='USD';
        
        List<ATI_extndWarrantyRegController.ExtendedWRWrapper> wpListextndWntyCont =  
            new  List<ATI_extndWarrantyRegController.ExtendedWRWrapper>{wp};
        ATI_extndWarrantyRegController.saveTransactionHistory(wpListextndWntyCont,policyIdString,inv[0].Id);
        ATI_extndWarrantyRegController.registerExtWarrantyCoverages('test',wr[0].Id,'test123');
        ATI_extndWarrantyRegController.saveWarrantyCoverages(wcString);
        //ATI_extndWarrantyRegController.createTransaction(wr[0].Id,'test123');
        String purchasedCoverageDetails = '{"exPricingList": [{"policyName":"test policy","basePrice":50.0,"handlingFee":10.0,"lateFee":5.0,"finalPrice":65.0,"finalPriceInLocalCurrency":"65"}],"totalPrice":123.0,"basePrice":100.0,"showLocalCurrency":false}';
        ATI_extndWarrantyRegController.createTransaction(wr[0].Id,purchasedCoverageDetails);
        ATI_extndWarrantyRegController.getExtendedWarrantyPricing(policyIds,wr[0].Id);
        ATI_extndWarrantyRegController.warrantyRuleException(wr[0].Id);
        ATI_extndWarrantyRegController.checkPurchaseDate(wr[0].Id);
    }

    @isTest
    private static void testGetWarrantyCoverages(){
        List<WOD_2__Inventory__c> inv = [SELECT id,ATI_Vocation_Code__c,RecordType.Name, WOD_2__Account__c  FROM WOD_2__Inventory__c];
        List<WOD_2__Warranty_Registration__c> wr =[Select Id,WOD_2__Registration_Type__c, WOD_2__Inventory__r.WOD_2__Install_Date__c,WOD_2__Inventory__r.ATI_Vocation_Code__c,WOD_2__Inventory__r.WOD_2__Account__r.Country__c,
                                                  WOD_2__Account__r.ATI_Inactive_Date__c, WOD_2__Status__c,WOD_2__Inventory__r.WOD_2__Item__r.WOD_2__Parent_Product__c,WOD_2__Inventory__r.WOD_2__Business_Unit__c,WOD_2__Account__r.ATI_Active__c,
                                                  WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Registration_Date__c From WOD_2__Warranty_Registration__c];
        wr[0].WOD_2__Registration_Type__c = 'Standard Registration';
        update wr;
        Test.startTest();
        // test for when only Std WR is done.
        Map<String, String> inputMap = new Map<String, String>{'invId' => inv[0].Id, 'accountId' => inv[0].WOD_2__Account__c, 'purchaseDt' => DateTime.now().format('yyyy-MM-dd'), 'poNumber' => '100'};
		// this will create a new ext. WR in Draft state.
		ATI_extndWarrantyRegController.getWarrantyCoverages(JSON.serialize(inputMap)); 
        List<WOD_2__Warranty_Registration__c> wrList =[Select Id From WOD_2__Warranty_Registration__c /*where WOD_2__Registration_Type__c = 'Extended' and WOD_2__Status__c = 'Draft'*/];
        System.debug('wrList -> ' + wrList);
        // this is for ensuring ext. WR in Draft state is reused.
        ATI_extndWarrantyRegController.getWarrantyCoverages(JSON.serialize(inputMap)); 
        wrList =[Select Id From WOD_2__Warranty_Registration__c where WOD_2__Registration_Type__c = 'Extended' and WOD_2__Status__c = 'Draft'];
        System.debug('wrList -> ' + wrList);
        Test.stopTest();
    }

    @isTest
    private static void testCreateTransaction(){
        List<WOD_2__Inventory__c> inv = [SELECT id,WOD_2__Install_Date__c,ATI_Vocation_Code__c,RecordType.Name, WOD_2__Account__c  FROM WOD_2__Inventory__c];
        inv[0].WOD_2__Install_Date__c = Date.today();
        update inv;
        List<WOD_2__Warranty_Registration__c> wr =[Select Id,WOD_2__Registration_Type__c, WOD_2__Inventory__r.WOD_2__Install_Date__c,WOD_2__Inventory__r.ATI_Vocation_Code__c,WOD_2__Inventory__r.WOD_2__Account__r.Country__c,
                                                  WOD_2__Status__c,WOD_2__Inventory__r.WOD_2__Item__r.WOD_2__Parent_Product__c,WOD_2__Inventory__r.WOD_2__Business_Unit__c,
                                                  WOD_2__Inventory__r.WOD_2__Serial_Number__c,WOD_2__Registration_Date__c From WOD_2__Warranty_Registration__c];
        wr[0].WOD_2__Registration_Type__c = 'Standard Registration';
        wr[0].WOD_2__Install_Date__c =  Date.today();
        update wr;
        List<WOD_2__Policy_Definition__c> policyDef =[Select Id,Name,WOD_2__Months_Covered__c From WOD_2__Policy_Definition__c];
        Test.startTest();
        // test for when only Std WR is done.
        Map<String, String> inputMap = new Map<String, String>{'invId' => inv[0].Id, 'accountId' => inv[0].WOD_2__Account__c, 'purchaseDt' => DateTime.now().format('yyyy-MM-dd'), 'poNumber' => '100'};
		// this will create a new ext. WR in Draft state.
		String covResponse = ATI_extndWarrantyRegController.getWarrantyCoverages(JSON.serialize(inputMap)); 
        System.debug('covResponse -> ' + covResponse);
        List<WOD_2__Warranty_Registration__c> wrList =[Select Id,WOD_2__Registration_Type__c From WOD_2__Warranty_Registration__c /*where WOD_2__Registration_Type__c = 'Extended' and WOD_2__Status__c = 'Draft'*/];
        wrList[0].WOD_2__Registration_Type__c = 'Extended';
        update wrList;
        system.debug('wrList'+wrList[0].WOD_2__Registration_Type__c);
        ATI_extndWarrantyRegController.WntyCoverageWrapper wrapper = (ATI_extndWarrantyRegController.WntyCoverageWrapper)JSON.deserialize(covResponse, ATI_extndWarrantyRegController.WntyCoverageWrapper.class);
        WOD_2.ResponseWrapper response = ATI_extndWarrantyRegController.getExtendedWarrantyPricing(new List<Id>{policyDef[0].Id}, wrList[0].Id);
        //String wcInputString,String wrId, String purchasedCoverageDetails
        Map<String, Object> wcInputWrapper = new Map<String, Object>();
        wcInputWrapper.put('coverages',wrapper.warrantyCoverages);
        wcInputWrapper.put('warrantyCoverageBeforeSaveOverrideClassName', 'WR_WarrantyCoverageBeforeSaveOverride');
        wcInputWrapper.put('wrRecordIds', new List<Id>{wrList[0].Id});
        ATI_extndWarrantyRegController.registerExtWarrantyCoverages(JSON.serialize(wcInputWrapper), wrList[0].Id, response.data);
        System.debug('response -> ' + response);
        Test.stopTest();
        
    }    
}