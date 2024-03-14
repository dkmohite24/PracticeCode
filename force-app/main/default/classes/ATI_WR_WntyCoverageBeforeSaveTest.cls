@isTest
public class ATI_WR_WntyCoverageBeforeSaveTest {
    @isTest
    public static void saveWarrantyCoveragesTest(){
        Test.startTest();
            WOD_2.WR_CoverageInputWrapper wrapperObj = new WOD_2.WR_CoverageInputWrapper();
            List<WOD_2__Warranty_Coverages__c> warCovList = TestDataFactory.createWarrantyCoverage(1);
            wrapperObj.warrantyCoverageBeforeSaveOverrideClassName='ABC';
            wrapperObj.coverages = warCovList;
            List<Account> accLst = TestDataFactory.createAccount(2);
            for(Integer i=0;i<accLst.size();i++){
                accLst[i].Sales_RegionA__c = 'EMEA';
                accLst[i].SAP_ID__c = '1223123'+i;
                accLst[i].Location_Type__c = 'test'+i;    
            }
            accLst[0].WOD_2__Warranty_Account_Type__c='Dealer';
            accLst[0].ATI_RPS_Status__c=true;
            accLst[1].WOD_2__Warranty_Account_Type__c='Customer';
            insert accLst;
            List<WOD_2__Warranty_Product__c>  warrantyProLst = TestDataFactory.createWarrantyProduct(3);
            insert warrantyProLst;
            List<WOD_2__Inventory__c> inventoryLst = TestDataFactory.createInventory(1);
            for(WOD_2__Inventory__c inventory : inventoryLst){
                inventory.WOD_2__Type__c = 'Stock';
                inventory.WOD_2__Account__c = accLst[0].id;
                inventory.WOD_2__Item__c = warrantyProLst[2].id;
            }
            insert inventoryLst;
            List<WOD_2__Warranty_Registration__c> wrLst = TestDataFactory.createWarrantyRegistration(1);
            wrLst[0].WOD_2__Inventory__c = inventoryLst[0].id;
            wrLst[0].WOD_2__Account__c = accLst[0].Id;
            wrLst[0].WOD_2__Customer__c = accLst[1].Id;
            wrLst[0].WOD_2__Status__c = 'In Progress';
            insert wrLst;
            wrapperObj.wrRecordIds = new List<String>{wrLst[0].Id};
            List<ATI_Vehicle_Information__c> viList = TestDataFactory.createVehicleInformation(1);
            //viList[0].ATI_Inventory__c = inventoryLst[0].Id;
            insert viList;
        List<ATI_VIN_Transmission_Mapper__c> vinTransmissionMapperLst =  new List<ATI_VIN_Transmission_Mapper__c>();
        ATI_VIN_Transmission_Mapper__c vehicleTransMapper = new ATI_VIN_Transmission_Mapper__c();
        vehicleTransMapper.ATI_Inventory__c = inventoryLst[0].Id;
        vehicleTransMapper.ATI_Vehicle_Information__c = viList[0].id;
        vinTransmissionMapperLst.add(vehicleTransMapper);
        insert vinTransmissionMapperLst;
            ATI_WR_WntyCoverageBeforeSaveOverirde att = new ATI_WR_WntyCoverageBeforeSaveOverirde();
            WOD_2.WR_PolicyPickOutputWrapper response = att.saveWarrantyCoverages(wrapperObj);
        Test.stopTest();
    }
}