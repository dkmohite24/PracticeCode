/**
* (c) 2020 Tavant Technology.
* -------------------------------------------------------------------------------------------------------------
This class is used to upload bulk WR records. Uploaded file is initially stored in WOD_2__Batch_Log__c 
object then proccessed in this class and stored under objected mentioned in ATI_Bulk_Upload_Configuration__mdt.
* --------------------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        23-DEC-2020
* @modified
* --------------------------------------------------------------------------------------------------------------
* @changes		  
* --------------------------------------------------------------------------------------------------------------
*/
public without sharing class ATI_BulkWRUploadController implements ATI_BulkUploadProcessInterface {
    public static ATI_BulkUploadConfiguration bulkUploadConfigurationObj;
    public static List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst;
    /*
* Proccessing uploaded file based on ATI_Bulk_Upload_Configuration__mdt and insert it
*/
    public static ATI_BatchLogResults parseData(List<Map<String, Object>> mapWRData, String strParentId) {
        System.debug('mapWRData>>>>>> '+mapWRData);
        ATI_BatchLogResults objBatchLogResult = new ATI_BatchLogResults(); //store process record count with success and failures.
        objBatchLogResult.totalRecordCount = mapWRData.size();
        String recordIdToAttachBatchLogStr = '';
        WOD_2.ResponseWrapper objBatchLogReadAccessCheck = ATI_Utils.checkReadAccess(
            'WOD_2__Batch_Log__c',
            new List<String>{ 'WOD_2__Process_Type__c'}
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
                    if (!objRecordWithResult.isAnyError){
                        recordDataMap.put(i,objRecordWithResult);
                        i++;
                        objToMapForErrorLst.add(objData);
                    } else {
                        objBatchLogResult.failedRecordCount++;
                        objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + objRecordWithResult.errorStr;
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
            //System.debug('objBulkUploadFieldMap>>> '+objBulkUploadFieldMap.columnName+ ' >>> '+objBulkUploadFieldMap);
            objProcessedConfigWrap.bulkUploadFieldMappingMap.put(objBulkUploadFieldMap.columnName.trim(), objBulkUploadFieldMap);
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
                    if(objBulkUploadFieldMap.referenceFieldAPIName == 'WOD_2__Serial_Number__c'){
                        strQuery =
                            'Select Id,WOD_2__Item__c,' +
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
                                                        ) {
                                                            RecordWithResult objRecordWithResult = new RecordWithResult();
                                                            SObject wrInfoSObject = Schema.getGlobalDescribe().get(bulkUploadConfigurationObj.objectApiNameStr).newSObject();
                                                            SObject vehicleInfoSObject = Schema.getGlobalDescribe().get('ATI_Vehicle_Information__c').newSObject();
                                                            SObject customerInfoSObject = Schema.getGlobalDescribe().get('Account').newSObject();
                                                            SObject extendedWarrantyInfoSObject = Schema.getGlobalDescribe().get('WOD_2__Warranty_Coverages__c').newSObject();
                                                            SObject warrantyProductInfoSObject = Schema.getGlobalDescribe().get('WOD_2__Warranty_Product__c').newSObject();
                                                            String errorStr = '';
                                                            String extendedPolicyName = (String)bulkUploadDataMap.get('Extended Warranty Policy Name');
                                                            String modelNumber = (String)bulkUploadDataMap.get('Standard Model');
                                                            for(String strKeys : bulkUploadDataMap.keySet()){
                                                                String strCoulumVal = (String)bulkUploadDataMap.get(strKeys);
                                                                ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strKeys.trim());
                                                                //ignore columns if not present in configuration
                                                                if(objfielMapMdt != null){
                                                                    String fieldAPIName = objfielMapMdt.fieldAPIName;
                                                                    if(objfielMapMdt.isMandatory == true){
                                                                        if(objfielMapMdt.columnName == 'In-Service Date'){ 
                                                                            if(String.valueOf(bulkUploadDataMap.get('Pre-Delivery')).equalsIgnoreCase('false') && String.isBlank(strCoulumVal)){ //In-Service Date not Mandatory for Pre-Delivery
                                                                                objRecordWithResult.isAnyError = true;
                                                                                errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                            }
                                                                            if(String.valueOf(bulkUploadDataMap.get('Pre-Delivery')).equalsIgnoreCase('true') && !String.isBlank(strCoulumVal)){
                                                                                objRecordWithResult.isAnyError = true;
                                                                                errorStr += Label.ATI_BulkWR_InServiceDate_ValidationMessage;
                                                                            }
                                                                            //ALSN-142
                                                                            Object Acc = bulkUploadDataMap.get('Business Partner');
                                                                            String Id = (String) Acc;
                                                                            //ALSN-212 updated the existing regex to check if first 5 characters are 0
                                                                            //Previous regex: ^[0-9]{5}$... New regex: ^[0]{5}[0-9]{5}$
                                                                            Boolean sapId = Pattern.matches('^[0]{5}[0-9]{5}$', Id);
                                                                            //ALSN-212 end
                                                                            String accName =[Select Id, Name from Account where SAP_ID__c =:Id limit 1].Name;
                                                                            //ALSN-212 Updated the condition to trigger the error if length is not equal to 10 digits
                                                                            if(String.valueOf(bulkUploadDataMap.get('Business Partner')).length() != 10 || sapId || accName.Contains('Subparent')){
                                                                                objRecordWithResult.isAnyError = true;
                                                                                errorStr += Label.ATI_Account_5_digit_SAPId;
                                                                            }
                                                                            //ALSN-142 END
                                                                            
                                                                        }else if(String.isBlank(strCoulumVal)){
                                                                            objRecordWithResult.isAnyError = true;
                                                                            errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                        }
                                                                    }
                                                                    if(!referenceFieldWithQueryMap.isEmpty() && referenceFieldWithQueryMap.containsKey(strKeys)){
                                                                        if(objfielMapMdt.IsMandatory == true && !String.isBlank(strCoulumVal) && (referenceValuesToUseMap.isEmpty() || !referenceValuesToUseMap.containsKey(strKeys) || !referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal.trim()))){
                                                                            objRecordWithResult.isAnyError = true;
                                                                            errorStr += 'Invalid '+objfielMapMdt.columnName + '\n';
                                                                        }
                                                                        if(!referenceValuesToUseMap.isEmpty() && referenceValuesToUseMap.containsKey(strKeys) && referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal.trim())){
                                                                            if(objfielMapMdt.objectAPIName == bulkUploadConfigurationObj.objectApiNameStr){
                                                                                if(strKeys == Label.ATI_BulkWR_Serial_Number){
                                                                                    wrInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[0]); 
                                                                                    wrInfoSObject.put('WOD_2__Warranty_Product__c',referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()).split(':')[1]);
                                                                                }else{
                                                                                    wrInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()));
                                                                                }
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'ATI_Vehicle_Information__c'){
                                                                                vehicleInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()));
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'Account'){
                                                                                customerInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()));
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'WOD_2__Warranty_Coverages__c'){
                                                                                extendedWarrantyInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()));
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'WOD_2__Warranty_Product__c'){
                                                                                warrantyProductInfoSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal.trim()));
                                                                            }
                                                                        }
                                                                    }else{
                                                                        try{
                                                                            if(objfielMapMdt.objectAPIName == bulkUploadConfigurationObj.objectApiNameStr){
                                                                                wrInfoSObject = processSobjectField(wrInfoSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'ATI_Vehicle_Information__c' && !String.isBlank(strCoulumVal)){
                                                                                vehicleInfoSObject = processSobjectField(vehicleInfoSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                            if(objfielMapMdt.objectAPIName == 'Account'){
                                                                                customerInfoSObject = processSobjectField(customerInfoSObject, fieldAPIName, objfielMapMdt, strCoulumVal.trim());
                                                                            }
                                                                        }
                                                                        catch(Exception exp){
                                                                            objRecordWithResult.isAnyError = true;
                                                                            errorStr += exp.getMessage() + '\n';
                                                                            System.debug('errorStr>>>>> '+errorStr+' >>>>>> '+fieldAPIName);
                                                                            break;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            if(!objRecordWithResult.isAnyError){
                                                                objRecordWithResult.wrInfoSObject = wrInfoSObject;
                                                                objRecordWithResult.vehicleInfoSObject = vehicleInfoSObject;
                                                                objRecordWithResult.customerInfoSObject = customerInfoSObject;
                                                                if(!String.isBlank(extendedPolicyName)){
                                                                    objRecordWithResult.extendedWarrantyInfoSObject = extendedWarrantyInfoSObject;
                                                                }
                                                                if(!String.isBlank(modelNumber)){
                                                                    objRecordWithResult.warrantyProductInfoSObject = warrantyProductInfoSObject;
                                                                }
                                                            }else {
                                                                List<Object> objData = bulkUploadDataMap.values();
                                                                Object firstColumn = objData.get(0);
                                                                objData.remove(0);
                                                                objRecordWithResult.errorStr = firstColumn +',"'+String.join(objData,'","') + '","' + errorStr + '"\n';
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
            //Alsn-165
            String userLocale  = UserInfo.getLocale();
            System.debug('-*********-'+userLocale);
            if(strCoulumVal != '') {              
                Integer day=integer.valueof(strCoulumVal.substringBetween('/'));
                Integer month = integer.valueof(strCoulumVal.substringBefore('/')); 
                if(month <=12){
                    if(userLocale.contains('th')){
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
                objSObject.put(fieldAPIName, DateTime.parse(strCoulumVal));
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
            if (!recordDataMap.isEmpty()) {
                Set<Id> successWRIdSet = new Set<Id>();
                List<sObject> insertResultLst = new List<sObject>();
                Integer errorResultIndex = 0;
                Integer saveResultIndex = 0;
                for (Integer rowKey : recordDataMap.keySet()) {
                    RecordWithResult sObjectData = recordDataMap.get(rowKey);
                    WOD_2.ResponseWrapper respWrapperObj = ATI_BulkWarrantyRegistrationService.saveWarrantyRegistrationInfo(sObjectData.wrInfoSObject,sObjectData.vehicleInfoSObject,sObjectData.customerInfoSObject,sObjectData.extendedWarrantyInfoSObject,sObjectData.warrantyProductInfoSObject);
                    //System.debug('#123RespWrapperObj>>>> '+respWrapperObj);
                    if (respWrapperObj.status == false) {
                        objBatchLogResult.failedRecordCount++;
                        List<Object> objData = objToMapForErrorLst[errorResultIndex].values();
                        Object firstColumn = objData.get(0);
                        objData.remove(0);
                        String failedRecordStr = firstColumn+',"'+String.join(objData, '","') +'","'+
                            respWrapperObj.errormessage + '"\n';
                        objBatchLogResult.failedRecords = failedRecordStr+objBatchLogResult.failedRecords;
                    } else {
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
            for (String strObjectName : refObjNameWithFieldsCheckMap.keySet()) {
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
            String strObjectName = bulkUploadFieldMappingMap.get(strReferenceKey.trim()).referenceObjectAPIName;
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
                    for (SObject objSObject : referenceObjectLst) {
                        ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strReferenceKey.trim());
                        String fieldName = objfielMapMdt.referenceFieldAPIName;
                        String fieldVal = ((string) objSObject.get(fieldName)).trim();
                        if(strReferenceKey == Label.ATI_BulkWR_Serial_Number){
                            fieldKEyWithValueMap.put(fieldVal,objSObject.Id+':'+objSObject.get('WOD_2__Item__c'));
                        }else{
                            fieldKEyWithValueMap.put(fieldVal, objSObject.Id);       
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
        public SObject extendedWarrantyInfoSObject;
        public SObject warrantyProductInfoSObject;
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