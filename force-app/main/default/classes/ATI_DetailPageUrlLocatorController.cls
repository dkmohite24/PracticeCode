/* Name: ATI_DetailPageUrlLocatorController
Description : This class is used to redirect to detail page
Author : TAVANT
History:
Test Class: ATI_DetailPageUrlLocatorControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_DetailPageUrlLocatorController {
/*
	Method Name	:	getURL
	Params		:	recordId, urlLocatorConfig
*/
@AuraEnabled
public static WOD_2.ResponseWrapper getURL(String recordId, String urlLocatorConfig) {
	system.debug(recordId+'====='+urlLocatorConfig);
	WOD_2__Class_Override_Setting__mdt customMetaData = ATI_DetailPageUrlLocatorController.getCustomMetaData(urlLocatorConfig);
	if(customMetaData != null) {
		Type typeObject = Type.forName(customMetaData.WOD_2__ClassName__c);
		ATI_DetailPageUrlLocatorInterface detailPageUrlLocatorObject = (ATI_DetailPageUrlLocatorInterface)typeObject.newInstance();
		return new WOD_2.ResponseWrapper(detailPageUrlLocatorObject.getURL(recordId),true,'');
	} else {
		return new WOD_2.ResponseWrapper('',true,''); 
	}
}

/*
	Method Name	:	getCustomMetaData
	Params		:	logicName
*/
private static WOD_2__Class_Override_Setting__mdt getCustomMetaData(String logicName) {
	WOD_2__Class_Override_Setting__mdt customSettingData = null;
	WOD_2__Class_Override_Setting__mdt[] comArray = [SELECT MasterLabel, QualifiedApiName,WOD_2__ClassName__c,WOD_2__LogicName__c FROM WOD_2__Class_Override_Setting__mdt Where WOD_2__LogicName__c=:logicName];
	if(comArray.size() != 0 && comArray[0].WOD_2__ClassName__c != null) {
		customSettingData = comArray[0];
	}
	return customSettingData;
}

/*
	Method Name	:	getURLFromMetadata
	Params		:	recordId, detailPageConfigName
*/
public static String getURLFromMetadata(String recordId, String detailPageConfigName) {
	String redirectURL = '';
	List<ATI_DetailpageConfiguration__mdt> detailPageConfigList = ATI_DetailPageCompController.queryDetailPageConfig(detailPageConfigName);
	if(detailPageConfigList != null && detailPageConfigList.size() == 1) {
		redirectURL = redirectURL + detailPageConfigList.get(0).RedirectUrl__c.replace('{id}',recordId).replace('{page}', detailPageConfigName);
	}
    system.debug('redirectURL '+redirectURL);
	return redirectURL;
}
}