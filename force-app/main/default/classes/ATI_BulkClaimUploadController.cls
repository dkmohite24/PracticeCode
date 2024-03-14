/* Name: ATI_BulkClaimUploadController
Description : Controller for Bulk Claim Upload
Author : Tavant (Akshatha S)
History : This class is used to upload bulk claim records. Uploaded file is initially stored in WOD_2__Batch_Log__c 
object then proccessed in this class and stored under objected mentioned in ATI_Bulk_Upload_Configuration__mdt.
VERSION     AUTHOR                 DATE               DETAIL                   UserStory/Req#
1.0 -       Tavant (Akshatha S)    02/03/2020         INITIAL DEVELOPMENT
*/
public class ATI_BulkClaimUploadController implements ATI_BulkUploadProcessInterface{
    public static ATI_BulkUploadConfiguration bulkUploadConfigurationObj;
    public static List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst;
    /*
* Proccessing uploaded file based on ATI_Bulk_Upload_Configuration__mdt and insert it
*/
    public static ATI_BatchLogResults parseData(List<Map<String, Object>> mapWRData, String strParentId) {
        ATI_BatchLogResults objBatchLogResult = new ATI_BatchLogResults(); //store process record count with success and failures.
        objBatchLogResult.totalRecordCount = mapWRData.size();
        String recordIdToAttachBatchLogStr = '';
        WOD_2.ResponseWrapper objBatchLogReadAccessCheck = ATI_Utils.checkReadAccess(
            'WOD_2__Batch_Log__c',
            new List<String>{'WOD_2__Process_Type__c'}
        );
        Map<String, Object> accessCheckMap = (Map<String, Object>) Json.deserializeUntyped(objBatchLogReadAccessCheck.data);
        try {
            if (
                objBatchLogReadAccessCheck.status &&
                ((List<Object>) accessCheckMap.get('noAccessObjectList')).isEmpty() &&
                ((List<Object>) accessCheckMap.get('noAccessFieldList')).isEmpty()
            ) {
                String query = 'Select Id,WOD_2__Process_Type__c from WOD_2__Batch_Log__c where Id=: idString';
                List<WOD_2__Batch_Log__c> batchLogLst = (List<WOD_2__Batch_Log__c>) ATI_QueryRunWithSharing.runQueryIdString(query, strParentId); //changed query from without sharing to with sharing
                //fetching bulk upload configuration configuration
                recordIdToAttachBatchLogStr = fetchFieldMappingFromConfig(batchLogLst);
                Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap = new Map<String, ATI_BulkUploadFieldMapping>(); //bulk  upload field mappings with column names
                Map<String, String> referenceFieldWithQueryMap = new Map<String, String>(); //used to put partial query for reference fields from configuration
                Map<String, List<String>> refObjNameWithFieldsAccCheckMap = new Map<String, List<String>>(); //used to check field access for all fields
                //fetching configurations to upload
                ProcessedConfigWrap objProcessedConfigWrap = processConfigurations();
                bulkUploadFieldMappingMap = objProcessedConfigWrap.bulkUploadFieldMappingMap;
                referenceFieldWithQueryMap = objProcessedConfigWrap.referenceFieldWithQueryMap;
                refObjNameWithFieldsAccCheckMap = objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap;
                Map<String, Map<String, String>> referenceValuesToUseMap = new Map<String, Map<String, String>>(); // column name with uploaded value for reference and its Id
                if (!referenceFieldWithQueryMap.isEmpty()) {
                    //itirate through uploaded data to get column value of reference field
                    Map<String, List<String>> referenceFieldValuesMap = getColumnValuesforRefFields(
                        referenceFieldWithQueryMap,
                        mapWRData
                    );
                    //get reference field values list
                    system.debug('>> referenceFieldWithQueryMap :'+referenceFieldWithQueryMap);
                    referenceValuesToUseMap = getValueforReferenceFields(
                        refObjNameWithFieldsAccCheckMap,
                        referenceFieldWithQueryMap,
                        bulkUploadFieldMappingMap,
                        referenceFieldValuesMap
                    );
                }
                Map<Integer,RecordWithResult> recordDataMap = new Map<Integer,RecordWithResult>();
                List<Map<String, Object>> objToMapForErrorLst = new List<Map<String, Object>>(); //list of row data to add in failed records for any error
                Integer i=0;
                for (Map<String, Object> objData : mapWRData) {
                    RecordWithResult objRecordWithResult = createRecordToInsert(
                        objData,
                        bulkUploadFieldMappingMap,
                        referenceFieldWithQueryMap,
                        referenceValuesToUseMap,
                        recordIdToAttachBatchLogStr
                    );
                    if (!objRecordWithResult.isAnyError) {
                        recordDataMap.put(i,objRecordWithResult);
                        i++;
                        objToMapForErrorLst.add(objData);
                    } else {
                        objBatchLogResult.failedRecordCount++;
                        objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + objRecordWithResult.errorStr;
                        System.debug('objBatchLogResult.failedRecords>>>> '+objBatchLogResult.failedRecords);
                    }
                }
                //iteration through uploaded file to insert records
                List<String> columnHeaders = new List<String>();
                for (String strKeys : mapWRData[0].keySet()) {
                    columnHeaders.add(strKeys);
                }
                //save records
                objBatchLogResult = saveProcessedRecords(
                    recordDataMap,
                    objToMapForErrorLst,
                    objBatchLogResult,
                    strParentId,
                    columnHeaders
                );
            } else {
                throw new ATI_Exception(Label.ATI_Log_Insufficient_access);
            }
        } catch (Exception exp) {
            System.debug('====No Access Exception ==' + exp);
            System.debug('====No Access Exception Line==' + exp.getLineNumber());
        }    
        return objBatchLogResult;
    }
    
    /*  
* This method is used fetch configurations based on process type
*/
    private static String fetchFieldMappingFromConfig(List<WOD_2__Batch_Log__c> batchLogLst) {
        String recordIdToAttachBatchLogStr = '';
        //if (!Test.isRunningTest()) {
        // Access check cannot be performed since it is a Custom Metadata
        String processType = String.escapeSingleQuotes(batchLogLst[0].WOD_2__Process_Type__c);
        String queryConfigStr = 'SELECT Id,ATI_Object_API_Name__c,(SELECT Id,ATI_Column_Name__c,ATI_Field_API_Name__c,ATI_Object_API_Name__c,ATI_Display_Name__c,ATI_Type__c,ATI_Reference_Object_API_Name__c,ATI_Reference_Field_API_Name__c,ATI_IsMandatory__c,ATI_Bulk_Upload_Configuration__c,ATI_Query_Filter__c FROM ATI_Bulk_Upload_Field_Mappings__r) FROM ATI_Bulk_Upload_Configuration__mdt WHERE ATI_Process_Type__c =:idString';
        List<ATI_Bulk_Upload_Configuration__mdt> bulkUploadConfigLst = (List<ATI_Bulk_Upload_Configuration__mdt>) ATI_QueryRunWithSharing.runQueryIdString(
            queryConfigStr,
            processType
        );
        bulkUploadConfigurationObj = new ATI_BulkUploadConfiguration();
        bulkUploadConfigurationObj.objectApiNameStr = bulkUploadConfigLst[0].ATI_Object_API_Name__c;
        if (!bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r.isEmpty()) {
            bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
            for(ATI_Bulk_Upload_Field_Mapping__mdt objBulkUploadFieldMap : bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r) {
                ATI_BulkUploadFieldMapping objFieldMapping = new ATI_BulkUploadFieldMapping();
                objFieldMapping.fieldAPIName = objBulkUploadFieldMap.ATI_Field_API_Name__c;
                objFieldMapping.objectAPIName = objBulkUploadFieldMap.ATI_Object_API_Name__c ;
                objFieldMapping.columnName = objBulkUploadFieldMap.ATI_Column_Name__c;
                objFieldMapping.isMandatory = objBulkUploadFieldMap.ATI_IsMandatory__c;
                objFieldMapping.referenceFieldAPIName = objBulkUploadFieldMap.ATI_Reference_Field_API_Name__c;
                objFieldMapping.referenceObjectAPIName = objBulkUploadFieldMap.ATI_Reference_Object_API_Name__c;
                objFieldMapping.type = objBulkUploadFieldMap.ATI_Type__c;
                objFieldMapping.displayName = objBulkUploadFieldMap.ATI_Display_Name__c;
                objFieldMapping.queryFilter = objBulkUploadFieldMap.ATI_Query_Filter__c;
                //System.debug('objFieldMapping>>>> '+objFieldMapping);
                bulkUploadFieldMappingLst.add(objFieldMapping);
            }
        }
        //}
        return recordIdToAttachBatchLogStr;
    }
    
    /*
this method is used process the configuration to get reference fields
*/
    private static ProcessedConfigWrap processConfigurations() {
        ProcessedConfigWrap objProcessedConfigWrap = new ProcessedConfigWrap();
        objProcessedConfigWrap.bulkUploadFieldMappingMap = new Map<String, ATI_BulkUploadFieldMapping>(); //bulk  upload field mappings with column names
        objProcessedConfigWrap.referenceFieldWithQueryMap = new Map<String, String>(); //used to put partial query for reference fields from configuration
        objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap = new Map<String, List<String>>(); //used to check field access for all fields
        
        //fetching configurations to upload
        for (ATI_BulkUploadFieldMapping objBulkUploadFieldMap : bulkUploadFieldMappingLst) {
            objProcessedConfigWrap.bulkUploadFieldMappingMap.put(objBulkUploadFieldMap.columnName, objBulkUploadFieldMap);
            //System.debug('bulkUploadFieldMappingMap>>>> '+objBulkUploadFieldMap);
            //framing query for reference fields
            if (objBulkUploadFieldMap.type == 'Reference') {
                if (objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap.containsKey(objBulkUploadFieldMap.referenceObjectAPIName))
                    objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap.get(objBulkUploadFieldMap.referenceObjectAPIName).add(objBulkUploadFieldMap.referenceFieldAPIName);
                else
                    objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap.put(
                        objBulkUploadFieldMap.referenceObjectAPIName,
                        new List<String>{ objBulkUploadFieldMap.referenceFieldAPIName }
                    );
                
                String strQuery = '';
                Boolean hasQueryFilter = String.isNotBlank(objBulkUploadFieldMap.queryFilter);
                if (objBulkUploadFieldMap.referenceFieldAPIName != 'Id') {
                    if(objBulkUploadFieldMap.referenceFieldAPIName == 'WOD_2__Serial_Number__c'){ //Alsn-174 added extended base model field in query
                        strQuery =
                            'Select Id,WOD_2__Item__c,WOD_2__Item__r.WOD_2__Description__c,WOD_2__Item__r.Extended_Base_Model__c,WOD_2__Business_Unit__c,' +
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' FROM ' +
                            objBulkUploadFieldMap.referenceObjectAPIName +
                            ' WHERE ' +
                            ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' IN: ';
                    }
                    //Alsn-154
                    else if(objBulkUploadFieldMap.columnName == 'Primary Failed Part'){
                        strQuery =
                            'Select WOD_2__Description__c,WOD_2__Business_Unit__c,' +
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' FROM ' +
                            objBulkUploadFieldMap.referenceObjectAPIName +
                            ' WHERE ' +
                            ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' IN: ';
                    }
                    // end of Alsn-154
                    else if(objBulkUploadFieldMap.columnName == 'Business Partner'){
                        strQuery =
                            'Select Id,CurrencyIsoCode,ATI_Currency__c,' +
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' FROM ' +
                            objBulkUploadFieldMap.referenceObjectAPIName +
                            ' WHERE ' +
                            ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' IN: ';
                    }else if(objBulkUploadFieldMap.columnName == 'Claim Number'){
                        strQuery =
                            'Select Id,WOD_2__Claim_Status__c,' +
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' FROM ' +
                            objBulkUploadFieldMap.referenceObjectAPIName +
                            ' WHERE ' +
                            ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' IN: ';
                    }else{
                        strQuery =
                            'Select Id,' +
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' FROM ' +
                            objBulkUploadFieldMap.referenceObjectAPIName +
                            ' WHERE ' +
                            ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                            objBulkUploadFieldMap.referenceFieldAPIName +
                            ' IN: ';
                    }
                    objProcessedConfigWrap.referenceFieldWithQueryMap.put(objBulkUploadFieldMap.columnName, strQuery);
                } else {
                    strQuery =
                        'SELECT ' +
                        objBulkUploadFieldMap.referenceFieldAPIName +
                        ' FROM ' +
                        objBulkUploadFieldMap.referenceObjectAPIName +
                        ' WHERE ' +
                        ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                        objBulkUploadFieldMap.referenceFieldAPIName +
                        ' IN: ';
                    objProcessedConfigWrap.referenceFieldWithQueryMap.put(objBulkUploadFieldMap.columnName, strQuery);
                }
            }
        }
        return objProcessedConfigWrap;
    }
    
    /*
this method is used save the records
*/
    private static RecordWithResult createRecordToInsert(Map<String,Object> bulkUploadDataMap,
                                                         Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap,
                                                         Map<String, String> referenceFieldWithQueryMap,
                                                         Map<String, Map<String, String>> referenceValuesToUseMap,
                                                         String recordIdToAttachBatchLogStr
                                                        ) { // Claim Obj, part, labor, Othercost etc 
                                                            RecordWithResult objRecordWithResult = new RecordWithResult();
                                                            SObject claimSObject = Schema.getGlobalDescribe().get(bulkUploadConfigurationObj.objectApiNameStr).newSObject();
                                                            SObject ServiceCampaign = Schema.getGlobalDescribe().get('twodcms__Service_Campaign__c').newSObject();
                                                            SObject claimTemplate = Schema.getGlobalDescribe().get('WOD_2__Claim__c').newSObject();
                                                            
                                                            //objects for stock claim
                                                            SObject wrInfoSObject = Schema.getGlobalDescribe().get('WOD_2__Warranty_Registration__c').newSObject();
                                                            SObject vehicleInfoSObject = Schema.getGlobalDescribe().get('ATI_Vehicle_Information__c').newSObject();
                                                            SObject customerInfoSObject = Schema.getGlobalDescribe().get('Account').newSObject();
                                                            
                                                            //SObject partSObject = Schema.getGlobalDescribe().get('WOD_2__Claim_Part__c').newSObject();
                                                            List<WOD_2__Claim_Part__c> partSObject = new List<WOD_2__Claim_Part__c>();
                                                            List<WOD_2__Claim_Service_Information__c> laborSObject =  new List<WOD_2__Claim_Service_Information__c>();
                                                            List<WOD_2__Other_Cost__c> otherCostSObject =  new List<WOD_2__Other_Cost__c>();
                                                            List<ATI_Diagnostic_Code__c> diaCodeSObject =  new List<ATI_Diagnostic_Code__c>();
                                                            String errorStr = '';
                                                            String strCoulumVal = '';
                                                            try{
                                                                //Anjali added for Campaign claim functionality for Bulk
                                                                System.debug('bulkUploadDataMap--->'+bulkUploadDataMap);
                                                                System.debug('bulkUploadDataMap12--->'+bulkUploadDataMap.get('Pre-Authorization Required'));
                                                                List<twodcms__Campaign_Members__c> cmpMem = [Select id from twodcms__Campaign_Members__c where twodcms__Service_Campaign__r.Name =:string.valueof(bulkUploadDataMap.get('Service Campaign Name')) and   twodcms__Inventory__r.Name =:string.valueof(bulkUploadDataMap.get('Serial Number')) ];                                                                                                          
                                                                if(bulkUploadDataMap.get('Claim Type') =='Campaign')
                                                                {
                                                                    //Alsn-169
                                                                    if(cmpMem.size()==0){
                                                                           errorStr +='8033-SN not eligible for specified campaign'+'\n';
                                                                    }
                                                                    // end of Alsn-169
                                                                    if(String.isBlank(string.valueof(bulkUploadDataMap.get('Claim Number'))) && 
                                                                       String.isBlank(string.valueof(bulkUploadDataMap.get('Service Campaign Name'))) && String.isBlank(string.valueof(bulkUploadDataMap.get('Claim Template Name')))){
                                                                           errorStr +='Service Campaign Name and Claim Template Name is mandatory'+'\n'; 
                                                                       }
                                                                    else if(String.isBlank(string.valueof(bulkUploadDataMap.get('Claim Number'))) && String.isBlank(string.valueof(bulkUploadDataMap.get('Claim Template Name')))){
                                                                        errorStr +='Claim Template Name is mandatory'+'\n'; 
                                                                    }
                                                                    else if(String.isBlank(string.valueof(bulkUploadDataMap.get('Claim Number'))) && String.isBlank(string.valueof(bulkUploadDataMap.get('Service Campaign Name')))){
                                                                        errorStr +='Service Campaign Name is mandatory'+'\n'; 
                                                                    }
                                                                    /*else if(String.isBlank(string.valueof(bulkUploadDataMap.get('Claim Template Name')))){
errorStr +='Claim Template Name is mandatory'+'\n'; 
}*/
                                                                    //now added
                                                                    else if(bulkUploadDataMap.get('Pre-Authorization Required')== 'TRUE')
                                                                    {
                                                                        errorStr +='Pre Auth should not be true for Campaign claim'+'\n';
                                                                    }
                                                                    else if(String.isBlank(string.valueof(bulkUploadDataMap.get('Failure Code'))))
                                                                    {
                                                                        errorStr +='Failure Code is Mandatory'+'\n'; 
                                                                    }
                                                                    if(String.isNotBlank(errorStr)){
                                                                        objRecordWithResult.isAnyError = true;
                                                                    }
                                                                    System.debug('errorStr--->Campain'+errorStr);
                                                                }
                                                                //End of Modification
                                                                
                                                                for(String strKeys : bulkUploadDataMap.keySet()){
                                                                    ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strKeys);
                                                                    //ignore columns if not present in configuration
                                                                    if(objfielMapMdt != null){
                                                                        String fieldAPIName = objfielMapMdt.fieldAPIName;
                                                                        //Anjali Added
                                                                        if(objfielMapMdt.objectAPIName == 'twodcms__Service_Campaign__c' && objfielMapMdt.columnName == 'Service Campaign Name'){
                                                                            ServiceCampaign.put('Name',bulkUploadDataMap.get(strKeys));
                                                                            
                                                                        }
                                                                        if(objfielMapMdt.objectAPIName == 'WOD_2__Claim__c' && objfielMapMdt.columnName == 'Claim Template Name'){
                                                                            claimTemplate.put('Name',bulkUploadDataMap.get(strKeys));
                                                                        }
                                                                        //End of modification
                                                                        if(objfielMapMdt.objectAPIName != 'WOD_2__Claim_Part__c' && objfielMapMdt.objectAPIName != 'WOD_2__Claim_Service_Information__c' && 
                                                                           objfielMapMdt.objectAPIName != 'WOD_2__Other_Cost__c' && objfielMapMdt.objectAPIName != 'ATI_Diagnostic_Code__c'){
                                                                               strCoulumVal = (String)bulkUploadDataMap.get(strKeys);
                                                                               strCoulumVal = strCoulumVal.unescapeUnicode();
                                                                           }
                                                                        if(objfielMapMdt.objectAPIName == 'WOD_2__Claim_Part__c'){
                                                                            //string partVal = string.valueof(bulkUploadDataMap.get(strKeys)).replaceAll('\\(','[').replaceAll('\\)',']').replaceAll('\\{','{"').replaceAll('=','":"').replaceAll('}, ','"},').replaceAll(', ','","').replaceAll('}]','"}]');
                                                                            //partSObject = (List<WOD_2__Claim_Part__c>)Json.deserialize(partVal, List<WOD_2__Claim_Part__c>.class);
                                                                            //system.debug('partSObject===>'+partSObject);
                                                                            partSObject = (List<WOD_2__Claim_Part__c>)Json.deserialize(JSON.serialize(bulkUploadDataMap.get(strKeys)), List<WOD_2__Claim_Part__c>.class);
                                                                            
                                                                        }
                                                                        if(objfielMapMdt.objectAPIName == 'WOD_2__Claim_Service_Information__c'){
                                                                            //string laborVal = string.valueof(bulkUploadDataMap.get(strKeys)).replaceAll('\\(','[').replaceAll('\\)',']').replaceAll('\\{','{"').replaceAll('=','":"').replaceAll('}, ','"},').replaceAll(', ','","').replaceAll('}]','"}]');
                                                                            laborSObject = (List<WOD_2__Claim_Service_Information__c>)Json.deserialize(JSON.serialize(bulkUploadDataMap.get(strKeys)), List<WOD_2__Claim_Service_Information__c>.class);
                                                                            //system.debug('laborSObject===>'+laborSObject);
                                                                        }
                                                                        if(objfielMapMdt.objectAPIName == 'WOD_2__Other_Cost__c'){
                                                                            //string otherCostVal = string.valueof(bulkUploadDataMap.get(strKeys)).replaceAll('\\(','[').replaceAll('\\)',']').replaceAll('\\{','{"').replaceAll('=','":"').replaceAll('}, ','"},').replaceAll(', ','","').replaceAll('}]','"}]');
                                                                            otherCostSObject = (List<WOD_2__Other_Cost__c>)Json.deserialize(JSON.serialize(bulkUploadDataMap.get(strKeys)), List<WOD_2__Other_Cost__c>.class);
                                                                            //system.debug('otherCostSObject===>'+otherCostSObject);
                                                                        }
                                                                        if(objfielMapMdt.objectAPIName == 'ATI_Diagnostic_Code__c'){
                                                                            //string diaCodeVal = string.valueof(bulkUploadDataMap.get(strKeys)).replaceAll('\\(','[').replaceAll('\\)',']').replaceAll('\\{','{"').replaceAll('=','":"').replaceAll('}, ','"},').replaceAll(', ','","').replaceAll('}]','"}]');
                                                                            diaCodeSObject = (List<ATI_Diagnostic_Code__c>)Json.deserialize(JSON.serialize(bulkUploadDataMap.get(strKeys)), List<ATI_Diagnostic_Code__c>.class);
                                                                            //system.debug('diaCodeSObject===>'+diaCodeSObject);
                                                                        }
                                                                        
                                                                        if(objfielMapMdt.isMandatory == true){
                                                                            if(objfielMapMdt.columnName == 'In-Service Date'){ 
                                                                                if(String.valueOf(bulkUploadDataMap.get('Pre-Delivery')).equalsIgnoreCase('false') && String.isBlank(strCoulumVal)){ //In-Service Date not Mandatory for Pre-Delivery
                                                                                    errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                                }
                                                                                if(String.valueOf(bulkUploadDataMap.get('Pre-Delivery')).equalsIgnoreCase('true') && !String.isBlank(strCoulumVal)){
                                                                                    errorStr += Label.ATI_BulkWR_InServiceDate_ValidationMessage;
                                                                                }
                                                                            }else if(objfielMapMdt.columnName == 'Replacement Type'){
                                                                                if(String.valueOf(bulkUploadDataMap.get('Transmission Replaced?')).equalsIgnoreCase('true')){ 
                                                                                    if(String.isBlank(strCoulumVal)){
                                                                                        errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                                    }else if(!(String.valueOf(bulkUploadDataMap.get('Replacement Type')).equalsIgnoreCase('retran') || String.valueOf(bulkUploadDataMap.get('Replacement Type')).equalsIgnoreCase('swing'))){
                                                                                        errorStr += objfielMapMdt.columnName + ' is Invalid' + '\n';
                                                                                    }
                                                                                }
                                                                            }else if(objfielMapMdt.columnName == 'Replaced Serial Number'){
                                                                                objfielMapMdt.IsMandatory = false;
                                                                                if(String.valueOf(bulkUploadDataMap.get('Transmission Replaced?')).equalsIgnoreCase('true')){ 
                                                                                    if(String.isBlank(strCoulumVal)){
                                                                                        errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                                    }else{
                                                                                        objfielMapMdt.IsMandatory = true;
                                                                                    }
                                                                                }
                                                                            }else if(String.isBlank(strCoulumVal)){
                                                                                errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                            }
                                                                        }
                                                                        if(!referenceFieldWithQueryMap.isEmpty() && referenceFieldWithQueryMap.containsKey(strKeys)){
                                                                            if(objfielMapMdt.IsMandatory == true && (referenceValuesToUseMap.isEmpty() || !referenceValuesToUseMap.containsKey(strKeys) || !referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal.trim()))){
                                                                                errorStr += 'Invalid '+objfielMapMdt.columnName+'\n';
                                                                            }
                                                                            if(!referenceValuesToUseMap.isEmpty() && referenceValuesToUseMap.containsKey(strKeys) && referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal.trim())){
                                                                                if(objfielMapMdt.objectAPIName == bulkUploadConfigurationObj.objectApiNameStr){
                                                                                    if(strKeys == Label.ATI_BulkWR_Serial_Number){
                                                                                        claimSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[0]); 
                                                                                        claimSObject.put('WOD_2__Model_Number__c',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[1]);
                                                                                        if(referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[2] != null){
                                                                                            claimSObject.put('WOD_2__Description__c',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[2]);
                                                                                            System.debug('-------11111111122'+referenceValuesToUseMap);
                                                                                        }else{
                                                                                            claimSObject.put('WOD_2__Description__c','');
                                                                                            System.debug('-------11111111122'+referenceValuesToUseMap);
                                                                                        }
                                                                                        claimSObject.put('WOD_2__BusinessCategory__c',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[3]);
                                                                                    }else if(strKeys == 'Business Partner'){
                                                                                        claimSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[0]); 
                                                                                        claimSObject.put('CurrencyIsoCode',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[1]);                
                                                                                    }
                                                                                    //Alsn-154
                                                                                    else if(strKeys == 'Primary Failed Part'){
                                                                                        claimSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[0]); 
                                                                                        claimSObject.put('WOD_2__Causal_Part_Description__c',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[1]);                
                                                                                    }
                                                                                    // end of Alsn-154
                                                                                    else if(strKeys == 'Claim Number'){
                                                                                        claimSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[0]); 
                                                                                        claimSObject.put('WOD_2__Claim_Status__c',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[1]); 
                                                                                    }
                                                                                    else{
                                                                                        claimSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim())); // Lookup Assignments
                                                                                    } 
                                                                                }
                                                                                if(objfielMapMdt.objectAPIName == 'WOD_2__Warranty_Registration__c'){
                                                                                    wrInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()));
                                                                                }
                                                                            }
                                                                        }else{
                                                                            if(objfielMapMdt.objectAPIName == bulkUploadConfigurationObj.objectApiNameStr && objfielMapMdt.columnName != 'Claim Template Name'){
                                                                                claimSObject = processSobjectField(claimSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'ATI_Vehicle_Information__c' && !String.isBlank(strCoulumVal)){
                                                                                vehicleInfoSObject = processSobjectField(vehicleInfoSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'Account'){
                                                                                customerInfoSObject = processSobjectField(customerInfoSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'WOD_2__Warranty_Registration__c'){
                                                                                wrInfoSObject = processSobjectField(wrInfoSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }catch(Exception exp){
                                                                objRecordWithResult.isAnyError = true;
                                                                errorStr += exp.getMessage();
                                                                System.debug('errorStr>>>>> '+errorStr+' >>>>>> '+exp.getLineNumber());
                                                                //break;
                                                            }
                                                            
                                                            if(String.isNotBlank(errorStr)){
                                                                objRecordWithResult.isAnyError = true;
                                                            }
                                                            
                                                            if(!objRecordWithResult.isAnyError){
                                                                objRecordWithResult.laborSObject = laborSObject;
                                                                objRecordWithResult.diaCodeSObject = diaCodeSObject;
                                                                objRecordWithResult.otherCostSObject = otherCostSObject;
                                                                objRecordWithResult.partSObject = partSObject;
                                                                objRecordWithResult.claimSObject = claimSObject;
                                                                objRecordWithResult.ServiceCampaign = ServiceCampaign;
                                                                objRecordWithResult.claimTemplate = claimTemplate;
                                                                objRecordWithResult.vehicleInfoSObject = vehicleInfoSObject;
                                                                objRecordWithResult.customerInfoSObject = customerInfoSObject;
                                                                objRecordWithResult.wrInfoSObject = wrInfoSObject;
                                                            }else {
                                                                String failedRecordStr = '';
                                                                Integer i = 0;
                                                                for(String st : bulkUploadDataMap.keySet()){
                                                                    /*if(st == 'Parts' || st == 'Labor' || st == 'OtherCost' || st == 'DiagnosticCode'){
List<Object> bulkData = (List<Object>)bulkUploadDataMap.get(st);
failedRecordStr += '"';
for(Object data : bulkData){
Map<String,Object> bulkDataMap = (Map<String,Object>)data;
failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
}
failedRecordStr += '",';
}else{
if(i == 0){
failedRecordStr += bulkUploadDataMap.get(st)+',';
}else{
failedRecordStr += '"'+bulkUploadDataMap.get(st)+'",';
}
}
i++;*/
                                                                    if(st != 'Parts' && st != 'Labor' && st != 'OtherCost' && st != 'DiagnosticCode'){
                                                                        if(i == 0){
                                                                            failedRecordStr += bulkUploadDataMap.get(st)+',';
                                                                        }else{
                                                                            failedRecordStr += '"'+bulkUploadDataMap.get(st)+'",';
                                                                        }
                                                                    }
                                                                    i++;
                                                                }
                                                                
                                                                
                                                                /* for(String st : bulkUploadDataMap.keySet()){
if(st == 'Parts' || st == 'Labor' || st == 'OtherCost' || st == 'DiagnosticCode'){
List<Object> bulkData = (List<Object>)bulkUploadDataMap.get(st);
failedRecordStr += '"';
for(Object data : bulkData){
Map<String,Object> bulkDataMap = (Map<String,Object>)data;
failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
}
failedRecordStr += '",';
}
} */
                                                                
                                                                if(!bulkUploadDataMap.containsKey('Parts')){
                                                                    failedRecordStr += '"'+'",';
                                                                }
                                                                else{
                                                                    List<Object> bulkData = (List<Object>)bulkUploadDataMap.get('Parts');
                                                                    failedRecordStr += '"';
                                                                    for(Object data : bulkData){
                                                                        Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                                                        failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                                                                    }
                                                                    failedRecordStr += '",';
                                                                }
                                                                
                                                                if(!bulkUploadDataMap.containsKey('Labor')){
                                                                    failedRecordStr += '"'+'",';
                                                                }
                                                                else
                                                                {
                                                                    List<Object> bulkData = (List<Object>)bulkUploadDataMap.get('Labor');
                                                                    failedRecordStr += '"';
                                                                    for(Object data : bulkData){
                                                                        Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                                                        failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                                                                    }
                                                                    failedRecordStr += '",';  
                                                                }
                                                                if(!bulkUploadDataMap.containsKey('OtherCost')){
                                                                    failedRecordStr += '"'+'",';
                                                                }
                                                                else{
                                                                    List<Object> bulkData = (List<Object>)bulkUploadDataMap.get('OtherCost');
                                                                    failedRecordStr += '"';
                                                                    for(Object data : bulkData){
                                                                        Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                                                        failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                                                                    }
                                                                    failedRecordStr += '",';
                                                                }
                                                                if(!bulkUploadDataMap.containsKey('DiagnosticCode')){
                                                                    failedRecordStr += '"'+'",';
                                                                }
                                                                else{
                                                                    List<Object> bulkData = (List<Object>)bulkUploadDataMap.get('DiagnosticCode');
                                                                    failedRecordStr += '"';
                                                                    for(Object data : bulkData){
                                                                        Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                                                        failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                                                                    }
                                                                    failedRecordStr += '",';
                                                                }
                                                                System.debug('failedRecordStr--->'+failedRecordStr);
                                                                objRecordWithResult.errorStr = failedRecordStr+'"'+errorStr+'"\n';
                                                            }
                                                            return objRecordWithResult;
                                                        }
    
    /*
Method to process field values and added it to sobject
*/
    private static SObject processSobjectField(
        SObject objSObject,
        string fieldAPIName,
        ATI_BulkUploadFieldMapping objfielMapMdt,
        String strCoulumVal
    ) {
        if (objfielMapMdt.type == 'Decimal') {
            if(strCoulumVal != '')
                objSObject.put(fieldAPIName, decimal.valueOf(strCoulumVal));
            else {
                objSObject.put(fieldAPIName, null);
            }
        } else if (objfielMapMdt.type == 'Integer') {
            if(strCoulumVal != '') {
                objSObject.put(fieldAPIName, Integer.valueOf(strCoulumVal));
            }else {
                objSObject.put(fieldAPIName, null);
            }
        } else if (objfielMapMdt.type == 'Date') {
            if(strCoulumVal != '') {    
                //Alsn-165
                Integer day=integer.valueof(strCoulumVal.substringBetween('/'));
                Integer month = integer.valueof(strCoulumVal.substringBefore('/')); 
                if(month <=12){
                    if(UserInfo.getLocale().contains('th')){
                        Integer thaiYear=integer.valueof(strCoulumVal.right(4)) +543;
                        Date dateValue = Date.newInstance(thaiYear,month,day);
                        String formattedDate = dateValue.format();
                        objSObject.put(fieldAPIName, Date.parse(formattedDate)); 
                    }else{
                        Integer year = integer.valueof(strCoulumVal.right(4));
                        Date dateValue = Date.newInstance(year,month,day);
                        String formattedDate = dateValue.format();
                        objSObject.put(fieldAPIName, Date.parse(formattedDate)); 
                    }    
                }else{
                    throw new ATI_Exception('Invalid Date'); 
                }
                //end of Alsn-165
            } else {
                objSObject.put(fieldAPIName, null);
            }
        } else if (objfielMapMdt.type == 'DateTime') {
            if(strCoulumVal != '') {
                //Alsn-165
                if(UserInfo.getLocale().contains('th')){
                Integer year=integer.valueof(strCoulumVal.substringBefore('-'))+543;
                String thaiyear = string.valueOf(year);
                strCoulumVal = strCoulumVal.replace(strCoulumVal.substringBefore('-'), thaiyear);
                String replacedString = strCoulumVal.replace('T', ' ');
                String finalDateTimeString = replacedString.replace('Z', '');
                Datetime gmt = datetime.valueOfGMT(finalDateTimeString);
                Integer offset = UserInfo.getTimezone().getOffset(gmt);
                Datetime local = gmt.addSeconds(-(offset)/1000);
                objSObject.put(fieldAPIName,local);
                }else{
                String replacedString = strCoulumVal.replace('T', ' ');
                String finalDateTimeString = replacedString.replace('Z', '');
                Datetime gmt = datetime.valueOfGMT(finalDateTimeString);
                Integer offset = UserInfo.getTimezone().getOffset(gmt);
                Datetime local = gmt.addSeconds(-(offset)/1000);
                objSObject.put(fieldAPIName,local);
                }
                //end of Alsn-165
            } else {
                objSObject.put(fieldAPIName, null);
            }
        } else if (objfielMapMdt.type == 'Boolean') {
            objSObject.put(fieldAPIName, Boolean.valueof(strCoulumVal));
        } else {
            objSObject.put(fieldAPIName, strCoulumVal);
        }
        return objSObject;
    }
    
    /*
this method is used save the records
*/
    private static ATI_BatchLogResults saveProcessedRecords(
        Map<Integer,RecordWithResult> recordDataMap,
        List<Map<String, Object>> objToMapForErrorLst,
        ATI_BatchLogResults objBatchLogResult,
        String batchLogId,
        List<String> columnHeaders
    ){
        try {
            if(!recordDataMap.isEmpty()) {
                Set<Id> successWRIdSet = new Set<Id>();
                List<sObject> insertResultLst = new List<sObject>();
                Integer errorResultIndex = 0;
                Integer saveResultIndex = 0;
                for(Integer rowKey : recordDataMap.keySet()) {
                    RecordWithResult sObjectData = recordDataMap.get(rowKey);
                    WOD_2.ResponseWrapper respWrapperObj = ATI_BulkClaimService.saveClaimInfo(batchLogId,sObjectData.claimSObject,sObjectData.partSObject,
                                                                                              sObjectData.laborSObject,sObjectData.otherCostSObject,sObjectData.diaCodeSObject,
                                                                                              sObjectData.ServiceCampaign,sObjectData.claimTemplate,sObjectData.customerInfoSObject,
                                                                                              sObjectData.vehicleInfoSObject,sObjectData.wrInfoSObject);
                    System.debug('respWrapperObj>>>> '+respWrapperObj.errormessage);
                    System.debug('respWrapperObj.data>>>> '+respWrapperObj.data);
                    if(!respWrapperObj.status) {
                        objBatchLogResult.failedRecordCount++;
                        Integer i = 0;
                        String failedRecordStr = '';
                        System.debug('objToMapForErrorLst--->'+objToMapForErrorLst[errorResultIndex]);
                        for(String st : objToMapForErrorLst[errorResultIndex].keySet()){
                            /*if(st == 'Parts' || st == 'Labor' || st == 'OtherCost' || st == 'DiagnosticCode'){
List<Object> bulkData = (List<Object>)objToMapForErrorLst[errorResultIndex].get(st);
failedRecordStr += '"';
for(Object data : bulkData){
Map<String,Object> bulkDataMap = (Map<String,Object>)data;
failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
}
failedRecordStr += '",';
}else{*/
                            if(st != 'Parts' && st != 'Labor' && st != 'OtherCost' && st != 'DiagnosticCode'){
                                if(i == 0){
                                    failedRecordStr += objToMapForErrorLst[errorResultIndex].get(st)+',';
                                }else if(i == 1){
                                    failedRecordStr += ',';
                                }
                                else{
                                    failedRecordStr += '"'+objToMapForErrorLst[errorResultIndex].get(st)+'",';
                                }
                            }
                            i++;
                        }
                        
                        /* for(String st : objToMapForErrorLst[errorResultIndex].keySet()){
if(st == 'Parts' || st == 'Labor' || st == 'OtherCost' || st == 'DiagnosticCode'){
List<Object> bulkData = (List<Object>)objToMapForErrorLst[errorResultIndex].get(st);
failedRecordStr += '"';
for(Object data : bulkData){
Map<String,Object> bulkDataMap = (Map<String,Object>)data;
failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
}
failedRecordStr += '",';
}
} */
                        if(!objToMapForErrorLst[errorResultIndex].containsKey('Parts')){
                            failedRecordStr += '"'+'",';
                        }
                        else{
                            List<Object> bulkData = (List<Object>)objToMapForErrorLst[errorResultIndex].get('Parts');
                            failedRecordStr += '"';
                            for(Object data : bulkData){
                                Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                            }
                            failedRecordStr += '",';
                        }
                        if(!objToMapForErrorLst[errorResultIndex].containsKey('Labor')){
                            failedRecordStr += '"'+'",';
                        }
                        else{
                            List<Object> bulkData = (List<Object>)objToMapForErrorLst[errorResultIndex].get('Labor');
                            failedRecordStr += '"';
                            for(Object data : bulkData){
                                Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                            }
                            failedRecordStr += '",';
                        }
                        if(!objToMapForErrorLst[errorResultIndex].containsKey('OtherCost')){
                            failedRecordStr += '"'+'",';
                        }
                        else{
                            List<Object> bulkData = (List<Object>)objToMapForErrorLst[errorResultIndex].get('OtherCost');
                            failedRecordStr += '"';
                            for(Object data : bulkData){
                                Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                            }
                            failedRecordStr += '",';
                        }
                        if(!objToMapForErrorLst[errorResultIndex].containsKey('DiagnosticCode')){
                            failedRecordStr += '"'+'",';
                        } 
                        else{
                            List<Object> bulkData = (List<Object>)objToMapForErrorLst[errorResultIndex].get('DiagnosticCode');
                            failedRecordStr += '"';
                            for(Object data : bulkData){
                                Map<String,Object> bulkDataMap = (Map<String,Object>)data;
                                failedRecordStr += String.join(bulkDataMap.values(),',')+'#';
                            }
                            failedRecordStr += '",';
                        }
                        System.debug('failedRecordStr123--->'+failedRecordStr);
                        
                        objBatchLogResult.failedRecords = failedRecordStr+'"'+respWrapperObj.errormessage+'"\n'+ objBatchLogResult.failedRecords;
                        System.debug('objBatchLogResult>>> '+objBatchLogResult.failedRecords);
                    }else{
                        objBatchLogResult.successRecordCount++;
                        successWRIdSet.add(respWrapperObj.data);
                        saveResultIndex++;
                    }
                    errorResultIndex++;
                }
                
                // Add all the success record id's for the batch to send out email on finish
                objBatchLogResult.successRecordIdsSet = new Set<Id>();
                if (successWRIdSet.size() > 0) {
                    objBatchLogResult.successRecordIdsSet.addAll(successWRIdSet);
                }
            }
            return objBatchLogResult;
        } catch (Exception e) {
            System.debug('====WR create error==' + e);
            System.debug('====WR create error line==' + e.getLineNumber());
            throw e;
        }
    }
    
    /*
iterate through uploaded data to get column value of reference field
*/
    private static Map<String, List<String>> getColumnValuesforRefFields(
        Map<String, String> referenceFieldWithQueryMap,
        List<Map<String, Object>> mapClaimData
    ) {
        Map<String, List<String>> referenceFieldValuesMap = new Map<String, List<String>>();
        //itirate through uploaded data to get column value of reference field
        for (Map<String, Object> objData : mapClaimData) {
            for (String strKeys : objData.keySet()) {
                if (referenceFieldWithQueryMap.containsKey(strKeys)) {
                    string strVal = String.valueOf(objData.get(strKeys));
                    if (referenceFieldValuesMap.containsKey(strKeys)) {
                        referenceFieldValuesMap.get(strKeys).add(strVal.trim());
                    } else {
                        referenceFieldValuesMap.put(strKeys, new List<String>());
                        referenceFieldValuesMap.get(strKeys).add(strVal.trim());
                    }
                }
            }
        }
        return referenceFieldValuesMap;
    }
    
    /*
iterate through uploaded data to get column value of reference field
*/
    private static Map<String, Map<String, String>> getValueforReferenceFields(
        Map<String, List<String>> refObjNameWithFieldsCheckMap,
        Map<String, String> referenceFieldWithQueryMap,
        Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap,
        Map<String, List<String>> referenceFieldValuesMap
    ) {
        Map<String, Map<String, String>> referenceValuesToUseMap = new Map<String, Map<String, String>>(); // column name with uploaded value for reference and its Id
        Set<String> objectHavingReadAccessSet = new Set<String>();
        if (!refObjNameWithFieldsCheckMap.isEmpty()) {
            for(String strObjectName : refObjNameWithFieldsCheckMap.keySet()) {
                WOD_2.ResponseWrapper objCheckReadAccess = ATI_Utils.checkReadAccess(
                    strObjectName,
                    refObjNameWithFieldsCheckMap.get(strObjectName)
                );
                Map<String, Object> readAccessCheckMap = (Map<String, Object>) Json.deserializeUntyped(objCheckReadAccess.data);
                if (objCheckReadAccess.status && ((List<Object>) readAccessCheckMap.get('noAccessObjectList')).isEmpty() &&
                    ((List<Object>) readAccessCheckMap.get('noAccessFieldList')).isEmpty())
                    objectHavingReadAccessSet.add(strObjectName);
            }
        }
        //Querying refence fields. Uploaded file can have many object and field reference in it. We need to get referce IDs for each column.
        //So, we are doing SOQL inside for loop which will loop through each coloum and store matched reference Id column wise.
        for (String strReferenceKey : referenceFieldWithQueryMap.keySet()) {
            String strQuery = referenceFieldWithQueryMap.get(strReferenceKey);
            //system.debug('@strReferenceKey'+strReferenceKey);
            String strObjectName = bulkUploadFieldMappingMap.get(strReferenceKey).referenceObjectAPIName;
            if (
                !objectHavingReadAccessSet.isEmpty() &&
                objectHavingReadAccessSet.contains(strObjectName) &&
                !referenceFieldValuesMap.isEmpty() &&
                referenceFieldValuesMap.containsKey(strReferenceKey) &&
                !referenceFieldValuesMap.get(strReferenceKey).isEmpty()
            ) {
                List<String> queryLst = referenceFieldValuesMap.get(strReferenceKey);
                strQuery += 'queryLst';
                List<sObject> referenceObjectLst = Database.query(strQuery);  //changed query from without sharing to with sharing
                if (!referenceObjectLst.isEmpty()) {
                    Map<String, String> fieldKEyWithValueMap = new Map<String, String>();
                    for(SObject objSObject : referenceObjectLst) {
                        ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strReferenceKey);
                        String fieldName = objfielMapMdt.referenceFieldAPIName;
                        if(objSObject.get(fieldName) != null){
                            String fieldVal = ((string) objSObject.get(fieldName)).trim();
                            if(strReferenceKey == Label.ATI_BulkWR_Serial_Number){ // Alsn - 174 retrieving the extended base model value instead of description value 
                                fieldKEyWithValueMap.put(fieldVal,objSObject.Id+':'+objSObject.get('WOD_2__Item__c')+':'+objSObject.getSObject('WOD_2__Item__r').get('Extended_Base_Model__c')+':'+objSObject.get('WOD_2__Business_Unit__c'));
                            }else if(strReferenceKey == 'Business Partner'){
                                fieldKEyWithValueMap.put(fieldVal,objSObject.Id+':'+objSObject.get('ATI_Currency__c'));
                            }else if(strReferenceKey == 'Claim Number'){
                                fieldKEyWithValueMap.put(fieldVal,objSObject.get('Name')+':'+objSObject.get('WOD_2__Claim_Status__c'));
                            }
                            //Alsn-154
                            else if(strReferenceKey == 'Primary Failed Part'){
                                fieldKEyWithValueMap.put(fieldVal,objSObject.Id+':'+objSObject.get('WOD_2__Description__c'));
                            }   
                            //end of Alsn-154
                            else{
                                fieldKEyWithValueMap.put(fieldVal, objSObject.Id);       
                            }
                        }
                    }
                    if (!fieldKEyWithValueMap.isEmpty())
                        referenceValuesToUseMap.put(strReferenceKey, fieldKEyWithValueMap);
                }
            }
        }
        return referenceValuesToUseMap;
    }
    
    public class RecordWithResult {
        public Boolean isAnyError;
        public SObject wrInfoSObject;
        public SObject vehicleInfoSObject;
        public SObject customerInfoSObject;
        public SObject claimSObject;
        public List<WOD_2__Claim_Part__c> partSObject;
        public List<WOD_2__Claim_Service_Information__c> laborSObject;
        public List<WOD_2__Other_Cost__c> otherCostSObject;
        public List<ATI_Diagnostic_Code__c> diaCodeSObject;
        public SObject claimTemplate;   
        public SObject ServiceCampaign;
        public String errorStr;
        public RecordWithResult() {
            isAnyError = false;
        }
    }
    
    public class ProcessedConfigWrap {
        public Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap;
        public Map<String, List<String>> refObjNameWithFieldsAccCheckMap;
        public Map<String, String> referenceFieldWithQueryMap;
        public ProcessedConfigWrap() {
            Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap = new Map<String, ATI_BulkUploadFieldMapping>();
            Map<String, List<String>> refObjNameWithFieldsAccCheckMap = new Map<String, List<String>>();
            Map<String, String> referenceFieldWithQueryMap = new Map<String, String>();
        }
    }
}