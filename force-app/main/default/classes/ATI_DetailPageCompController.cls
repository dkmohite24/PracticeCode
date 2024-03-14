/* Name: ATI_DetailPageCompController
Description : This class is used to get detail page config settings
Author : TAVANT
History:
Test Class: ATI_DetailPageCompControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_DetailPageCompController {
    /*
        Method Name :   getDetailPageConfig
        Params      :   detailPageMetadataConfigName
                        recordId
    */ 
    @AuraEnabled
    public static WOD_2.ResponseWrapper getDetailPageConfig(String detailPageMetadataConfigName,String recordId) {
        try {
            List<ATI_DetailpageConfiguration__mdt> detailPageConfigList = ATI_DetailPageCompController.queryDetailPageConfig(detailPageMetadataConfigName);
            if(detailPageConfigList != null && detailPageConfigList.size() == 1) {
                if(ATI_DetailPageCompController.validateURL(detailPageConfigList,recordId)) {
                    return new WOD_2.ResponseWrapper(JSON.serialize(detailPageConfigList.get(0)),true,'');
                }else {
                    return new WOD_2.ResponseWrapper('',false,System.Label.ATI_Log_Insufficient_access);
                }
            }else {
                return new WOD_2.ResponseWrapper('{}',false,System.Label.ATI_No_matching_metadata_found_for_config + detailPageMetadataConfigName);
            }
        }catch(Exception e) {return new WOD_2.ResponseWrapper('{}',false,System.Label.ATI_No_matching_metadata_found + e.getStackTraceString());}
        
    }

    /*
        Method Name :   validateURL
        Params      :   detailPageConfigList
                        recordId
    */
    private static Boolean validateURL(List<ATI_DetailpageConfiguration__mdt> detailPageConfigList,String recordId) {
        Boolean result = true;
        if(detailPageConfigList.get(0).DetailPageValidationOverrideClass__c != null) {
            Type objectType = Type.forname(detailPageConfigList.get(0).DetailPageValidationOverrideClass__r.WOD_2__ClassName__c);
            ATI_ValidateDetailPageInterface validateDetailPage = (ATI_ValidateDetailPageInterface) objectType.newInstance();
            result = validateDetailPage.validateDetailPage(recordId);
        }
        return result;
        
    }
    
    /*
        Method Name :   queryDetailPageConfig
        Params      :   detailPageMetadataConfigName
    */
    public static List<ATI_DetailpageConfiguration__mdt> queryDetailPageConfig(String detailPageMetadataConfigName) {
        try {
            List<ATI_DetailpageConfiguration__mdt> detailPageConfigList = [SELECT DeveloperName,HeaderLabel__c,RedirectUrl__c,DetailPageValidationOverrideClass__r.WOD_2__ClassName__c,
                                                                       (SELECT DeveloperName,ATI_Section_Name__c,ATI_Order__c
                                                                        FROM SectionConfigurations__r order by ATI_Order__c)
                                                                       FROM ATI_DetailpageConfiguration__mdt WHERE DeveloperName = :detailPageMetadataConfigName];
            return detailPageConfigList; 
            
        }catch(Exception e) {System.debug('Exception in fetching meta data '+e.getMessage());return null;}
    }

    /*
        Method Name :   queryWithoutShare
        Params      :   queryString
    */
    @AuraEnabled
    public static WOD_2.ResponseWrapper queryWithoutShare(String queryString) {
        WOD_2.ResponseWrapper responseWrapper = new WOD_2.ResponseWrapper('', false,'');
        List<sObject> sObjectList = ATI_QueryRunWithoutSharing.runQuery(queryString);
        
        responseWrapper.data = JSON.serialize(sObjectList);
        responseWrapper.status = true;
        return responseWrapper;
    }
    
    /*
        Method Name :   updateSObjects
        Params      :   sObjectList,allOrNone
    */
    @AuraEnabled
    public static WOD_2.ResponseWrapper updateSObjects(List<sObject> sObjectList, boolean allOrNone){
        WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.updateSObjects(sObjectList,allOrNone);
        return responseWrapperObj;
    }
    
    /*
        Method Name :   hasAccessToClaim
        Params      :   String claimId
    */
    @AuraEnabled
    public static WOD_2.ResponseWrapper hasAccessToClaim(String claimId){
        Boolean hasAccess = false;
        // check record read access is there for the dealer or not
        List<UserRecordAccess>  accessRecords = [SELECT HasReadAccess,RecordId FROM UserRecordAccess WHERE RecordId =:claimId AND UserId =:UserInfo.getuserId()];
        if(!accessRecords.isEmpty()) {
            hasAccess = accessRecords[0].HasReadAccess;
        }
        return new WOD_2.ResponseWrapper('',hasAccess,'');
    }
}