/* Name: ATI_Rest_BatchETCSubmitResponseCheckTest
Description : Test Class for ATI_Rest_BatchETCSubmitResponseCheck,ATI_Rest_BatchETCSubmitResponseValidator, ATI_Rest_BatchETCSubmitResponseRequest 
Author : Tavant(Punam)
History:
VERSION     AUTHOR             DATE              DETAIL                UserStory/Req#
1.0 -     Tavant(Punam)      25/02/2021      INITIAL DEVELOPMENT                              
*/

@isTest
public class ATI_Rest_BatchETCSubmitResponseCheckTest {
    
    @testSetup
    public static void testSetup(){
        List<Account> accountObjectLst = TestDataFactory.createAccount(1);
        accountObjectLst[0].ATI_RPS_Status__c= true;
        insert accountObjectLst;
        
        //Business Category Configuration Creation
        List<WOD_2__Business_Category_Configuration__c> businessUnitObjectLst = TestDataFactory.createBusinessCategoryConfiguration(1);
        for(WOD_2__Business_Category_Configuration__c businessUnitObject : businessUnitObjectLst) {
            businessUnitObject.Name = 'ATI';
            businessUnitObject.WOD_2__Applicable_Claim_Types__c = null;
            businessUnitObject.WOD_2__Applicable_Cost_Categories__c = null;
        }
        Database.insert(businessUnitObjectLst,false);
        List<WOD_2__Warranty_Product__c> warrantyFirstLevelProductList= TestDataFactory.createWarrantyProduct(1);
        for(WOD_2__Warranty_Product__c warrantyMainProductObject : warrantyFirstLevelProductList) {
            warrantyMainProductObject.Name = 'WarrantyMainProduct';
            warrantyMainProductObject.WOD_2__Business_Unit__c = null;
            warrantyMainProductObject.WOD_2__Description__c = null;
            warrantyMainProductObject.WOD_2__Item_Type__c = null;
            warrantyMainProductObject.WOD_2__Major_Part__c = false;
            warrantyMainProductObject.WOD_2__Parent_Product__c = null;
            warrantyMainProductObject.WOD_2__Product_Name__c = 'WarrantyMainProduct';
            warrantyMainProductObject.WOD_2__Standard_Price__c = null;
            warrantyMainProductObject.WOD_2__Track_Type__c = null;
            warrantyMainProductObject.WOD_2__Type__c = 'Product';
            warrantyMainProductObject.WOD_2__Units_Of_Measure__c = null;
        }
        Database.insert(warrantyFirstLevelProductList,false);
        
        List<WOD_2__Warranty_Product__c> warrantySecondLevelProductList = TestDataFactory.createWarrantyProduct(2);
        for(WOD_2__Warranty_Product__c warrantyMainModelObject : warrantySecondLevelProductList) {
            warrantyMainModelObject.Name = 'WarrantyMainModel';
            warrantyMainModelObject.WOD_2__Business_Unit__c = null;
            warrantyMainModelObject.WOD_2__Description__c = null;
            warrantyMainModelObject.WOD_2__Item_Type__c = null;
            warrantyMainModelObject.WOD_2__Major_Part__c = false;
            warrantyMainModelObject.WOD_2__Parent_Product__c = warrantyFirstLevelProductList[0].Id;
            warrantyMainModelObject.WOD_2__Product_Name__c = 'WarrantyMainModel';
            warrantyMainModelObject.WOD_2__Standard_Price__c = null;
            warrantyMainModelObject.WOD_2__Track_Type__c = null;
            warrantyMainModelObject.WOD_2__Type__c = 'Model';
            warrantyMainModelObject.WOD_2__Units_Of_Measure__c = null;
        }
        Database.insert(warrantySecondLevelProductList,false);
        
        List<WOD_2__Warranty_Product__c> warrantyThirdLevelProductList = TestDataFactory.createWarrantyProduct(3);
        for(WOD_2__Warranty_Product__c warrantyItemObject : warrantyThirdLevelProductList) {
            warrantyItemObject.Name = 'WarrantyItem';
            warrantyItemObject.WOD_2__Business_Unit__c = null;
            warrantyItemObject.WOD_2__Description__c = null;
            warrantyItemObject.WOD_2__Item_Type__c = 'Machine';
            warrantyItemObject.WOD_2__Major_Part__c = false;
            warrantyItemObject.WOD_2__Parent_Product__c = warrantySecondLevelProductList[1].Id;
            warrantyItemObject.WOD_2__Product_Name__c = 'WarrantyItem';
            warrantyItemObject.WOD_2__Standard_Price__c = null;
            warrantyItemObject.WOD_2__Track_Type__c = 'Serialized';
            warrantyItemObject.WOD_2__Type__c = 'Item';
            warrantyItemObject.WOD_2__Units_Of_Measure__c = null;
        }
        Database.insert(warrantyThirdLevelProductList,false);
        
        //Inventory Creation
            List<WOD_2__Inventory__c> inventoryObjectLst = TestDataFactory.createInventory(2);
        	for(WOD_2__Inventory__c inv: inventoryObjectLst){
                inv.Name = 'SN-0001025';
                inv.WOD_2__Account__c = accountObjectLst[0].Id;
                inv.WOD_2__Business_Unit__c = businessUnitObjectLst[0].Id;
                inv.WOD_2__Install_Date__c = Date.valueOf(Date.today().addDays(-150));
                inv.WOD_2__Inventory__c = null;
                inv.WOD_2__Is_D2D_Approval_Needed__c = false;
                inv.WOD_2__Is_ERT_Approval_Needed__c = false;
                inv.WOD_2__Is_RMT_Approval_Needed__c = false;
                inv.WOD_2__Item__c = warrantyThirdLevelProductList[0].Id;
                inv.WOD_2__Latest_Transaction__c = null;
                inv.WOD_2__Manufacturing_Date__c = Date.valueOf(Date.today().addDays(-150));       
                inv.WOD_2__Owned_By_National_Account__c = false;
                inv.WOD_2__Pre_Owned__c = false;
                inv.WOD_2__Scrapped__c = false;
                inv.WOD_2__Serial_Number__c = 'SN-0001025';
                inv.WOD_2__Shipment_Date__c = Date.today();
                inv.WOD_2__Stolen_Inventory__c = false;
                inv.WOD_2__Type__c = 'Retail';
                inv.WOD_2__Units_Usage__c = null;
                inv.WOD_2__Warranty_End_Date__c = Date.today();
        	}
        inventoryObjectLst[1].Name='SN-111';
        inventoryObjectLst[1].WOD_2__Serial_Number__c='SN-111';
        insert inventoryObjectLst;
        
        //Warranty Registration Creation
        List<WOD_2__Warranty_Registration__c> warrantyRegistrationObjectLst = TestDataFactory.createWarrantyRegistration(1);
        warrantyRegistrationObjectLst[0].Name = 'Test';
        warrantyRegistrationObjectLst[0].WOD_2__Account__c = accountObjectLst[0].Id;
        warrantyRegistrationObjectLst[0].WOD_2__Batch_Log__c = null;
        warrantyRegistrationObjectLst[0].WOD_2__Customer__c = null;
        warrantyRegistrationObjectLst[0].WOD_2__Inventory__c = inventoryObjectLst[0].Id;
        warrantyRegistrationObjectLst[0].WOD_2__Registration_Comments__c = null;
        warrantyRegistrationObjectLst[0].WOD_2__Registration_Date__c = Date.valueOf(Date.today().addDays(-214));
        warrantyRegistrationObjectLst[0].WOD_2__Registration_Type__c = 'Retail';
        warrantyRegistrationObjectLst[0].WOD_2__Status__c = 'Draft';
        warrantyRegistrationObjectLst[0].WOD_2__Usage_Type__c = null;
        warrantyRegistrationObjectLst[0].WOD_2__Warranty_Product__c = null;
       warrantyRegistrationObjectLst[0].ATI_Submittal_Indicator__c ='I';
        insert warrantyRegistrationObjectLst;
        
        List<WOD_2__Payment_Definitions__c> paymentDefLst=TestDataFactory.createPaymentDefinition(2);
        for(WOD_2__Payment_Definitions__c paymentDef : paymentDefLst) {
            paymentDef.WOD_2__Status__c='Active';
        }
        Database.insert(paymentDefLst,false);
        
        //policy Definition creation
            List<WOD_2__Policy_Definition__c> stdPolicyObject = TestDataFactory.createPolicyDefinition(1);
            stdPolicyObject[0].Name = 'Standard1-Dont Delete';
            stdPolicyObject[0].WOD_2__Active_From__c = Date.valueOf(Date.today().addDays(-214));
            stdPolicyObject[0].WOD_2__Active_Until__c = Date.valueOf(Date.today().addYears(1).addDays(-214));
            stdPolicyObject[0].WOD_2__Default_Policy_Definition__c = false;
            stdPolicyObject[0].WOD_2__Description__c = 'Testing For WarrantyRegistration';
            stdPolicyObject[0].WOD_2__Extended_Policy_Cost__c = null;
            stdPolicyObject[0].WOD_2__Is_Policy_Optional__c = false;
            stdPolicyObject[0].WOD_2__Months_Covered__c = 12;
            stdPolicyObject[0].WOD_2__Payment_Definition__c = paymentDefLst[0].id;
            stdPolicyObject[0].WOD_2__Pricebook_Type__c = null;
            stdPolicyObject[0].WOD_2__Priority__c = 2;
            stdPolicyObject[0].WOD_2__Status__c = 'Active';
            stdPolicyObject[0].WOD_2__Sub_Type__c = null;
            stdPolicyObject[0].WOD_2__Transfer_Fee__c = null;
            stdPolicyObject[0].WOD_2__Transferable_Month__c = null;
            stdPolicyObject[0].WOD_2__Transferable__c = true;
            stdPolicyObject[0].WOD_2__Type__c = 'Standard';
        	insert stdPolicyObject;
        
        	List<WOD_2__Policy_Definition__c> stdPolicyObject2 = TestDataFactory.createPolicyDefinition(1);
            stdPolicyObject2[0].Name = 'Standard1-Dont Delete2';
            stdPolicyObject2[0].WOD_2__Payment_Definition__c = paymentDefLst[1].id;
            stdPolicyObject2[0].WOD_2__Type__c = 'Extended';
            insert stdPolicyObject2;
        
           //Warranty Coverage Creation
            List<WOD_2__Warranty_Coverages__c> lstWarrantyCoverage = TestDataFactory.createWarrantyCoverage(2);
            lstWarrantyCoverage[0].WOD_2__Warranty_Registration__c=warrantyRegistrationObjectLst[0].Id;
            lstWarrantyCoverage[0].WOD_2__Policy_Definition__c=stdPolicyObject[0].Id;
            lstWarrantyCoverage[1].WOD_2__Warranty_Registration__c=warrantyRegistrationObjectLst[0].Id;
            lstWarrantyCoverage[1].WOD_2__Policy_Definition__c=stdPolicyObject2[0].Id;
            insert lstWarrantyCoverage;
        
    }
    
    @isTest
    private static void testForAtiRestBatchETCSubmittalSyncTest(){
    	String jsonMsg='{"ETCStatusCheck": {"identifier": "","BusinessPartnerCode": "","SerialNumber": "","BusinessCategoryConfiguration": ""}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestBatchETC/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response = res; 
         Test.startTest();
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response3 = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        	System.assertEquals('Failed', response3.status, 'All the records have failed to insert or update...!!!');
        
        
        	jsonMsg='{"ETCStatusCheck": {"identifier": "","BusinessPartnerCode": "SAP_ID_10","SerialNumber": "SN-000","BusinessCategoryConfiguration": "AIiuy"}}';
            req.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = req;	
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response4 = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        	System.assertEquals('Failed', response4.status, 'All the records have failed to insert or update...!!!');
        
        	jsonMsg='{"ETCStatusCheck": {"identifier": "12345","BusinessPartnerCode": "SAP_ID_1","SerialNumber": "SN-111","BusinessCategoryConfiguration": "ATI"}}';
            req.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = req;	
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response7 = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        	System.assertEquals('No Extended Warranty Registration Found for Serial no: SN-111', response7.message, 'All the records have failed to insert or update...!!!');
        
        	jsonMsg='{"ETCStatusCheck": {"identifier": "12345","BusinessPartnerCode": "SAP_ID_1","SerialNumber": "SN-0001025","BusinessCategoryConfiguration": "ATI"}}';
            req.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = req;	
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        	System.assertEquals('Success', response.status,'All the records have inserted or updated...!!!');
                                
        	List<WOD_2__Warranty_Registration__c> wRegList =[select Id,ATI_Unique_WR_No__c,WOD_2__Registration_Date__c,WOD_2__Status__c,WOD_2__Inventory__c,ATI_Submittal_Indicator__c,WOD_2__Inventory__r.WOD_2__Serial_Number__c From WOD_2__Warranty_Registration__c limit 1];
        	system.debug('wRegList**'+wRegList[0].WOD_2__Status__c);
        	wRegList[0].ATI_Submittal_Indicator__c= null;
        	wRegList[0].WOD_2__Status__c= null;
        	wRegList[0].WOD_2__Registration_Date__c = Date.today()+1;
        	
        	update wRegList;
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response2 = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        	wRegList[0].WOD_2__Status__c = 'Rejected';
        	update wRegList;
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response5 = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        	System.assertEquals('ETC Denied, reason explained on ETC Registration.', response5.data.etcInfo.dispositionCodeDescription);	
        	
        	wRegList[0].WOD_2__Status__c = 'De-Registered';
        	update wRegList;
        	ATI_Rest_BatchETCSubmitResponseCheck.ATI_Rest_BatchETCSubmitCheckResponse response6 = ATI_Rest_BatchETCSubmitResponseCheck.doPost();
        
        Test.stopTest();
    }

}