/**
 * @Description: Test class for PRPC_createServiceDealerDevScheduler
 * Created:  02/17/2021 – Nitish Gyansys
**/
@isTest(SeeAllData=false)
public class PRPC_createServiceDealerDevSchedulerTest {
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
        accountRec.Name = 'Test Service Dealer 1';
        accountRec.Type = 'Service Dealer';
        accountRec.Location_Type__c = 'DLR';
        accountRec.SAP_ID__c = '111100101';
        accountRec.Sales_RegionA__c = 'North America';
        accountRec.ShippingCity = 'City';
        accountRec.ShippingCountry = 'Country';
        accountRec.ShippingState = 'State';
        accountRec.ShippingPostalCode = '765432';
        accountRec.ShippingStreet = 'Street123';
       // accountRec.PRP_Participation__c = true;
       accountRec.Service_Dealer_Development__c = true;
        accountRec.ParentId = allNADistributors[0].Id;
        INSERT accountRec;
        
        Account accountRec2 = new Account();
        accountRec2.Name = 'Test Subparent';
        accountRec2.Type = 'Distributor';
        accountRec2.Location_Type__c = 'D';
        accountRec2.SAP_ID__c = '12345';
        accountRec2.Sales_RegionA__c = 'North America';
        accountRec2.ShippingCity = 'City';
        accountRec2.ShippingCountry = 'Country';
        accountRec2.ShippingState = 'State';
        accountRec2.ShippingPostalCode = '765432';
        accountRec2.ShippingStreet = 'Street123';
       // accountRec.PRP_Participation__c = true;
       INSERT accountRec2;
        
        Account accountRec3 = new Account();
        accountRec3.Name = 'Test Service Dealer 2';
        accountRec3.Type = 'Service Dealer';
        accountRec3.Location_Type__c = 'DLR';
        accountRec3.SAP_ID__c = '111100102';
        accountRec3.Sales_RegionA__c = 'North America';
        accountRec3.ShippingCity = 'City';
        accountRec3.ShippingCountry = 'Country';
        accountRec3.ShippingState = 'State';
        accountRec3.ShippingPostalCode = '765432';
        accountRec3.ShippingStreet = 'Street123';
       // accountRec.PRP_Participation__c = true;
       accountRec3.Service_Dealer_Development__c = true;
        accountRec3.ParentId =  accountRec2.Id;
        INSERT accountRec3;
        
        
    }
    
    @isTest
    private static void executeCreateServiceDealerDev(){
        PRPC_createServiceDealerDevScheduler executeServiceDlr = new PRPC_createServiceDealerDevScheduler();
        test.StartTest();
        executeServiceDlr.execute(null);
        test.stopTest();
        System.assertEquals(1,[select Service_Dealer_Count__c from Service_Dealer_Development__c LIMIT 1].Service_Dealer_Count__c);
    }
}