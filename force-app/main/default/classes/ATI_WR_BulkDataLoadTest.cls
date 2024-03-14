/* Name: ATI_WR_BulkDataLoadTest
Description : ATI_WR_BulkDataLoadTest - test class for ATI_WR_BulkDataLoad
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      19-APR-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_WR_BulkDataLoadTest {
    
    @testSetup
    public static void testSetup(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<WOD_2__Business_Category_Configuration_Setting__c> bccsList = TestDataFactory.createBccs(bcc);
        insert bccsList;
        List<Account> accList = TestDataFactory.createAccount(2);
        accList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        accList[1].WOD_2__Warranty_Account_Type__c = 'Customer';
        insert accList;
        
        //Warranty Product at Model Level for Extended Warranty Pricing
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(1);
        for(Integer i=0;i<warrantyProLst.size();i++){
            warrantyProLst[i].External_Product_Code__c = 'TESTCODE'+i;
            warrantyProLst[i].WOD_2__Type__c = 'Item';
            warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
            warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProLst;
        
        //Vocation Code 
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createVocationCode(1,false);
        insert wcLst;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(10);
        for(WOD_2__Inventory__c inv : invList){
            inv.WOD_2__Business_Unit__c = bcc.Id;
            inv.WOD_2__Account__c = accList[0].Id;
            inv.WOD_2__Customer__c = accList[1].Id;
            inv.WOD_2__Install_Date__c = system.today();
            inv.WOD_2__Item__c = warrantyProLst[0].Id;
            inv.WOD_2__Units_Usage__c = 100;
        }
        insert invList;
        
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(3);
        policyDefList.get(0).Name = 'Standard Policy';
        policyDefList.get(0).WOD_2__Type__c = 'Standard';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        policyDefList.get(1).WOD_2__Type__c = 'Standard';
        policyDefList.get(1).Name = 'Pre-Delivery Policy';
        policyDefList.get(1).WOD_2__Sub_Type__c = '01';
        policyDefList.get(1).WOD_2__Months_Covered__c = null;
        policyDefList.get(1).WOD_2__Days_Covered__c = 30;
        policyDefList.get(1).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        policyDefList.get(2).WOD_2__Type__c = 'Extended';
        policyDefList.get(2).Name = 'Extended Policy';
        policyDefList.get(2).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        policyDefList.get(2).WOD_2__Months_Covered__c = 24;
        insert policyDefList;
        
        //ApplicabilityTerms
        List<WOD_2__Applicability_Term__c> applicabilityTermsLst = TestDataFactory.createApplicabilityTerms(3,'Inclusion');
        applicabilityTermsLst[0].WOD_2__Policy_Definition__c = policyDefList[0].Id;
        applicabilityTermsLst[0].WOD_2__Logical_Grouping__c = '1';
        applicabilityTermsLst[1].WOD_2__Policy_Definition__c = policyDefList[1].Id;
        applicabilityTermsLst[1].WOD_2__Logical_Grouping__c = '1';
        applicabilityTermsLst[2].WOD_2__Policy_Definition__c = policyDefList[2].Id;
        applicabilityTermsLst[2].WOD_2__Logical_Grouping__c = '1';
		insert applicabilityTermsLst;
        
        //Standard ApplicabilityCriterias
        List<WOD_2__Applicability_Criteria__c> standardCriteriaLst = TestDataFactory.createApplicabilityCriterias(2,applicabilityTermsLst.get(0));
        standardCriteriaLst[0].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        standardCriteriaLst[0].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        standardCriteriaLst[0].WOD_2__Field_Type__c = 'BOOLEAN';
        standardCriteriaLst[0].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[0].WOD_2__Criteria_Value__c =  'FALSE';
        standardCriteriaLst[0].WOD_2__Sequence__c = 1;
        standardCriteriaLst[1].WOD_2__Field_Path_Label__c ='Pre-Delivery';
        standardCriteriaLst[1].WOD_2__Field_Path__c = 'ATI_Pre_Delivery__c';
        standardCriteriaLst[1].WOD_2__Field_Type__c = 'BOOLEAN';
        standardCriteriaLst[1].WOD_2__Operator__c = 'EQUALS';
        standardCriteriaLst[1].WOD_2__Criteria_Value__c =  'TRUE';
        standardCriteriaLst[1].WOD_2__Sequence__c = 1;
        standardCriteriaLst[1].WOD_2__Applicability_Term__c = applicabilityTermsLst.get(1).Id;
        insert standardCriteriaLst;
        
    }
    
    @isTest
    static void testBulk(){
        List<WOD_2__Inventory__c> invList = [select WOD_2__Serial_Number__c from WOD_2__Inventory__c];
        List<STG_WR_Load__c> stgList = new List<STG_WR_Load__c>();
        Integer i = 0;
        for(WOD_2__Inventory__c inv : invList){
        	STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c=inv.WOD_2__Serial_Number__c,Status__c='New',Pre_Delivery__c=true,Ext_Warranty_Policy_Name__c='');
            stgList.add(stgWR);
        }
        insert stgList;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad(),10);
        Test.stopTest();
        /*stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.assertEquals(true, stgWR.Status__c == 'Failed', 'Status is not failed !!!');
        System.assertEquals(false, String.isBlank(stgWR.Failure_Message__c), 'Failure Message is blank!!!');*/
    }
    

    @isTest
    static void testValidations1(){
        STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c='',Status__c='New',Pre_Delivery__c=true,Ext_Warranty_Policy_Name__c='');
        insert stgWR;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad());
        Test.stopTest();
        stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.assertEquals(true, stgWR.Status__c == 'Failed', 'Status is not failed !!!');
        System.assertEquals(false, String.isBlank(stgWR.Failure_Message__c), 'Failure Message is blank!!!');
    }
 
    @isTest
    static void testValidations2(){
        STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c='Test',Status__c='New',Pre_Delivery__c=true,Ext_Warranty_Policy_Name__c='Test Policy');
        insert stgWR;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad());
        Test.stopTest();
        stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.assertEquals(true, stgWR.Status__c == 'Failed', 'Status is not failed !!!');
        System.assertEquals(false, String.isBlank(stgWR.Failure_Message__c), 'Failure Message is blank!!!');
    }

    @isTest
    static void testValidations3(){
        WOD_2__Inventory__c inv = [select WOD_2__Serial_Number__c from WOD_2__Inventory__c][0];
        STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c=inv.WOD_2__Serial_Number__c,Status__c='New',Pre_Delivery__c=false,Ext_Warranty_Policy_Name__c='Ext');
        insert stgWR;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad());
        Test.stopTest();
        stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.assertEquals(true, stgWR.Status__c == 'Failed', 'Status is not failed !!!');
        System.assertEquals(false, String.isBlank(stgWR.Failure_Message__c), 'Failure Message is blank!!!');
    }
    
  
    @isTest
    static void testForPreDeliveryRegistration(){
        WOD_2__Inventory__c inv = [select WOD_2__Serial_Number__c from WOD_2__Inventory__c][0];
        STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c=inv.WOD_2__Serial_Number__c,Status__c='New',Pre_Delivery__c=true,Ext_Warranty_Policy_Name__c='');
        insert stgWR;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad());
        Test.stopTest();
        stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.debug('Staging Record -> ' + stgWR);
        System.assertEquals(true, stgWR.Status__c == 'Success', 'Status is not Success !!!');
        WOD_2__Warranty_Registration__c wr = [select id, WOD_2__Registration_Type__c, (select id, Name,WOD_2__Policy_Definition__r.Name from WOD_2__Warranty_Coverages__r) from WOD_2__Warranty_Registration__c];
        system.debug('WR -> ' + wr);
        System.assertEquals('Pre-delivery', wr.WOD_2__Registration_Type__c, 'Pre-delivery registration is not done !!!');
        System.assertEquals('Pre-Delivery Policy', wr.WOD_2__Warranty_Coverages__r[0].WOD_2__Policy_Definition__r.Name, 'Pre-delivery policy is not picked !!!');
    }

    @isTest
    static void testForStdWarrantyRegistration(){
        WOD_2__Inventory__c inv = [select WOD_2__Serial_Number__c from WOD_2__Inventory__c][0];
        WOD_2__Policy_Definition__c p = [select Name from WOD_2__Policy_Definition__c where WOD_2__Type__c = 'Extended'];
        STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c=inv.WOD_2__Serial_Number__c,Status__c='New',Pre_Delivery__c=false,Ext_Warranty_Policy_Name__c='');
        insert stgWR;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad());
        Test.stopTest();
        stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.debug('Staging Record -> ' + stgWR);
        System.assertEquals(true, stgWR.Status__c == 'Success', 'Status is not Success !!!');
        WOD_2__Warranty_Registration__c wr = [select id, WOD_2__Registration_Type__c,ATI_isExtended__c, (select id, Name,WOD_2__Policy_Definition__r.Name from WOD_2__Warranty_Coverages__r) from WOD_2__Warranty_Registration__c];
        system.debug('WR -> ' + wr);
        System.assertEquals('Standard Registration', wr.WOD_2__Registration_Type__c, 'Standard Registration is not done !!!');
        System.assertEquals(false, wr.ATI_isExtended__c, 'Is Extended Flag is not set !!!');
        System.assertEquals(1, wr.WOD_2__Warranty_Coverages__r.size(), 'Invalid Policy Count !!!');
        System.assertEquals('Standard Policy', wr.WOD_2__Warranty_Coverages__r[0].WOD_2__Policy_Definition__r.Name, 'STandard policy is not picked !!!');
    }
    
    
    
    @isTest
    static void testForExtWarrantyRegistration(){
        WOD_2__Inventory__c inv = [select WOD_2__Serial_Number__c from WOD_2__Inventory__c][0];
        WOD_2__Policy_Definition__c p = [select Name from WOD_2__Policy_Definition__c where WOD_2__Type__c = 'Extended'];
        STG_WR_Load__c stgWR = new STG_WR_Load__c(Serial_Number__c=inv.WOD_2__Serial_Number__c,Status__c='New',Pre_Delivery__c=false,Ext_Warranty_Policy_Name__c=p.Name);
        insert stgWR;
        Test.startTest();
        Database.executeBatch(new ATI_WR_BulkDataLoad());
        Test.stopTest();
        stgWR = [select Id, Serial_Number__c, Status__c, Pre_Delivery__c, Ext_Warranty_Policy_Name__c, Failure_Message__c from STG_WR_Load__c];
        System.debug('Staging Record -> ' + stgWR);
        System.assertEquals(true, stgWR.Status__c == 'Success', 'Status is not Success !!!');
        WOD_2__Warranty_Registration__c wr = [select id, WOD_2__Registration_Type__c,ATI_isExtended__c, (select id, Name,WOD_2__Policy_Definition__r.Name from WOD_2__Warranty_Coverages__r) from WOD_2__Warranty_Registration__c];
        system.debug('WR -> ' + wr);
        System.assertEquals('Standard Registration', wr.WOD_2__Registration_Type__c, 'Standard Registration is not done !!!');
        System.assertEquals(true, wr.ATI_isExtended__c, 'Is Extended Flag is not set !!!');
        System.assertEquals(2, wr.WOD_2__Warranty_Coverages__r.size(), 'Invalid Policy Count !!!');
        System.assertEquals('Standard Policy', wr.WOD_2__Warranty_Coverages__r[0].WOD_2__Policy_Definition__r.Name, 'STandard policy is not picked !!!');
        System.assertEquals('Extended Policy', wr.WOD_2__Warranty_Coverages__r[1].WOD_2__Policy_Definition__r.Name, 'Extended policy is not picked !!!');
    }
  
    

}