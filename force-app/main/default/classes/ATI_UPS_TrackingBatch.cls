/*
	Class Name	:	ATI_UPS_TrackingBatch
	Description	:	Batch apex to track shipments, calling product method shipmentTrackingForUPS
	Developed On:	1st June 2021
	Author		: 	TAVNT (RSG)
*/
global with sharing class ATI_UPS_TrackingBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select Id,WOD_2__Carriers__r.Name from WOD_2__Shipment_Detail__c where WOD_2__Tracking_Status__c !=\'Delivered\' AND '+
            		   'WOD_2__Carriers__c != null AND WOD_2__Status__c =\'Shipped\' AND WOD_2__Tracking_Number__c != null AND WOD_2__Carriers__r.Name=\'UPS\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WOD_2__Shipment_Detail__c> ShipmentList) {
        WOD_2.SHP_ShipmentHandler handlerObj = new WOD_2.SHP_ShipmentHandler();
        WOD_2.ResponseWrapper respo = handlerObj.shipmentTrackingForUPS(ShipmentList[0].Id);
        System.debug('respo------>'+respo);
    }
    
    global void finish(Database.BatchableContext BC) {
     
    } 
}