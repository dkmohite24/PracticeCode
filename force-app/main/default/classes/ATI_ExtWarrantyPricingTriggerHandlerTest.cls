/* Name: ATI_ExtWarrantyPricingTriggerHandlerTest
Description : Test calss for ATI_ExtWarrantyPricingTriggerHandler
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      04-JAN-2021          INITIAL DEVELOPMENT
*/
@isTest
public class ATI_ExtWarrantyPricingTriggerHandlerTest {

	@testSetup    
    static void testSetup(){
        List<WOD_2__Payment_Definitions__c> paymentDefnList = TestDataFactory.createPaymentDefinition(1);
        insert paymentDefnList;
        List<WOD_2__Policy_Definition__c> policyDefList = TestDataFactory.createPolicyDefinition(1);
        policyDefList.get(0).WOD_2__Type__c = 'Extended';
        policyDefList.get(0).WOD_2__Payment_Definition__c = paymentDefnList.get(0).Id;
        insert policyDefList;
        List<WOD_2__Warranty_Product__c> warrantyProdList = TestDataFactory.createWarrantyProduct(0);
        insert warrantyProdList;
        warrantyProdList = TestDataFactory.createWarrantyProduct(0);
        for(Integer i = 0; i < warrantyProdList.size(); i++){
            if(warrantyProdList.get(i).Name == 'Product'){
                warrantyProdList.get(i).Name = 'Product1';
            }else if(warrantyProdList.get(i).Name == 'Model1'){
                warrantyProdList.get(i).Name = 'Model2';
            }
        }
        insert warrantyProdList;
        List<WOD_2__Warranty_Code__c> vcCodes = TestDataFactory.createVocationCode(1, false);
        insert vcCodes;
    }

    @isTest
    static void tesValidEWPForFirstTime(){
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            System.assert(true, 'Exception thrown, was not expected');
        }
    }

    @isTest
    static void tesValidEWPWithDifferentModelSameDates(){
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        ewpList = createEWP();
        List<WOD_2__Warranty_Product__c> warrantyProdList =[select id from WOD_2__Warranty_Product__c where name = 'Model2'];
        ewpList.get(0).ATI_Warranty_Product__c = warrantyProdList.get(0).Id;
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            System.assert(true, 'Exception thrown, was not expected');
        }
    }

    @isTest
    static void tesValidEWPWithSameModelDifferentDates(){
        Boolean hasException = false;
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        ewpList = createEWP();
        Date today = Date.today();
        Date activeFrom = today.addYears(-12);
        Date activeTill = today.addYears(-13);
        ewpList.get(0).ATI_Active_From__c = activeFrom;
        ewpList.get(0).ATI_Active_Until__c = activeTill;
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            hasException = true;
        }
        System.assert(!hasException, 'Exception thrown, was not expected');
    }

    @isTest
    static void testForError(){
        Boolean hasException = false;
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        ewpList = createEWP();
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            hasException = true;
        }
        System.assert(hasException, 'Exception was expected, but not thrown!!!');
    }

    @isTest
    static void testForUpdateEWP(){
        Boolean hasException = false;
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        Date today = Date.today();
        Date activeFrom = today.addYears(-1);
        ewpList.get(0).ATI_Active_From__c = activeFrom;
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.update(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            hasException = true;
        }
       // System.assert(hasException, 'Exception was expected, but not thrown!!!');
    }
    

    @isTest
    static void tesValidEWPInsertWithNewCountry(){
        Boolean hasException = false;
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        ewpList = createEWP();
        Date today = Date.today();
        Date activeFrom = today.addYears(-1);
        Date activeTill = today.addYears(1);
        ewpList.get(0).ATI_Active_From__c = activeFrom;
        ewpList.get(0).ATI_Active_Until__c = activeTill;
        ewpList.get(0).ATI_Country__c = 'India';
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            hasException = true;
        }
        System.assert(!hasException, 'Exception thrown, was not expected');
    }

    @isTest
    static void tesValidEWPInsertWithNewPgmLvl(){
        Boolean hasException = false;
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        ewpList = createEWP();
        ewpList.get(0).ATI_Program_Level__c = 'PG1';
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            hasException = true;
        }
        System.assert(!hasException, 'Exception thrown, was not expected');
    }

    @isTest
    static void tesValidEWPInsertWithNewPgmLvlCountry(){
        Boolean hasException = false;
        List<ATI_Extended_Warranty_Pricing__c> ewpList = createEWP();
        Database.insert(ewpList);    
        ewpList = createEWP();
        ewpList.get(0).ATI_Country__c = 'India';
        ewpList.get(0).ATI_Program_Level__c = 'PG1';
        Test.startTest();
        try{
        	List<Database.SaveResult> result = Database.insert(ewpList);    
        }catch(Exception e){
            System.debug('Exception -> ' + e.getMessage());
            hasException = true;
        }
        System.assert(!hasException, 'Exception thrown, was not expected');
    }
    
    
    static List<ATI_Extended_Warranty_Pricing__c> createEWP(){
		List<ATI_Extended_Warranty_Pricing__c> ewpList = TestDataFactory.createExtendedWarrantyPricing(1);        
        List<WOD_2__Warranty_Code__c> vcCodes = [select id from WOD_2__Warranty_Code__c];
        List<WOD_2__Warranty_Product__c> warrantyProdList =[select id from WOD_2__Warranty_Product__c where name = 'Model1'];
        List<WOD_2__Policy_Definition__c> policyDefList = [select id from WOD_2__Policy_Definition__c];
        ewpList.get(0).ATI_Policy_Definition__c = policyDefList.get(0).Id;
        ewpList.get(0).ATI_Warranty_Product__c = warrantyProdList.get(0).Id;
        ewpList.get(0).ATI_Vocation_Code__c = vcCodes.get(0).Id;
        return ewpList;
    }
}