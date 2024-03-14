/**
* (c) 2020 Tavant Technology.
* --------------------------------------------------------------------------------------------------------
This class is used to upload bulk records. Uploaded file is initially stored in WOD_2__Batch_Log__c object 
then proccessed in this class and stored under objected mentioned in ATI_Bulk_Upload_Configuration__mdt.
* --------------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        (TY) - (23-DEC-2020)
* -------------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------------
*/
public with sharing class ATI_BulkUploadHandler implements ATI_BulkUploadProcessInterface{ 
    public static ATI_BulkUploadConfiguration bulkUploadConfigurationObj;
    public static List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst;
    
    
    //Proccessing uploaded file based on ATI_Bulk_Upload_Configuration__mdt and insert it
    public static ATI_BatchLogResults parseData(List<Map<String,Object>> bulkUploadDataMap, String strParentId){
        ATI_BatchLogResults objBatchLogResult = new ATI_BatchLogResults();//store process record count with success and failures.
        objBatchLogResult.totalRecordCount = bulkUploadDataMap.size();
        WOD_2.ResponseWrapper objBatchLogReadAccessCheck =  ATI_Utils.CheckReadAccess('WOD_2__Batch_Log__c',new List<String>{'WOD_2__Process_Type__c'});
        Map<String,Object> accessCheckMap = (Map<String,Object>)Json.deserializeUntyped(objBatchLogReadAccessCheck.data);
        if(objBatchLogReadAccessCheck.status && ((List<Object>)accessCheckMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckMap.get('noAccessFieldList')).isEmpty()){
            List<WOD_2__Batch_Log__c> batchLogLst = [Select Id,WOD_2__Process_Type__c from WOD_2__Batch_Log__c where Id=: strParentId];
            //fetching bulk upload configuration configuration
            if(!batchLogLst.isEmpty() && !Test.isRunningTest()){
                List<ATI_Bulk_Upload_Configuration__mdt> bulkUploadConfigLst =  Database.query('SELECT Id,ATI_Object_API_Name__c,(SELECT Id,ATI_Column_Name__c,ATI_Field_API_Name__c,ATI_Object_API_Name__c,ATI_Type__c,ATI_Reference_Object_API_Name__c,ATI_Reference_Field_API_Name__c,ATI_IsMandatory__c,ATI_Bulk_Upload_Configuration__c,ATI_Reference_BU_Name__c FROM ATI_Bulk_Upload_Field_Mappings__r) FROM ATI_Bulk_Upload_Configuration__mdt WHERE ATI_Process_Type__c ='+'\''+batchLogLst[0].WOD_2__Process_Type__c+'\'');
                bulkUploadConfigurationObj = new ATI_BulkUploadConfiguration();
                bulkUploadConfigurationObj.objectApiNameStr = bulkUploadConfigLst[0].ATI_Object_API_Name__c;
                if(!bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r.isEmpty()){
                    bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
                    for(ATI_Bulk_Upload_Field_Mapping__mdt objBulkUploadFieldMap : bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r){
                        if(bulkUploadConfigLst[0].ATI_Object_API_Name__c == objBulkUploadFieldMap.ATI_Object_API_Name__c){
                            ATI_BulkUploadFieldMapping objFieldMapping = new ATI_BulkUploadFieldMapping();
                            objFieldMapping.fieldAPIName = objBulkUploadFieldMap.ATI_Field_API_Name__c ;
                            objFieldMapping.objectAPIName = objBulkUploadFieldMap.ATI_Object_API_Name__c ;
                            objFieldMapping.columnName = objBulkUploadFieldMap.ATI_Column_Name__c ;
                            objFieldMapping.isMandatory = objBulkUploadFieldMap.ATI_IsMandatory__c ;
                            objFieldMapping.referenceFieldAPIName = objBulkUploadFieldMap.ATI_Reference_Field_API_Name__c ;
                            objFieldMapping.referenceObjectAPIName = objBulkUploadFieldMap.ATI_Reference_Object_API_Name__c ;
                            objFieldMapping.type = objBulkUploadFieldMap.ATI_Type__c ;
                            objFieldMapping.referenceBUName = objBulkUploadFieldMap.ATI_Reference_BU_Name__c;
                            bulkUploadFieldMappingLst.add(objFieldMapping);
                        }
                    }
                }
            }
            Map<String, ATI_BulkUploadFieldMapping> bulkUploadFieldMappingMap = new Map<String, ATI_BulkUploadFieldMapping>();//bulk  upload field mappings with column names
            Map<String,String> referenceFieldWithQueryMap =  new Map<String,String>(); //used to put partial query for reference fields from configuration
            //Map<String,String> fieldLabelWithColumnNameMap = new Map<String,String>(); //used to change field API name with column name for error logs
            Map<String,List<String>> refObjNameWithFieldsAccCheckMap = new Map<String,List<String>>(); //used to check field access for all fields
            refObjNameWithFieldsAccCheckMap.put(bulkUploadConfigurationObj.objectApiNameStr, new List<String>()); // adding base object to access
            //fetching configurations to upload
            for(ATI_BulkUploadFieldMapping objBulkUploadFieldMap : bulkUploadFieldMappingLst){
                bulkUploadFieldMappingMap.put(objBulkUploadFieldMap.columnName,objBulkUploadFieldMap);
                //fieldLabelWithColumnNameMap.put(objBulkUploadFieldMap.API_Field_Name__c,objBulkUploadFieldMap.Column_Name__c);
                refObjNameWithFieldsAccCheckMap.get(bulkUploadConfigurationObj.objectApiNameStr).add(objBulkUploadFieldMap.fieldAPIName);
                //framing query for reference fields
                if(objBulkUploadFieldMap.type == 'Reference'){
                    if(refObjNameWithFieldsAccCheckMap.containsKey(objBulkUploadFieldMap.referenceObjectAPIName))
                        refObjNameWithFieldsAccCheckMap.get(objBulkUploadFieldMap.referenceObjectAPIName).add(objBulkUploadFieldMap.referenceFieldAPIName);
                    else
                        refObjNameWithFieldsAccCheckMap.put(objBulkUploadFieldMap.referenceObjectAPIName,new List<String>{objBulkUploadFieldMap.referenceFieldAPIName});
                    String strQuery='';
                    if(objBulkUploadFieldMap.referenceFieldAPIName != 'Id')
                        strQuery = 'SELECT Id,'+objBulkUploadFieldMap.referenceFieldAPIName+' FROM '+
                        objBulkUploadFieldMap.referenceObjectAPIName + ' WHERE '+objBulkUploadFieldMap.referenceFieldAPIName +
                        ' IN :';
                    else
                        strQuery =  'SELECT '+objBulkUploadFieldMap.referenceFieldAPIName+' FROM '+
                        objBulkUploadFieldMap.referenceObjectAPIName + ' WHERE '+objBulkUploadFieldMap.referenceFieldAPIName +
                        ' IN :';
                    referenceFieldWithQueryMap.put( objBulkUploadFieldMap.columnName ,strQuery);
                }
            }
            Map<String, Map<String,String>> referenceValuesToUseMap = new Map<String, Map<String,String>>(); // column name with uploaded value for reference and its Id
            //Map<String, Map<String,String>> referenceIdWithValuesToUseMap = new Map<String, Map<String,String>>(); // column name with referenceID and its value
            //itirate through uploaded data to get column value of reference field
            if(!referenceFieldWithQueryMap.isEmpty()){
                Map<String,List<String>> referenceFieldValuesMap = new Map<String,List<String>>();//reference column name with its value
                //getting reference field values form uploaded file
                for(Map<String,Object> objData : bulkUploadDataMap){
                    for(String strKeys : objData.keySet()){
                        if(referenceFieldWithQueryMap.containsKey(strKeys)){
                            string strVal = (String)objData.get(strKeys);
                            if(referenceFieldValuesMap.containsKey(strKeys))
                                referenceFieldValuesMap.get(strKeys).add(strVal);
                            else{
                                referenceFieldValuesMap.put(strKeys,new List<String>());
                                referenceFieldValuesMap.get(strKeys).add(strVal);
                            }
                        }
                    }
                }
                Set<String> objectHavingReadAccessSet = new Set<String>();
                //checking read access for reference objects and fields for querying
                if(!refObjNameWithFieldsAccCheckMap.isEmpty()){
                    for(String strObjectName : refObjNameWithFieldsAccCheckMap.keySet()){
                        WOD_2.ResponseWrapper objCheckReadAccess = ATI_Utils.CheckReadAccess(strObjectName,refObjNameWithFieldsAccCheckMap.get(strObjectName));
                        Map<String,Object> accessCheckForRefMap = (Map<String,Object>)Json.deserializeUntyped(objCheckReadAccess.data);
                        if(objCheckReadAccess.status && ((List<Object>)accessCheckForRefMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckForRefMap.get('noAccessFieldList')).isEmpty()){
                            objectHavingReadAccessSet.add(strObjectName);
                        }
                    }
                }
                
                //Querying refence fields. Uploaded file can have many object and field reference in it. We need to get referce IDs for each column.
                //So, we are doing SOQL inside for loop which will loop through each coloum and store matched reference Id column wise.
                for(String strReferenceKey : referenceFieldWithQueryMap.keySet()){
                    
                    String strQuery = referenceFieldWithQueryMap.get(strReferenceKey);
                    String strObjectName = bulkUploadFieldMappingMap.get(strReferenceKey).referenceObjectAPIName;
                    if(!objectHavingReadAccessSet.isEmpty() && objectHavingReadAccessSet.contains(strObjectName) && !referenceFieldValuesMap.isEmpty() && referenceFieldValuesMap.containsKey(strReferenceKey) && !referenceFieldValuesMap.get(strReferenceKey).isEmpty()){
                        List<String> queryList = referenceFieldValuesMap.get(strReferenceKey);
                        strQuery += 'queryList';
                        List<sObject> referenceObjectLst = Database.query(strQuery);
                        if(!referenceObjectLst.isEmpty()){
                            Map<String,String> mapFieldKEyWithValue = new map<String,String>();
                            for(SObject objSObject : referenceObjectLst){
                                ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strReferenceKey);
                                string fieldName = objfielMapMdt.referenceFieldAPIName;
                                String fieldVal= (string)objSObject.get(fieldName);
                                mapFieldKEyWithValue.put(fieldVal,objSObject.Id);
                            }
                            if(!mapFieldKEyWithValue.isEmpty())
                                referenceValuesToUseMap.put(strReferenceKey,mapFieldKEyWithValue);
                        }
                    }
                }
            }
            
            String listType = 'List<' + bulkUploadConfigurationObj.objectApiNameStr + '>';
            List<SObject> recordsToInsertLst = (List<SObject>)Type.forName(listType).newInstance();
            List<Map<String,Object>> objToMapForErrorLst = new List<Map<String,Object>>();
            //iteration through uploaded file to insert records
            for(Map<String,Object> objData : bulkUploadDataMap){
                SObject objSObject = Schema.getGlobalDescribe().get(bulkUploadConfigurationObj.objectApiNameStr).newSObject();
                Boolean isMandatoryCheckSuccess = true ;
                for(String strKeys : objData.keySet()){
                    String strCoulumVal = (String)objData.get(strKeys);
                    ATI_BulkUploadFieldMapping objfielMapMdt = bulkUploadFieldMappingMap.get(strKeys);
                    //ignore columns if not present in configuration
                    if(objfielMapMdt != null){
                        string fieldAPIName = objfielMapMdt.fieldAPIName;
                        if(objfielMapMdt.IsMandatory == true && String.isBlank(strCoulumVal)){
                            System.debug('strCoulumVal>>>>> '+strCoulumVal);
                            isMandatoryCheckSuccess = false;
                            objBatchLogResult.failedRecordCount ++;
                            objBatchLogResult.failedRecords = objBatchLogResult.failedRecords +String.join(objData.values(),',')+','+Label.ATI_MandatoryFieldMissingError+'\n ';
                            break;
                        }
                        if(!referenceFieldWithQueryMap.isEmpty() && referenceFieldWithQueryMap.containsKey(strKeys) ){
                            if(objfielMapMdt.IsMandatory == true && (referenceValuesToUseMap.isEmpty() || !referenceValuesToUseMap.containsKey(strKeys) || !referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal))){
                                System.debug('referenceValuesToUseMap>>>>> '+referenceValuesToUseMap +' strCoulumVal>>>>> '+strCoulumVal);
                                isMandatoryCheckSuccess = false;
                                objBatchLogResult.failedRecordCount ++;
                                objBatchLogResult.failedRecords = objBatchLogResult.failedRecords +String.join(objData.values(),',')+','+Label.ATI_MandatoryFieldMissingError+'\n ';
                                break;
                            }
                            if(!referenceValuesToUseMap.isEmpty() && referenceValuesToUseMap.containsKey(strKeys) && referenceValuesToUseMap.get(strKeys).containsKey(strCoulumVal)){
                                objSObject.put(fieldAPIName,referenceValuesToUseMap.get(strKeys).get(strCoulumVal));
                            }
                        }
                        else{
                            try{
                                if(objfielMapMdt.Type =='Decimal')
                                    objSObject.put(fieldAPIName,decimal.valueOf(strCoulumVal));
                                else if(objfielMapMdt.Type =='Integer')
                                    objSObject.put(fieldAPIName,Integer.valueOf(strCoulumVal));
                                else if(objfielMapMdt.Type =='Date')
                                    objSObject.put(fieldAPIName,Date.parse(strCoulumVal));
                                else if(objfielMapMdt.Type =='DateTime')
                                    objSObject.put(fieldAPIName,DateTime.parse(strCoulumVal));
                                else if(objfielMapMdt.Type =='Boolean')
                                    objSObject.put(fieldAPIName,Boolean.valueof(strCoulumVal));
                                else
                                    objSObject.put(fieldAPIName,strCoulumVal);
                            }
                            catch(Exception exp){
                                isMandatoryCheckSuccess = false;
                                objBatchLogResult.failedRecordCount ++;
                                objBatchLogResult.failedRecords = objBatchLogResult.failedRecords +String.join(objData.values(),',')+','+exp.getMessage()+'\n ';
                                break;
                            }
                        }
                    }
                }
                if(isMandatoryCheckSuccess){
                    recordsToInsertLst.add(objSObject);
                    objToMapForErrorLst.add(objData);
                }
            }
            if(!recordsToInsertLst.isEmpty()){
                System.debug('recordsToInsertLst>>>>>>> '+recordsToInsertLst);
                List<Database.SaveResult> lstInsertResult = Database.insert(recordsToInsertLst,false);
                Integer saveResultIndex = 0;
                // Iterate through each returned result
                for (Database.SaveResult sr : lstInsertResult) {
                    if (sr.isSuccess()) {
                        objBatchLogResult.successRecordCount++;
                    }
                    else{
                        objBatchLogResult.failedRecordCount ++;
                        Database.Error error = sr.getErrors().get(0);
                        String errorStr = error.getMessage();
                        errorStr = errorStr.replaceAll('(\\r|\\n)+', '');
                        String failedRecordStr = String.join(objToMapForErrorLst[saveResultIndex].values(),',')+','+errorStr+'\n ';
                        objBatchLogResult.failedRecords = objBatchLogResult.failedRecords +failedRecordStr;
                    }
                    saveResultIndex ++;
                }
            }
            
        }
        return objBatchLogResult;
    }
}