/*
	Class Name	:	ATI_WarrantyRegistrationApprovalsTest
	Description	:	Test class for ATI_WarrantyRegistrationApprovals
*/
@isTest 
public class ATI_WarrantyRegistrationApprovalsTest {
	/*
        Method Name :   setupMethod
        Description :   Method to create test data
    */
    @testSetup
    public static void testSetup(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accountList = TestDataFactory.createAccount(3); 
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
        accountList[1].WOD_2__Warranty_Account_Type__c='Dealer';
        accountList[1].ATI_Primary_Email_Id__c='test@test.com';
        accountList[1].ParentId = accountList[0].Id;
        insert accountList[1];
        
        accountList[2].Name = 'Test Customer';
        accountList[2].Sales_RegionA__c = 'North America';
        accountList[2].SAP_ID__c = '2435';
        accountList[2].Location_Type__c = 'ds';
        accountList[2].WOD_2__Warranty_Account_Type__c='Customer';
        insert accountList[2];
        
        insert new Group(Name='ATI_Warranty_Approver_'+accountList[0].Id);
        
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
        invList[0].WOD_2__Manufacturing_Date__c = system.today().addYears(-3);
        invList[0].WOD_2__Install_Date__c = system.today();
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].WOD_2__Units_Usage__c = 6000;
        insert invList;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accountList[1].Id;
            wrRec.WOD_2__Status__c='In Progress';
            wrRec.WOD_2__Customer__c = accountList[2].Id;
        }
        insert wrList;
        List<WOD_2__Transaction_Memo_History__c> tmhLst = TestDataFactory.createTransactionMemo(1);
       // tmhLst[0].WOD_2__Claim__c = claim.id;
        tmhLst[0].WOD_2__Transaction_Status__c = 'Pending';
       // tmhLst[0].ATI_Type__c = 'Claim';
        tmhLst[0].WOD_2__Transaction_Type__c = 'Credit';
        insert tmhLst;
    }
    
     @isTest
    public static void WarrantyRegistrationApprovalsTest(){
        Test.startTest();
            List<WOD_2__Warranty_Registration__c> wrList = [SELECT id,WOD_2__Inventory__c,WOD_2__Customer__c,WOD_2__Status__c,WOD_2__Account__c,ATI_Pre_Delivery__c FROM WOD_2__Warranty_Registration__c];
            ATI_WarrantyRegistrationApprovals.wrAutoManualApproval(wrList);
        Test.stopTest();
        //WOD_2__Warranty_Registration__Share wrShareRec = [SELECT Id,ParentId,UserOrGroupId,RowCause FROM WOD_2__Warranty_Registration__Share LIMIT 1];
       /* System.assertEquals(1,[SELECT Id FROM WOD_2__Warranty_Registration__Share 
                               WHERE ParentId=:wrList[0].Id AND RowCause='Manual'].size(),
                              'Warranty registration should be shared to Warranty approver group');*/
    }
    
    @isTest
    private static void testUpdateINVAndWR(){
        Test.startTest();
            List<WOD_2__Warranty_Registration__c> wrList1 = [SELECT id,WOD_2__Inventory__c,WOD_2__Customer__c,WOD_2__Status__c,WOD_2__Account__c FROM WOD_2__Warranty_Registration__c];
            ATI_WarrantyRegistrationApprovals.updateWRANDINV('Approve',wrList1[0].Id,'approving by distributor','');
        	System.assertEquals('Registered',[SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c].WOD_2__Status__c,'It should be Pending Claim Processor Approval');
        	
        	delete [SELECT Id FROM WOD_2__Warranty_Registration__c];
        	Account accObj = [SELECT Id FROM Account WHERE SAP_ID__c = '1133445'];
        	Account custObj = [SELECT Id FROM Account WHERE SAP_ID__c = '2435'];
        	WOD_2__Inventory__c invObj = [SELECT Id FROM WOD_2__Inventory__c LIMIT 1];
            List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        	wrList[0].WOD_2__Inventory__c=invObj.Id;
            wrList[0].WOD_2__Account__c = accObj.Id;
            wrList[0].WOD_2__Status__c='In Progress';
            wrList[0].WOD_2__Customer__c = custObj.Id;
        	wrList[0].ATI_Pre_Delivery__c = true;
            wrList[0].WOD_2__Units_Usage__c = 6000;
        	wrList[0].WOD_2__Registration_Date__c = system.today();
        	insert wrList;
        	ATI_WarrantyRegistrationApprovals.updateWRANDINV('Reject',wrList[0].Id,'Rejecting','7143');
        	System.assertEquals('Rejected',[SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c WHERE Id=:wrList[0].Id].WOD_2__Status__c,'It should be Rejected');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetWRForApprovalAndCheckEditAccess(){ 
        Test.startTest();
        	List<WOD_2__Warranty_Registration__c> wrList1 = [SELECT id,WOD_2__Inventory__c,WOD_2__Customer__c,WOD_2__Status__c,WOD_2__Account__c FROM WOD_2__Warranty_Registration__c];
        	ATI_WarrantyRegistrationApprovals.getWRForApprovalAndCheckEditAccess(wrList1[0].WOD_2__Inventory__c,'WOD_2__Inventory__c');
        
        	Account accObj = [SELECT Id FROM Account WHERE SAP_ID__c = '1133445'];
        	Account custObj = [SELECT Id FROM Account WHERE SAP_ID__c = '2435'];
        	WOD_2__Inventory__c invObj = [SELECT Id FROM WOD_2__Inventory__c LIMIT 1];
            List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        	wrList[0].WOD_2__Inventory__c=invObj.Id;
            wrList[0].WOD_2__Account__c = accObj.Id;
            wrList[0].WOD_2__Status__c='In Progress';
            wrList[0].WOD_2__Customer__c = custObj.Id;
        	wrList[0].ATI_Pre_Delivery__c = true;
            wrList[0].WOD_2__Units_Usage__c = 6000;
        	wrList[0].ATI_isExtended__c = true;
        	wrList[0].WOD_2__Registration_Date__c = system.today();
        	insert wrList;
        System.debug('wrList------->'+[SELECT id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c WHERE Id=:wrList[0].Id]);
            WOD_2.ResponseWrapper response = ATI_WarrantyRegistrationApprovals.getWRForApprovalAndCheckEditAccess(wrList[0].WOD_2__Inventory__c,'WOD_2__Inventory__c');
        	ATI_WarrantyRegistrationApprovals.getWRForApprovalAndCheckEditAccess(wrList[0].Id,'WOD_2__Warranty_Registration__c');
        	System.assertEquals(true,response.status,'Access should be there');
       Test.stopTest();
    }
}