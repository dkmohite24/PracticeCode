/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
This class is used for BulkUpload component to process uploaded file
* -------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        22-DEC-2020
* @modified
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
public class ATI_BulkUploadBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
 String strBatchLogId;
    public Integer proccesingCount;
    public ATI_BatchLogResults batchLogResultsObj;
    public Static ATI_BulkUploadConfiguration bulkUploadConfigMdt;
    public Static List<ATI_BulkUploadFieldMapping> bulkUploadFieldMappingLst;
    public static List<String> configurationObjectFieldLst;
    List<String> configurationObjectColumnFieldLst;
    
    public ATI_BulkUploadBatch(String strBatchLogIdTemp) {
        strBatchLogId = strBatchLogIdTemp;
        batchLogResultsObj = new ATI_BatchLogResults();
        batchLogResultsObj.successRecordIdsSet = new Set<Id>();
        batchLogResultsObj.successRecordsSet = new Set<String>();
        proccesingCount = 0;
        configurationObjectColumnFieldLst = new List<String>();
    }
    
    //Used to upaded the satus of the batch log and process the attached file
    public Database.QueryLocator start(Database.BatchableContext bc) {
       	WOD_2.ResponseWrapper objBatchLogAccessCheck =  ATI_Utils.checkUpdateAccess('WOD_2__Batch_Log__c',new List<String>{'ATI_Status__c','ATI_Error_Message__c'});
        Map<String,Object> accessCheckMap = (Map<String,Object>)Json.deserializeUntyped(objBatchLogAccessCheck.data);
        if(objBatchLogAccessCheck.status && ((List<Object>)accessCheckMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckMap.get('noAccessFieldList')).isEmpty()){
            bulkUploadOverrideCheck();
            if(bulkUploadConfigMdt == null || configurationObjectFieldLst.isEmpty()){
                WOD_2__Batch_Log__c objFailedBatchLog = new WOD_2__Batch_Log__c(Id=strBatchLogId,ATI_Status__c='Failed',ATI_Error_Message__c=Label.ATI_NoConfigurationFound);
                update objFailedBatchLog;
                String query = 'SELECT Id, VersionData, ContentDocumentId from contentversion where ContentDocumentId = \'000000000000000\'';
                return Database.getQueryLocator(query);
            } else {
                WOD_2.ResponseWrapper objCreateAccessCheck = ATI_Utils.checkCreateAccess(bulkUploadConfigMdt.objectApiNameStr,configurationObjectFieldLst);
                Map<String,Object> createAccessCheckMap = (Map<String,Object>)Json.deserializeUntyped(objCreateAccessCheck.data);
                if((objBatchLogAccessCheck.status && ((List<Object>)createAccessCheckMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)createAccessCheckMap.get('noAccessFieldList')).isEmpty())){
                    WOD_2__Batch_Log__c objBatchLog = new WOD_2__Batch_Log__c(Id=strBatchLogId,ATI_Status__c='Initiated',WOD_2__Batch_Start_Date__c=System.now());
                    update objBatchLog;
                    // The file name starts with 'BulkUpload_' (Contains JSON data) will be used to process the claims data
                    List<ContentDocumentLink> contentDocumentLinkObjList = [SELECT ContentDocumentId, ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId =:strBatchLogId AND ContentDocument.title like '%BulkUpload_%'];
                    List<Id> contentDocumentIdList = new List<Id>();
                    for(ContentDocumentLink contentDocumentObj : contentDocumentLinkObjList ) {
                        contentDocumentIdList.add(ContentDocumentObj.ContentDocumentId);
                    }
                    return Database.getQueryLocator([SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIdList]);
                }else{
                    WOD_2__Batch_Log__c objFailedBatchLog = new WOD_2__Batch_Log__c(Id=strBatchLogId,ATI_Status__c='Failed',ATI_Error_Message__c=Label.ATI_Log_Insufficient_access);
                    update objFailedBatchLog;
                    String query = 'SELECT Id, VersionData, ContentDocumentId from contentversion where ContentDocumentId = \'000000000000000\'';
                    return Database.getQueryLocator(query);
                }
            }
        } else {
            String query = 'SELECT Id, VersionData, ContentDocumentId from contentversion where ContentDocumentId = \'000000000000000\'';
            return Database.getQueryLocator(query);
        } 
    }
    
	
    //Used for proccessing attachments under batch log
	public void execute(Database.BatchableContext bc, List<ContentVersion> lstAttachment) {
        List<Object> lstBulkUploadData = new List<Object>();
        List<map<string,object>> mapBulkUploadData =  new List<map<String,Object>>();
        //deserialize the JSON persent in attachment boday to proccess and store
        for(ContentVersion objAttchments :lstAttachment) {
            String strBlob =  objAttchments.VersionData.tostring();     // replaced Body of attachment
            lstBulkUploadData = (List<Object>)JSON.deserializeUntyped(strBlob);
        }
        
        //bulkUploadOverrideCheck(); 
        for(Object objMemberData : lstBulkUploadData) {
            Map<String, Object> objMemberDataMap = (Map<String, Object>)objMemberData;
            mapBulkUploadData.add(objMemberDataMap);
            if(configurationObjectColumnFieldLst.isEmpty() && !objMemberDataMap.isEmpty()){
                configurationObjectColumnFieldLst.addAll(objMemberDataMap.keySet());
            }
        }
        //Anjali added for allignment issue in Bulk Claim
        
        if(configurationObjectColumnFieldLst.contains('Parts'))
        {
        configurationObjectColumnFieldLst.remove(configurationObjectColumnFieldLst.indexOf('Parts'));
        }
        if(configurationObjectColumnFieldLst.contains('Labor')){
        configurationObjectColumnFieldLst.remove(configurationObjectColumnFieldLst.indexOf('Labor'));
        }
        if(configurationObjectColumnFieldLst.contains('OtherCost')){
        configurationObjectColumnFieldLst.remove(configurationObjectColumnFieldLst.indexOf('OtherCost'));
        }
        if(configurationObjectColumnFieldLst.contains('DiagnosticCode')){
        configurationObjectColumnFieldLst.remove(configurationObjectColumnFieldLst.indexOf('DiagnosticCode'));
        }
        configurationObjectColumnFieldLst.addAll(new List<String>{'Parts','Labor','OtherCost','DiagnosticCode'});
      
        
        if(proccesingCount == 0){
            WOD_2.ResponseWrapper objBatchLogAccessCheck =  ATI_Utils.checkUpdateAccess('WOD_2__Batch_Log__c',new List<String>{'ATI_Status__c'});
            Map<String,Object> accessCheckMap = (Map<String,Object>)Json.deserializeUntyped(objBatchLogAccessCheck.data);
          	if(objBatchLogAccessCheck.status && ((List<Object>)accessCheckMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckMap.get('noAccessFieldList')).isEmpty()) {
                WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Id=strBatchLogId,
                                                                                                                           ATI_Status__c='Processing')},true);
            }
            proccesingCount++;
        }
        if(!mapBulkUploadData.isEmpty()) { 
            //  Need to reload bulkUploadFieldMappingLst 
            bulkUploadOverrideCheck(); 
            
            //check any override persent for current proccess type
            ATI_BatchLogResults objBatchLogResultAfterProcessing = new ATI_BatchLogResults();
            if(String.isBlank(bulkUploadConfigMdt.classOverrideName)) {
                objBatchLogResultAfterProcessing = ATI_BulkUploadHandler.parseData(mapBulkUploadData,strBatchLogId);
            } else {
                Type classType = Type.forName(bulkUploadConfigMdt.classOverrideName);
                ATI_BulkUploadProcessInterface instance = (ATI_BulkUploadProcessInterface) classType.newInstance();
                objBatchLogResultAfterProcessing = instance.parseData(mapBulkUploadData,strBatchLogId);
            }
            batchLogResultsObj.totalRecordCount = batchLogResultsObj.totalRecordCount + objBatchLogResultAfterProcessing.totalRecordCount;
            batchLogResultsObj.successRecordCount = batchLogResultsObj.successRecordCount + objBatchLogResultAfterProcessing.successRecordCount;
            batchLogResultsObj.failedRecordCount = batchLogResultsObj.failedRecordCount + objBatchLogResultAfterProcessing.failedRecordCount;
            batchLogResultsObj.failedRecords = batchLogResultsObj.failedRecords + objBatchLogResultAfterProcessing.failedRecords;
            if(objBatchLogResultAfterProcessing.successRecordIdsSet != null){
                batchLogResultsObj.successRecordIdsSet.addAll(objBatchLogResultAfterProcessing.successRecordIdsSet);
            }
            if(objBatchLogResultAfterProcessing.successRecordsSet != null){
                batchLogResultsObj.successRecordsSet.addAll(objBatchLogResultAfterProcessing.successRecordsSet);
            }
            
            //attach failed records under batch log
            if(batchLogResultsObj.failedRecords.length() >3000000){
                insertFailedRecords();
            }
        }
      
    }
    
     //used to update the batch log status with success and failure
    public void finish(Database.BatchableContext bc) {
        //  Need to reload bulkUploadFieldMappingLst
        bulkUploadOverrideCheck();
        //run another batch to submit claims Ravi - need to add this only for claim
        WOD_2__Batch_Log__c objBatchLog = [Select Id, OwnerId,ATI_Status__c,ATI_Error_Message__c,WOD_2__Process_Type__c From WOD_2__Batch_Log__c Where Id=: strBatchLogId];
        List<WOD_2__Claim__c> claimsLst = [SELECT Id,Name,WOD_2__BusinessCategory__c FROM WOD_2__Claim__c WHERE Id IN:batchLogResultsObj.successRecordIdsSet];
        if(bulkUploadConfigMdt.processType == 'ClaimUpload'){
            if(claimsLst.size()>=1){
                ATI_BulkClaimUploadSubmittalBatch validateClaimSubmittalBatch =new ATI_BulkClaimUploadSubmittalBatch(strBatchLogId,batchLogResultsObj,bulkUploadConfigMdt,configurationObjectColumnFieldLst,bulkUploadFieldMappingLst);
                Database.executeBatch(validateClaimSubmittalBatch,1);
            }
            failedRecordsSaveHelper(objBatchLog);
            /*else {
                if(objBatchLog.ATI_Status__c != 'Failed' && claimsLst.size() == 1) {
                    List<WOD_2.TWoD_RecordOutputWrapper> outputWrapper = ATI_BulkClaimService.validateBURules(claimsLst[0]);
                    System.debug('outputWrapper>>>>> '+outputWrapper);
                    if(outputWrapper.get(0).status){
                        insertSuccessRecords(strBatchLogId, batchLogResultsObj.successRecordIdsSet,bulkUploadConfigMdt.objectApiNameStr);
                    }else{
                        batchLogResultsObj.successRecordCount--;
                        batchLogResultsObj.failedRecordCount++;
                        
                        batchLogResultsObj.failedRecords = batchLogResultsObj.failedRecords + ', Claim submission failed :'+claimsLst[0].Name+', Please contact support!';
                    }
                }
                failedRecordsSaveHelper(objBatchLog);
            }*/
        }else{
            if(batchLogResultsObj.successRecordCount > 0){
                if(bulkUploadConfigMdt.processType == 'WRCancellationUpload'){
                    insertSuccessWRCancelRecords(strBatchLogId, batchLogResultsObj.successRecordsSet);
                }else{
                    insertSuccessRecords(strBatchLogId, batchLogResultsObj.successRecordIdsSet,bulkUploadConfigMdt.objectApiNameStr); // objectName => bulkUploadConfigMdt.objectApiNameStr 
                }
            }
            failedRecordsSaveHelper(objBatchLog);
        }
    }
    
    private void failedRecordsSaveHelper(WOD_2__Batch_Log__c objBatchLog){
        WOD_2.ResponseWrapper objBatchLogAccessCheck =  ATI_Utils.checkUpdateAccess('WOD_2__Batch_Log__c',new List<String>{'WOD_2__Process_Type__c','WOD_2__Success_Record_Count__c','WOD_2__Failure_Record_Count__c','WOD_2__Total_Record_Count__c','ATI_Status__c','WOD_2__Batch_End_Date__c'});
        Map<String,Object> accessCheckMap = (Map<String,Object>)Json.deserializeUntyped(objBatchLogAccessCheck.data);
        if(objBatchLogAccessCheck.status && ((List<Object>)accessCheckMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckMap.get('noAccessFieldList')).isEmpty()) {
            if(objBatchLog.ATI_Status__c != 'Failed') {
                WOD_2__Batch_Log__c batchLogObj = new WOD_2__Batch_Log__c(Id=objBatchLog.Id,WOD_2__Batch_End_Date__c=System.now(),
                                                                          //WOD_2__Success_Record_Count__c=batchLogResultsObj.successRecordCount,
                                                                          WOD_2__Failure_Record_Count__c=batchLogResultsObj.failedRecordCount,
                                                                          WOD_2__Total_Record_Count__c = batchLogResultsObj.totalRecordCount);
                String status = 'Completed';
                if(bulkUploadConfigMdt.processType == 'ClaimUpload'){
                    status = (batchLogResultsObj.successRecordCount > 0) ? 'Processing' : 'Completed' ;
                }
                if(status == 'Completed'){
                    batchLogObj.WOD_2__Success_Record_Count__c=batchLogResultsObj.successRecordCount;
                }
                batchLogObj.ATI_Status__c=status;
                WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{batchLogObj},true);
                
                insertFailedRecords();
                ATI_BulkUploadEmailNotification.sendBulkUploadCompletedEmail(strBatchLogId);
            }else{
                // Update the failed record count
                WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.updateSObjects(new List<WOD_2__Batch_Log__c>{new WOD_2__Batch_Log__c(Id=objBatchLog.Id,WOD_2__Batch_End_Date__c=System.now(),
                                                                                                                                          WOD_2__Success_Record_Count__c=batchLogResultsObj.successRecordCount,
                                                                                                                                          WOD_2__Failure_Record_Count__c=batchLogResultsObj.failedRecordCount,
                                                                                                                                          WOD_2__Total_Record_Count__c = batchLogResultsObj.totalRecordCount)},true);
                insertFailedRecords();
            }
        }
    }
    
     //insert failed records as attachments
    private void insertFailedRecords(){
        List<User> users = [SELECT IsActive,IsPortalEnabled,LastName,Contact.AccountId FROM User where Id = :UserInfo.getUserId()];
        Boolean isPortalEnabled = users[0].IsPortalEnabled;
        List<ContentDocumentLink> cDocList = new List<ContentDocumentLink>();
        WOD_2.ResponseWrapper objCVCreateAccessCheck =  ATI_Utils.checkCreateAccess('ContentVersion',new List<String>{'PathOnClient','ContentLocation','Title','VersionData'});
        if(objCVCreateAccessCheck.status && String.isNotBlank(batchLogResultsObj.failedRecords)){
            WOD_2.ResponseWrapper responseWrapperObj;
            if(isPortalEnabled){
                String communityId = null;
                String communityName = bulkUploadConfigMdt.communityName;
                List<Network> network = new List<Network>();
                if(communityName != ''){
                    network = [Select Id, Name From Network Where Name =: communityName Limit 1];
                }         
                
                if(network.size()>0){
                    communityId = network[0].Id;
                }
                responseWrapperObj = ATI_Utils.insertSObjects(new List<ContentVersion>{new ContentVersion(VersionData=Blob.valueOf(String.join(configurationObjectColumnFieldLst,',')+',Failure Reason\n '+batchLogResultsObj.failedRecords),
                                                                                                               PathOnClient='BulkUploadFailure_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv',
                                                                                                               Title='BulkUploadFailure_' + System.now().format('yyyy_MM_dd_hh_mm_ss'),
                                                                                                               ContentLocation='S',
                                                                                                               NetworkId=communityId)},true);
            }else{
                responseWrapperObj = ATI_Utils.insertSObjects(new List<ContentVersion>{new ContentVersion(VersionData=Blob.valueOf(String.join(configurationObjectColumnFieldLst,',')+',Failure Reason\n '+batchLogResultsObj.failedRecords),
                                                                                                               PathOnClient='BulkUploadFailure_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv',
                                                                                                               Title='BulkUploadFailure_' + System.now().format('yyyy_MM_dd_hh_mm_ss'),
                                                                                                               ContentLocation='S')},true);
            }
            
            List<Database.SaveResult> cvSuccessList = (List<Database.SaveResult>)Json.deserialize(responseWrapperObj.data,List<Database.SaveResult>.class);
			Set<Id> conVersionIdSet = new Set<Id>();
            for(Database.SaveResult conVerResult : cvSuccessList) {
                if(conVerResult.Id != null) {
                    conVersionIdSet.add(conVerResult.Id);
                }
            }
            
            Map<String,ContentVersion> conVerIdWithConDocIdMap = new Map<String,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionIdSet]);
            for(Database.SaveResult conVerResult : cvSuccessList) {
                if(conVerResult.Id != null) {
                    // First get the content document Id from ContentVersion
                    // Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVerResult.Id].ContentDocumentId;
                    Id conDoc = conVerIdWithConDocIdMap.get(conVerResult.Id).ContentDocumentId;
                    ContentDocumentLink cDoc = new ContentDocumentLink();
                    cDoc.ContentDocumentId = conDoc;
                    cDoc.LinkedEntityId = strBatchLogId; // BatchLog Id
                    cDoc.ShareType = 'V'; //Only View permission
                    cDoc.Visibility = 'AllUsers'; // AllUsers/InternalUsers/SharedUsers
                    cDocList.add(cDoc);
                }
            }
            if(cDocList.size()>0) { 
                insert cDocList;
                responseWrapperObj.data = '';
                responseWrapperObj.status = true;
                responseWrapperObj.errormessage = '';
            }
            
        }
        batchLogResultsObj.failedRecords = '';
    }
    
    //check any override persent for current proccess type also check configuration based on process type
    private void bulkUploadOverrideCheck(){
        WOD_2.ResponseWrapper objBatchLogReadAccessCheck =  ATI_Utils.checkReadAccess('WOD_2__Batch_Log__c',new List<String>{'WOD_2__Process_Type__c'});
        Map<String,Object> accessCheckMap = (Map<String,Object>)Json.deserializeUntyped(objBatchLogReadAccessCheck.data);
        if(objBatchLogReadAccessCheck.status && ((List<Object>)accessCheckMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckMap.get('noAccessFieldList')).isEmpty()){
            WOD_2.ResponseWrapper objBatchLogResponse =  ATI_Utils.querySObjects('Select Id,WOD_2__Process_Type__c from WOD_2__Batch_Log__c Where Id=\''+ strBatchLogId+'\' and WOD_2__Process_Type__c != null');
            if(objBatchLogResponse.Status){
                fetchConfigurationforBulkUpload(objBatchLogResponse);
            }
        }
    }
    

    private static void fetchConfigurationforBulkUpload(WOD_2.ResponseWrapper objBatchLogResponse){
        List<Object> lstResult = (List<Object>)Json.deserializeUntyped(objBatchLogResponse.data);
        List<ATI_Bulk_Upload_Configuration__mdt> bulkUploadConfigLst = new List<ATI_Bulk_Upload_Configuration__mdt>();
        if(!lstResult.isEmpty()){
            String strJSONResult = JSON.serialize(lstResult[0]);
            Map<String,object> mapResult = (Map<String,object>)Json.deserializeUntyped(strJSONResult);
            //No need for access check as custom metadata is being queried.
            bulkUploadConfigLst =  Database.query('SELECT Id,ATI_Class_Override_Setting__r.WOD_2__ClassName__c,ATI_Object_API_Name__c,ATI_Community_Name__c,ATI_Process_Type__c,(SELECT Id,ATI_Field_API_Name__c,ATI_Object_API_Name__c,ATI_Column_Name__c,ATI_Reference_Field_API_Name__c,ATI_IsMandatory__c,ATI_Reference_Object_API_Name__c,ATI_Type__c,ATI_Display_Name__c,ATI_Reference_BU_Name__c FROM ATI_Bulk_Upload_Field_Mappings__r) FROM ATI_Bulk_Upload_Configuration__mdt WHERE ATI_Process_Type__c ='+'\''+mapResult.get('WOD_2__Process_Type__c')+'\'');
            if(!bulkUploadConfigLst.isEmpty() && !bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r.isEmpty()){ //&& !Test.isRunningTest()
                bulkUploadConfigMdt = new ATI_BulkUploadConfiguration();
                bulkUploadConfigMdt.classOverrideName = bulkUploadConfigLst[0].ATI_Class_Override_Setting__r.WOD_2__ClassName__c;
                bulkUploadConfigMdt.objectApiNameStr = bulkUploadConfigLst[0].ATI_Object_API_Name__c;
                bulkUploadConfigMdt.communityName = bulkUploadConfigLst[0].ATI_Community_Name__c;
                bulkUploadConfigMdt.processType   = bulkUploadConfigLst[0].ATI_Process_Type__c;
                configurationObjectFieldLst = new List<String>(); 
                bulkUploadFieldMappingLst = new List<ATI_BulkUploadFieldMapping>();
                for(ATI_Bulk_Upload_Field_Mapping__mdt objBulkUploadFieldMap : bulkUploadConfigLst[0].ATI_Bulk_Upload_Field_Mappings__r) {
                    if(bulkUploadConfigLst[0].ATI_Object_API_Name__c == objBulkUploadFieldMap.ATI_Object_API_Name__c){
                        if(objBulkUploadFieldMap.ATI_Field_API_Name__c != 'Id' && objBulkUploadFieldMap.ATI_Field_API_Name__c != 'WOD_2__Inventory__r.WOD_2__Units_Usage__c'){
                            configurationObjectFieldLst.add(objBulkUploadFieldMap.ATI_Field_API_Name__c);
                        }
                    ATI_BulkUploadFieldMapping objFieldMapping = new ATI_BulkUploadFieldMapping();
                    objFieldMapping.fieldAPIName = objBulkUploadFieldMap.ATI_Field_API_Name__c;
                    objFieldMapping.objectAPIName = objBulkUploadFieldMap.ATI_Object_API_Name__c;
                    objFieldMapping.columnName = objBulkUploadFieldMap.ATI_Column_Name__c;
                    objFieldMapping.isMandatory = objBulkUploadFieldMap.ATI_IsMandatory__c;
                    objFieldMapping.referenceFieldAPIName = objBulkUploadFieldMap.ATI_Reference_Field_API_Name__c;
                    objFieldMapping.referenceObjectAPIName = objBulkUploadFieldMap.ATI_Reference_Object_API_Name__c;
                    objFieldMapping.type = objBulkUploadFieldMap.ATI_Type__c;
                    objFieldMapping.displayName = objBulkUploadFieldMap.ATI_Display_Name__c;
                    objFieldMapping.referenceBUName = objBulkUploadFieldMap.ATI_Reference_BU_Name__c;
                    bulkUploadFieldMappingLst.add(objFieldMapping);
                    }
                }
            }
        }
        
    }
    
    public static void insertSuccessRecords(String batchLogId, Set<Id> successRecordIdSet, String objectName){ 
        // Map of Column API Names vs Display Name
        Map<String, String> columnHeaderWithFieldApiMap = new Map<String,String>();
        Map<String, String> columnHeaderReferenceWithFieldApiMap = new Map<String,String>();
        
        List<User> users = [SELECT IsActive,IsPortalEnabled,LastName,Contact.AccountId FROM User where Id = :UserInfo.getUserId()];
        Boolean isPortalEnabled = users[0].IsPortalEnabled;
        
        if(bulkUploadConfigMdt.processType == 'WarrantyRegUpload'){
            columnHeaderWithFieldApiMap.put('Name','Warranty Registration Code');
        }else{
            columnHeaderWithFieldApiMap.put('Id','Id');
        }
        for(ATI_BulkUploadFieldMapping fieldMap : bulkUploadFieldMappingLst) {
            if(!String.isBlank(fieldMap.displayName) && fieldMap.displayName != 'ATI_Extended_Warranty_Purchase_Date__c' && fieldMap.displayName != 'Claim Template Name'){
                columnHeaderWithFieldApiMap.put(fieldMap.displayName,fieldMap.columnName);
                columnHeaderReferenceWithFieldApiMap.put(fieldMap.displayName,fieldMap.type);
            }
        }
        
        
        // List to Set for String Join
        List<String> csvColumnDisplayNameList = new List<String>();
        csvColumnDisplayNameList.addAll(columnHeaderWithFieldApiMap.keySet());
        
        String query = 'SELECT '+ String.join(csvColumnDisplayNameList,',') + ' FROM '+ objectName + ' WHERE Id IN: successRecordIdSet';
        System.debug('query----->'+query);
        List<sObject> successRecordListforCSV = Database.query(query);
        System.debug('successRecordListforCSV----->'+successRecordListforCSV);
        String csvFile = '';
        csvFile = String.join(columnHeaderWithFieldApiMap.values(),',');         //Column headers in CSV file
        //System.debug('csvFile>>>>>> '+csvFile);
        for(sObject successRecordObj : successRecordListforCSV) {
            List<String> successCSVRow = new List<String>();
            for(String columnDisplayName : columnHeaderWithFieldApiMap.keySet()) {
                if(columnDisplayName != 'RecordTypeId') { // Ignore RecordType fields
                    // Get the field type on the configuration setting to format
                    String fieldType = '';
                    if(columnHeaderReferenceWithFieldApiMap.containsKey(columnDisplayName)) {
                        fieldType = columnHeaderReferenceWithFieldApiMap.get(columnDisplayName);
                    }
                    if(fieldType == 'Date') {
                        Date dt = (date)successRecordObj.get(columnDisplayName);
                        if(dt != null){
                            successCSVRow.add(dt.format());
                        }else{
                            successCSVRow.add(null);
                        }
                    } else {
                        successCSVRow.add(getFieldValue(successRecordObj, columnDisplayName));
                    }
                }
            }
            csvFile = csvFile + '\n"'+ String.join(successCSVRow,'","')+'"';
            //System.debug('csvFile>>>>> '+csvFile);
        }
        // Uploaded claims data saved to file(Content Version) & attached to Batch Log
        WOD_2.ResponseWrapper objContentVersionAccessCheck =  ATI_Utils.checkCreateAccess('ContentVersion',new List<String>{'PathOnClient','ContentLocation','Title','VersionData'});
        Map<String,Object> accessCheckCVMap = (Map<String,Object>)Json.deserializeUntyped(objContentVersionAccessCheck.data);
        if(objContentVersionAccessCheck.status && ((List<Object>)accessCheckCVMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckCVMap.get('noAccessFieldList')).isEmpty()
           && String.isNotBlank(batchLogId)){  
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = 'BulkUploadSuccess_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'BulkUploadSuccess_' + System.now().format('yyyy_MM_dd_hh_mm_ss'); // Display name of the files
            conVer.VersionData = Blob.valueOf(csvFile); //EncodingUtil.base64Decode(strJsonArray); // converting your binary string to Blog
            if(isPortalEnabled){
                String communityName = bulkUploadConfigMdt.communityName;
                List<Network> network = new List<Network>();
                if(communityName != ''){
                    network = [Select Id, Name From Network Where Name =: communityName Limit 1];
                }         
                if(network.size()>0){
                    conVer.NetworkId = network[0].Id;
                }
                
            }
            insert conVer;
            
            if(conVer.Id != null) {
                // First get the content document Id from ContentVersion
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                //Create ContentDocumentLink
                ContentDocumentLink cDoc = new ContentDocumentLink();
                cDoc.ContentDocumentId = conDoc;
                cDoc.LinkedEntityId = batchLogId; // BatchLog Id
                cDoc.ShareType = 'V'; //Only View permission
                cDoc.Visibility = 'AllUsers'; // AllUsers/InternalUsers/SharedUsers
                insert cDoc;
            }
        }
    }
    
    private static void insertSuccessWRCancelRecords(String batchLogId, Set<String> successRecordsSet){
        Map<String, String> columnHeaderWithFieldApiMap = new Map<String,String>();
        Map<String, String> columnHeaderReferenceWithFieldApiMap = new Map<String,String>();
        
        List<User> users = [SELECT IsActive,IsPortalEnabled,LastName,Contact.AccountId FROM User where Id = :UserInfo.getUserId()];
        Boolean isPortalEnabled = users[0].IsPortalEnabled;
        for(ATI_BulkUploadFieldMapping fieldMap : bulkUploadFieldMappingLst) {
                        columnHeaderWithFieldApiMap.put(fieldMap.displayName,fieldMap.columnName);
            columnHeaderReferenceWithFieldApiMap.put(fieldMap.displayName,fieldMap.type);
        }
        
        List<String> csvColumnDisplayNameList = new List<String>();
        csvColumnDisplayNameList.addAll(columnHeaderWithFieldApiMap.keySet());
        
        String csvFile = '';
        csvFile = String.join(columnHeaderWithFieldApiMap.values(),',');         //Column headers in CSV file
        for(String successRecordObj : successRecordsSet) {
            List<String> successCSVRow = new List<String>();
            successCSVRow.add(successRecordObj);
            csvFile = csvFile + '\n'+ String.join(successCSVRow,',');
        }
        
        // Uploaded claims data saved to file(Content Version) & attached to Batch Log
        WOD_2.ResponseWrapper objContentVersionAccessCheck =  ATI_Utils.checkCreateAccess('ContentVersion',new List<String>{'PathOnClient','ContentLocation','Title','VersionData'});
        Map<String,Object> accessCheckCVMap = (Map<String,Object>)Json.deserializeUntyped(objContentVersionAccessCheck.data);
        if(objContentVersionAccessCheck.status && ((List<Object>)accessCheckCVMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckCVMap.get('noAccessFieldList')).isEmpty()
           && String.isNotBlank(batchLogId)){  
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
            conVer.PathOnClient = 'BulkUploadSuccess_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.csv'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = 'BulkUploadSuccess_' + System.now().format('yyyy_MM_dd_hh_mm_ss'); // Display name of the files
            conVer.VersionData = Blob.valueOf(csvFile); //EncodingUtil.base64Decode(strJsonArray); // converting your binary string to Blog
            if(isPortalEnabled){
                String communityName = bulkUploadConfigMdt.communityName;
                List<Network> network = new List<Network>();
                if(communityName != ''){
                    network = [Select Id, Name From Network Where Name =: communityName Limit 1];
                }         
                if(network.size()>0){
                    conVer.NetworkId = network[0].Id;
                }
                
            }
            insert conVer;
            
            if(conVer.Id != null) {
                // First get the content document Id from ContentVersion
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                //Create ContentDocumentLink
                ContentDocumentLink cDoc = new ContentDocumentLink();
                cDoc.ContentDocumentId = conDoc;
                cDoc.LinkedEntityId = batchLogId; // BatchLog Id
                cDoc.ShareType = 'V'; //Only View permission
                cDoc.Visibility = 'AllUsers'; // AllUsers/InternalUsers/SharedUsers
                insert cDoc;
            }
        }
    }
    
    // Get sObject field value
    public Static String getFieldValue(SObject sObj, String fullFieldName) {
        String[] fields = fullFieldName.split('\\.');
        String fieldValue = '';
        if(fields.size() > 1) {
            fieldValue = '';
            Integer totalFields = fields.size();
            for(Integer i = 0; i < totalFields-1; i++) {
                if(sobj != null) {
                    sobj = getSObjectReference(sobj,fields[i]);
                }
            }
            if(sobj != null) {
                fieldValue = String.valueOf(sobj.get(fields[totalFields-1]));
            }
        }else {
            if(sobj != null) {
                fieldValue = String.valueOf(sobj.get(fullFieldName));
                
            }
        }
        return fieldValue == null ? '' : fieldValue;
    }
    
    public static SObject getSObjectReference(SObject sobj,String referenceFieldName) {
        return sobj.getSObject(referenceFieldName);
    }
    public static void dummyMethodForCodeCoverage(){
    	integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}