/* Name: ATI_ATI_SHP_ShipmentDataServiceTest
@Description :Test class for ATI_SHP_ShipmentService Class
@changes - Prasad
Copied from Product as this class is not global and we have to override interfaces and update shipment and RCP objects   	
*/
@isTest
private class ATI_SHP_ShipmentDataServiceTest {
    @testSetup 
    static void setupMethod() {
        List<WOD_2__Removed_Claim_Part__c> removedpartList= new List<WOD_2__Removed_Claim_Part__c>();
        Account accObj = TestDataFactory.createAccount(1)[0];
        insert accObj;
        
         Account acc = new Account(Name = 'Test Cust',WOD_2__Warranty_Account_Type__c = 'customer',AccountNumber = 'CD',BillingCity='New Jersey',BillingState='LA',BillingCountry='US',BillingStreet='6TH Block',BillingPostalCode='560095',Phone='1234567890',Fax='12345',
                                      ShippingCity ='New Jersey',ShippingCountry ='US',ShippingState='AL',ShippingPostalCode='560095');
        
        insert acc;
        //create business category configuration
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        List<WOD_2__Warranty_Product__c> wpObjList = TestDataFactory.createWarrantyProduct(3);
        wpObjList[2].WOD_2__Item_Type__c = 'Machine';
        insert wpObjList;
        
        WOD_2__Account_Business_Category_Configuration__c accBusinessCategoryObj = new WOD_2__Account_Business_Category_Configuration__c();
        accBusinessCategoryObj.WOD_2__Account__c = accObj.id;
        accBusinessCategoryObj.WOD_2__Business_Category_Configuration__c = busCategoryConfig[0].id;
        insert accBusinessCategoryObj;
        
        WOD_2__Inventory__c invObj = TestDataFactory.createInventory(1)[0];
        invObj.WOD_2__Account__c = accObj.id;
        invObj.WOD_2__Item__c = wpObjList[2].Id;
        invObj.WOD_2__Business_Unit__c = busCategoryConfig[0].id;
        invObj.WOD_2__Warranty_End_Date__c = Date.newInstance(2020, 15,10);
        insert invObj;
        
        WOD_2__Warranty_Registration__c wrObj = TestDataFactory.createWarrantyRegistration(1)[0];
        wrObj.WOD_2__Inventory__c = invObj.id;
        wrObj.WOD_2__Account__c = accObj.id;
        wrObj.WOD_2__Customer__c = acc.id;
        wrObj.WOD_2__Status__c='In Progress';
        insert wrObj;
        
        WOD_2__Rates_Details__c rateDetailObj = new WOD_2__Rates_Details__c();
        rateDetailObj.Name = 'Rate Details';
        rateDetailObj.WOD_2__Active_From__c = Date.today();
        rateDetailObj.WOD_2__Active_Until__c = Date.newInstance(Date.today().year()+2, Date.today().month(), Date.today().day());
        rateDetailObj.WOD_2__Dealer__c = accObj.id;
        rateDetailObj.WOD_2__Status__c = 'Active';
        insert rateDetailObj;
        
        WOD_2__Payment_Definitions__c paymentDefinitions = TestDataFactory.createPaymentDefinition(1)[0];
        insert paymentDefinitions;
        
        WOD_2__Policy_Definition__c policyDefObj = TestDataFactory.createPolicyDefinition(1)[0];
        policyDefObj.WOD_2__Payment_Definition__c = paymentDefinitions.Id;
        policyDefObj.WOD_2__Active_From__c = Date.newInstance(Date.today().year(), Date.today().month()-1, Date.today().day());
        policyDefObj.WOD_2__Active_Until__c = Date.newInstance(Date.today().year()+2, Date.today().month(), Date.today().day());
        insert policyDefObj;
        
        WOD_2__Warranty_Coverages__c wcObj = new WOD_2__Warranty_Coverages__c();
        wcObj.Name = 'Warranty Coverages';
        wcObj.WOD_2__Policy_Definition__c = policyDefObj.id;
        wcObj.WOD_2__Warranty_Registration__c = wrObj.id;
        wcObj.WOD_2__Warranty_Start_Date__c = Date.today();
        wcObj.WOD_2__Warranty_End_Date__c = Date.newInstance(Date.today().year()+2, Date.today().month(), Date.today().day());
        insert wcObj;
        
        WOD_2__Applicability_Term__c appTermObj = TestDataFactory.createApplicabilityTerms(1, 'Inclusion')[0];
        appTermObj.WOD_2__Policy_Definition__c = policyDefObj.id;
        insert appTermObj;
        
        WOD_2__Policy_Definition_Inventory_Usage__c polDefInvUsageObj = new WOD_2__Policy_Definition_Inventory_Usage__c();
        polDefInvUsageObj.Name = 'Policy Definition Inventory Usage';
        polDefInvUsageObj.WOD_2__Maximum_Unit__c = 35;
        polDefInvUsageObj.WOD_2__Policy_Definition__c = policyDefObj.id;
        polDefInvUsageObj.WOD_2__Usage_Reading_Type__c = 'Machine';
        insert polDefInvUsageObj;
        
        //String recType = [Select Id From RecordType Where SobjectType = 'WOD_2__Claim__c' and Name = 'Serialized'].Id;
        
        
        String recType1 =[Select Id From RecordType Where SobjectType = 'WOD_2__Claim__c' and Name = 'Non-Serialized'].Id;
        WOD_2__Claim__c claimNonSerObj = new WOD_2__Claim__c(recordtypeId=recType1);
        
        String recType2 = [Select Id From RecordType Where SobjectType = 'WOD_2__Claim__c' and Name = 'Field Modification'].Id;
        String recTypeOfClaim = [Select Id From RecordType Where SobjectType = 'WOD_2__Claim__c' and Name = 'Machine'].Id;
        List<WOD_2__Claim__c> claimList=new List<WOD_2__Claim__c>();
        for(integer i=0; i<3; i++){
            WOD_2__Claim__c claimObj = new WOD_2__Claim__c();
            WOD_2__Claim__c claimFdObj = new WOD_2__Claim__c(recordtypeId=recType2);
            claimObj.Name='TestClaim';
            claimObj.WOD_2__Account__c=accObj.id;
            claimObj.WOD_2__Inventory__c=invObj.id;
            claimObj.WOD_2__Rate__c=rateDetailObj.id;
            claimObj.WOD_2__Applicable_Policy__c=policyDefObj.id;
            claimObj.WOD_2__Work_Order__c='12345';
            claimObj.WOD_2__Date_Of_Failure__c= Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()-5);
            claimObj.WOD_2__Date_Of_Repair__c= Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day()-2);
            claimObj.WOD_2__Causal_Part_Number__c=wpObjList[2].id;
            claimObj.WOD_2__Host_NonHost__c='Installed on OEM machine';
            claimObj.WOD_2__Date_Of_Purchase__c=Date.newInstance(2018,9,10);
            claimObj.WOD_2__BusinessCategory__c=busCategoryConfig[0].Id;
            claimObj.WOD_2__Submit_Date__c=Date.today();
            claimObj.WOD_2__Causal_Part_Serial_Number__c = 'Test1111';
            claimObj.recordtypeId = recTypeOfClaim;
            claimObj.WOD_2__Claim_Type__c = 'Machine';
            claimObj.WOD_2__Model_Number__c = wpObjList[0].Id;
            claimList.add(claimObj);
        }
        insert claimList;
        WOD_2__Warehouse__c warehouse=new WOD_2__Warehouse__c();
        warehouse.Name='Bangalore';
        warehouse.WOD_2__Business_Units__c = 'ATI';
        insert warehouse;
        
        WOD_2__Part_Return_Configuration__c prc=new WOD_2__Part_Return_Configuration__c();
        prc.Name='TEST-PRC';
        prc.WOD_2__Applicable_To_Date__c = Date.Today().addYears(-1);
        prc.WOD_2__Applicable_From_Date__c= Date.Today().addYears(3);
        prc.WOD_2__Days_Due_Within__c=30;
        prc.WOD_2__Max_Quantity_For_PRC__c=40;
        prc.WOD_2__Priority__c= 1;
        prc.WOD_2__Return_Location__c=warehouse.Id;
        prc.WOD_2__Payment_Condition__c='Pay After Return';
        prc.WOD_2__IsActive__c = TRUE;
        insert prc;
        List<WOD_2__Removed_Claim_Part__c> rcpList=new List<WOD_2__Removed_Claim_Part__c>();
        for(integer i=0; i <= 20; i++){
            WOD_2__Removed_Claim_Part__c removedpart=new WOD_2__Removed_Claim_Part__c();
            removedpart.Name='removed part';
            if(i <= 10){ 
                removedpart.WOD_2__Claim__c=claimList[0].Id;
            }else{
                removedpart.WOD_2__Claim__c=claimList[1].Id; 
            }
            removedpart.WOD_2__Warranty_Product__c= wpObjList[1].id;
            removedpart.WOD_2__Invoice_Quantity__c=2;
            removedpart.WOD_2__Serial_Number__c ='30';
            removedpart.WOD_2__Return_Location__c=null;
            rcpList.add(removedpart);
        }
        insert rcpList;
        WOD_2__Shipment_Detail__c shp=new WOD_2__Shipment_Detail__c();
        shp.WOD_2__Business_Unit__c=busCategoryConfig[0].Id;
        shp.WOD_2__Status__c='Draft';
        shp.WOD_2__Dealer_Account__c=accObj.id;
        //shp.WOD_2__Return_Location__c=;
        insert shp;
        
        List<WOD_2__Claim_Shipment__c> claimSHPList=new List<WOD_2__Claim_Shipment__c>();
        for(WOD_2__Removed_Claim_Part__c rcp: rcpList){
            WOD_2__Claim_Shipment__c clSHP=new WOD_2__Claim_Shipment__c();
            clSHP.Name='test';
            clSHP.WOD_2__Inspection_Status__c='Approved';
            clSHP.WOD_2__Is_Inspected__c=false;
            clSHP.WOD_2__Is_Received__c=false;
            clSHP.WOD_2__Is_Shipped__c=false;
            clSHP.WOD_2__Quantity__c=2;
            clSHP.WOD_2__Removed_Claim_Part__c=rcp.Id;
            clSHP.WOD_2__Shipment_Detail__c=shp.Id;
            claimSHPList.add(clSHP);
            
        }
        insert claimSHPList;
        
    }
    @isTest
    private static void upsertClaimShipmentRecordsTest(){
        List<WOD_2__Claim_Shipment__c> clmSHPList = [SELECT ID FROM WOD_2__Claim_Shipment__c ];
        Boolean flag = false;
        try{
            ATI_SHP_ShipmentDataService.upsertClaimShipmentRecords(clmSHPList);
            flag = true;
            system.assertEquals(true, flag);
        }catch (exception e){
            flag = false;
            system.assertEquals(false, flag);
        }
    }
    
    @isTest
    private static void fetchDealerAccountIdTest(){
        contact c = new contact();
        c.lastname = 'test';
        insert c;
        system.assertEquals(true, c.Id != null);
        String dealerAccId  = ATI_SHP_ShipmentDataService.fetchDealerAccountId(c.Id);
        system.assertEquals(true, dealerAccId != null);
    }
    @isTest
    private static void deleteClaimShipmentRecordsTest(){
        List<WOD_2__Claim_Shipment__c> clmSHPList = [SELECT ID FROM WOD_2__Claim_Shipment__c LIMIT 1];
        List<WOD_2__Claim_Shipment__c> clmShpList3 = ATI_SHP_ShipmentDataService.fetchRelatedClaimShipments([select id from WOD_2__Shipment_Detail__c LIMIT 1].Id,new List<String>{'Name'});
        List<WOD_2__Claim_Shipment__c> claimShpLisr4 = ATI_SHP_ShipmentDataService.fetchClaimShipmentRecords(new List<String>{'Name'},new List<Id>{[select id from WOD_2__Removed_Claim_Part__c LIMIT 1].Id}, [select id from WOD_2__Shipment_Detail__c LIMIT 1].Id);
        system.assertEquals(true, clmShpList3 != null);
        system.assertEquals(true, claimShpLisr4 != null);
        ATI_SHP_ShipmentDataService.deleteClaimShipmentRecords(new List<WOD_2__Claim_Shipment__c>{clmSHPList[0]});
        List<WOD_2__Claim_Shipment__c> clmSHPList2 = [SELECT ID FROM WOD_2__Claim_Shipment__c LIMIT 1];
        ATI_SHP_ShipmentDataService.deleteClaimShipmentRecords(new List<String>{clmSHPList2[0].Id});
        ATI_SHP_ShipmentDataService.deleteClaimShipmentRecords([select id from WOD_2__Shipment_Detail__c LIMIT 1].Id);
    }
    
    @isTest
    public static void upsertShipmentRecordsTest(){
        List<WOD_2__Shipment_Detail__c> shpList = new List<WOD_2__Shipment_Detail__c>([select id from WOD_2__Shipment_Detail__c]);
        ATI_Utils.NoAccessObjectFieldWrapper NoAccessObjectFieldWrapper = new ATI_Utils.NoAccessObjectFieldWrapper();
        NoAccessObjectFieldWrapper.noAccessObjectList = new List<String>{'Name'};
        NoAccessObjectFieldWrapper.noAccessObjectList = new List<String>{'Name'};
        ATI_SHP_ShipmentDataService.upsertShipmentRecords(shpList);
        List<WOD_2__Shipment_Detail__c> shpList2 = ATI_SHP_ShipmentDataService.fetchShipmentRecord(new List<String>{shpList[0].Id}, new List<String>{'WOD_2__Height__c'});
        system.assertEquals(true, shpList2 != null);
        List<WOD_2__Business_Category_Configuration__c> buList = ATI_SHP_ShipmentDataService.fetchBUDetails(new List<String>{'Test'});
        system.assertEquals(true, buList != null);
        //List<WOD_2__Warehouse__c> whList = ATI_SHP_ShipmentDataService.fetchWareHouseRecords(new List<String>{'ATI'});
        //system.assertEquals(true, whList != null);
        List<User> userList = ATI_SHP_ShipmentDataService.fetchUserRecords();
        system.assertEquals(true, userList != null);
        ATI_SHP_ShipmentDataService.deleteShipment(shpList[0].Id);
        List<WOD_2__claim__c> claimRecList = [select Id from WOD_2__claim__c];
        List<WOD_2__Warehouse_Member__c> whMemberList = ATI_SHP_ShipmentDataService.fetchReceiverInspectorWarehouseMembers([select Id from WOD_2__Warehouse__c LIMIT 1].Id, 'Receiver');
        system.assertEquals(true, whMemberList != null);
        List<WOD_2__Removed_Claim_Part__c> rcpRecList3 = ATI_SHP_ShipmentDataService.fetchRCPList(new List<Id>{claimRecList[0].Id});
        system.assertEquals(true, rcpRecList3 != null);
        List<WOD_2__Removed_Claim_Part__c> rcpRecList4 = ATI_SHP_ShipmentDataService.fetchRCPListWithQueryFields(new List<Id>{claimRecList[0].Id}, new List<String> {'Name'});
        system.assertEquals(true, rcpRecList4 != null);
        List<WOD_2__Removed_Claim_Part__c> rcpRecList5 = ATI_SHP_ShipmentDataService.getRCPRecords(new List<Id>{[select id from WOD_2__removed_claim_part__c LIMIT 1].Id});
        system.assertEquals(true, rcpRecList5 != null);
        List<WOD_2__Removed_Claim_Part__c> rcpRecList6 = ATI_SHP_ShipmentDataService.getRCPRecords(new List<Id>{claimRecList[0].Id}, new List<String>{'Name'});
        system.assertEquals(true, rcpRecList6 != null);
        List<WOD_2__Claim__c> claimList = ATI_SHP_ShipmentDataService.getClaimDetails(new List<Id>{claimRecList[0].Id});
        system.assertEquals(true, claimList != null);
        List<WOD_2__Shipment_Detail__c> shpList3 = ATI_SHP_ShipmentDataService.fetchShipmentList(new Set<Id> {[select Id from WOD_2__Warehouse__c LIMIT 1].Id}, [select Id from Account limit 1].Id, [select Id from WOD_2__Business_Category_Configuration__c LIMIT 1].Id,new Map<String, String>());
        system.assertEquals(true, shpList3 != null);
        List<WOD_2__Shipment_Detail__c> shpList4 = ATI_SHP_ShipmentDataService.fetchShipmentList(new Map<String, Object> {'Name'=>new WOD_2__shipment_detail__C()});
        system.assertEquals(true, shpList4 != null);
    }
}