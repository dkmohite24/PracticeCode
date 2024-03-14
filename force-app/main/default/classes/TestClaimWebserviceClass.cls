@IsTest
public class TestClaimWebserviceClass {
    @IsTest
    public static void WebServiceClaimMethod(){
        
         
        Account acc = new Account();
        acc.Name ='TESTACC';
        acc.SAP_ID__c ='1508767896';
        insert acc;
        
        WOD_2__Business_Category_Configuration__c bsc = new WOD_2__Business_Category_Configuration__c();
        bsc.Name = 'TestATI';
        insert bsc;
        WOD_2__Warranty_Code__c code = new WOD_2__Warranty_Code__c();
        code.Name = 'AGO3';
        insert code;
        
         WOD_2__Warranty_Product__c warranty = new WOD_2__Warranty_Product__c();
        warranty.WOD_2__Type__c = 'Item';
        warranty.WOD_2__Track_Type__c = 'Serialized';
        warranty.Name='testprod';
        warranty.External_Product_Code__c = 'testparent';
        warranty.WOD_2__Item_Type__c = 'Machine';
        insert warranty;
        
        
        WOD_2__Inventory__c inv = new WOD_2__Inventory__c();
        inv.Name = '123456';
        inv.WOD_2__Account__c = acc.id;
        inv.WOD_2__Serial_Number__c = inv.Name;
        inv.WOD_2__Business_Unit__c = bsc.id;  
        inv.WOD_2__Item__c =warranty.id;
        insert inv;
        
        WOD_2__Claim__c claim = new WOD_2__Claim__c();
        claim.WOD_2__Claim_Status__c='Submitted';
        claim.WOD_2__Claim_Type__c = 'Machine';
        claim.WOD_2__Inventory__c = inv.id;
        claim.WOD_2__Account__c = acc.id;
       
        claim.ATI_Total_Requested_Amount__c=10000.00;
        claim.ATI_Total_Approved_Amount__c =1000.00;
        claim.WOD_2__Date_Of_Failure__c = date.newInstance(2021, 01, 10);
        claim.WOD_2__Causal_Part_Number__c = warranty.id;
        claim.WOD_2__Causal_Part_Serial_Number__c = '1246';
        claim.WOD_2__Model_Number__c = warranty.id;
        claim.WOD_2__Submit_Date__c = date.newInstance(2021, 05, 06);
        claim.WOD_2__Pre_Authorization_Comments__c ='hi this is for test';
        //claim.WOD_2__Pre_Authorization_Reason__c = 'Major Parts Replacement';
        claim.WOD_2__Date_Of_Repair__c = date.newInstance(2021, 01, 20);
     
        json.serialize(claim);
        insert claim;
        
        WOD_2__Transaction_Memo_History__c memo = new WOD_2__Transaction_Memo_History__c();
        memo.Name= 'testMemo';
        memo.WOD_2__Claim__c = claim.id;
        insert memo;
        
         WOD_2__Transaction_Memo_History__c memo3 = new WOD_2__Transaction_Memo_History__c();
        memo3.Name= 'testMemo';
        memo3.WOD_2__Claim__c = claim.id;
        insert memo3;
       
        
        WOD_2__Claim__c claim2 = new WOD_2__Claim__c();
        claim2.WOD_2__Claim_Status__c='Pending Payment';
        claim2.WOD_2__Claim_Type__c = 'Machine';
        claim2.WOD_2__Inventory__c = inv.id;
        claim2.WOD_2__Account__c = acc.id;
       
        claim2.ATI_Total_Requested_Amount__c=10000.00;
        claim2.ATI_Total_Approved_Amount__c =1000.00;
        claim2.WOD_2__Date_Of_Failure__c = date.newInstance(2021, 01, 10);
        claim2.WOD_2__Causal_Part_Number__c = warranty.id;
        claim2.WOD_2__Causal_Part_Serial_Number__c = '1246';
        claim2.WOD_2__Model_Number__c = warranty.id;
        claim2.WOD_2__Submit_Date__c = date.newInstance(2021, 05, 09);
        claim2.WOD_2__Pre_Authorization_Comments__c ='hi this is for test';
        //claim.WOD_2__Pre_Authorization_Reason__c = 'Major Parts Replacement';
        claim2.WOD_2__Date_Of_Repair__c = date.newInstance(2021, 01, 20);
     
        json.serialize(claim2);
        insert claim2;
        
        WOD_2__Transaction_Memo_History__c memo2 = new WOD_2__Transaction_Memo_History__c();
        memo2.Name= 'testMemo2';
        memo2.WOD_2__Claim__c = claim2.id;
        insert memo2;
        
        
        
        
        
         RestRequest request = new RestRequest();
        
       // request.requestUri = 'https://allisontransmissionenterprise--integrasit.my.salesforce.com/services/apexrest/getClaims';
        //request.requestUri = 'https://allisontransmissionenterprise--preproduat.my.salesforce.com/services/apexrest/getClaims';
   // PROD
        request.requestUri = 'https://allisontransmissionenterprise.my.salesforce.com/services/apexrest/getClaims';


        request.addParameter('CustomerCode', '1508767896');
        request.addParameter('BeginDateRange', '05/03/2021');
        request.addParameter('EndDateRange', '05/10/2021');
    
     
        
        
        system.debug(+request.requestUri);
        request.httpMethod = 'GET';
        system.debug(+request.httpMethod );
        RestContext.request = request;
        system.debug(+RestContext.request);
        
        WebserviceClaim.fetchClaim();
        

}
}