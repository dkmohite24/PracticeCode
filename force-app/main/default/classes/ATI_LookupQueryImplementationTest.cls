@isTest
public class ATI_LookupQueryImplementationTest {
    @testSetup
    private static void setup(){
        List<WOD_2__Warranty_Product__c> createWarrantyProductList = TestDataFactory.createWarrantyProduct(3);
        insert createWarrantyProductList;
        system.debug('createWarrantyProductList'+createWarrantyProductList);
        
        List<WOD_2__Group__c> gpLst = TestDataFactory.createGroup(1);
        for(WOD_2__Group__c gpObj : gpLst){
            gpObj.WOD_2__Object_Name__c = 'WOD_2__Warranty_Product__c';
        }
        insert gpLst;
        
        List<WOD_2__Warranty_Product__c> wpList = [SELECT Id FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Model'];
        List<WOD_2__Warranty_Product__c> itemsList = [SELECT Id FROM WOD_2__Warranty_Product__c WHERE WOD_2__Type__c='Item'];
        itemsList[0].WOD_2__Parent_Product__c=wpList[0].Id;
        update itemsList[0];
        List<WOD_2__Group_Member__c> gpMemLst = TestDataFactory.createGroupMember(1,gpLst[0].Id);
        gpMemLst[0].WOD_2__Warranty_Product__c = wpList[0].Id;
        insert gpMemLst;

        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createWarrantyCode(1,'Labor Operations Codes');
        wcLst[0].Name = 'Test005';
        insert wcLst;

        WOD_2__FaultCode_Mapper__c fcmObj = new WOD_2__FaultCode_Mapper__c(Name='TestFCM',WOD_2__Code__c=wcLst[0].Id,
                                                                           WOD_2__Group__c=gpLst[0].Id,WOD_2__Status__c=true);
        insert fcmObj;
        
        WOD_2__Carrier__c carrier = new WOD_2__Carrier__c(Name='UPS', WOD_2__Business_Units__c = 'ATI');
        insert carrier;
    }
    
    @isTest
    private static void testLookupConfigForLabor(){
        List<WOD_2__Warranty_Product__c> wpList = [SELECT Id,WOD_2__Parent_Product__c FROM WOD_2__Warranty_Product__c 
                                                   WHERE WOD_2__Type__c='Item' AND WOD_2__Parent_Product__c!=NULL];
        WOD_2.QueryBuilderWrapper wrapper = new WOD_2.QueryBuilderWrapper();
        Map<String,String> extraParams = new Map<String,String>{'WOD_2__Warranty_Product__c' => wpList[0].Id};
        wrapper.extraParams = JSON.serialize(extraParams);
        wrapper.fieldsToQuery = new List<String>{'Name','WOD_2__Code__r.Name'};
        wrapper.fromObject = 'WOD_2__FaultCode_Mapper__c';
        wrapper.lookUpConfigurationName = 'WOD_2__Claim_Services_JobCodeLookUp';
        wrapper.orderBy = 'WOD_2__Code__r.Name ASC';
        wrapper.orderByLogic = 'ASC';
        wrapper.recordLimit = 50;
        wrapper.userEnteredValue = '%%%';
        
        Test.startTest();
            ATI_LookupQueryImplementation controllerObj = new ATI_LookupQueryImplementation();
            String strResult = controllerObj.fetchRecords(wrapper);
        Test.stopTest();
        List<WOD_2__FaultCode_Mapper__c> response = (List<WOD_2__FaultCode_Mapper__c>)JSON.deserialize(strResult,List<WOD_2__FaultCode_Mapper__c>.class);
       System.assertEquals(1, response.size());
    }
     @isTest
    private static void testLookupConfigForDiagnosticCodes(){
         WOD_2__Warranty_Product__c warrantyPro = new WOD_2__Warranty_Product__c(Name='Product', WOD_2__Product_Name__c='Product1',WOD_2__Type__c='Product', External_Product_Code__c='Product');
        insert warrantyPro;
        WOD_2__Warranty_Product__c warrantyPro1=new WOD_2__Warranty_Product__c(Name='Model1', WOD_2__Product_Name__c='Model1',WOD_2__Type__c='Model', External_Product_Code__c='Model1');
        warrantyPro1.WOD_2__Parent_Product__c=warrantyPro.id;
        insert warrantyPro1;      
        System.debug('warrantyPro1'+warrantyPro1);
         WOD_2__Warranty_Product__c wp = new WOD_2__Warranty_Product__c(Name = 'TestWarrantyItem',WOD_2__Product_Name__c='TestWarrantyItem',WOD_2__Item_Type__c = 'Machine',
                                                                           WOD_2__Track_Type__c = 'Serialized',WOD_2__Type__c='Item',WOD_2__Parent_Product__c =  warrantyPro1.Id, External_Product_Code__c='TestWarrantyItem',
                                                                           WOD_2__Description__c = 'Warranty Product Item Description');
        
         insert wp;
        System.debug('wp'+wp);
        /*List<WOD_2__Warranty_Product__c> wpList = [SELECT Id,WOD_2__Parent_Product__c,WOD_2__Parent_Product__r.WOD_2__Parent_Product__c FROM WOD_2__Warranty_Product__c 
                                                   WHERE WOD_2__Type__c='Product'];*/
        
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createDiagnosticCode(2,false);
        insert wcLst;
        system.debug('wcLst'+wcLst);

        ATI_Diagnostic_Codes_Mapper__c dc = new ATI_Diagnostic_Codes_Mapper__c();
        dc.ATI_Warranty_Product__c = warrantyPro1.WOD_2__Parent_Product__c; 
        dc.ATI_Warranty_Code__c = wcLst[0].Id;
        insert dc;
        system.debug('dc'+dc);
               //system.debug('wpList'+wpList);
        WOD_2.QueryBuilderWrapper wrapper = new WOD_2.QueryBuilderWrapper();
        Map<String,String> extraParams = new Map<String,String>{'modelId' => wp.Id};
        wrapper.extraParams = JSON.serialize(extraParams);
        wrapper.fieldsToQuery = new List<String>{'Name'};
            wrapper.comparisonFields = new List<String>{'Name'};
        wrapper.fromObject = 'WOD_2__Warranty_Code__c';
        wrapper.lookUpConfigurationName = 'ATI_DiagnosticCodes_Lookup';
        wrapper.orderByField = 'Name';
        wrapper.orderByLogic = 'ASC';
        wrapper.recordLimit = 5;
        wrapper.userEnteredValue = '%%%';
        wrapper.conditions = '[{ "fieldName" : "RecordType.Name","value" : "Diagnostics Codes","operator" : "eq", "searchType" : "EXACT", "valueType" : "string"}]';
        
        Test.startTest();
            ATI_LookupQueryImplementation controllerObj = new ATI_LookupQueryImplementation();
            String strResult = controllerObj.fetchRecords(wrapper);
        system.debug('strResult'+strResult);
        Test.stopTest();
        List<WOD_2__Warranty_Code__c> response = (List<WOD_2__Warranty_Code__c>)JSON.deserialize(strResult,List<WOD_2__Warranty_Code__c>.class);
        System.assertEquals(1, response.size());
    }
    
    @isTest
    private static void testCarrierLookup(){
        WOD_2.QueryBuilderWrapper wrapper = new WOD_2.QueryBuilderWrapper();
        wrapper.fieldsToQuery = new List<String>{'Name','Id'};
        wrapper.fromObject = 'WOD_2__Carrier__c';
        wrapper.lookUpConfigurationName = 'WOD_2__SHP_Carrier_Lookup_Configuration';
        wrapper.orderBy = 'Name';
        wrapper.orderByLogic = 'ASC';
        wrapper.recordLimit = 50;
        wrapper.userEnteredValue = '%%%';
        
        Test.startTest();
            ATI_LookupQueryImplementation controllerObj = new ATI_LookupQueryImplementation();
            String strResult = controllerObj.fetchRecords(wrapper);
        Test.stopTest();
        List<WOD_2__Carrier__c> response = (List<WOD_2__Carrier__c>)JSON.deserialize(strResult,List<WOD_2__Carrier__c>.class);
       System.assertEquals(1, response.size());
       
    }
}