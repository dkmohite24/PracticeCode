/*
* @Description: Test Class for PRPC_DataMovementBatchForETCData.
* Created:  06/12/2023 – Susovan Mondal & Chinmaya Dash
* */
@isTest(SeeAllData=false)
public class PRPC_DataMovementBatchForETCDataTest {
    
    
    @testSetup 
    private static void setup() {
        List<Disable_Rules__c> insertDisableRules = new List<Disable_Rules__c>();
        List<Disable_Rules__c> disableRules = PRPC_TestDataFactory.createDisableRules();
        for(Disable_Rules__c rule : disableRules) {
            if(rule.Name== 'PRPC_BranchCount') {
                rule.Disable__c = false;
                
                insertDisableRules.add(rule);
            }
        }
        
        insert insertDisableRules;
        List<Account> allNADistributors = PRPC_TestDataFactory.createAccount('D', 'North America', 1, false, false);
        Account accountRec = new Account();
        accountRec.Name = 'Test Etc Data 1';
        accountRec.Type = 'Distributor';
        accountRec.Location_Type__c = 'D';
        accountRec.SAP_ID__c = '0000001019';
        accountRec.Sales_RegionA__c = 'North America';
        accountRec.ShippingCity = 'City';
        accountRec.ShippingCountry = 'Country';
        accountRec.ShippingState = 'State';
        accountRec.ShippingPostalCode = '765432';
        accountRec.ShippingStreet = 'Street123';
        accountRec.PRP_Participation__c = true;
        accountRec.WOD_2__Warranty_Account_Type__c='Dealer';
        
        accountRec.ParentId = allNADistributors[0].Id;
        INSERT accountRec;
        
        WOD_2__Warranty_Product__c warrantyProductRec = new WOD_2__Warranty_Product__c();
        warrantyProductRec.Name='123456';
        warrantyProductRec.WOD_2__Type__c='Item';
        warrantyProductRec.WOD_2__Track_Type__c='Serialized';
        warrantyProductRec.WOD_2__Item_Type__c='Machine';
        warrantyProductRec.External_Product_Code__c='1234';
        
        Insert warrantyProductRec;
        
        WOD_2__Inventory__c inventoryRec= new WOD_2__Inventory__c();
        inventoryRec.Name ='6511815074';
        inventoryRec.WOD_2__Serial_Number__c='6511815074';
        inventoryRec.WOD_2__Account__c=accountRec.id;
        inventoryRec.WOD_2__Item__c=warrantyProductRec.id;
        
        Insert inventoryRec;
        
        WOD_2__Warranty_Registration__c warrantyRec = new WOD_2__Warranty_Registration__c();
        warrantyRec.WOD_2__Account__c=accountRec.id;
        warrantyRec.WOD_2__Warranty_Product__c=warrantyProductRec.id;
        warrantyRec.WOD_2__Inventory__c=inventoryRec.id;
        warrantyRec.WOD_2__Registration_Date__c=Date.newInstance(2023,12,05);
        
        Insert warrantyRec;
        
        WOD_2__Transaction_Memo_History__c transacRec =new WOD_2__Transaction_Memo_History__c();
        transacRec.WOD_2__Transaction_Date__c=Date.newInstance(2023,11,01);
        transacRec.WOD_2__Amount__c=760;
        transacRec.ATI_Warranty_Registration__c=warrantyRec.id;
        
        Insert transacRec;
    }
    
    @isTest
    private static void executeCreateServiceDealerDev(){
        PRPC_DataMovementBatchForETCData executeEtc = new PRPC_DataMovementBatchForETCData();
        test.StartTest();
        executeEtc.execute(null);
        test.stopTest();
        system.debug('TMH' +[SELECT id, ATI_Amount_USD__c, WOD_2__Transaction_Date__c, ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c from WOD_2__Transaction_Memo_History__c]);
    }
}