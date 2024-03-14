/* Name: ATI_BR_RoDateMonthsCoveredInServiceTest
Description : Test Class for ATI_BR_RoDateMonthsCoveredInService
Author : Tavant(AS)
History:
VERSION     AUTHOR         DATE               	DETAIL                 UserStory/Req#
1.0 -     Tavant(AS)       Dec 29th 2021		INITIAL DEVELOPMENT                           
*/
@isTest
public class ATI_BR_RoDateMonthsCoveredInServiceTest {
	@testSetup
    public static void testSetup(){
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
        
        //create warranty product
        List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
        for(WOD_2__Inventory__c inventory : inventoryLst){
            inventory.WOD_2__Type__c = 'Retail';
            inventory.WOD_2__Account__c = accLst[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Manufacturing_Date__c = Date.today() - 720;
            inventory.WOD_2__Install_Date__c = Date.today().addmonths(-4);
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        List<WOD_2__Warranty_Registration__c> lstWR = TestDataFactory.createWarrantyRegistration(1);
        lstWR[0].WOD_2__Inventory__c = [select id from WOD_2__Inventory__c][0].id;
        lstWR[0].WOD_2__Account__c = [select id from Account where WOD_2__Warranty_Account_Type__c = 'Dealer'][0].Id;
        lstWR[0].ATI_Pre_Delivery__c = true;
        insert lstWR[0];
        
        List<twodcms__Service_Campaign__c> serviceCampaignLst = TestDataFactory.createServiceCampaign(1,busCategoryConfig.get(0).id);
        serviceCampaignLst[0].Name = 'SC001';
        serviceCampaignLst[0].ATI_Months_Covered__c = 2;
        insert serviceCampaignLst;
        
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        twodcms__Campaign_Members__c campaignMembers = TestDataFactory.createCampaignMembers(inventoryLst.get(0).id,serviceCampaignLst.get(0).Id);
        campaignMembers.Name = inventoryLst.get(0).Name;
        insert campaignMembers;
        
        Id claimTempRecordTypeId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Claim_Template').getRecordTypeId();
        List<WOD_2__Claim__c> claimTemplateLst = TestDataFactory.createClaim(1);
        for(WOD_2__Claim__c claimObj : claimTemplateLst){
			claimObj.CurrencyISOCode = 'USD';
            claimObj.WOD_2__Claim_Status__c = 'Draft';
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.RecordTypeId = claimTempRecordTypeId;
            claimObj.WOD_2__Claim_Type__c = 'Claim Template';
            claimObj.WOD_2__Is_Template__c = true;
        }
        insert claimTemplateLst;
        
        twodcms__Campaign_Claim_Template_Association__c campaignClaimTempAssc = TestDataFactory.createCampaignClaimTempAss(claimTemplateLst[0].id,serviceCampaignLst.get(0).Id,paymentDefLst.get(0).Id);
        insert campaignClaimTempAssc; 
        
        serviceCampaignLst[0].twodcms__Status__c = 'Active';
        update serviceCampaignLst;
        
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        Id campaignClaimId = Schema.SObjectType.WOD_2__Claim__c.getRecordTypeInfosByDeveloperName().get('Campaign').getRecordTypeId();
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createClaim(1); 
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
        claimLst[0].RecordTypeId = campaignClaimId;
        claimLst[0].WOD_2__Claim_Type__c = 'Campaign';
        insert claimLst;
    }
    
    @isTest
    private static void testRule(){
        List<WOD_2__Claim__c> claimList = [Select Id from WOD_2__Claim__c];
        WOD_2.BR_BusinessRuleClassOverrideWrapper wrapperObj = new WOD_2.BR_BusinessRuleClassOverrideWrapper();
        wrapperObj.ruleObjectId=claimList[0].Id;
        ATI_BR_RoDateMonthsCoveredInService obj = new ATI_BR_RoDateMonthsCoveredInService();
        Boolean returnValue1 = obj.checkBusinessRule(wrapperObj);
    }
}