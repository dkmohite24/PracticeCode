/* Name: ATI_REST_SerialNumberSyncTest
Description : Test Class for ATI_REST_SerialNumberSync,ATI_REST_SerialNumberValidator, ATI_REST_SerialNumberRequest
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE              DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)        22/01/2021        INITIAL DEVELOPMENT                           
*/
@isTest
public class ATI_REST_SerialNumberSyncTest {

    @testSetup
    public static void testSetup(){
        //Distributor Account
        List<Account> distributorAccount = TestDataFactory.createATIDistributorAccount(1);
        insert distributorAccount;
		
        //Create BCC
        List<WOD_2__Business_Category_Configuration__c> busCategoryConfig = TestDataFactory.createBusinessCategoryConfiguration(1);
        insert busCategoryConfig;
        
        String recordId = Schema.SObjectType.WOD_2__Business_Category_Configuration_Setting__c.getRecordTypeInfosByName().get('Configuration').getRecordTypeId();
        
        //Create BCCS
        WOD_2__Business_Category_Configuration_Setting__c bccs = new WOD_2__Business_Category_Configuration_Setting__c();
        bccs.WOD_2__Business_Category_Configuration__c = busCategoryConfig.get(0).id;
        bccs.recordtypeId = recordId;
        bccs.Name = 'ATI_InventorySyncAccountLookup';
        bccs.WOD_2__Unique_Rule_Name__c='ATI_InventorySyncAccountLookup';
        bccs.WOD_2__Value__c = distributorAccount.get(0).id;
        bccs.WOD_2__isActive__c = TRUE;
        bccs.WOD_2__Rule_Object__c='WOD_2__Inventory__c';
        bccs.WOD_2__Module__c='Inventory';
        bccs.WOD_2__Sub_Module__c='Inventory Information';
        insert bccs;
		

        //Create WarrantyProduct
         List<WOD_2__Warranty_Product__c> wpLst = TestDataFactory.createWarrantyProduct(3);
         insert wpLst;

        //Create Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(1,'Stock');
        invLst.get(0).WOD_2__Item__c = wpLst.get(2).Id;
        invLst.get(0).WOD_2__Business_Unit__c = busCategoryConfig.get(0).Id;
        invLst.get(0).WOD_2__Account__c = distributorAccount.get(0).Id;
		insert invLst;
        
        
        //Create VehicleInformation
        List<ATI_Vehicle_Information__c> vehicleInfoLst = TestDataFactory.createVehicleInformation(1);
        vehicleInfoLst.get(0).Name = '1J4GL58K96W180703';
        insert vehicleInfoLst;
        
		//Create VehicleTransMapper
        List<ATI_VIN_Transmission_Mapper__c> vehicleTransMapperLst = TestDataFactory.createVinMappers(1,vehicleInfoLst.get(0).id);
        vehicleTransMapperLst[0].ATI_Inventory__c = invLst.get(0).Id;
        insert vehicleTransMapperLst;
        
        //Create MajorComponent
        List<WOD_2__Major_Component__c> majorCmpLst = TestDataFactory.createMajorComp(1);
        majorCmpLst.get(0).WOD_2__Serial_number__c = 'BK5536N19260014E';
        majorCmpLst.get(0).ATI_Type__c = 'ECU';
        insert majorCmpLst;
    }

    @isTest
    private static void testForInventoryInsertion(){
        Account acc = [SELECT Id,SAP_ID__c FROM Account];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonArray = '{"Inventory":[{"SerialNumber":"63118750221","Item":"'+wp.Name+'","Egcn":"G01232","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 0","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"1"}]}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
       // System.assertEquals('Success', response.status, 'All the records have been inserted successfully...!!!');
        List<WOD_2__Inventory__c> inv = [SELECT Id,Name FROM WOD_2__Inventory__c WHERE Name='63118750221'];
        //System.assertEquals(1,inv.size(),'Number Of inventories are Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of Inventories Passed in Request');
        //System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
        //System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForInventoryAndMCInsertionBulk(){
        Account acc = [SELECT Id,SAP_ID__c FROM Account];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        WOD_2__Inventory__c inv = [SELECT Id FROM WOD_2__Inventory__c];
        WOD_2__Major_Component__c mc = [SELECT Id FROM WOD_2__Major_Component__c];
        ATI_VIN_Transmission_Mapper__c vinTransMapper = [SELECT Id FROM ATI_VIN_Transmission_Mapper__c];
        String jsonArray = '{"Inventory":[';
        for(Integer index=0;index<100;index++){
            jsonArray += '{"SerialNumber":"63118750221'+(index+1)+'","Item":"'+wp.Name+'","Egcn":"G01232","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"1001","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 0","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"'+(index+1)+'"},';
        }
        for(Integer index=101;index<=200;index++){
            jsonArray += '{"SerialNumber":"63118750221'+(index+1)+'","Item":"'+wp.Name+'","Egcn":"G01232","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"1001","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 0","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"ECU","VIN":"1B3LC46K58N102589","TransmissionSerialNumber":"631187502211","identifier":"'+(index+1)+'"}';
        	if(index != 200){
                jsonArray += ',';
            }
        }
        jsonArray += ']}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
       // System.assertEquals('Success', response.status, 'All the records have been inserted successfully...!!!');
        List<WOD_2__Inventory__c> inv1 = [SELECT Id,Name FROM WOD_2__Inventory__c WHERE Id !=: inv.id];
        //System.assertEquals(100,inv1.size(),'Number Of inventories are Inserted...!!!');
        List<WOD_2__Major_Component__c> mc1 = [SELECT Id,Name,ATI_VIN_from_Unit_history_field__c FROM WOD_2__Major_Component__c WHERE Id !=: mc.id];
       // System.assertEquals(100,mc1.size(),'Number Of MajorComponents are Inserted...!!!');
      //  System.assertEquals(true,mc1[0].ATI_VIN_from_Unit_history_field__c != NULL,'VIN should be updated on major component!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync' limit 1];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 200,'Number of Inventories Passed in Request');
       // System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 200,'Number of Success Inventories');
    }

    @isTest
    private static void testForInventoryUpdation(){
        Account acc = [SELECT Id,SAP_ID__c FROM Account];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Item__r.Name,ATI_CustomerId__c FROM WOD_2__Inventory__c];
        String jsonMsg = '{"Inventory":[{"SerialNumber":"'+inv.WOD_2__Serial_Number__c+'","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"00012345","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 1","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"1"}]}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonMsg);
        WOD_2__Inventory__c inv2 = [SELECT Id,ATI_CustomerId__c FROM WOD_2__Inventory__c WHERE Id=:inv.id];
      //  System.assert(inv.ATI_CustomerId__c != inv2.ATI_CustomerId__c,'Inventory CustomerId Update Check!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of Inventories Passed in Request');
       // System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success Inventories');
    }

    @isTest
    private static void testForInventoryWithSameSerialNumber(){
        Account acc = [SELECT Id,SAP_ID__c FROM Account];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Item__r.Name FROM WOD_2__Inventory__c];
        String jsonArray = '{"Inventory":[{"SerialNumber":"63118750221","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 0","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"1"},';
               jsonArray += '{"SerialNumber":"63118750221","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 0","Active":"false","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"2"}]}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
      //  System.assertEquals('Success', response.status, 'All the records have been inserted / updated successfully...!!!');
        List<WOD_2__Inventory__c> invLst = [SELECT Id,ATI_Active__c FROM WOD_2__Inventory__c WHERE Name='63118750221'];
       // System.assertEquals(1,invLst.size(),'Number Of inventories are Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 2,'Number of Inventories Passed in Request');
        //System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 2,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForInventoryPartialSuccess(){
        Account acc = [SELECT Id,SAP_ID__c FROM Account];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Item__r.Name FROM WOD_2__Inventory__c];
        String jsonArray = '{"Inventory":[{"SerialNumber":"63118750221","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"Program Level 0","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"1"},';
               jsonArray += '{"SerialNumber":"63118750221","Item":"test","Egcn":"","ShipDate":"2020-09-30","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"test","ProgramLevel":"Program Level 0","Active":"false","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":"2"}]}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
      //  System.assertEquals('Partial Success', response.status, 'All the records have failed to update...!!!');
        List<WOD_2__Inventory__c> invLst = [SELECT Id,ATI_Active__c FROM WOD_2__Inventory__c WHERE Name='63118750221'];
        //System.assertEquals(1,invLst.size(),'Number Of inventories are Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 2,'Number of Inventories Passed in Request');
       // System.assert(batchLog.WOD_2__Failure_Record_Count__c == 1,'Number of Failed Inventories');
       // System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success Inventories');
    }

    @isTest
    private static void testForInventoryDataValidation(){
        String jsonArray = '{"Inventory":[{"SerialNumber":"","Item":"","Egcn":"2500HS2","ShipDate":"test","BuildDate":"test","ShipTo":"","CustomerId":"","PlantCode":"1391","BusinessCategoryUnit":"","ProgramLevel":"Program Levl 0","Active":"true","Partcfn":"C07-00028-266","MajorComponentType":"","VIN":"","TransmissionSerialNumber":"","identifier":""}]}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of Inventories Passed in Request');
        System.assert(batchLog.WOD_2__Failure_Record_Count__c == 1,'Number of Failed Inventories');
        System.assert(batchLog.WOD_2__Success_Record_Count__c == 0,'Number of Success Inventories');
    }

	@isTest
    private static void testForMajorComponentInsertion(){
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        WOD_2__Inventory__c inv = [SELECT Id,Name FROM WOD_2__Inventory__c];
        String jsonMsg = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"'+wp.Name+'","Egcn":"","ShipDate":"","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"1J4GL58K96W180703","TransmissionSerialNumber":"'+inv.Name+'","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonMsg);
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c='MC0012345'];
        System.assertEquals(1,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of Inventories Passed in Request');
        System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
        System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForMCWithSameSCAndDifferentType(){
        WOD_2__Major_Component__c majorCmp = [SELECT Id,WOD_2__Serial_Number__c,ATI_Type__c FROM WOD_2__Major_Component__c];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonArray = '{"Inventory":[{"SerialNumber":"'+majorCmp.WOD_2__Serial_Number__c+'","Item":"'+wp.Name+'","Egcn":"","ShipDate":"","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"TCM","VIN":"","TransmissionSerialNumber":"","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id,ATI_Type__c FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c=:majorCmp.WOD_2__Serial_Number__c];
        System.assertEquals(1,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
        System.assert(majorCmpLst[0].ATI_Type__c == 'TCM', 'Major Component Type Not updated!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 1,'Number of Inventories Passed in Request');
        System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
        System.assert(batchLog.WOD_2__Success_Record_Count__c == 1,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForMajorComponentUpdation(){
        WOD_2__Major_Component__c majorCmp = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Manufacturing_Date__c FROM WOD_2__Major_Component__c];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonArray = '{"Inventory":[{"SerialNumber":"'+majorCmp.WOD_2__Serial_Number__c+'","Item":"'+wp.Name+'","Egcn":"","ShipDate":"","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"","TransmissionSerialNumber":"","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        WOD_2__Major_Component__c majorCmp2 = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Manufacturing_Date__c FROM WOD_2__Major_Component__c WHERE Id=:majorCmp.Id];
        System.assert(majorCmp.WOD_2__Manufacturing_Date__c != majorCmp2.WOD_2__Manufacturing_Date__c,'ManufacturingDate Updation Check');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assertEquals(1,batchLog.WOD_2__Total_Record_Count__c,'Number of Inventories Passed in Request');
        System.assertEquals(0,batchLog.WOD_2__Failure_Record_Count__c,'Failure Record Count....!!!');
        System.assertEquals(1,batchLog.WOD_2__Success_Record_Count__c,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForVINMapperUpdation(){
        WOD_2__Inventory__c inv = [SELECT Id,Name FROM WOD_2__Inventory__c LIMIT 1];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        ATI_VIN_Transmission_Mapper__c vinTransMapper = [SELECT Id,ATI_Vehicle_Information__r.Name,ATI_Inventory__r.Name FROM ATI_VIN_Transmission_Mapper__c WHERE ATI_Inventory__c=:inv.id];
        String jsonArray = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"'+wp.Name+'","Egcn":"","ShipDate":"","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"1B3LC46K58N102589","TransmissionSerialNumber":"'+inv.Name+'","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id,ATI_VIN_from_Unit_history_field__c FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c='MC0012345'];
        System.assertEquals(1,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
		//System.assertEquals('1B3LC46K58N102589',majorCmpLst[0].ATI_VIN_from_Unit_history_field__c,'VIN should be updated on major component!');
    }
    
    @isTest
    private static void testForVINMapperInsertion(){
        WOD_2__Inventory__c inv = [SELECT Id,Name FROM WOD_2__Inventory__c LIMIT 1];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        ATI_VIN_Transmission_Mapper__c vinTransMapper = [SELECT Id,ATI_Vehicle_Information__r.Name,ATI_Inventory__r.Name FROM ATI_VIN_Transmission_Mapper__c WHERE ATI_Inventory__c=:inv.id];
        delete vinTransMapper;
        String jsonArray = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"'+wp.Name+'","Egcn":"","ShipDate":"","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"1B3LC46K58N102589","TransmissionSerialNumber":"'+inv.Name+'","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c='MC0012345'];
        System.assertEquals(1,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
    }
    
    @isTest
    private static void testForMCWithAssociateInventory(){
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Item__r.Name FROM WOD_2__Inventory__c];
        String jsonArray = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"","BuildDate":"","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"","TransmissionSerialNumber":"","identifier":"1"},';
               jsonArray += '{"SerialNumber":"MC0012345","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"","BuildDate":"","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"","TransmissionSerialNumber":"'+inv.WOD_2__Serial_Number__c+'","identifier":"2"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id,WOD_2__Serial_number__c,WOD_2__Inventory__r.Name FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c='MC0012345'];
        System.assertEquals(1,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
        System.assert(majorCmpLst.get(0).WOD_2__Inventory__r.Name == inv.WOD_2__Serial_Number__c, 'MajorComponent-Inventory Association Check');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assert(batchLog.WOD_2__Total_Record_Count__c == 2,'Number of Inventories Passed in Request');
        System.assert(batchLog.WOD_2__Failure_Record_Count__c == 0,'Number of Failed Inventories');
        System.assert(batchLog.WOD_2__Success_Record_Count__c == 2,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForUpdateMCFromInv1ToInv2(){
        Account acc = [SELECT Id,SAP_ID__c FROM Account];
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        WOD_2__Inventory__c inv = [SELECT Id,WOD_2__Serial_Number__c,WOD_2__Item__r.Name FROM WOD_2__Inventory__c];

        //Create Inventory
        List<WOD_2__Inventory__c> invLst = TestDataFactory.createInventoryWithRecordType(1,'Stock');
        invLst.get(0).Name = 'TestSN001';
        invLst.get(0).WOD_2__Serial_number__c = 'TestSN001';
        invLst.get(0).WOD_2__Item__c = wp.Id;
        invLst.get(0).WOD_2__Business_Unit__c = bcc.Id;
        invLst.get(0).WOD_2__Account__c = acc.Id;
		insert invLst;
        
        WOD_2__Major_Component__c majorCmp = [SELECT Id,WOD_2__Inventory__c FROM WOD_2__Major_Component__c];
        majorCmp.WOD_2__Inventory__c = inv.id;
        update majorCmp;
      
        String jsonArray = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"'+inv.WOD_2__Item__r.Name+'","Egcn":"","ShipDate":"","BuildDate":"","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"","TransmissionSerialNumber":"'+invLst.get(0).WOD_2__Serial_Number__c+'","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id,WOD_2__Serial_number__c,WOD_2__Inventory__r.Name FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c='MC0012345'];
        System.assertEquals(1,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
        System.assert(majorCmpLst.get(0).WOD_2__Inventory__r.Name == invLst.get(0).WOD_2__Serial_Number__c, 'MajorComponent-Inventory Association Updation Check');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assertEquals(1,batchLog.WOD_2__Total_Record_Count__c,'Number of Inventories Passed in Request');
        System.assertEquals(0,batchLog.WOD_2__Failure_Record_Count__c,'Number of Failed Inventories');
        System.assertEquals(1,batchLog.WOD_2__Success_Record_Count__c,'Number of Success Inventories');
    }
    
    @isTest
    private static void testForMCDataValidation(){
        String jsonArray = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"","Egcn":"","ShipDate":"","BuildDate":"","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"ECU","VIN":"","TransmissionSerialNumber":"test001","identifier":"1"}]}';
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        System.assertEquals('Failed', response.status, 'All the records have failed to update...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assertEquals(1,batchLog.WOD_2__Total_Record_Count__c,'Number of Inventories Passed in Request');
        System.assertEquals(1,batchLog.WOD_2__Failure_Record_Count__c,'Number of Failed Inventories');
        System.assertEquals(0,batchLog.WOD_2__Success_Record_Count__c,'Number of Success Inventories');
    } 
    
    @isTest
    private static void testForMajorComponentCatchException(){
        WOD_2__Business_Category_Configuration__c bcc = [SELECT Id,Name FROM WOD_2__Business_Category_Configuration__c];
        WOD_2__Warranty_Product__c wp = [SELECT Id,Name FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        String jsonArray = '{"Inventory":[{"SerialNumber":"MC0012345","Item":"'+wp.Name+'","Egcn":"","ShipDate":"","BuildDate":"2020-09-23","ShipTo":"","CustomerId":"","PlantCode":"","BusinessCategoryUnit":"'+bcc.Name+'","ProgramLevel":"","Active":"","Partcfn":"","MajorComponentType":"test","VIN":"","TransmissionSerialNumber":"","identifier":"1"}]}';
    	ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = sendSerialNumberRequest(jsonArray);
        System.assert(response.status == 'Fail','Runtime Exception Check');
        List<WOD_2__Major_Component__c> majorCmpLst = [SELECT Id FROM WOD_2__Major_Component__c WHERE WOD_2__Serial_number__c='MC0012345'];
        System.assertEquals(0,majorCmpLst.size(),'Number Of MajorComponents are Inserted...!!!');
        WOD_2__Batch_Log__c batchLog = [SELECT Id,WOD_2__Total_Record_Count__c,WOD_2__Failure_Record_Count__c,WOD_2__Success_Record_Count__c FROM WOD_2__Batch_Log__c WHERE WOD_2__Process_Type__c='SerialNumberSync'];
        System.assertEquals(1,batchLog.WOD_2__Total_Record_Count__c,'Number of Inventories Passed in Request');
        System.assertEquals(1,batchLog.WOD_2__Failure_Record_Count__c,'Number of Failed Inventories');
        System.assertEquals(0,batchLog.WOD_2__Success_Record_Count__c,'Number of Success Inventories');
    }
    
    private static ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse sendSerialNumberRequest(String jsonRequest){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/ATIRestSerialNumberSync/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonRequest);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        ATI_REST_SerialNumberSync.ATI_REST_SerialNumberSyncResponse response = ATI_REST_SerialNumberSync.doPost();
        Test.stopTest();
        return response;
    }
}