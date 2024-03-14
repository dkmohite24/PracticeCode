/* Name: ATI_ShipmentTriggerHandler
Description : 
Author : Tavant(MB)
History:
VERSION     AUTHOR            	DATE               DETAIL                  UserStory/Req#
1.0 -     Tavant(MB)        16/03/2021       INITIAL DEVELOPMENT                              
*/
@isTest
public class ATI_ShipmentTriggerHandlerTest {
    
    public @testSetup static void createData(){
        List<Account> accList =  TestDataFactory.createAccount(1);
        
        Group tGroup = new Group();
        tGroup.Name = 'Test Group';
        insert tGroup;
        accList[0].Public_Group_Id__c = tGroup.id;
        insert accList;
        
    }
    @isTest
    public static void testShipment(){
        List<WOD_2__Shipment_Detail__c> shipmentList = TestDataFactory.createShipments(1);
        Account acc = [SELECT id FROM Account LIMIT 1];
        shipmentList[0].WOD_2__Dealer_Account__c = acc.id;
        //User communityUser = new User();
        insert shipmentList;
        List<WOD_2__Shipment_Detail__c> shpmnt=[select id from WOD_2__Shipment_Detail__c limit 1];
        shpmnt[0].WOD_2__Status__c = 'Inspected';
        update shpmnt;
        WOD_2__Shipment_Detail__c shp = new WOD_2__Shipment_Detail__c(); 
        test.startTest();
        ATI_ShipmentTriggerHandler shpment = new ATI_ShipmentTriggerHandler();
        shpment.updateShipmentStatus(shipmentList);
        test.stopTest();
     
    }
}