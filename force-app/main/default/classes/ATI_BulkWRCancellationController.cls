/* Name: ATI_BulkWRCancellationController
   Description : Controller for cancelExtendedWarrantyComponent
   Author : Tavant (Akshatha S)
   History : This class is used to cancel bulk WR records. Uploaded file is initially stored in WOD_2__Batch_Log__c 
   object then proccessed in this class and stored under objected mentioned in ATI_Bulk_Upload_Configuration__mdt.
   VERSION     AUTHOR                 DATE               DETAIL                   UserStory/Req#
   1.0 -       Tavant (Akshatha S)    30/12/2020         INITIAL DEVELOPMENT
*/
public without sharing class ATI_BulkWRCancellationController implements ATI_BulkUploadProcessInterface {
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
                System.debug('bulkUploadFieldMappingMap>>>>>>> '+objProcessedConfigWrap.bulkUploadFieldMappingMap);
                System.debug('referenceFieldWithQueryMap>>>>>>> '+objProcessedConfigWrap.referenceFieldWithQueryMap);
                System.debug('refObjNameWithFieldsAccCheckMap>>>>>>> '+objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap);
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
                    System.debug('referenceFieldValuesMap>>>>>> '+referenceFieldValuesMap);
                    //get reference field values list
                    referenceValuesToUseMap = getValueforReferenceFields(
                        refObjNameWithFieldsAccCheckMap,
                        referenceFieldWithQueryMap,
                        bulkUploadFieldMappingMap,
                        referenceFieldValuesMap
                    );
                }
                List<String> recordsToInsertLst = new List<String>();
                set<String> serialNumSet = new set<String>();
                List<Map<String, Object>> objToMapForErrorLst = new List<Map<String, Object>>(); //list of row data to add in failed records for any error
                for (Map<String, Object> objData : mapWRData) {
                    RecordWithResult objRecordWithResult = cancelWR(
                        objData,
                        bulkUploadFieldMappingMap,
                        referenceFieldWithQueryMap,
                        referenceValuesToUseMap,
                        recordIdToAttachBatchLogStr
                    );
                    if (!objRecordWithResult.isAnyError) {
                        objToMapForErrorLst.add(objData);
                        serialNumSet.add((string.valueof(objData.get('Serial Number'))).trim());
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
                objBatchLogResult.successRecordsSet = new Set<String>();
                //save records
                for(string serialNum : serialNumSet){
                objBatchLogResult = saveProcessedRecords(
                    new set<string>{serialNum},
                    objToMapForErrorLst,
                    objBatchLogResult,
                    strParentId,
                    columnHeaders
                );
                }
            }
            else {
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
            objProcessedConfigWrap.bulkUploadFieldMappingMap.put(objBulkUploadFieldMap.columnName, objBulkUploadFieldMap);
            
            //framing query for reference fields
            if (objBulkUploadFieldMap.type == 'Reference') {
                if (objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap.containsKey(objBulkUploadFieldMap.referenceObjectAPIName)){
                    objProcessedConfigWrap.refObjNameWithFieldsAccCheckMap.get(objBulkUploadFieldMap.referenceObjectAPIName).add(objBulkUploadFieldMap.referenceFieldAPIName);
                }
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
                    }/*else{
                        strQuery =
                        'Select Id,' +
                        objBulkUploadFieldMap.referenceFieldAPIName +
                        ' FROM ' +
                        objBulkUploadFieldMap.referenceObjectAPIName +
                        ' WHERE ' +
                        ((hasQueryFilter) ? objBulkUploadFieldMap.queryFilter + ' AND ' : '') + 
                        objBulkUploadFieldMap.referenceFieldAPIName +
                        ' IN: ';
                    }*/
                    objProcessedConfigWrap.referenceFieldWithQueryMap.put(objBulkUploadFieldMap.columnName, strQuery);
                } /*else {
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
                }*/
            }
        }
        return objProcessedConfigWrap;
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
                System.debug('refObjNameWithFieldsCheckMap>>>>> '+ refObjNameWithFieldsCheckMap.get(strObjectName));
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
                    for (SObject objSObject : referenceObjectLst) {
                        ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strReferenceKey);
                        String fieldName = objfielMapMdt.referenceFieldAPIName;
                        String fieldVal = (string) objSObject.get(fieldName);
                        if(strReferenceKey == Label.ATI_BulkWR_Serial_Number){
                            fieldKEyWithValueMap.put(fieldVal,objSObject.Id+':'+objSObject.get('WOD_2__Item__c'));
                        }else{
                            fieldKEyWithValueMap.put(fieldVal, objSObject.Id);       
                        }
                    }
                    System.debug('fieldKEyWithValueMap>>>> '+fieldKEyWithValueMap);
                    if (!fieldKEyWithValueMap.isEmpty())
                        referenceValuesToUseMap.put(strReferenceKey, fieldKEyWithValueMap);
                     System.debug('referenceValuesToUseMap>>>> '+referenceValuesToUseMap);
                }
            }
        }
        return referenceValuesToUseMap;
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
                        referenceFieldValuesMap.get(strKeys).add(strVal);
                    } else {
                        referenceFieldValuesMap.put(strKeys, new List<String>());
                        referenceFieldValuesMap.get(strKeys).add(strVal);
                    }
                }
            }
        }
        return referenceFieldValuesMap;
    }
    
     /*
  this method is used save the records
  */
    private static RecordWithResult cancelWR(Map<String,Object> bulkUploadDataMap,
                                                         Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap,
                                                         Map<String, String> referenceFieldWithQueryMap,
                                                         Map<String, Map<String, String>> referenceValuesToUseMap,
                                                         String recordIdToAttachBatchLogStr
                                                        ) 
    {
        RecordWithResult objRecordWithResult = new RecordWithResult();
        String errorStr = '';
            for(String strKeys : bulkUploadDataMap.keySet()){
                                                                String strCoulumVal = (String)bulkUploadDataMap.get(strKeys);
                                                                ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strKeys);
                                                                //ignore columns if not present in configuration
                                                                if(objfielMapMdt != null){
                                                                    String fieldAPIName = objfielMapMdt.fieldAPIName;
                                                                    if(objfielMapMdt.isMandatory == true && String.isBlank(strCoulumVal)){
                                                                        objRecordWithResult.isAnyError = true;
                                                                        errorStr += objfielMapMdt.columnName + ' is Mandatory' + '\n';
                                                                    }else if(!referenceFieldWithQueryMap.isEmpty() && referenceFieldWithQueryMap.containsKey(strKeys) ){
                                                                        if(objfielMapMdt.IsMandatory == true && (referenceValuesToUseMap.isEmpty() || !referenceValuesToUseMap.containsKey(strKeys) || !referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal))){
                                                                            objRecordWithResult.isAnyError = true;
                                                                            errorStr += System.label.ATI_BulkCancellationInvalidSerNum+ '\n';
                                                                        }                                                                      
                                                                }
                                                            }
                                                            if(objRecordWithResult.isAnyError){
                                                                objRecordWithResult.errorStr = String.join(bulkUploadDataMap.values(),',') + ',"' + errorStr + '"\n';
                                                            }
        }
        return objRecordWithResult;
    }
    
    /*
  this method is used save the records
  */
    private static ATI_BatchLogResults saveProcessedRecords(set<String> serialNumSet,
        List<Map<String, Object>> objToMapForErrorLst,
        ATI_BatchLogResults objBatchLogResult,
        String batchLogId,
        List<String> columnHeaders
    ){
        try {
            system.debug('serialNumSet===>'+serialNumSet);
            WOD_2__Business_Category_Configuration_Setting__c bccsRec=new WOD_2__Business_Category_Configuration_Setting__c();
            List<String> fieldsForBCCS = new List<String> {'WOD_2__Value__c','Name'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessBCCSFieldWrapperObject = ATI_Utils.fetchReadAccess('WOD_2__Business_Category_Configuration_Setting__c',fieldsForBCCS);
            if(noAccessBCCSFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessBCCSFieldWrapperObject.noAccessFieldList.size() == 0)
            {
                bccsRec = [SELECT Id, WOD_2__Value__c FROM WOD_2__Business_Category_Configuration_Setting__c WHERE Name ='ATI_CancelExtendedWRWithinDays' LIMIT 1];
            }
            
            List<String> fieldsForWR = new List<String> {'WOD_2__Inventory__c','WOD_2__Registration_Type__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c',fieldsForWR);
            List<String> fieldsForWRCov = new List<String> {'ATI_Reason__c','Name','WOD_2__Warranty_Registration__c'};
            ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectWRCov = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Coverages__c',fieldsForWRCov);
            Map<string,List<WOD_2__Warranty_Registration__c>> invWRMap =  new Map<string,List<WOD_2__Warranty_Registration__c>>();
            fieldsForWRCov = new List<String> {'WOD_2__Is_Active__c','ATI_Reason__c'};
            ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheckWRCov = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Coverages__c',fieldsForWRCov);
            
            List<String> fieldsForlineItem = new List<String> {'WOD_2__Total_Amount__c','WOD_2__Unit_Amount__c','ATI_Late_Fee__c','ATI_Handling_Fee__c','Name','WOD_2__Quantity__c','WOD_2__Transaction_Type__c','WOD_2__Transaction_Memo_History__c'};
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessChecklineItem = ATI_Utils.fetchReadAccess('WOD_2__Transaction_Memo_History_Line_Item__c',fieldsForlineItem);
            List<String> fieldsForTransacHistory = new List<String> {'Name','WOD_2__Transaction_Status__c','WOD_2__Transaction_Type__c','ATI_Warranty_Registration__c','ATI_Type__c'}; 
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheckHistory = ATI_Utils.fetchReadAccess('WOD_2__Transaction_Memo_History__c',fieldsForTransacHistory);
            fieldsForTransacHistory = new List<String> {'WOD_2__Amount__c','WOD_2__Transaction_Type__c','Name','WOD_2__Transaction_Status__c','WOD_2__Settlement_Category__c','ATI_Type__c','ATI_Warranty_Registration__c'};
            ATI_Utils.NoAccessObjectFieldWrapper sObjCreateAccessCheckHistory = ATI_Utils.fetchCreateAccess('WOD_2__Transaction_Memo_History__c',fieldsForTransacHistory);
            fieldsForlineItem = new List<String> {'WOD_2__Total_Amount__c','WOD_2__Unit_Amount__c','ATI_Late_Fee__c','ATI_Handling_Fee__c','Name','WOD_2__Quantity__c','WOD_2__Transaction_Type__c','WOD_2__Transaction_Memo_History__c'};
            ATI_Utils.NoAccessObjectFieldWrapper sObjCreateAccessChecklineItem = ATI_Utils.fetchCreateAccess('WOD_2__Transaction_Memo_History_Line_Item__c',fieldsForlineItem);
                               
            Savepoint sp = Database.setSavepoint();
            if(noAccessObjectWRCov.noAccessObjectList.size() == 0 && noAccessObjectWRCov.noAccessFieldList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0
              && sObjUpdateAccessCheckWRCov.noAccessObjectList.size() == 0 && sObjUpdateAccessCheckWRCov.noAccessFieldList.size() == 0 &&
              sObjCreateAccessCheckHistory.noAccessObjectList.size() == 0 && sObjCreateAccessCheckHistory.noAccessFieldList.size() == 0 && sObjCreateAccessChecklineItem.noAccessObjectList.size() == 0 && sObjCreateAccessChecklineItem.noAccessFieldList.size() == 0 && 
              sObjReadAccessChecklineItem.noAccessObjectList.size() == 0 && sObjReadAccessChecklineItem.noAccessFieldList.size() == 0 && sObjReadAccessCheckHistory.noAccessObjectList.size() == 0 && sObjReadAccessCheckHistory.noAccessFieldList.size() == 0)
            {
                for(WOD_2__Warranty_Registration__c wrRec : [SELECT Id,WOD_2__Inventory__r.WOD_2__Serial_Number__c, WOD_2__Inventory__r.WOD_2__Install_Date__c, WOD_2__Registration_Type__c, WOD_2__Inventory__c,(SELECT Id,WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c,ATI_Reason__c,Name FROM WOD_2__Warranty_Coverages__r where WOD_2__Policy_Definition__r.WOD_2__Type__c='Extended' AND WOD_2__Is_Active__c=true) FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__r.WOD_2__Serial_Number__c in :serialNumSet AND WOD_2__Status__c='Registered']){
                    if(!invWRMap.containskey(wrRec.WOD_2__Inventory__r.WOD_2__Serial_Number__c)){
                        invWRMap.put(wrRec.WOD_2__Inventory__r.WOD_2__Serial_Number__c,new List<WOD_2__Warranty_Registration__c>{wrRec});
                    }
                    else{
                        invWRMap.get(wrRec.WOD_2__Inventory__r.WOD_2__Serial_Number__c).add(wrRec);
                    }
                }
                
                set<string> wrIdSet=new set<string>();
                List<WOD_2__Warranty_Registration__c> wrUpdateList=new List<WOD_2__Warranty_Registration__c>();
                List<WOD_2__Warranty_Coverages__c> wrCovUpdateList=new List<WOD_2__Warranty_Coverages__c>();
                Map<string,string> wrSerialNumMap=new Map<string,string>();
                Map<string,string> covSerialNumMap=new Map<string,string>();
                for(string serialnum : serialNumSet){
                    if(!invWRMap.containskey(serialnum)){
                        objBatchLogResult.failedRecordCount++;
                        String failedRecordStr =serialnum + ',' +System.label.ATI_NoExtendedWarranty+'\n';
                        objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;
                    }
                    else{                    
                        boolean updateWRRecord=false;
                        for(WOD_2__Warranty_Registration__c wrRec : invWRMap.get(serialnum)){
                            if(wrRec.WOD_2__Warranty_Coverages__r.size()>0){
                                wrSerialNumMap.put(wrRec.Id,wrRec.WOD_2__Inventory__r.WOD_2__Serial_Number__c);
                                updateWRRecord=true;
                                if(invWRMap.get(serialnum).size()>1){
                                    wrRec.WOD_2__Status__c = 'InActive';
                                    wrUpdateList.add(wrRec);
                                }
                                for(WOD_2__Warranty_Coverages__c covRec : wrRec.WOD_2__Warranty_Coverages__r){
                                    covRec.ATI_Reason__c=System.Label.ATI_BulkCancellationReason;
                                    covRec.WOD_2__Is_Active__c = false;
                                    covRec.WOD_2__Warranty_End_Date__c=system.today();
                                    wrCovUpdateList.add(covRec);
                                    covSerialNumMap.put(covRec.Id,covRec.WOD_2__Warranty_Registration__r.WOD_2__Inventory__r.WOD_2__Serial_Number__c);
                                }
                            }
                        }
                        if(updateWRRecord==false){
                            objBatchLogResult.failedRecordCount++;
                            String failedRecordStr =serialnum + ',' +System.Label.ATI_NoExtendedWarranty +'\n';
                            objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;
                            return objBatchLogResult;
                        }
                        if((invWRMap.get(serialnum)[0].WOD_2__Inventory__r.WOD_2__Install_Date__c).addDays(integer.valueof(bccsRec.WOD_2__Value__c))<system.today()){
                            objBatchLogResult.failedRecordCount++;
                            String failedRecordStr =serialnum + ',' +System.label.ATI_CancelExtendedWRWithinErr1+' '+bccsRec.WOD_2__Value__c+' '+System.label.ATI_CancelExtendedWRWithinErr2+'\n';
                            objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;
                            return objBatchLogResult;
                        }
                    }
                }
                
                fieldsForWR = new List<String> {'WOD_2__Status__c'};
                ATI_Utils.NoAccessObjectFieldWrapper sObjUpdateAccessCheckWR = ATI_Utils.fetchUpdateAccess('WOD_2__Warranty_Registration__c',fieldsForWR);
                if(sObjUpdateAccessCheckWR.noAccessObjectList.size() == 0 && sObjUpdateAccessCheckWR.noAccessFieldList.size() == 0){
                    List<Database.SaveResult> wrUpdateResult = Database.update(wrUpdateList,false);
                    set<string> wrFailedIds=new set<string>();
                    for(Integer i=0;i<wrUpdateResult.size();i++){
                        if (!wrUpdateResult.get(i).isSuccess()){
                            objBatchLogResult.failedRecordCount++;
                            Database.Error error = wrUpdateResult.get(i).getErrors().get(0);
                            String errorStr = error.getMessage();
                            errorStr = errorStr.replaceAll('(\\r|\\n)+', '');
                            String failedRecordStr = '';
                            if(wrSerialNumMap.containskey(wrUpdateList.get(i).Id)){
                                failedRecordStr =wrSerialNumMap.get(wrUpdateList.get(i).Id);
                            }
                            failedRecordStr = failedRecordStr + ',' + 'Warranty Registration : '+ wrUpdateList.get(i).Id + ' - ' + errorStr +'\n';
                            objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;
                            wrFailedIds.add(wrUpdateList.get(i).Id);
                        }
                    }
                        
                    List<WOD_2__Warranty_Coverages__c> coverageUpdateList=new List<WOD_2__Warranty_Coverages__c>();
                    if(wrCovUpdateList.size()>0){
                        for(WOD_2__Warranty_Coverages__c covRec : wrCovUpdateList){
                            if(!wrFailedIds.contains(covRec.WOD_2__Warranty_Registration__c)){
                                coverageUpdateList.add(covRec);
                            }
                        }
                        List<Database.SaveResult> wrCovUpdateResult = Database.update(coverageUpdateList,false);
                        set<string> wcFailedIds=new set<string>();
                        for(Integer i=0;i<wrCovUpdateResult.size();i++){
                            if(wrCovUpdateResult.get(i).isSuccess()){
                                wrIdSet.add(coverageUpdateList.get(i).WOD_2__Warranty_Registration__c); 
                            }
                            else if (!wrCovUpdateResult.get(i).isSuccess()){
                                objBatchLogResult.failedRecordCount++;
                                Database.Error error = wrCovUpdateResult.get(i).getErrors().get(0);
                                String errorStr = error.getMessage();
                                errorStr = errorStr.replaceAll('(\\r|\\n)+', '');
                                String failedRecordStr = '';
                                if(covSerialNumMap.containskey(coverageUpdateList.get(i).Id)){
                                    failedRecordStr =covSerialNumMap.get(coverageUpdateList.get(i).Id);
                                }
                                failedRecordStr = failedRecordStr + ',' + 'Warranty Coverage : ' + coverageUpdateList.get(i).Id + ' - ' +errorStr +'\n';
                                objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;
                                wcFailedIds.add(coverageUpdateList.get(i).Id);
                            }
                        }
                        if(wcFailedIds.size()>0){
                            Database.rollback(sp);
                        }
                               
                        List<WOD_2__Transaction_Memo_History__c> memoInsertList = new List<WOD_2__Transaction_Memo_History__c>();
                        List<WOD_2__Transaction_Memo_History_Line_Item__c> lineItemInsertList = new List<WOD_2__Transaction_Memo_History_Line_Item__c>();
                        List<WOD_2__Transaction_Memo_History__c> memoList = new List<WOD_2__Transaction_Memo_History__c>();
                                
                                
                        memoList = [SELECT Id,Name,ATI_Warranty_Registration__c,(SELECT Id,WOD_2__Transaction_Memo_History__c,Name,ATI_Late_Fee__c,ATI_Handling_Fee__c,WOD_2__Quantity__c,WOD_2__Total_Amount__c,WOD_2__Unit_Amount__c FROM WOD_2__Transaction_Memo_History_Line_Items__r)
                            FROM WOD_2__Transaction_Memo_History__c WHERE ATI_Warranty_Registration__c in :wrIdSet AND WOD_2__Transaction_Status__c='Paid' AND WOD_2__Transaction_Type__c='Debit' AND ATI_Type__c='EWP'];
                                                                                                    
                        Map<string,string> tranWRMap=new Map<string,string>();
                        for(WOD_2__Transaction_Memo_History__c memoRec:memoList){
                            WOD_2__Transaction_Memo_History__c transctnHistory = new WOD_2__Transaction_Memo_History__c(Name=memoRec.Name, ATI_Type__c='EWP',WOD_2__Amount__c =memoRec.WOD_2__Transaction_Memo_History_Line_Items__r[0].WOD_2__Total_Amount__c,
                            WOD_2__Transaction_Type__c ='Credit', WOD_2__Transaction_Status__c ='Pending', WOD_2__Settlement_Category__c ='EWP',ATI_Warranty_Registration__c = memoRec.ATI_Warranty_Registration__c);
                            memoInsertList.add(transctnHistory);
                        }
                                        
                        if(memoInsertList.size()>0){
                            List<Database.SaveResult> memoInsertResult = Database.insert(memoInsertList,false);
                            set<string> successIdSet=new set<string>();
                            Map<string,string> memoMap = new Map<string,string>();
                            Map<string,string> memoInvMap = new Map<string,string>();
                            boolean isFailure = false;
                            for(Integer i=0;i<memoInsertResult.size();i++){
                                if(memoInsertResult.get(i).isSuccess()){
                                    tranWRMap.put(memoInsertList.get(i).Id,memoInsertList.get(i).ATI_Warranty_Registration__c);
                                    successIdSet.add(memoInsertList.get(i).Id);
                                    memoMap.put(memoInsertList.get(i).Name+memoInsertList.get(i).ATI_Warranty_Registration__c,memoInsertResult.get(i).Id);
                                }
                                else if (!memoInsertResult.get(i).isSuccess()){
                                    isFailure=true;
                                    objBatchLogResult.failedRecordCount++;
                                    objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + wrSerialNumMap.get(memoInsertList.get(i).ATI_Warranty_Registration__c)+',' + 'Transaction Memo History - ' + memoInsertResult.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n';
                                }
                            }
                                            
                            if(isFailure){
                                Database.rollback(sp);
                            }
                                            
                            if(successIdSet.size()>0){
                                isFailure=false;
                                for(WOD_2__Transaction_Memo_History__c memoRec:memoList){
                                    if(memoMap.containskey(memoRec.Name+memoRec.ATI_Warranty_Registration__c)){
                                        for(WOD_2__Transaction_Memo_History_Line_Item__c lineItemRec : memoRec.WOD_2__Transaction_Memo_History_Line_Items__r){
                                            WOD_2__Transaction_Memo_History_Line_Item__c transactionLineItem = new WOD_2__Transaction_Memo_History_Line_Item__c(WOD_2__Transaction_Memo_History__c=memoMap.get(memoRec.Name+memoRec.ATI_Warranty_Registration__c),
                                            Name= lineItemRec.Name, WOD_2__Total_Amount__c= lineItemRec.WOD_2__Total_Amount__c,WOD_2__Unit_Amount__c=lineItemRec.WOD_2__Unit_Amount__c,ATI_Late_Fee__c=lineItemRec.ATI_Late_Fee__c,ATI_Handling_Fee__c=lineItemRec.ATI_Handling_Fee__c, WOD_2__Transaction_Type__c= 'Credit', WOD_2__Quantity__c=1);
                                            lineItemInsertList.add(transactionLineItem);
                                        }
                                    }
                                }
                                if(lineItemInsertList.size()>0){
                                    List<Database.SaveResult> lineItemResult = Database.insert(lineItemInsertList,false);
                                    for(Integer i=0;i<lineItemResult.size();i++){
                                        if(lineItemResult.get(i).isSuccess()){
                                            objBatchLogResult.successRecordCount++;
                                            if(tranWRMap.containskey(lineItemInsertList.get(i).WOD_2__Transaction_Memo_History__c)){
                                                if(wrSerialNumMap.containskey(tranWRMap.get(lineItemInsertList.get(i).WOD_2__Transaction_Memo_History__c))){
                                                    objBatchLogResult.successRecordsSet.add(wrSerialNumMap.get(tranWRMap.get(lineItemInsertList.get(i).WOD_2__Transaction_Memo_History__c)));
                                                }
                                            }
                                        }
                                        else if (!lineItemResult.get(i).isSuccess()){
                                            objBatchLogResult.failedRecordCount++;
                                            isFailure=true;
                                            objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + wrSerialNumMap.get(lineItemInsertList.get(i).WOD_2__Transaction_Memo_History__r.ATI_Warranty_Registration__c)+',' + 'Transaction Memo History - ' + lineItemResult.get(i).getErrors().get(0).getMessage().replaceAll('(\\r|\\n)+', '')+'\n';
                                        }
                                    }
                                    if(isFailure){
                                        Database.rollback(sp);
                                    }
                                }
                            }             
                        }
                        else{
                            for(String wrId : wrIdSet){
                                objBatchLogResult.failedRecordCount++;
                                objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + wrSerialNumMap.get(wrId)+',' + System.label.ATI_BulkCancellationNoMemoError +'\n';
                            }
                            Database.rollback(sp);
                        }
                    }
                } 
                else{
                    for(WOD_2__Warranty_Registration__c wrRec : wrUpdateList){
                        objBatchLogResult.failedRecordCount++;
                        String failedRecordStr =wrRec.WOD_2__Inventory__r.WOD_2__Serial_Number__c + ',' +System.label.ATI_Log_Insufficient_access+'\n';
                        objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;         
                    }
                    Database.rollback(sp);
                }
            }
            else{
                for(String serialNum : serialNumSet){
                    objBatchLogResult.failedRecordCount++;
                    String failedRecordStr =serialnum + ',' +System.label.ATI_Log_Insufficient_access+'\n';
                    objBatchLogResult.failedRecords = objBatchLogResult.failedRecords + failedRecordStr;
                }
            }
            return objBatchLogResult;
        } catch (Exception e) {
            System.debug('====WR create error==' + e);
            System.debug('====WR create error line==' + e.getLineNumber());
            throw e;
        }
    }
    
    public class RecordWithResult {
        public Boolean isAnyError;
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