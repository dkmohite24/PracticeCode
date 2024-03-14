/* Name: ATI_InventoryPageUrlLocatorController
Description : This class is used to get Inventory Page URL
Author : TAVANT
History:
Test Class: ATI_InventoryPageUrlLocatorCntrlTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_InventoryPageUrlLocatorController implements ATI_DetailPageUrlLocatorInterface {

/*
	Method Name	:	getURL
	Params		:	recordId
*/
@AuraEnabled
public static String getURL(String recordId) {
	String redirectURL = '';
	Boolean hasAccess = false;

	// check record read access is there for the dealer or not
	List<UserRecordAccess>  accessRecords = [SELECT HasReadAccess,RecordId FROM UserRecordAccess WHERE RecordId =:  recordId AND UserId =:UserInfo.getuserId()];
	if(!accessRecords.isEmpty()) {
		hasAccess = accessRecords[0].HasReadAccess;
	}
	String objectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
	String query = 'Select Id,recordType.developerName  FROM ' + objectName + ' WHERE Id =\''+recordId+'\'';
   System.debug('query InventoryPageUrlLocatorController'+query);
	List<WOD_2__Inventory__c> inventoryList = ATI_QueryRunWithoutSharing.runQuery(query); //Database.query(query);
	if(inventoryList != null && inventoryList.size() == 1) {
		if(inventoryList.get(0).recordType.developerName == 'OEM_Stock' || inventoryList.get(0).recordType.developerName == 'Dealer_Stock'||inventoryList.get(0).recordType.developerName == 'Stock') {
      redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'StockInventoryDetailPage');
		}else {
      redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'RetailInventoryDetailPage');
    }
	}
	return redirectURL;
}
}