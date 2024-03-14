/* Name: ATI_CustomRelatedListCompController
Description : This class is used to get configuration setting
Author : TAVANT
History:
Test Class: ATI_CustomRelatedListCompControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_CustomRelatedListCompController {
    /*
Method Name :   getRelatedListData
Params      :   relatedListConfigName
parentRecordId
fetchDataWithoutShare 
*/
    @AuraEnabled
    public static WOD_2.ResponseWrapper getRelatedListData(String relatedListConfigName,String parentRecordId,String fetchDataWithoutShare) {
        try{
            System.debug('getRelatedListData parentRecordId = '+parentRecordId);
            List<String> idList = new List<String>{parentRecordId};
                CustomRelatedListWrapper customRelatedListWrapperObject = new CustomRelatedListWrapper();
            List<ATI_RelatedListConfiguration__mdt> relatedListConfigSettings  = ATI_ConfigSettingsService.getRelatedListSettingMetaData(relatedListConfigName);
            if(relatedListConfigSettings != null && relatedListConfigSettings.size() > 0 ) {
                customRelatedListWrapperObject.relatedListConfig = relatedListConfigSettings.get(0);
                List<ATI_FieldSetDetailService.FieldSetDetailsWrapper> fieldsetDetailWrapperList = ATI_FieldSetDetailService.fetchFieldSetDetails(relatedListConfigSettings.get(0).ATI_ObjectName__c,relatedListConfigSettings.get(0).ATI_FieldsetName__c);
                customRelatedListWrapperObject.fields = fieldsetDetailWrapperList;
                Set<String> fields = new Set<String>();
                System.debug('-- fieldsetDetailWrapperList'+fieldsetDetailWrapperList);
                Map<String,String> fieldAndReferenceFieldMap = new Map<String,String>();
                List<String> ignoreFieldList = new List<String>{'CreatedById'};
                    for(ATI_FieldSetDetailService.FieldSetDetailsWrapper fieldsetObject: fieldsetDetailWrapperList) {
                        if(fieldsetObject.type == 'REFERENCE' && !ignoreFieldList.contains(fieldsetObject.fieldpath)) {
                            String parentField = fieldsetObject.fieldpath.replace('__c','__r')+'.Name';
                            fields.add(parentField);
                            fieldAndReferenceFieldMap.put(fieldsetObject.fieldpath,parentField);
                        }else if(fieldsetObject.type == 'PICKLIST') {
                            fields.add(' toLabel('+fieldsetObject.fieldpath+') ' + fieldsetObject.fieldpath);
                        }else {
                            fields.add(fieldsetObject.fieldpath);
                        }
                    }
                List<String> fieldsList = new List<String>(fields);
                String query = 'SELECT ' + String.join(fieldsList,',') + ',CurrencyISOCode FROM '+relatedListConfigSettings.get(0).ATI_ObjectName__c + ' WHERE '+ relatedListConfigSettings.get(0).ATI_Reference_Field__c +' = :idList';
                System.debug('-- query' +query);
                if(fieldsList.size() > 0) {
                    List<sObject> recordDetailList = new List<sObject>();
                    if(fetchDataWithoutShare == 'YES') {
                        recordDetailList = ATI_QueryRunWithoutSharing.runQueryWithIdsStringList(query,idList);
                    }else {
                        recordDetailList = Database.query(query);
                    }
                    customRelatedListWrapperObject.data = recordDetailList;
                }
                return new WOD_2.ResponseWrapper(JSON.serialize(customRelatedListWrapperObject),true,'');
            }else {
                return new WOD_2.ResponseWrapper('[]',false,System.Label.ATI_No_configuration_found_for_this_related_List);
            }
        }catch(Exception e) {
            system.debug('Exception in Error in getRelatedListData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
            return new WOD_2.ResponseWrapper('{}',false,System.Label.ATI_Error_in_fetching_Data);
        }
    }
    
    /*
Method Name :   getDatatableData
Params      :   relatedListConfigName
whereClause
fetchDataWithoutShare
*/
    @AuraEnabled
    public static WOD_2.ResponseWrapper getDatatableData(String relatedListConfigName,String whereClause,String fetchDataWithoutShare) {
        try{
            CustomRelatedListWrapper customRelatedListWrapperObject = new CustomRelatedListWrapper();
            if(whereClause != 'null') {
                System.debug('getDatatableData relatedListConfigName  = '+relatedListConfigName);
                WOD_2.QueryBuilderWrapper queryBuilderWrapperObject = new WOD_2.QueryBuilderWrapper(); 
                List<ATI_RelatedListConfiguration__mdt> relatedListConfigSettings  = ATI_ConfigSettingsService.getRelatedListSettingMetaData(relatedListConfigName);
                System.debug('relatedListConfigSettings '+relatedListConfigSettings);
                if(relatedListConfigSettings != null && relatedListConfigSettings.size() > 0 ) {
                    customRelatedListWrapperObject.relatedListConfig = relatedListConfigSettings.get(0);
                    List<ATI_FieldSetDetailService.FieldSetDetailsWrapper> fieldsetDetailWrapperList = ATI_FieldSetDetailService.fetchFieldSetDetails(relatedListConfigSettings.get(0).ATI_ObjectName__c,relatedListConfigSettings.get(0).ATI_FieldsetName__c);
                    customRelatedListWrapperObject.fields = fieldsetDetailWrapperList;
                    Set<String> fields = new Set<String>();
                    
                    System.debug('-- fieldsetDetailWrapperList'+fieldsetDetailWrapperList);
                    Map<String,String> fieldAndReferenceFieldMap = new Map<String,String>();
                    List<String> ignoreFieldList = new List<String>{'CreatedById'};
                        for(ATI_FieldSetDetailService.FieldSetDetailsWrapper fieldsetObject: fieldsetDetailWrapperList) {
                            System.debug(fieldsetObject.type + ' '+ fieldsetObject.fieldpath +' ');
                            if(fieldsetObject.type == 'REFERENCE' && !ignoreFieldList.contains(fieldsetObject.fieldpath)) {
                                String parentField = fieldsetObject.fieldpath.replace('__c','__r')+'.Name';
                                fields.add(parentField);
                                fieldAndReferenceFieldMap.put(fieldsetObject.fieldpath,parentField);
                            }
                            // else if(fieldsetObject.type == 'PICKLIST') {
                            //      fields.add(' toLabel('+fieldsetObject.fieldpath+') ' + fieldsetObject.fieldpath);
                            // }
                            else {
                                fields.add(fieldsetObject.fieldpath);
                            }
                        }
                    System.debug('fields'+fields);
                    Integer count = 0;
                    queryBuilderWrapperObject.fieldsToQuery = new List<String>();
                    for(String field : fields) {
                        queryBuilderWrapperObject.fieldsToQuery.add(field);
                    }
                    
                    //update where clause when VIN is selected
                    whereClause = whereClause.trim();
                    if(whereClause.contains('VIN =')){
                        whereClause = getWhereClauseWhenVINPresent(whereClause);
                        if(whereClause=='vin is empty' || whereClause=='invalid vin'){
                            return new WOD_2.ResponseWrapper('',false,System.Label.ATI_Please_provide_valid_VIN);
                        }
                    }
                    
                    queryBuilderWrapperObject.fromObject = relatedListConfigSettings.get(0).ATI_ObjectName__c;
                    queryBuilderWrapperObject.whereClause = whereClause;      
                    queryBuilderWrapperObject.recordLimit = Integer.valueOf(relatedListConfigSettings.get(0).ATI_Limit__c);
                    if(relatedListConfigSettings.get(0).ATI_Orderby__c != null && relatedListConfigSettings.get(0).ATI_Orderby__c != '' && relatedListConfigSettings.get(0).ATI_Orderby__c != ' ') {
                        queryBuilderWrapperObject.OrderBy = relatedListConfigSettings.get(0).ATI_Orderby__c;
                    }else {
                        queryBuilderWrapperObject.OrderBy = '';
                    }
                    System.debug('queryBuilderWrapperObject'+queryBuilderWrapperObject);
                    //System.debug('relatedListConfigSettings.get(0).Class_Override_Setting__r.ClassName__c'+relatedListConfigSettings.get(0).Class_Override_Setting__r.ClassName__c);
                    String recordJSON = ATI_CustomRelatedListCompController.queryTableRecords(queryBuilderWrapperObject,relatedListConfigSettings.get(0).ATI_Class_Override_Setting__r.WOD_2__ClassName__c,fetchDataWithoutShare);
                    List<SObject> claimLst = (List<sObject>)JSON.deserialize(recordJSON,List<sObject>.class);
                    String urlStr ='';
                    if(!claimLst.isEmpty() && relatedListConfigName == 'DT_AdvancedSearch_Claim'){
                        urlStr = ATI_ClaimDetailPageUrlLocatorController.getURL(claimLst[0].Id);
                        if(customRelatedListWrapperObject.relatedListConfig !=NULL && customRelatedListWrapperObject.relatedListConfig.HyperLinkConfigurations__r !=NULL && urlStr!=''
                           && urlStr !='claim record is shared'){
                               for(ATI_HyperLinkConfiguration__mdt hyperlinkConfig : customRelatedListWrapperObject.relatedListConfig.HyperLinkConfigurations__r){
                                   if(hyperlinkConfig.HyperLinkFieldPath__c =='ATI_Claim_Number__c'){
                                       hyperlinkConfig.RedirectUrl__c = urlStr;
                                   }
                               }
                           }
                    }
                    customRelatedListWrapperObject.data = (List<sObject>)JSON.deserialize(recordJSON,List<sObject>.class);
                    return new WOD_2.ResponseWrapper(JSON.serialize(customRelatedListWrapperObject),true,'');
                    
                }else {
                    return new WOD_2.ResponseWrapper('[]',false,System.Label.ATI_No_configuration_found_for_this_related_List);
                }
            } else {
                return new WOD_2.ResponseWrapper(JSON.serialize(customRelatedListWrapperObject),true,'');
            }
            
        }catch(Exception e) {
            system.debug('Exception in Error in getRelatedListData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
            return new WOD_2.ResponseWrapper('{}',false,System.Label.ATI_Error_in_fetching_Data);
        }
    }
    
    private static String getWhereClauseWhenVINPresent(String whereClause){
        String vinStr = '';
        if(whereClause.contains('VIN =')){
            String subStr = 'VIN = \'';
            Integer i = whereClause.indexOfIgnoreCase('\'',whereClause.indexOf(subStr)+7);
            vinStr = whereClause.substring(whereClause.indexOf(subStr),i+1);
        }
        String vinNumber = vinStr.substring(vinStr.indexOf('\'')+1,vinStr.length()-1);
        if(String.isNotBlank(vinNumber)){
            String strToConcat = '(';
            for(WOD_2__Inventory__c invObj : [SELECT Id FROM WOD_2__Inventory__c 
                                              WHERE Id IN (SELECT ATI_Inventory__c FROM ATI_VIN_Transmission_Mapper__c
                                                           WHERE ATI_Vehicle_Information__r.Name=:vinNumber)])
            {
                strToConcat = strToConcat + '\''+invObj.Id+ '\'';
            }
            strToConcat = strToConcat +')';
            if(strToConcat =='()'){
                return 'invalid vin';
            }
            if(whereClause.equalsIgnoreCase(vinStr)){
                whereClause = 'WOD_2__Inventory__c IN '+strToConcat;
            }else if(whereClause.startsWith(vinStr+ ' AND')){
                whereClause = whereClause.replace(vinStr+ ' AND', '');
                System.debug('--11-->'+whereClause);
                whereClause = whereClause + ' AND WOD_2__Inventory__c IN '+strToConcat;
            }else if(whereClause.contains('AND '+vinStr)){
                whereClause = whereClause.replace('AND '+vinStr, '');
                whereClause = whereClause + ' AND WOD_2__Inventory__c IN '+strToConcat;
            }
            System.debug('---->'+whereClause);   
            return whereClause;
        }
        return 'vin is empty';
    }
    
    /*
Method Name :   queryTableRecords
Params      :   querybuilderObject
classOverrideSettingMetadataName
fetchDataWithoutShare
*/
    private Static String queryTableRecords(WOD_2.QueryBuilderWrapper querybuilderObject, String classOverrideSettingMetadataName,String fetchDataWithoutShare){
        WOD_2__Class_Override_Setting__mdt customSettingData = ATI_ConfigSettingsService.getClassOverrideSettingMetaData(classOverrideSettingMetadataName);
        List<sObject> recordDetailList = new List<sObject>();
        if(customSettingData != null) {
            Type typeObject = Type.forName(customSettingData.WOD_2__ClassName__c);
            ATI_TableComponentInterface tableComponentInstance = (ATI_TableComponentInterface) typeObject.newInstance();
            String recordJSON = tableComponentInstance.queryRecords(querybuilderObject);
            return recordJSON;
        }else {
            String query = ATI_Utils.buildQueryWithoutAccessCheck(querybuilderObject);
            if(fetchDataWithoutShare == 'YES') {
                recordDetailList = ATI_QueryRunWithoutSharing.runQuery(query);               
            }else {
                recordDetailList = Database.query(query);
            }
            //Alsn-147
            List<SObject> recordDetailListUpd = new List<SObject>();
            for(SObject invLst : recordDetailList){
                WOD_2__Inventory__c inv = (WOD_2__Inventory__c)invLst; 
                String getInvId = (String)invLst.get('Id');
                List<WOD_2__Warranty_Registration__c> wrList =[select Id,ATI_isExtended__c,WOD_2__Inventory__r.WOD_2__Type__c,WOD_2__Status__c,WOD_2__Inventory__c,WOD_2__Inventory__r.Is_Extended__c from WOD_2__Warranty_Registration__c where WOD_2__Inventory__c =:getInvId and WOD_2__Status__c ='Registered' and ATI_isExtended__c = true and WOD_2__Inventory__r.WOD_2__Type__c ='Retail'];                
                if(wrList.size()>0){
                    inv.Is_Extended__c = true;
                    update inv;
                }
                else{
                    inv.Is_Extended__c = false;
                    update inv;
                }
            }
            //Alsn-147 end
            return JSON.serialize(recordDetailList);
        }
    }
    class CustomRelatedListWrapper {
        public List<ATI_FieldSetDetailService.FieldSetDetailsWrapper> fields;
        public List<sObject> data;
        public ATI_RelatedListConfiguration__mdt relatedListConfig;
    }
}