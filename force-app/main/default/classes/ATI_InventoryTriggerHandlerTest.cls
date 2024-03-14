/* Name: ATI_InventoryTriggerHandlerTest
   Description : Test class for ATI_InventoryTriggerHandler
   Author : Tavant (Punam Chakraborty)
   History :
   VERSION     AUTHOR                          DATE               DETAIL                                    UserStory/Req#
   1.0 -       Tavant (Punam Chakraborty)   03/12/2020          INITIAL DEVELOPMENT
*/

@isTest
public with sharing class ATI_InventoryTriggerHandlerTest {
    
    /*
        Method Name :   testSetup
		Method Added By Punam
		Create all test data for test class execution. 
    */
    @testSetup
    public static void testSetup(){
		WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        //ATI_CreateDealerPublicGroupsQueueable.doChainJob = false;
        List<Account> accountList = TestDataFactory.createATIDistributorAccount(1); 
        accountList[0].WOD_2__Warranty_Account_Type__c ='Dealer';
        insert accountList; 
        //Create Group
        Group groupObj = new Group(Name='ATI_'+accountList[0].WOD_2__Warranty_Account_Type__c+'_'+accountList[0].id);
        insert groupObj;
        
        //PaymentDefinition
        List<WOD_2__Payment_Definitions__c> paymentDefLst = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefLst;
        
        List<WOD_2__Policy_Definition__c> pdList = TestDataFactory.createPolicyDefinition(2);
        for(WOD_2__Policy_Definition__c  policyDef : pdList){
            policyDef.WOD_2__Active_From__c = Date.today().addDays(-365);
            policyDef.WOD_2__Payment_Definition__c = paymentDefLst.get(0).Id;
            policyDef.WOD_2__Type__c = 'Standard';
            policyDef.WOD_2__Sub_Type__c = '01';
        }
        pdList[1].WOD_2__Type__c = 'Extended';
        //pdList[2].WOD_2__Sub_Type__c = 'Stock';
        insert pdList;
        
        List<WOD_2__Applicability_Term__c> atList = TestDataFactory.createApplicabilityTerms(1,'Inclusion');
        atList[0].WOD_2__Policy_Definition__c =pdList[0].id;
        List<WOD_2__Applicability_Criteria__c> atcList = TestDataFactory.createApplicabilityCriterias(1,atList[0]);
        atcList[0].WOD_2__Field_Path__c = 'ATI_Vocation_Code__c';
        atcList[0].WOD_2__Field_Path_Label__c = 'Vocation Code';
        atcList[0].WOD_2__Field_Type__c = 'REFERENCE';
        atcList[0].WOD_2__Operator__c = 'Is Blank';
        atcList[0].WOD_2__Value_Type__c = 'Static';
        atcList[0].WOD_2__Sequence__c = 1;
        atcList[0].WOD_2__Delimiter__c = ',';
        atcList[0].WOD_2__Display_Format__c ='String';
        //atcList[0].
        insert atcList;  
    }
    
    /*
        Method Name :   inventorySharingTest
		Method Added By Punam
		Test method for InventoryShare test class.
    */
    /*@isTest
    public static void inventorySharingTest(){
        Test.startTest();
        	WOD_2__Business_Category_Configuration__c bccConfig = [Select Id From WOD_2__Business_Category_Configuration__c limit 1];
            List<Account> accountList =[Select Id From Account limit 1]; 
        	List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
            invList[0].WOD_2__Business_Unit__c = bccConfig.Id;
            invList[0].WOD_2__Account__c = accountList[0].Id;
            insert invList;
        	//WOD_2__Inventory__Share invShareRec =[Select Id,ParentId From WOD_2__Inventory__Share limit 1];
        
        	//System.assertEquals(invShareRec.ParentId, invList[0].Id);
        Test.stopTest();
    }*/

    /*
        Method Name :   createNewWRonVacationCodeChangeTest
		Method Added By Mukesh
		Test method for createNewWRonVacationCodeChange test class.
    */
    
    
    @isTest
    public static void createNewWRonVacationCodeChangeTest(){
        Test.startTest();
        	WOD_2__Business_Category_Configuration__c bccConfig = [Select Id From WOD_2__Business_Category_Configuration__c limit 1];
            List<Account> accountList =[Select Id From Account limit 1]; 
         	List<WOD_2__Warranty_Code__c> vocationCodeList = TestDataFactory.createVocationCode(2, true);
        	List<WOD_2__Warranty_Product__c> wpList = TestDataFactory.createWarrantyProduct(3);
         	wpList[2].WOD_2__Type__c = 'Item';
        	wpList[2].WOD_2__Item_Type__c = 'Machine';
        	wpList[2].WOD_2__Track_Type__c = 'Serialized';	
        	insert wpList;
        list<RecordType> stockRecord = [SELECT id FROM RecordType WHERE RecordType.Name = 'Stock'];
        	List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        	invList[0].WOD_2__Item__c  = wpList[2].id;
        	invList[0].ATI_IsSynced__c = true;
        	invList[0].WOD_2__Type__c='Retail';
        	invList[0].recordtypeid= stockRecord[0].id;
            invList[0].WOD_2__Business_Unit__c = bccConfig.Id;
            invList[0].WOD_2__Account__c = accountList[0].Id;
            insert invList;
        	invList[0].WOD_2__Type__c='Stock';
        	update invList;
        	invList[0].WOD_2__Type__c='Retail';
        	update invList;
        	List<WOD_2__Warranty_Registration__c> WRList =TestDataFactory.createWarrantyRegistration(1);
            WRList[0].WOD_2__Inventory__c = invList[0].id;
        	WRList[0].ATI_Vocation_Code__c = vocationCodeList[0].id;
       		WRList[0].WOD_2__Registration_Type__c= 'Extended';
       		WRList[0].WOD_2__De_Registration_Reason__c='Faulty Product';
        	WRList[0].WOD_2__Status__c='Registered';
       		WRList[0].WOD_2__Units_Usage__c=40002;
        	insert WRList;
        	
        	//WOD_2__Inventory__Share invShareRec =[Select Id,ParentId From WOD_2__Inventory__Share limit 1];
        	//System.debug('>> vocationCodeList[0].id:'+);
            //System.debug('>> vocationCodeList[1].id:'+vocationCodeList[1].id);
        	//invList[0].Vocation_Code__c = vocationCodeList[1].id;
            List<WOD_2__Inventory__c> inv = [SELECT id,ATI_Vocation_Code__c,RecordTypeId 
                                       FROM WOD_2__Inventory__c WHERE id =: invList[0].id Limit 1];
        
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(invList.size());
        insert vehicleInfoLst;
        
        	List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        for(Integer i=0;i<invList.size();i++){
            ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
            vehicleTransMapper.ATI_Inventory__c = invList[i].Id;
            vehicleTransMapper.ATI_Vehicle_Information__c = vehicleInfoLst[i].id;
            vinTransmissionMapperLst.add(vehicleTransMapper);
        }
        insert vinTransmissionMapperLst;
        Map<Id,WOD_2__Inventory__c> invOldMap = new  Map<Id,WOD_2__Inventory__c>();
        for(WOD_2__Inventory__c inv123 : inv){
            invOldMap.put(inv123.Id,inv123);
        }
             ATI_InventoryTriggerHandler.updateInvOnDeRegistration(invList,invOldMap);
        	//System.assertEquals(invShareRec.ParentId, invList[0].Id);
        Test.stopTest();
    }
}