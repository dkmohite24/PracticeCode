@isTest
public class ATI_UpdatePartDescrOnWPOneTimeBatchTest {
	@testSetup
    private static void setUp(){
        List<WOD_2__Warranty_Product__c> wpLst = TestDataFactory.createWarrantyProduct(202);
        for(WOD_2__Warranty_Product__c wpObj : wpLst){
            if(wpObj.WOD_2__Item_Type__c == 'Machine'){
                wpObj.WOD_2__Item_Type__c = 'Part';
            }
        }
        insert wpLst;
    }
    
    @isTest
    private static void testPartsUpdate(){
        Test.startTest();
        	Database.executeBatch(new ATI_UpdatePartDescrOnWPOneTimeBatch(),200);
        Test.stopTest();
        System.assertEquals(200, [SELECT Id FROM WOD_2__Warranty_Product__c 
                                  	WHERE ATI_Part_Description__c != NULL].size());
    }
}