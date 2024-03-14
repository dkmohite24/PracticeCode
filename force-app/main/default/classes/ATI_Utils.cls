/* Name: ATI_Utils
Description : Utils Class 
Author : Tavant (Akshatha S)
History :
VERSION     AUTHOR                 DATE               DETAIL                                    UserStory/Req#
1.0 -       Tavant (Akshatha S)    02/12/2020          INITIAL DEVELOPMENT
*/

public with sharing class ATI_Utils { 
    
    public static Map<String, WOD_2__Configuration_Setting__mdt> configurationSettingMetadataMap;
    private static ATI_TWODPermissionCache PERMISSION_CACHE = new ATI_TWODPermissionCache();
    private static String comboHash;

    private ATI_Utils(){ // making it singleton to aviod issues later
        
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper getFieldsetDetailsByConfigSettingHaveReadAccess(String objectName,String metadataRecordAPIName) {
        WOD_2__Configuration_Setting__mdt configurationSettingMetaData = ATI_Utils.getConfigurationSettingMetaData(metadataRecordAPIName);
        try{
            if(configurationSettingMetaData != null) {
                //System.debug('objectName>>>> '+objectName+' configurationSettingMetaData>>>> '+configurationSettingMetaData);
                return ATI_Utils.getFieldsetDetailsByFielsetReadAccess(objectName,configurationSettingMetaData.WOD_2__Configuration_Value__c);
            }else{
                //System.debug('No configuration setting available');
                return new WOD_2.ResponseWrapper('[]',false,'No configuration setting available');
            }
        }catch(Exception e) {
            System.debug('Error -getFieldsetDetailsByConfigSettingMetadata- '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    
   /* @AuraEnabled(cacheable = false)
    public static WOD_2.ResponseWrapper getDiagnosticCodes(String objectName,List<String> fields,String claimId) { 
        try{
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheck = ATI_Utils.fetchReadAccess(objectName,fields);
            if(sObjReadAccessCheck.noAccessObjectList.size() == 0 && sObjReadAccessCheck.noAccessFieldList.size() == 0){
                String query = 'SELECT '+String.join(fields,',')+' FROM ' + objectName + ' WHERE Claim__c=\'' + claimId + '\'';
                List<sObject> sObjectLst = Database.query(query);
                return new WOD_2.ResponseWrapper(JSON.serialize(sObjectLst),true,'');
            }else{
                return new WOD_2.ResponseWrapper('[]',false,'Insufficient Access '+sObjReadAccessCheck);
            }
        }catch(Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }*/
    
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper getFieldsetDetailsByFielsetReadAccess(String objectName,String fieldsetName) {
        try{
            List<FieldSetDetailsWrapper> fieldSetDetailsWrapperlist = ATI_Utils.fetchFieldSetDetails(objectName,fieldsetName);
            //adding VIN as picklist value to select in advance claim search
            if(fieldsetName=='ATI_Claim_Search_Dealer'){
                FieldSetDetailsWrapper fieldSetWrapperForVInObj = new FieldSetDetailsWrapper();
                fieldSetWrapperForVInObj.type = 'STRING';
                fieldSetWrapperForVInObj.required = false;
                fieldSetWrapperForVInObj.label = 'VIN';
                fieldSetWrapperForVInObj.fieldpath = 'VIN';
                fieldSetWrapperForVInObj.dbrequired = false;
                fieldSetDetailsWrapperlist.add(fieldSetWrapperForVInObj);
            }
            if(fieldSetDetailsWrapperlist != null && fieldSetDetailsWrapperlist.size() > 0) {
                String accessFields = ATI_Utils.getFieldSetData(objectName,fieldSetDetailsWrapperlist);
                return new WOD_2.ResponseWrapper(accessFields,true,'');
            }else {
                return new WOD_2.ResponseWrapper('[]',true,'No fields in Fieldset');
            }
        }catch(Exception e) {
            System.debug('Error -getFieldsetDetailsByConfigSettingMetadata- '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,e.getMessage());
        }
    }
    
    public static String getFieldSetData(String objectName,List<FieldSetDetailsWrapper> fieldSetDetailsWrapperlist) {
        List<FieldSetDetailsWrapper> readAccessFieldSetDetailsWrapperlist = new List<FieldSetDetailsWrapper>();
        List<String> fieldsetFields = new List<String>();
        for(FieldSetDetailsWrapper fieldSetDetailsWrapperObj : fieldSetDetailsWrapperlist) {
            if(fieldSetDetailsWrapperObj.fieldpath != 'VIN'){
                fieldsetFields.add(fieldSetDetailsWrapperObj.fieldpath);
            }
            if(fieldSetDetailsWrapperObj.fieldpath == 'ATI_Replaced_Inventory__r.WOD_2__Serial_Number__c'){
				fieldSetDetailsWrapperObj.label = 'Replaced Serial Number';                
            }
       }
        NoAccessObjectFieldWrapper noAccessWrapperObject = ATI_Utils.fetchReadAccess(objectName,fieldsetFields);
        if(noAccessWrapperObject.noAccessObjectList.size() == 0 && noAccessWrapperObject.noAccessFieldList.size() > 0) {
            for(FieldSetDetailsWrapper fieldSetDetailsWrapperObj : fieldSetDetailsWrapperlist) {
                if(!noAccessWrapperObject.noAccessFieldList.contains(fieldSetDetailsWrapperObj.fieldpath)) {
                    readAccessFieldSetDetailsWrapperlist.add(fieldSetDetailsWrapperObj);
                }
            }
            return JSON.serialize(readAccessFieldSetDetailsWrapperlist);
        }else {
            //All fields have access
            System.debug('getFieldSetData else   ***   '+JSON.serialize(fieldSetDetailsWrapperlist));
            return JSON.serialize(fieldSetDetailsWrapperlist);
        }
    }
    
    /*
	Method Name :   getConfigurationSettingMetaData
	Description :   Method to get custom metadata
	*/
    public static WOD_2__Configuration_Setting__mdt getConfigurationSettingMetaData(String metadataRecordAPIName) {
        WOD_2__Configuration_Setting__mdt configurationSettingMetaData = null;
        
        configurationSettingMetadataMap = configurationSettingMetadataMap == null ? new Map<String, WOD_2__Configuration_Setting__mdt>() : configurationSettingMetadataMap;
        try{
            // Access check cannot be performed since it is a Custom Metadata
            if(configurationSettingMetadataMap.isEmpty()) {
                for(WOD_2__Configuration_Setting__mdt config: [SELECT MasterLabel, QualifiedApiName, WOD_2__Configuration_Value__c, WOD_2__isActive__c FROM WOD_2__Configuration_Setting__mdt]) {
                    configurationSettingMetadataMap.put(config.QualifiedApiName,config);
                }
                if(!configurationSettingMetadataMap.isEmpty() && configurationSettingMetadataMap.containsKey(metadataRecordAPIName)) {
                    configurationSettingMetaData = configurationSettingMetadataMap.get(metadataRecordAPIName);
                }
            }else {
                if(configurationSettingMetadataMap.containsKey(metadataRecordAPIName)) {
                    configurationSettingMetaData = configurationSettingMetadataMap.get(metadataRecordAPIName);
                }
            }
        }catch(Exception e) {
            system.debug('Exception in Error in getConfigurationSettingMetaData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        System.debug('configurationSettingMetaData ********  ' +configurationSettingMetaData);
        return configurationSettingMetaData;
    }
    
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper updateSObjects(List<sObject> sObjectList, boolean allOrNone){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            Database.SaveResult[] results = Database.Update(sObjectList,allOrNone);
            responseWrapperObj.data = JSON.serialize(results);
            responseWrapperObj.status = true;
        } Catch(Exception e){responseWrapperObj.errormessage = e.getMessage();
                             System.debug(' Error Message ' + e.getMessage() + ' Line # ' + e.getLineNumber());
                            }
        return responseWrapperObj;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper isPartnerUser() {
        List<User> users = [SELECT IsActive,IsPortalEnabled,LastName,Contact.AccountId FROM User where Id = :UserInfo.getUserId()];
        if(users != null && users.size() != 0 && users.get(0).IsPortalEnabled) {
            System.debug('Partner User');
            return new WOD_2.ResponseWrapper(JSON.serialize(true),true,'');
        }else {
            System.debug('Internal User');
            return new WOD_2.ResponseWrapper(JSON.serialize(false),true,'');
        }
    }
    
    public static String buildQueryWithoutAccessCheck(WOD_2.QueryBuilderWrapper queryBuilderWrapperObject){
        String query = '';
        try{
            List<String> fieldsList = new List<String>();
            for(String field : queryBuilderWrapperObject.fieldsToQuery) {
                fieldsList.add(field);
            }
            
            query = 'SELECT '+String.join(queryBuilderWrapperObject.fieldsToQuery,',')+' FROM ' + queryBuilderWrapperObject.fromObject;
            if(queryBuilderWrapperObject.whereClause != null && queryBuilderWrapperObject.whereClause != '' ) {
                query = query + ' WHERE '+queryBuilderWrapperObject.whereClause;
            }
            if(queryBuilderWrapperObject.orderBy != null && queryBuilderWrapperObject.orderBy != '' && queryBuilderWrapperObject.orderBy != ' ') {
                query += ' ORDER BY '+queryBuilderWrapperObject.orderBy;
            }
            if(queryBuilderWrapperObject.recordLimit != null){
                query += ' LIMIT '+queryBuilderWrapperObject.recordLimit;
            }
            return query;
        } catch(Exception e) {System.debug(' Error building query for Lookup ' + e.getMessage() + ' Line # ' + e.getLineNumber());}return query;
    }
    
    public static String buildQuery(WOD_2.QueryBuilderWrapper queryBuilderWrapperObject){
        String query = '';
        try{
            List<String> fieldsList = new List<String>();
            for(String field : queryBuilderWrapperObject.fieldsToQuery) {
                fieldsList.add(field);
            }
            NoAccessObjectFieldWrapper noAccessList = fetchReadAccess(queryBuilderWrapperObject.fromObject,fieldsList);
            if(noAccessList.noAccessObjectList.size() == 0 && noAccessList.noAccessFieldList.size() == 0) {
                query = 'SELECT '+String.join(queryBuilderWrapperObject.fieldsToQuery,',')+' FROM ' + queryBuilderWrapperObject.fromObject + ' WHERE '+queryBuilderWrapperObject.whereClause;
                if(String.isNotBlank(queryBuilderWrapperObject.orderBy)) {
                    query += ' ORDER BY '+queryBuilderWrapperObject.orderBy;
                }
                query += ' LIMIT '+queryBuilderWrapperObject.recordLimit;
                return query;
            }else {throw new TWoDException('Insufficient Access to fields '+ noAccessList.noAccessFieldList);
                  }
        } catch(Exception e) {System.debug(' Error building query for Lookup ' + e.getMessage() + ' Line # ' + e.getLineNumber());}return query;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper checkReadAccess(String objectName, List<String> objectFieldsAPINames){
        SObjectType objectTypeRef;
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = fetchReadAccess(objectName,objectFieldsAPINames);
            responseWrapperObj.data = JSON.serialize(noAccessObjectFieldWrapperObj);
            responseWrapperObj.status = true;
        } Catch(Exception e){
            responseWrapperObj.errormessage = e.getMessage() + ' Line # ' + e.getLineNumber();
            system.debug('Exception in checkReadAccess - Object ' + objectName +' Fields - ' +  objectFieldsAPINames + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperObj;
    }
    
    public static NoAccessObjectFieldWrapper fetchReadAccess(String objectName, List<String> objectFieldsAPINames){
        //System.debug('Inside fetchReadAccess objectName '+objectName);
        //System.debug('fetchReadAccess objectFieldsAPINames '+objectFieldsAPINames);
        SObjectType objectTypeRef;
        NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = ATI_Utils.getValueFromCache('READ', objectName, objectFieldsAPINames);
        if(noAccessObjectFieldWrapperObj == null){
            noAccessObjectFieldWrapperObj = new NoAccessObjectFieldWrapper();
            list<string> noAccessObjectList = new list<string>();
            list<string> noAccessFieldList = new list<string>();
            try{
                SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                //System.debug('fetchReadAccess objectType '+objectType);
                isObjectAccessible(objectName,noAccessObjectList);
                Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
                System.debug('fetchReadAccess fieldsTokenMap '+fieldsTokenMap);
                // Segregate Reference and Fields in the Object Name from the Input field list
                for (String fieldToCheck : objectFieldsAPINames) {
                    fieldToCheck= fieldToCheck.trim();
                    //System.debug('fetchReadAccess fieldToCheck.trim() '+fieldToCheck.trim());
                    if (fieldToCheck.contains('.')) {
                        List<String> referenceFieldPath = fieldToCheck.split('\\.');
                        String parentObjectName = objectName;
                        for(String referenceRelationshipName: referenceFieldPath) {
                           // System.debug('referenceRelationshipName ' + referenceRelationshipName);
                            if(referenceRelationshipName.contains('__r') || referenceRelationshipName.contains('CreatedBy') || referenceRelationshipName.contains('LastModifiedBy') || referenceRelationshipName.contains('Owner') || referenceRelationshipName.contains('RecordType') 
                               || referenceRelationshipName.equalsIgnoreCase('Parent')) {
                                parentObjectName = getRelationshipObjectName(parentObjectName, referenceRelationshipName);
                                objectTypeRef = Schema.getGlobalDescribe().get(parentObjectName);
                                System.debug(parentObjectName  + ' -> ' +  objectTypeRef + ' -> ' + objectTypeRef.getDescribe());
                                if(!objectTypeRef.getDescribe().isAccessible()) {
                                    noAccessObjectList.add(parentObjectName);
                                }
                            } else {
                                Map<String,Schema.SObjectField> fieldsTokenMapRef = objectTypeRef.getDescribe().fields.getMap();
                                if (!fieldsTokenMapRef.get(referenceRelationshipName).getDescribe().isAccessible()) {
                                    noAccessFieldList.add(fieldToCheck);
                                }
                            }
                        }
                    } else{
                        if(fieldToCheck != null && !fieldToCheck.contains('RecordType') && !fieldsTokenMap.get(fieldToCheck).getDescribe().isAccessible()) {
                            noAccessFieldList.add(fieldToCheck);
                        }
                    }
                }
                system.debug('noAccessObjectList**'+noAccessObjectList);
                noAccessObjectFieldWrapperObj.noAccessObjectList = removeDuplicates(noAccessObjectList);
                noAccessObjectFieldWrapperObj.noAccessFieldList= removeDuplicates(noAccessFieldList);
                ATI_Utils.addToCache(noAccessObjectFieldWrapperObj);
            } Catch(Exception e){
                system.debug('Exception in fetchReadAccess - Object ' + objectName +' Fields - ' +  objectFieldsAPINames + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
            }
            system.debug('noAccessObjectFieldWrapperObj *******   '+noAccessObjectFieldWrapperObj);
        }
        return noAccessObjectFieldWrapperObj;
    }
    
    private static void isObjectAccessible(String objectName,List<String> noAccessObjectList) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        //system.debug('objectType.getDescribe().isAccessible()------>' + objectType.getDescribe().isAccessible());
        if(!objectType.getDescribe().isAccessible()) {
            noAccessObjectList.add(objectName);
        }
    }
    
    private static String getRelationshipObjectName(string parentObjectName, String relationshipName){
        String relationshipObjectName = '';
        Map<String, String> fieldRelationshipNameMap = new Map<String, String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(parentObjectName);
        Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
        // Segregate All the Reference Fields from the Object
        for(String objectField : fieldsTokenMap.Keyset()) {
            Schema.DescribeFieldResult fieldDescribe = fieldsTokenMap.get(objectField).getDescribe();
            if(fieldDescribe.getType()==Schema.DisplayType.Reference) {
                if(!fieldRelationshipNameMap.containsKey(objectField)) {
                    fieldRelationshipNameMap.put(objectField,fieldDescribe.getRelationshipName());
                }
            }
        }
        // Get the Parent Object name from the Child object Lookup/Master-detail field name
        for(String fieldRelationshipObjectName : fieldRelationshipNameMap.Keyset()) {
            if(fieldRelationshipNameMap.get(fieldRelationshipObjectName) == relationshipName) {
                List<Schema.sObjectType> parentReferenceList = (fieldsTokenMap.get(fieldRelationshipObjectName)).getDescribe().getReferenceTo();
                relationshipObjectName = parentReferenceList.get(0).getDescribe().getName();         // Need to Check with Harish/Sameer on the get(0)
            }
        }
        return relationshipObjectName;
    }
    
    public static List<FieldSetDetailsWrapper> fetchFieldSetDetails(String objectName, String fieldSetName){
        List<FieldSetDetailsWrapper> fieldSetDetailsWrapperlst = new List<FieldSetDetailsWrapper>();
        try{
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
            system.debug('objectType'+objectType+'**fieldSetName'+fieldSetName);
            List<Schema.FieldSetMember> fieldSetMemberList =  objectType.getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
            List<String> ignoreFieldList = new List<String> {'CreatedBy','LastModifiedBy'};
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    FieldSetDetailsWrapper fieldSetDetailsWrapperObj = new FieldSetDetailsWrapper();
                    fieldSetDetailsWrapperObj.label = fieldSetMemberObj.getLabel();
                    fieldSetDetailsWrapperObj.fieldpath = fieldSetMemberObj.getFieldPath();
                    fieldSetDetailsWrapperObj.type = String.valueof(fieldSetMemberObj.getType());
                    String helpText = '';
                    if(fieldSetDetailsWrapperObj.fieldpath.contains('.') && ignoreFieldList.contains(fieldSetDetailsWrapperObj.fieldpath.split('\\.')[0])) {
                        helpText = '';
                    }else if(fieldSetDetailsWrapperObj.fieldpath.contains('.')) {
                        // String refObjectName = fieldSetDetailsWrapperObj.fieldpath.split('\\.')[0].replace('__r','__c');
                        // String refObjectFieldName = fieldSetDetailsWrapperObj.fieldpath.split('\\.')[1];
                        // helpText = Schema.getGlobalDescribe().get(refObjectName).getDescribe().fields.getMap().get(refObjectFieldName).getDescribe().getInlineHelpText();
                        System.debug(helpText);
                    }else {
                        helpText = (fieldsTokenMap.get(fieldSetDetailsWrapperObj.fieldpath)).getDescribe().getInlineHelpText();
                    }
                    fieldSetDetailsWrapperObj.inlineHelpText = helpText != null ? helpText : '';
                    System.debug('IT '+fieldSetDetailsWrapperObj.inlineHelpText);
                    if(fieldSetDetailsWrapperObj.type==String.valueof(Schema.DisplayType.Reference)) {
                        List<Schema.sObjectType> parentReferenceList = (fieldsTokenMap.get(fieldSetDetailsWrapperObj.fieldpath)).getDescribe().getReferenceTo();
                        List<string> parentReferenceListNames = new List<string>();
                        for(Schema.sObjectType parentreference : parentReferenceList) {
                            parentReferenceListNames.add(parentReferenceList.get(0).getDescribe().getName());
                        }
                        fieldSetDetailsWrapperObj.parentReferenceList = parentReferenceListNames;
                    }
                    fieldSetDetailsWrapperObj.dbrequired = fieldSetMemberObj.getDBRequired();
                    fieldSetDetailsWrapperObj.required = fieldSetMemberObj.getRequired();
                    fieldSetDetailsWrapperlst.add(fieldSetDetailsWrapperObj);
                }
            //System.debug(' fieldSetDetailsWrapperlst BC'+fieldSetDetailsWrapperlst);
        } Catch(Exception e){
            System.debug(' Error Message in fetchFieldSetDetails ' + e.getMessage() + ' Line # ' + e.getLineNumber()+ ' '+e.getStackTraceString());
        }
        System.debug('fieldSetDetailsWrapperlst  **** ' + fieldSetDetailsWrapperlst);
        return fieldSetDetailsWrapperlst;
    }
    
    public static NoAccessObjectFieldWrapper fetchCreateAccess(String objectName, List<String> objectFieldsAPINames){
        SObjectType objectTypeRef;
        NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = ATI_Utils.getValueFromCache('Create', objectName, objectFieldsAPINames);
        if(noAccessObjectFieldWrapperObj == null){
            noAccessObjectFieldWrapperObj = new NoAccessObjectFieldWrapper();
            list<string> noAccessObjectList = new list<string>();
            list<string> noAccessFieldList = new list<string>();
            try{
                SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                ATI_Utils.isObjectCreatable(objectName,noAccessObjectList);
                Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
                // Segregate Reference and Fields in the Object Name from the Input field list
                for (String fieldToCheck : objectFieldsAPINames) {
                    fieldToCheck= fieldToCheck.trim();
                    System.debug('fieldcheck'+fieldToCheck);
                    if (fieldToCheck.contains('.')) {
                        List<String> referenceFieldPath = fieldToCheck.split('\\.');
                        String parentObjectName = objectName;
                        for(String referenceRelationshipName: referenceFieldPath) {
                            if(referenceRelationshipName.contains('__r')) {
                                parentObjectName = getRelationshipObjectName(parentObjectName, referenceRelationshipName);
                                objectTypeRef = Schema.getGlobalDescribe().get(parentObjectName);
                                if(!objectTypeRef.getDescribe().isCreateable()) {
                                    noAccessObjectList.add(parentObjectName);
                                }
                            } else {
                                Map<String,Schema.SObjectField> fieldsTokenMapRef = objectTypeRef.getDescribe().fields.getMap();
                                if (!fieldsTokenMapRef.get(referenceRelationshipName).getDescribe().isCreateable()) {
                                    noAccessFieldList.add(fieldToCheck);
                                }
                            }
                        }
                    } else{
                        if(!fieldsTokenMap.get(fieldToCheck).getDescribe().isCreateable()) {
                            noAccessFieldList.add(fieldToCheck);
                        }
                    }
                }
                noAccessObjectFieldWrapperObj.noAccessObjectList = removeDuplicates(noAccessObjectList);
                noAccessObjectFieldWrapperObj.noAccessFieldList= removeDuplicates(noAccessFieldList);
                ATI_Utils.addToCache(noAccessObjectFieldWrapperObj);
            } Catch(Exception e){
                system.debug('Exception in fetchCreateAccess - Object ' + objectName +' Fields - ' +  objectFieldsAPINames + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
            }
        }
        return noAccessObjectFieldWrapperObj;
    }
    
    private static void isObjectCreatable(String objectName,List<String> noAccessObjectList) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if(!objectType.getDescribe().isCreateable()) {
            noAccessObjectList.add(objectName);
        }
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper querySObjects(String queryString){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            List<SObject> sObjList = new List<SObject>();
            sObjList = Database.query(queryString);
            responseWrapperObj.data = JSON.serialize(sObjList);
            responseWrapperObj.status = true;
        } Catch(Exception e){
            responseWrapperObj.errormessage = e.getMessage();
            System.debug(' Error Message ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperObj;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper checkObjectDeleteAccess(String objectName){
		WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            SObjectType objectType = globalDescribeMap.get(objectName);
            //system.debug('objectType'+objectType);
            if(objectType.getDescribe().isDeletable()) {
				responseWrapperObj.status = true;
            }
        } catch(Exception e) {
			responseWrapperObj.errormessage = e.getMessage() + ' Line # ' + e.getLineNumber();
            system.debug('Exception in checkObjectDeleteAccess - Object ' + objectName + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperObj;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper checkCreateAccess(String objectName, List<String> objectFieldsAPINames){
        SObjectType objectTypeRef;
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = fetchCreateAccess(objectName,objectFieldsAPINames);
            responseWrapperObj.data = JSON.serialize(noAccessObjectFieldWrapperObj);
            responseWrapperObj.status = true;
        } Catch(Exception e){
            responseWrapperObj.errormessage = e.getMessage() + ' Line # ' + e.getLineNumber();
            system.debug('Exception in checkCreateAccess - Object ' + objectName +' Fields - ' +  objectFieldsAPINames + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperObj;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper insertSObjects(List<sObject> sObjectList, boolean allOrNone){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            Database.SaveResult[] results = Database.Insert(sObjectList,allOrNone);
            responseWrapperObj.data = JSON.serialize(results);
            responseWrapperObj.status = true;
        } Catch(Exception e){
            responseWrapperObj.errormessage = e.getMessage();
            System.debug(' Error Message ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperObj;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper checkUpdateAccess(String objectName, List<String> objectFieldsAPINames){
        SObjectType objectTypeRef;
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper('',false,'');
        try{
            NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = fetchUpdateAccess(objectName,objectFieldsAPINames);
            responseWrapperObj.data = JSON.serialize(noAccessObjectFieldWrapperObj);
            responseWrapperObj.status = true;
        } Catch(Exception e){
            responseWrapperObj.errormessage = e.getMessage() + ' Line # ' + e.getLineNumber();
            system.debug('Exception in checkReadAccess - Object ' + objectName +' Fields - ' +  objectFieldsAPINames + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperObj;
    }
    
    public static NoAccessObjectFieldWrapper fetchUpdateAccess(String objectName, List<String> objectFieldsAPINames){
        SObjectType objectTypeRef;
        NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = ATI_Utils.getValueFromCache('Update', objectName, objectFieldsAPINames);
        if(noAccessObjectFieldWrapperObj == null){
            noAccessObjectFieldWrapperObj = new NoAccessObjectFieldWrapper();
            list<string> noAccessObjectList = new list<string>();
            list<string> noAccessFieldList = new list<string>();
            try{
                SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                ATI_Utils.isObjectUpdatable(objectName,noAccessObjectList);
                Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
                // Segregate Reference and Fields in the Object Name from the Input field list
                for (String fieldToCheck : objectFieldsAPINames) {
                    fieldToCheck= fieldToCheck.trim();
                    if (fieldToCheck.contains('.')) {
                        List<String> referenceFieldPath = fieldToCheck.split('\\.');
                        String parentObjectName = objectName;
                        for(String referenceRelationshipName: referenceFieldPath) {
                            if(referenceRelationshipName.contains('__r')) {
                                parentObjectName = getRelationshipObjectName(parentObjectName, referenceRelationshipName);
                                objectTypeRef = Schema.getGlobalDescribe().get(parentObjectName);
                                if(!objectTypeRef.getDescribe().isUpdateable()) {
                                    noAccessObjectList.add(parentObjectName);
                                }
                            } else {
                                Map<String,Schema.SObjectField> fieldsTokenMapRef = objectTypeRef.getDescribe().fields.getMap();
                                if (!fieldsTokenMapRef.get(referenceRelationshipName).getDescribe().isUpdateable()) {
                                    noAccessFieldList.add(fieldToCheck);
                                }
                            }
                        }
                    } else{
                        if(!fieldsTokenMap.get(fieldToCheck).getDescribe().isUpdateable()) {
                            noAccessFieldList.add(fieldToCheck);
                        }
                    }
                }
                noAccessObjectFieldWrapperObj.noAccessObjectList = removeDuplicates(noAccessObjectList);
                noAccessObjectFieldWrapperObj.noAccessFieldList= removeDuplicates(noAccessFieldList);
                ATI_Utils.addToCache(noAccessObjectFieldWrapperObj);
            } Catch(Exception e){
                system.debug('Exception in fetchUpdateAccess - Object ' + objectName +' Fields - ' +  objectFieldsAPINames + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
            }
        }
        return noAccessObjectFieldWrapperObj;
    }
    
    private static void isObjectUpdatable(String objectName,List<String> noAccessObjectList) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if(!objectType.getDescribe().isUpdateable()) {
            noAccessObjectList.add(objectName);
        }
    }
    
    @TestVisible
    private static List<String> removeDuplicates(List<string> stringLst){
        return new List<String>(new Set<String>(stringLst));
    }
    
    //This method is to validate date for Integration
    public static Date parseDate(String dateStr){
        Date validDate = null;
        try{
            if(dateStr.contains('-') && !dateStr.contains('T') && !dateStr.contains(' ')){
                validDate = Date.valueOf(dateStr);
            }/*else{
                validDate = Date.parse(dateStr);
            }*/ 
        }catch(Exception e){
            System.debug('Error parsing date -> ' + dateStr);
        }
        return validDate;
    }
    
    //This method is to validate datatime for Integration
    public static DateTime parseDateTime(String dateTimeStr){
        DateTime validDateTime = null;
        try{
            if(dateTimeStr.contains('-')){
                validDateTime = DateTime.valueOf(dateTimeStr);
            }      
        }catch(Exception e){
            System.debug('Error parsing date -> ' + dateTimeStr);
        }
        return validDateTime;
    }
    
    public static Boolean checkIsBlankData(String str){
        if(String.isBlank(str)){
            return true;
        }else{
            return false;
        }
    }
    
    public static Map<String,CurrencyType> getGlobalCurrencies(Set<String> isoCodeSet){
        Map<String,CurrencyType> mapOfCurrencyTypes = new Map<String,CurrencyType>();
        List<CurrencyType> currecyTypeLst = [SELECT ConversionRate,IsoCode,IsCorporate FROM CurrencyType WHERE IsoCode IN:isoCodeSet];
        if(!currecyTypeLst.isEmpty()){
            for(CurrencyType ct : currecyTypeLst){
                mapOfCurrencyTypes.put(ct.IsoCode,ct);
            }
        }
        return mapOfCurrencyTypes;
    }
    
    public static Boolean checkIsNotBlankData(String str){
        if(String.isNotBlank(str)){
            return true;
        }else{
            return false;
        }
    }
    
  //Modification by Anjali for Dealer of Account Type as Distributor  
    public static boolean isLoggedInUserAsDistributor(){
         String UserID = UserInfo.getUserId();
         String typeStr = 'Distributor';
         boolean isDealerDistributor;
         String userQuery = 'Select Id,IsPortalEnabled,ContactId,AccountId,Name FROM User where Id=:UserID AND Account.Type=: typeStr';
        List<User> userList = Database.Query(userQuery);
        if(!userList.isEmpty()){
            isDealerDistributor= true;
            return isDealerDistributor;
            }
        else{
            isDealerDistributor= false;
            return isDealerDistributor;
        }
    }
    /*Modification end */
    
    /** Punam Get Account currency for Dealer**/
     public static String getAccountCurrencyForDealer(){
         String UserID = UserInfo.getUserId();
         String typeStr = 'Distributor';
         String accountCurrency;
         String userQuery = 'Select Id,Account.CurrencyIsoCode FROM User where Id=:UserID AND Account.Type=: typeStr';
        List<User> userList = Database.Query(userQuery);
        if(userList.isEmpty() || userList[0].Account.CurrencyIsoCode==''){
            accountCurrency='';
            return accountCurrency;
        }
        else{
            accountCurrency= userList[0].Account.CurrencyIsoCode;
            return accountCurrency;
        }
         
    }
    
    private static NoAccessObjectFieldWrapper getValueFromCache(String operationType,String objectType,List<String> fieldList){
        initComboHash(operationType, objectType, fieldList);
        if(ATI_Utils.checkIsNotBlankData(comboHash)){
            return (NoAccessObjectFieldWrapper) PERMISSION_CACHE.getCacheValue(comboHash);
        }
        return null;
    }
    
    private static void addToCache(NoAccessObjectFieldWrapper naofw){
        if(ATI_Utils.checkIsNotBlankData(comboHash)){
            PERMISSION_CACHE.saveToCache(comboHash, naofw, 172800);
        }
    }
    
    private static void initComboHash(String operationType,String objectType,List<String> fieldList){
        System.debug('User Id -> ' + UserInfo.getUserId());
        String userHash = (String)PERMISSION_CACHE.getCacheValue('wodU'+UserInfo.getUserId());
        if(ATI_Utils.checkIsBlankData(comboHash) && ATI_Utils.checkIsNotBlankData(userHash)){
            operationType = operationType == null ? '' : operationType;
            fieldList.sort();
            String requestHash = operationType+String.valueOf(fieldList.hashCode())+objectType;
            comboHash = ATI_TWODPermissionCache.getHashKey(requestHash);
        }
    }
    
    //Method To fetch picklist values dynamically
    @AuraEnabled
    public static Map<String,String> getPicklistOptions(String objectName,String fieldName){
        Map<String,String> mapOfPicklistValues = new Map<String,String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
        list<Schema.PicklistEntry> pickListvalues = fieldsTokenMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry value: pickListvalues) {
            mapOfPicklistValues.put(value.getValue(),value.getLabel());
        }       
        return mapOfPicklistValues;
    }
    
    //Method to check all kinds of access like READ, EDIT, DELETE and throws error if required permissions do not exist
    public static void checkForAccess(String objectName, String accessCheckType, List<String> fieldList){
        ATI_Utils.NoAccessObjectFieldWrapper noAccessWrapper = new ATI_Utils.NoAccessObjectFieldWrapper();
        String errorMessage = '';
        switch on  accessCheckType {
            when  'CREATE'{
                noAccessWrapper = ATI_Utils.fetchCreateAccess(objectName, fieldList);          
            }
            when 'UPDATE' {
                noAccessWrapper = ATI_Utils.fetchUpdateAccess(objectName, fieldList);
            }
            when 'READ'{
                noAccessWrapper = ATI_Utils.fetchReadAccess(objectName, fieldList);
            }
            when 'DELETE'{
                WOD_2.ResponseWrapper response = ATI_Utils.checkObjectDeleteAccess(objectName);
                if( !response.status){
                    errorMessage = System.Label.ATI_Log_Insufficient_access + ' for Object(s) '+objectName+' for Delete operation';
                    throw new TWoDException(errorMessage);
                }
            }
        } 
        if(noAccessWrapper.noAccessObjectList != null && (noAccessWrapper.noAccessObjectList.size() > 0 || noAccessWrapper.noAccessFieldList.size() > 0)){
            errorMessage = System.Label.ATI_Log_Insufficient_access + ' for Object(s) '+objectName;
            if(noAccessWrapper.noAccessFieldList.size() > 0){
                errorMessage += ' for Fields '+String.join(noAccessWrapper.noAccessFieldList, ',') + ' For operation: '+accessCheckType;
            }
            throw new TWoDException(errorMessage); 
        }
    }

    public static WOD_2__Business_Category_Configuration_Setting__c getConfiguration(String configurationName) {
        checkForAccess('WOD_2__Business_Category_Configuration__c', 'READ', new List<String>{'Name'});
        WOD_2__Business_Category_Configuration__c bu = [select Id, Name from WOD_2__Business_Category_Configuration__c where Name = 'ATI'];
        return getConfiguration(bu.Id, configurationName);
    }    
    
    public static Map<String, WOD_2__Business_Category_Configuration_Setting__c> getConfigurationList(List<String> configurationNameList) {
        checkForAccess('WOD_2__Business_Category_Configuration__c', 'READ', new List<String>{'Name'});
        WOD_2__Business_Category_Configuration__c bu = [select Id, Name from WOD_2__Business_Category_Configuration__c where Name = 'ATI'];
        return getConfigurationList(bu.Id, configurationNameList);
    }
    
    public static WOD_2__Business_Category_Configuration_Setting__c getConfiguration(Id buId, String configurationName) {
        return WOD_2.TwodUtility.getConfiguration(buId, configurationName);
    }    
    
    public static Map<String, WOD_2__Business_Category_Configuration_Setting__c> getConfigurationList(Id buId, List<String> configurationNameList) {
        return WOD_2.TwodUtility.getConfigurationList(buId, configurationNameList);
    }


    
    @TestVisible
    public class NoAccessObjectFieldWrapper {
        @AuraEnabled
        public List<string> noAccessObjectList;
        @AuraEnabled
        public List<string> noAccessFieldList;
    }
    
    public class FieldSetDetailsWrapper {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string fieldpath;
        @AuraEnabled
        public string type;
        @AuraEnabled
        public boolean dbrequired;
        @AuraEnabled
        public boolean required;
        @AuraEnabled
        public List<string> parentReferenceList;
        @AuraEnabled
        public String inlineHelpText;
    }
}