@isTest
public with sharing class ATI_VehicleInformationControllerTest {
    @testSetup
    public static void testSetup(){
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<Account> accountList = TestDataFactory.createAccount(2); 
        accountList[0].WOD_2__Warranty_Account_Type__c='Dealer';
        accountList[0].BillingCountry='United States';
        accountList[1].WOD_2__Warranty_Account_Type__c='Customer';
        insert accountList;
        accountList[0].BillingCountry='USA';
        update accountList;
        
        Id stockInvrecId = Schema.SObjectType.WOD_2__Inventory__c.getRecordTypeInfosByDeveloperName().get('Stock').getRecordTypeId(); 
        List<WOD_2__Warranty_Product__c> warrantyProLst = TestDataFactory.createWarrantyProduct(1);
        for(Integer i=0;i<warrantyProLst.size();i++){
            warrantyProLst[i].WOD_2__Type__c = 'Item';
            warrantyProLst[i].WOD_2__Item_Type__c = 'Machine';
            warrantyProLst[i].WOD_2__Track_Type__c = 'Serialized';
        }
        insert warrantyProLst;
        
        
        List<WOD_2__Warranty_Code__c> wcLst = TestDataFactory.createVocationCode(1,false);
        insert wcLst;
        System.debug('wcLst--->'+wcLst);
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        invList[0].WOD_2__Item__c = warrantyProLst[0].Id;
        invList[0].RecordTypeId = stockInvrecId;
        insert invList;
        
        List<WOD_2__Warranty_Registration__c> wrList = TestDataFactory.createWarrantyRegistration(1);
        for(WOD_2__Warranty_Registration__c wrRec : wrList){
            wrRec.WOD_2__Inventory__c=invList[0].Id;
            wrRec.WOD_2__Account__c = accountList[0].Id;
            wrRec.WOD_2__Customer__c = accountList[1].Id;
            wrRec.WOD_2__Status__c='In Progress';
            wrRec.ATI_Vocation_Code__c = wcLst.get(0).id;
            //wcLst.get(0).id
        }
        insert wrList;
    }
    @isTest
    public static void vehicleInfoSaveTest(){
          List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        List<Account> accountList =[SELECT Id FROM Account];
        Test.startTest();
        ATI_Vehicle_Information__c vehicleInfoRec = new ATI_Vehicle_Information__c(ATI_Vehicle_Make__c='make',ATI_Vehicle_Model__c='model',Name='1FAFP53UX3A107952',ATI_Customer_asset_number__c='123',ATI_Vehicle_Usage__c=13,ATI_Engine_Make__c='123',
                                                                                   ATI_Engine_Model__c='1334',ATI_Engine_Year__c='1993',ATI_Executive_order_Designation__c='ABC');
        insert vehicleInfoRec;
        String vehicleInfoList = JSON.serialize(vehicleInfoRec);
        String vehicleInfoListFirst = vehicleInfoList.removeEnd('}')  + ',\"ATI_Inventory__c\":\"' + invList[0].Id + '\"}';
        
        Map<Id,ATI_Vehicle_Information__c> vehcleInfoMap = new Map<Id,ATI_Vehicle_Information__c>();
        vehcleInfoMap.put(invList[0].Id,vehicleInfoRec);
        
        ATI_VehicleInformationController.saveVehicleInfo(vehicleInfoListFirst);
        ATI_VehicleInformationController.createVehicleInfoMapper(vehcleInfoMap);
        ATI_VehicleInformationController.getVehicleData(invList[0].Id);
        
        ATI_Vehicle_Information__c vehicleInfoRec1 = new ATI_Vehicle_Information__c(ATI_Vehicle_Make__c='make123',ATI_Vehicle_Model__c='model123',Name='1FAFP53UX3A107952',ATI_Customer_asset_number__c='123',ATI_Vehicle_Usage__c=13,ATI_Engine_Make__c='123',
                                                                                   ATI_Engine_Model__c='1334',ATI_Engine_Year__c='1993',ATI_Executive_order_Designation__c='ABC');
        insert vehicleInfoRec1;
        String vehicleInfoList2nd = JSON.serialize(vehicleInfoRec);
        String finalVehicleInfoList2nd = vehicleInfoList.removeEnd('}')  + ',\"ATI_Inventory__c\":\"' + invList[0].Id + '\"}';
        ATI_VehicleInformationController.saveVehicleInfo(finalVehicleInfoList2nd);
        List<ATI_Vehicle_Information__c> vehicleInfoListAfterSave = new  List<ATI_Vehicle_Information__c>();
        vehicleInfoListAfterSave = [SELECT Id FROM ATI_Vehicle_Information__c];
        system.assertEquals(2, vehicleInfoListAfterSave.size(),'Success');
    }
}