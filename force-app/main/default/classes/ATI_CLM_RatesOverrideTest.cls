/* Name: ATI_CLM_RatesOverrideTest
Description : ATI_CLM_RatesOverrideTest - test class for ATI_CLM_RatesOverride
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      27-APR-2021          INITIAL DEVELOPMENT
*/
@isTest			
public class ATI_CLM_RatesOverrideTest {
    
    @testSetup
    static void setUp(){
        WOD_2__Business_Category_Configuration__c bcc = TestDataFactory.createBcc();
        insert bcc;
        List<Account> accountList = TestDataFactory.createAccount(2); 
        for(Integer i=0;i<accountList.size();i++){
            accountList[i].Sales_RegionA__c = 'EMEA';
            accountList[i].SAP_ID__c = '1223123'+i;
            accountList[i].Location_Type__c = 'Type'+i;
            accountList[i].WOD_2__Warranty_Account_Type__c='Dealer';
        }
        accountList[0].Name = 'ClaimAccount';
        insert accountList;
        
        List<WOD_2__Inventory__c> invList = TestDataFactory.createInventory(1);
        invList[0].WOD_2__Business_Unit__c = bcc.Id;
        invList[0].WOD_2__Account__c = accountList[0].Id;
        insert invList;
        
        //casual part creation
        WOD_2__Warranty_Product__c casualPart =  TestDataFactory.createWarantyProduct();
        casualPart.WOD_2__Business_Unit__c = bcc.Id;
        casualPart.External_Product_Code__c = casualPart.Name;
        casualPart.WOD_2__Item_Type__c = 'Machine';
        casualPart.WOD_2__Track_Type__c = 'Non-Serialized';
        insert casualPart;
        
		List<WOD_2__Rates_Details__c> laborRates = TestDataFactory.createLaborRateDetails(2);
        for(Integer i = 0; i < laborRates.size(); i++){
            laborRates[i].WOD_2__Active_From__c = Date.today().addYears(i);
			laborRates[i].WOD_2__Active_Until__c = laborRates[i].WOD_2__Active_From__c.addYears(1);    
			laborRates[i].WOD_2__Labor_Rate__c = 100 * (i+1);  
            laborRates[i].WOD_2__Dealer__c = accountList[0].Id;
        }
        insert laborRates;
		List<WOD_2__Rates_Details__c> travelRates = TestDataFactory.createTravelRateDetails(2);        
        for(Integer i = 0; i < travelRates.size(); i++){
            travelRates[i].WOD_2__Active_From__c = Date.today().addYears(i);
			travelRates[i].WOD_2__Active_Until__c = travelRates[i].WOD_2__Active_From__c.addYears(1);                
            travelRates[i].WOD_2__Travel_By_Distance_Rate__c = 10 * (i+1);          
            travelRates[i].WOD_2__Travel_By_Hours_Rate__c = 100 * (i+1);
            travelRates[i].WOD_2__Dealer__c = accountList[0].Id;
        }
        insert travelRates;
    }
    
    @isTest
    static void testValidRates(){
        List<Account> accountList =[SELECT Id FROM Account where Name = 'ClaimAccount'];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        WOD_2__Warranty_Product__c casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart.Id,WOD_2__Date_Of_Failure__c=System.today(),  WOD_2__Date_Of_Repair__c=System.today()+3,WOD_2__Causal_Part_Number__c=casulaPart.Id );
        insert claim;
        Test.startTest();
        List<WOD_2.CLM_RatesOverrideOutputWrapper> owList = new ATI_CLM_RatesOverride().getRates(getInputWrapList(claim.Id));
        Test.stopTest();
        WOD_2.CLM_RatesOverrideOutputWrapper outputWrapper = owList.get(0);
        System.assertEquals(true, outputWrapper.status, 'Status is not true, rates are not fetched as expected');
        System.assertEquals(100, outputWrapper.laborRate, 'Incorrect Amount fetched for labor rate');
        System.assertEquals(100, outputWrapper.travelByHoursRate, 'Incorrect amount is fetched from travel rate');
    }
    
    @isTest
    static void testInValidRates(){
        List<Account> accountList =[SELECT Id FROM Account where Name = 'ClaimAccount'];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        WOD_2__Warranty_Product__c casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart.Id,WOD_2__Date_Of_Failure__c=System.today()-30,  WOD_2__Date_Of_Repair__c=System.today()-25,WOD_2__Causal_Part_Number__c=casulaPart.Id );
        insert claim;
        Test.startTest();
        List<WOD_2.CLM_RatesOverrideOutputWrapper> owList = new ATI_CLM_RatesOverride().getRates(getInputWrapList(claim.Id));
        Test.stopTest();
        WOD_2.CLM_RatesOverrideOutputWrapper outputWrapper = owList.get(0);
        System.assertEquals(false, outputWrapper.status, 'Status is not false, rates are fetched which is not expected');
        System.assertEquals(null, outputWrapper.laborRate, 'Amount fetched for labor rate, which is wrong');
        System.assertEquals(null, outputWrapper.travelByHoursRate, 'Amount fetched for travel rate, which is wrong');
    }
    
    @isTest
    static void testNoRatesForAccount(){
        List<Account> accountList =[SELECT Id FROM Account where Name <> 'ClaimAccount'];
        List<WOD_2__Inventory__c> invList =[SELECT Id FROM WOD_2__Inventory__c];
        WOD_2__Warranty_Product__c casulaPart = [SELECT Id FROM WOD_2__Warranty_Product__c];
        list<RecordType> rListMachine = [SELECT id FROM RecordType WHERE sObjectType = 'WOD_2__Claim__c'and RecordType.Name = 'Machine'];
        WOD_2__Claim__c claim = new WOD_2__Claim__c(Name = 'claimMachine',recordtypeid=rListMachine[0].id,WOD_2__Account__c =accountList[0].Id,WOD_2__Inventory__c=invList[0].Id,WOD_2__Model_Number__c=casulaPart.Id,WOD_2__Date_Of_Failure__c=System.today(),  WOD_2__Date_Of_Repair__c=System.today()+3,WOD_2__Causal_Part_Number__c=casulaPart.Id );
        insert claim;
        Test.startTest();
        List<WOD_2.CLM_RatesOverrideOutputWrapper> owList = new ATI_CLM_RatesOverride().getRates(getInputWrapList(claim.Id));
        Test.stopTest();
        WOD_2.CLM_RatesOverrideOutputWrapper outputWrapper = owList.get(0);
        System.assertEquals(false, outputWrapper.status, 'Status is not false, rates are fetched which is not expected');
        System.assertEquals(null, outputWrapper.laborRate, 'Amount fetched for labor rate, which is wrong');
        System.assertEquals(null, outputWrapper.travelByHoursRate, 'Amount fetched for travel rate, which is wrong');
    }
 
    private static List<WOD_2.CLM_RatesOverrideInputWrapper> getInputWrapList(Id claimId){
        List<WOD_2.CLM_RatesOverrideInputWrapper> iwList = new List<WOD_2.CLM_RatesOverrideInputWrapper>();
        WOD_2.CLM_RatesOverrideInputWrapper iw = new WOD_2.CLM_RatesOverrideInputWrapper();
        iw.claimId = claimId;
        iw.fetchLaborRate = true;
        iw.fetchTravelByDistanceRate = false;
        iw.fetchTravelByHoursRate = true;
        iwList.add(iw);
        return iwList;
    }
}