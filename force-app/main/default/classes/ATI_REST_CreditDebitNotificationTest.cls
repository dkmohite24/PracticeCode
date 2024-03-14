/*
	Class Name	:	ATI_REST_CreditDebitNotificationTest
	Description	:	Test class ATI_REST_CreditDebitNotification
*/
@isTest
public class ATI_REST_CreditDebitNotificationTest {
	@testSetup
    private static void setup(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accountList = TestDataFactory.createAccount(2); 
        accountList[0].Name = 'Testacc';
        accountList[0].Sales_RegionA__c = 'EMEA';
        accountList[0].SAP_ID__c = '1223123';
        accountList[0].Location_Type__c = 'Type';
        accountList[0].WOD_2__Warranty_Account_Type__c='Dealer';
        insert accountList[0];
        
        accountList[1].Name = 'Testacc Child';
        accountList[1].Sales_RegionA__c = 'North America';
        accountList[1].SAP_ID__c = '1133445';
        accountList[1].Location_Type__c = 'L';
        accountList[1].WOD_2__Warranty_Account_Type__c='Customer';
        accountList[1].ParentId = accountList[0].Id;
        insert accountList[1];
        
        insert new Group(Name='ATI_Dealer_'+accountList[0].Id);
        
        //Warranty Product at Model Level for Extended Warranty Pricing
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(1);
        for(Integer i=0;i<warrantyProLst.size();i++){
        	//warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
            warrantyProLst[i].WOD_2__Type__c = 'Item';
            warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
            warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProLst;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        invList[0].WOD_2__Install_Date__c = system.today();
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].WOD_2__Units_Usage__c = 6000;
        insert invList;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accountList[0].Id;
            wrRec.WOD_2__Status__c='In Progress';
            wrRec.WOD_2__Customer__c=accountList[1].Id;
        }
        insert wrList;
        
        //casual part creation
        WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
        casualPart.WOD_2__Business_Unit__c = bcc.Id;
        casualPart.External_Product_Code__c = casualPart.Name;
        casualPart.WOD_2__Type__c = 'Item';
        casualPart.WOD_2__Track_Type__c = 'Part';
        insert casualPart;
        
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claimObj = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casualPart.Id,WOD_2__Date_Of_Failure__c=system.today(),  WOD_2__Date_Of_Repair__c=system.today()+3,WOD_2__Causal_Part_Number__c=casualPart.Id );
        claimObj.WOD_2__Claim_Status__c='Pending Payment Confirmation';
        insert claimObj;
        
        WOD_2__Transaction_Memo_History__c tmhObj = new WOD_2__Transaction_Memo_History__c(WOD_2__Claim__c=claimObj.Id,
                                                                                           WOD_2__Transaction_Status__c = 'Waiting for Payment Confirmation',
                                                                                           WOD_2__Transaction_Type__c = 'Credit');
        insert tmhObj;
    }
    
    @isTest
    private static void testCreditNotificationValidation(){
        WOD_2__Claim__c c = [select id, name,WOD_2__Claim_Status__c from WOD_2__Claim__c limit 1];
        System.debug('Claim Before CN -> ' + c);
        String jsonMsg = '{"CreditDebitNotification":[{"claim":"","transactionNumber":"","transactionDate":"2021-05-41"}]}';
        Test.startTest();
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response = sendCNRequest(jsonMsg);
        System.debug(response);
        Test.stopTest();
        System.assertEquals('Failed', response.status);
        
        //transaction number is mandatory
        String jsonMsg1 = '{"CreditDebitNotification":[{"claim":"1234","transactionNumber":""}]}';
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response1 = sendCNRequest(jsonMsg1);
        System.assertEquals('Failed', response1.status);
        
        //claim number does not exit
        String jsonMsg2 = '{"CreditDebitNotification":[{"claim":"1234","transactionNumber":"1233","transactionDate": "2021-03-40"}]}';
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response2 = sendCNRequest(jsonMsg2);
        System.assertEquals('Failed', response2.status);
        
        //failed as wrong json
        String jsonMsg3 = '{"CreditDebitNotification":[{"claim":"1234","transactionNumber":"1233","transactionDate": "2021-03-40"';
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response3 = sendCNRequest(jsonMsg3);
        System.assertEquals('Failed', response3.status);
    }
    
    @isTest
    private static void testCreditNotificationSuccess(){
        WOD_2__Claim__c claimObj = [select Id, Name,WOD_2__Claim_Status__c from WOD_2__Claim__c limit 1];
        String jsonMsg = '{"CreditDebitNotification":[{"claim":"'+claimObj.Name+'","transactionNumber":"12344","transactionStatus": "Paid","transactionDate": "2021-03-25","Comment": "Test"}]}';
        Test.startTest();
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response = sendCNRequest(jsonMsg);
        System.debug(response);
        Test.stopTest();
        claimObj = [select id, name,WOD_2__Claim_Status__c from WOD_2__Claim__c limit 1];
        WOD_2__Transaction_Memo_History__c tmh = [Select id, name,WOD_2__Amount__c,WOD_2__Claim__c,WOD_2__Settlement_Category__c,WOD_2__Transaction_Status__c,WOD_2__Transaction_Type__c
                                                                           From WOD_2__Transaction_Memo_History__c where WOD_2__Claim__c = :claimObj.Id order by createdDate desc limit 1];
        System.debug('TMH after CN -> ' + tmh);
        System.assertEquals('Paid', claimObj.WOD_2__Claim_Status__c, 'Claim status is not changed to "Paid"');
        System.assertEquals('Paid', tmh.WOD_2__Transaction_Status__c, 'TMH status is not changed to "Paid"');
    }
    
    @isTest
    private static void testCreditNotificationPartialSuccess(){
        WOD_2__Claim__c claimObj = [select Id, Name,WOD_2__Claim_Status__c from WOD_2__Claim__c limit 1];
        String jsonMsg = '{"CreditDebitNotification":[{"claim":"'+claimObj.Name+'","transactionNumber":"12344","transactionStatus": "Paid","transactionDate": "2021-03-25","Comment": "Test"},{"claim":"1234","transactionNumber":""}]}';
        Test.startTest();
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response = sendCNRequest(jsonMsg);
        System.debug(response);
        Test.stopTest();
        System.assertEquals('Partial Success', response.status);
    }
 
	private static ATI_REST_CreditDebitNotification.CreditNotificationResponse sendCNRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestCreditDebitNotification/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        ATI_REST_CreditDebitNotification.CreditNotificationResponse response = ATI_REST_CreditDebitNotification.doPost();
        System.debug('Response -> ' + response);
        return response;
    } 
}