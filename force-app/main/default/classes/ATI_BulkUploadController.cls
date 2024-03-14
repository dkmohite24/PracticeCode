/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
This class is used for BulkUpload component to process uploaded file
* -------------------------------------------------------------------------------------------------
* @author         (Punam Chakraborty)
* @version        1.0
* @created        18-DEC-2020
* @modified		  (TY) - (22-DEC-2020) - Development Continued...
* -------------------------------------------------------------------------------------------------
* @changes  
* -------------------------------------------------------------------------------------------------
*/
public with sharing class ATI_BulkUploadController {
    
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
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper querySObjects(String queryString){
        WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.querySObjects(queryString);
        return responseWrapperObj;
    }
    
    @AuraEnabled
    public static WOD_2.ResponseWrapper checkCreateAccess(String objectName, List<String> objectFieldsAPINames){
        WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.checkCreateAccess(objectName, objectFieldsAPINames);
        return responseWrapperObj;
    }
    
    //create batch log record
    @AuraEnabled
    public static WOD_2.ResponseWrapper createBatchLog(String strRelatedRecordId,String strConfigurationContent,String strProcessType,String fileName){
        WOD_2.ResponseWrapper responseWrapperObj = ATI_Utils.insertSObjects(new List<WOD_2__Batch_Log__c >{new WOD_2__Batch_Log__c(Name=fileName,ATI_Related_Record_Id__c = strRelatedRecordId,ATI_Status__c='Queued',
                                                                                                                                    ATI_Configuration_Content__c=strConfigurationContent,WOD_2__Process_Type__c=strProcessType)},true);
        return responseWrapperObj;
        
    }
    
    
    //Used to fetch bulk upload configrations to get chunck file size
    @AuraEnabled
    public static WOD_2.ResponseWrapper fetchBulkUploadConfiguration(String strProcessType){
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper();
        //This is used to fetch metadata record so no need to check accessability
        String queryStr = 'SELECT Id,ATI_Chuck_File_Size__c,ATI_Maximum_Rows_Per_Batch__c FROM ATI_Bulk_Upload_Configuration__mdt WHERE ATI_Process_Type__c =\''+String.escapeSingleQuotes(strProcessType)  +'\'';
        //query string is alredy escaped single quote
        System.debug('#queryStr='+queryStr);
        List<ATI_Bulk_Upload_Configuration__mdt> lstBulkUploadConfig = Database.query(queryStr);
        
        //system.debug('@@lstBulkUploadConfig='+lstBulkUploadConfig);
        if(lstBulkUploadConfig.isEmpty()){
            responseWrapperObj.data = '';
            responseWrapperObj.status = false;
            responseWrapperObj.errormessage =  'No Configuration found';
        }
        else{
            responseWrapperObj.data = Json.serialize(lstBulkUploadConfig[0]);//String.valueOf(lstBulkUploadConfig[0].Chuck_File_Size__c);
            responseWrapperObj.status = true;
            responseWrapperObj.errormessage = '';
        }
        return responseWrapperObj;
        
    }
    
    //inserting uploaded csv in chunks under batch log
    @AuraEnabled
    public static WOD_2.ResponseWrapper uploadChunks(String strJsonArray,String strBatchlogId) {
        //system.debug('strJsonArray='+strJsonArray);
        system.debug('strBatchlogId='+strBatchlogId);
        
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper();
        try{
            // Uploaded claims data saved to file(Content Version) & attached to Batch Log 
            WOD_2.ResponseWrapper objContentVersionAccessCheck =  ATI_Utils.checkCreateAccess('ContentVersion',new List<String>{'PathOnClient','ContentLocation','Title','VersionData'});
            Map<String,Object> accessCheckCVMap = (Map<String,Object>)Json.deserializeUntyped(objContentVersionAccessCheck.data);
            if(objContentVersionAccessCheck.status && ((List<Object>)accessCheckCVMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckCVMap.get('noAccessFieldList')).isEmpty()
               && String.isNotBlank(strJsonArray) && String.isNotBlank(strBatchLogId)){
                // String yourFiles = 'Lets assume this is your binary string of the files';
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                conVer.PathOnClient = 'BulkUploadJSON' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = 'BulkUploadJSON' + System.now().format('yyyy_MM_dd_hh_mm_ss'); // Display name of the files
                //conver.Description = 'Uploaded Claims in JSON format';
                conVer.VersionData = Blob.valueOf(strJsonArray); //EncodingUtil.base64Decode(strJsonArray); // converting your binary string to Blog
                insert conVer;
                system.debug('conVer='+conVer);
                
                if(conVer.Id != null){
                    // First get the content document Id from ContentVersion
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    
                    //Create ContentDocumentLink
                    ContentDocumentLink cDoc = new ContentDocumentLink();
                    cDoc.ContentDocumentId = conDoc;
                    cDoc.LinkedEntityId = strBatchlogId; // BatchLog Id
                    cDoc.ShareType = 'V'; //Only View permission 
                    cDoc.Visibility = 'AllUsers'; // AllUsers/InternalUsers/SharedUsers
                    insert cDoc;
                    
                    responseWrapperObj.data = '';
                    responseWrapperObj.status = true;
                    responseWrapperObj.errormessage = '';
                }
                
            }
        }
        catch(Exception exp){
            responseWrapperObj.data = '';
            responseWrapperObj.status = false;
            responseWrapperObj.errormessage = exp.getMessage();
        }
        return responseWrapperObj;
    }
    
    //call batch to process uploaded file using attachments in batchlog
    @AuraEnabled
    public static WOD_2.ResponseWrapper callBatchJobToInsert(String strBatchLogId){
        ATI_BulkUploadBatch objbulkUploadBatch = new ATI_BulkUploadBatch(strBatchLogId);
        Database.executeBatch(objbulkUploadBatch,1);
        WOD_2.ResponseWrapper responseWrapperObj = new WOD_2.ResponseWrapper();
        responseWrapperObj.data = '';
        responseWrapperObj.status = true;
        responseWrapperObj.errormessage ='';
        return responseWrapperObj;
    }
    
    /*
	Method Name :   getProcesTypeList
	Params      :   Method to fetch ProcesType values from custom metadata
	*/	
    @AuraEnabled
    public static WOD_2.ResponseWrapper getProcesTypeList(){
        List<ATI_Bulk_Upload_Process_Type_Config__mdt> processTypeConfigList = new List<ATI_Bulk_Upload_Process_Type_Config__mdt>();
        processTypeConfigList = [SELECT Id, MasterLabel, ATI_Value__c FROM ATI_Bulk_Upload_Process_Type_Config__mdt WHERE ATI_Is_Active__c=true];
        return new WOD_2.ResponseWrapper(JSON.serialize(processTypeConfigList),true,'');
    }
}