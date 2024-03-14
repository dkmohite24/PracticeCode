@isTest
public class ATI_RESTSerialNumberInfoSyncTest {
	@isTest
    	public static void serialNumberInfoTest(){
            List<ATI_Vehicle_Information__c> vehiInfo = TestDataFactory.createVehicleInformation(1);
            insert vehiInfo;
            List<Account> accLst = TestDataFactory.createAccount(2);
            List<Account> accCustLst = TestDataFactory.createATICustomerAccount(2);
            for(Integer i=0;i<accLst.size();i++){
                accLst[i].Sales_RegionA__c = 'EMEA';
                accLst[i].SAP_ID__c = '1223123'+i;
                accLst[i].Location_Type__c = 'test'+i;    
            }
            accLst[0].WOD_2__Warranty_Account_Type__c='Dealer';
            accLst[0].ATI_RPS_Status__c=true;
            accLst[1].WOD_2__Warranty_Account_Type__c='Customer';
            accLst[1].BillingCity = 'CA';
            insert accLst;
            List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
            insert warrantyProLst;
            List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
            for(WOD_2__Inventory__c inventory : inventoryLst){
                inventory.WOD_2__Type__c = 'Stock';
                inventory.WOD_2__Account__c = accLst[0].id;
                inventory.WOD_2__Item__c = warrantyProLst[2].id;
                inventory.WOD_2__Customer__c = accCustLst[0].id;
                //inventory.WOD_2__Customer__r.Phone = accLst[0].Phone;
                //inventory.WOD_2__Customer__r.Email_Address__c = 'test@gmail.com';
                //inventory.WOD_2__Customer__r.BillingStreet ='Test';
                //inventory.WOD_2__Customer__r.BillingCity = accCustLst[0].BillingCity;
                //inventory.ATI_ = vehiInfo[0].id;
            }
            insert inventoryLst;
            List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
            wrLst[0].WOD_2__Inventory__c = inventoryLst[0].id;
            wrLst[0].WOD_2__Account__c = accLst[0].Id;
			wrLst[0].WOD_2__Customer__c = accLst[1].Id;            
            wrLst[0].WOD_2__Status__c = 'Registered';
            insert wrLst;
            List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        List<WOD_2__Policy_Definition__c> policyDefLst = TestDataFactory.createPolicyDefinition(1);
        policyDefLst[0].WOD_2__Payment_Definition__c = paymentDefLst.get(0).id;
        policyDefLst[0].WOD_2__Type__c = 'Extended';
        insert policyDefLst;
            List<WOD_2__Warranty_Coverages__c> warCovList = TestDataFactory.createWarrantyCoverage(1);
        	for(WOD_2__Warranty_Coverages__c warCovRec : warCovList){
            warCovRec.WOD_2__Policy_Definition__c=policyDefLst[0].Id;
            warCovRec.WOD_2__Warranty_Registration__c=wrLst[0].Id;
        }
        insert warCovList;
            ATI_RESTSerialNumberInfoSync restSerial = new ATI_RESTSerialNumberInfoSync();
            // ATI_REST_SerialNumberInfoSyncResponse syncResponse = ATI_RESTSerialNumberInfoSync.doPost();
            ATI_REST_SerialNumberInfoRequest request = new ATI_REST_SerialNumberInfoRequest();
           // ATI_REST_SerialNumberInfo_Validator.checkAccessMethod();
            ATI_REST_SerialNumberInfoRequest.SerialInformation srInfo = new ATI_REST_SerialNumberInfoRequest.SerialInformation(); 
            List<ATI_REST_SerialNumberInfoRequest.SerialInformation>  srInfoList = new List<ATI_REST_SerialNumberInfoRequest.SerialInformation>();
            ATI_REST_SerialNumberInfoRequest.SerialNumberInformation srNumInfo = new ATI_REST_SerialNumberInfoRequest.SerialNumberInformation();
            WOD_2__Warranty_Registration__c wr = [SELECT id,WOD_2__Account__r.SAP_ID__c ,WOD_2__Inventory__r.WOD_2__Serial_Number__c FROM WOD_2__Warranty_Registration__c Limit 1];
            srInfo.repairOutlet = wr.WOD_2__Account__r.SAP_ID__c;
            srInfo.serialNumber = wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c;
            srInfo.trackingNumber = '';
            srInfoList.add(srInfo);
            srNumInfo.serialInfo = srInfoList;
            srNumInfo.businessPartnerCode = wr.WOD_2__Account__r.SAP_ID__c;
            request.SerialNumberInfo = srNumInfo;
            String requestStr = JSON.serialize(request);
             
          ATI_REST_SerialNumberInfoSyncResponse serialResponse = sendSerialNumberRequest(requestStr);
          restSerial.createLog('processName','request', 'response', 'status', 'identifier',  'primaryKey', 'errorMessage');
          restSerial.createLog('processName','request', 'response', 'Failure', null , 'primaryKey', 'errorMessage');
          restSerial.createLog('processName','request', 'response', 'Success', null , 'primaryKey', 'errorMessage');
        }
    
    private static ATI_REST_SerialNumberInfoSyncResponse sendSerialNumberRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATI_RESTSerialNumberInfoSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_SerialNumberInfoSyncResponse response = ATI_RESTSerialNumberInfoSync.doPost();
        Test.stopTest();
        return response;
    }
}