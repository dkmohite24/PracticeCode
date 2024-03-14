/*
	Class Name	:	ATI_WarrantyRegistrationAutoApprovalTest
	Description	:	Test class for ATI_WarrantyRegistrationAutoApproval
*/
@isTest
public class ATI_WarrantyRegistrationAutoApprovalTest {
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
        accountList[1].ParentId = accountList[0].Id;
        insert accountList[1];
        
        accountList[2].Name = 'Customer Acc';
        accountList[2].Sales_RegionA__c = 'North America';
        accountList[2].SAP_ID__c = '1133446';
        accountList[2].Location_Type__c = 'L';
        accountList[2].WOD_2__Warranty_Account_Type__c='Customer';
        accountList[2].ParentId = accountList[0].Id;
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
        invList[0].WOD_2__Install_Date__c = system.today();
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].WOD_2__Units_Usage__c = 6000;
        insert invList;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(1);
        policyDefList.get(0).WOD_2__Type__c = 'Standard';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accountList[1].Id;
            wrRec.WOD_2__Customer__c = accountList[2].Id;
            wrRec.WOD_2__Status__c='In Progress';
			wrRec.ATI_Pre_Delivery__c=true;
        }
        insert wrList;
        List<WOD_2__Warranty_Coverages__c> wcList = TestDataFactory.createWarrantyCoverage(1);
        String policyType = 'Standard';
        WOD_2__Policy_Definition__c pd = [select Id, WOD_2__Months_Covered__c from WOD_2__Policy_Definition__c where WOD_2__Type__c = :policyType];
        wcList[0].WOD_2__Is_Active__c = true;
        wcList[0].WOD_2__Policy_Definition__c = pd.Id;
        wcList[0].WOD_2__Warranty_Start_Date__c = Date.today().addDays(-365);
        wcList[0].WOD_2__Warranty_End_Date__c = Date.today().addDays(365);
        wcList[0].WOD_2__Warranty_Registration__c = wrList[0].Id;
        insert wcList;
    }
    
    @isTest
    public static void WarrantyRegistrationAutoApprovalTest(){
        Test.startTest();
            List<WOD_2__Warranty_Registration__c> wrList = [SELECT id,WOD_2__Inventory__c,WOD_2__Customer__c,WOD_2__Status__c,WOD_2__Account__c,
                                                            	   WOD_2__Warranty_Start_Date__c,WOD_2__Warranty_End_Date__c,ATI_Pre_Delivery__c
                                                            FROM WOD_2__Warranty_Registration__c];
            ATI_WarrantyRegistrationAutoApproval.wrAutoApproval(wrList);
        Test.stopTest();
        System.assertEquals('Registered',[SELECT Id,WOD_2__Status__c FROM WOD_2__Warranty_Registration__c].WOD_2__Status__c,'Warranty registration should be Registered');
    }
}