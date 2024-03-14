/* Name: ATI_REST_BatchClaimSubmttalRespCheckTest
Description : Test Class for ATI_REST_BatchClaimSubmttalRespCheck,ATI_REST_BatchClaimSubmttalRespValidator and ATI_REST_BatchClaimSubmttalRespRequest
Author : Tavant(TY)
History:
VERSION     AUTHOR            DATE              DETAIL              UserStory/Req#
1.0 -     Tavant(TY)      01-Mar-2021      INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_REST_BatchClaimSubmttalRespCheckTest{
    @testSetup
    public static void testSetup(){
        Test.startTest();
        //create account
        List<Account> account = TestDataFactory.createATIDistributorAccount(1);
        account.get(0).ATI_Financial_BP_Code__c = '0000091005';
        account.get(0).SAP_ID__c = '0000091005';
        insert account;
        
        //create Business Category Configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        busCategoryConfig.get(0).Name = 'ATI';
        insert busCategoryConfig;
        
        //create Business Category Configuration Setting - Configuration
        List<WOD_2__Business_Category_Configuration_Setting__c> configurationBccsLst = TestDataFactory.createBccs(busCategoryConfig[0]);
        insert configurationBccsLst;
        
        //Machine
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(3);
        insert warrantyProLst;
        
        //Parts
        List<WOD_2__Warranty_Product__c> warrantyProPartLst = TestDataFactory.createWarrantyProductItem(1);
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
            inventory.WOD_2__Account__c = account[0].id;
            inventory.WOD_2__Item__c = warrantyProLst[2].id;
            inventory.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        }
        insert inventoryLst;
        
        //create Warranty Code
        List<WOD_2__Warranty_Code__c> warrantyFaultCodeLst = TestDataFactory.createFaultCode(1);
        insert warrantyFaultCodeLst;
        
        
        //create claim
        List<WOD_2__Claim__c> claimLst = TestDataFactory.createMachineClaim(1); 
        for(WOD_2__Claim__c claimObj : claimLst){
            claimObj.WOD_2__Claim_Status__c = 'Approved';
            claimObj.WOD_2__Account__c = account[0].id;
            claimObj.ATI_Submittal_Indicator__c = 'I';
            claimObj.WOD_2__Inventory__c = inventoryLst[0].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Fault_Code__c = warrantyFaultCodeLst[0].id;
            claimObj.WOD_2__BusinessCategory__c = busCategoryConfig[0].id;
            claimObj.WOD_2__Model_Number__c = warrantyProLst[2].id;
            claimObj.WOD_2__Causal_Part_Number__c = warrantyProPartLst[0].id;
            claimObj.ATI_Tracking_Number__c = 'Y023434987';
            claimObj.WOD_2__Work_Order__c = 'Test';
            claimObj.ATI_Disposition_Code__c = '101-Claim Type is missing or not valid';
        }
        insert claimLst;
        
        //create warehouse
        List<WOD_2__Warehouse__c> whLst = TestDataFactory.createWarehouse(1);
        insert whLst;
        
        //create partreturnconfiguration
        List<WOD_2__Part_Return_Configuration__c> prcLst = TestDataFactory.createPartReturnConfiguration(1);
        for(WOD_2__Part_Return_Configuration__c prc : prcLst){
            prc.WOD_2__Return_Location__c = whLst[0].Id;
        }
        insert prcLst;
        
        //create Removed ClaimPart
        List<WOD_2__Removed_Claim_Part__c> removedpartList = TestDataFactory.createRemovedClaimPart(1);
        for(WOD_2__Removed_Claim_Part__c removedpart : removedpartList) {
            removedpart.WOD_2__Claim__c = claimLst[0].Id;
            removedpart.WOD_2__Is_Auto_PRC__c = true;
            removedpart.WOD_2__Warranty_Product__c =  warrantyProPartLst[0].id;
            removedpart.WOD_2__Part_Return_Requested__c = true;
            removedpart.WOD_2__Is_Shipped__c = true;
            removedpart.WOD_2__Is_Returned__c = true;
            removedpart.WOD_2__Is_Inspected__c = true;
            removedpart.WOD_2__Part_Return_Configuration__c = prcLst[0].id;
        }
        insert removedpartList;
        
        //create ApplicabilityTerm
        List<WOD_2__Applicability_Term__c> atInclusionObjectLst = TestDataFactory.createApplicabilityTerms(1,'Inclusion');
        for(WOD_2__Applicability_Term__c atInclusionObject : atInclusionObjectLst){
            atInclusionObject.WOD_2__isValidExpression__c = true;
            atInclusionObject.WOD_2__Logical_Grouping__c = '1';
            atInclusionObject.WOD_2__Part_Return_Configuration__c = prcLst[0].id;
            atInclusionObject.WOD_2__Functionality__c = 'Claim Part Returns';
            atInclusionObject.WOD_2__Rule_Object_API_Name__c = 'WOD_2__Removed_Claim_Part__c';
        }
        insert atInclusionObjectLst;
        
        //create ApplicabilityCriteria
        List<WOD_2__Applicability_Criteria__c> acObjectLst = TestDataFactory.createApplicabilityCriterias(1,atInclusionObjectLst.get(0));
        for(WOD_2__Applicability_Criteria__c acObject : acObjectLst){
            acObject.WOD_2__Applicability_Term__c = atInclusionObjectLst[0].id;
            acObject.WOD_2__Criteria_Value__c = 'TRUE';
            acObject.WOD_2__Field_Path_Label__c = 'Warranty Product> RMA Policy';
            acObject.WOD_2__Field_Path__c = 'WOD_2__Warranty_Product__r.RMA_Policy__c';
            acObject.WOD_2__Field_Type__c = 'STRING';
            acObject.WOD_2__Operator__c = 'Equals';
            acObject.WOD_2__Sequence__c = 1;
        }
        insert acObjectLst;
        Test.stopTest();
    }
    
    private static testmethod void testBatchClaimRespForSuccess(){
        WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c];
        claim.WOD_2__Claim_Status__c = 'Paid';
        update claim;
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"0000091005","BusinessCategoryConfiguration":"ATI","TrackingNumber":"Y023434987","Identifier":"1"}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Success Response');
    }
    
    private static testmethod void testBatchClaimRespForRecievedParts(){
        WOD_2__Claim__c claim = [SELECT Id FROM WOD_2__Claim__c];
        WOD_2__Business_Category_Configuration_Setting__c bccs = [SELECT Id,WOD_2__Display_Message__c,WOD_2__Module__c,WOD_2__Sub_Module__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name='ATI_Check_For_Auto_Approval'];
        WOD_2__Business_Rule__c buRule = new WOD_2__Business_Rule__c(WOD_2__Claim__c=claim.id,WOD_2__Message__c=bccs.WOD_2__Display_Message__c,
                                                                    WOD_2__Business_Category_Configuration_Setting__c=bccs.id);
        insert buRule;
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"0000091005","BusinessCategoryConfiguration":"ATI","TrackingNumber":"Y023434987","Identifier":"1"}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Success Response');
    }
    
    private static testmethod void testBatchClaimRespForRejected(){
        WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c];
        claim.WOD_2__Claim_Status__c = 'Rejected';
        update claim;
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"0000091005","BusinessCategoryConfiguration":"ATI","TrackingNumber":"Y023434987","Identifier":"1"}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Success Response');
    }
    
    private static testmethod void testBatchClaimRespForShipped(){
        WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c];
        WOD_2__Removed_Claim_Part__c rcp = [SELECT Id,WOD_2__Is_Returned__c FROM WOD_2__Removed_Claim_Part__c];
        rcp.WOD_2__Is_Returned__c = false;
        update rcp;
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"0000091005","BusinessCategoryConfiguration":"ATI","TrackingNumber":"Y023434987","Identifier":"1"}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Success Response');
    }
    
    private static testmethod void testBatchClaimRespForIssued(){
        WOD_2__Claim__c claim = [SELECT Id,WOD_2__Claim_Status__c FROM WOD_2__Claim__c];
        WOD_2__Removed_Claim_Part__c rcp = [SELECT Id,WOD_2__Is_Shipped__c,WOD_2__Is_Returned__c FROM WOD_2__Removed_Claim_Part__c];
        rcp.WOD_2__Is_Shipped__c = false;
        rcp.WOD_2__Is_Returned__c = false;
        rcp.WOD_2__Is_Inspected__c = false;
        update rcp;
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"0000091005","BusinessCategoryConfiguration":"ATI","TrackingNumber":"Y023434987","Identifier":"1"}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Success Response');
    }
    
    private static testmethod void testBatchClaimRespForMandatoryCheck(){
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"","BusinessCategoryConfiguration":"","TrackingNumber":"","Identifier":""}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Failed Response');
    }
    
    private static testmethod void testBatchClaimRespForClaimNotFound(){
        String jsonMsg = '{"ClaimStatusCheck":{"BusinessPartnerCode":"0000091005Test","BusinessCategoryConfiguration":"Test","TrackingNumber":"Test","Identifier":"1"}}';
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = sendBatchClaimResponseRequest(jsonMsg);
        System.assertEquals('Success', response.status, 'Failed Response');
    }
    
    private static ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse sendBatchClaimResponseRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRESTBatchClaimSubmittalResponse/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_BatchClaimSubmttalRespCheck.ATI_REST_BatchClaimSubmittalResponse response = ATI_REST_BatchClaimSubmttalRespCheck.doPost();
        Test.stopTest();
        return response;
    }
}