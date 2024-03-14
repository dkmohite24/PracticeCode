/* Name: ATI_LogService
Description : Service Class to Support Logging feature like Create Log record
Author : Tavant (TY)
History :
VERSION      AUTHOR          DATE                DETAIL                   UserStory/Req#
1.0 -       Tavant (TY)    24/11/2020          INITIAL DEVELOPMENT
*/
public with sharing class ATI_LogService {
    
    public static void createLogForAccess(String processName,String errortext){
        ATI_LogServiceWrapper logServiceWarraperObj = new ATI_LogServiceWrapper();
        logServiceWarraperObj.statusText = 'Failed';
        logServiceWarraperObj.errortext = errortext;
        logServiceWarraperObj.processName = processName;
        ATI_LogService.logRecord(logServiceWarraperObj);
    }
    //ALSN-199
    public static void createLogForCatchException(String processName,String errortext,String request){
        ATI_LogServiceWrapper logServiceWarraperObj = new ATI_LogServiceWrapper();
        logServiceWarraperObj.statusText = 'Failed';
        logServiceWarraperObj.errortext = errortext;
        logServiceWarraperObj.processName = processName;
        logServiceWarraperObj.inputRequestJSON = request;
        ATI_LogService.logRecord(logServiceWarraperObj);
    }
    //ALSN-199 end
    public static void createOrUpdateLogForAccess(String processName,String errortext,String batchLogId){
        ATI_LogServiceWrapper logServiceWarraperObj = new ATI_LogServiceWrapper();
        logServiceWarraperObj.statusText = 'Failed';
        logServiceWarraperObj.errortext = errortext;
        logServiceWarraperObj.processName = processName;
        logServiceWarraperObj.batchLogId = batchLogId;
        ATI_LogService.logRecord(logServiceWarraperObj);
    }
    
    public static WOD_2.ResponseWrapper logRecord(ATI_LogServiceWrapper logServiceWarraperObj) {
        WOD_2.ResponseWrapper responseWrapperobj = new WOD_2.ResponseWrapper('', false, '');
        try {
            List<String> fieldAPINamesList = new List<String>{ 'WOD_2__Process_Type__c', 'WOD_2__Status__c', 'WOD_2__Total_Record_Count__c','WOD_2__Success_Record_Count__c',
                'WOD_2__Failure_Record_Count__c','ATI_Error_Message__c','ATI_Failed_Records__c','ATI_Request_JSON__c','ATI_Response_JSON__c','ATI_Unique_Identifier__c'};
                    if(checkCreateAccess('WOD_2__Batch_Log__c', fieldAPINamesList)) {
                        WOD_2__Batch_Log__c logObj = new WOD_2__Batch_Log__c();
                        logObj.Name = logServiceWarraperObj.processName+'_'+System.now().format('yyyy_MM_dd_hh_mm_ss');
                        logObj.WOD_2__Process_Type__c = logServiceWarraperObj.processName;
                        logObj.WOD_2__Status__c = logServiceWarraperObj.statusText;
                        logObj.ATI_Error_Message__c = logServiceWarraperObj.errortext;
                        if(logServiceWarraperObj.identifier != null && logServiceWarraperObj.identifier.length() > 255){
                            List<String> listOfData = new List<String>();
                            List<String> identifierDataLst = (List<String>)System.JSON.deserialize(logServiceWarraperObj.identifier,List<String>.class);
                            for(String st : identifierDataLst){
                                if((JSON.serialize(listOfData)+st).length() < 255){
                                    listOfData.add(st);
                                }
                            }
                            logServiceWarraperObj.identifier = JSON.serialize(listOfData);
                        }
                        logObj.ATI_Failed_Records__c = logServiceWarraperObj.identifier;
                        logObj.ATI_Unique_Identifier__c	= logServiceWarraperObj.primaryKey;
                        logObj.WOD_2__Success_Record_Count__c = logServiceWarraperObj.successRecordCount;
                        logObj.WOD_2__Total_Record_Count__c   = logServiceWarraperObj.totalRecordCount;
                        logObj.WOD_2__Failure_Record_Count__c = logServiceWarraperObj.failureRecordCount;
                        //ALSN-151 Created 2 fields to store value if exceeds the length
                        //if characters length exceeds both fields than we will create a text file.
                        if(logServiceWarraperObj.inputRequestJSON != null){
                            if(logServiceWarraperObj.inputRequestJSON.length() <= 131072){
                                logObj.ATI_Request_JSON__c = logServiceWarraperObj.inputRequestJSON;
                            }else if(logServiceWarraperObj.inputRequestJSON.length() <= 262144){
                                logObj.ATI_Request_JSON__c = logServiceWarraperObj.inputRequestJSON.substring(0,131072);
                                logObj.ATI_Request_JSON_2__c = logServiceWarraperObj.inputRequestJSON.substring(131072);
                            }else{
                                logObj.ATI_Request_JSON__c = logServiceWarraperObj.inputRequestJSON.substring(0,131072);
                                logObj.ATI_Request_JSON_2__c = logServiceWarraperObj.inputRequestJSON.substring(131072,262144);
                            }
                        }
                        logObj.ATI_Response_JSON__c = logServiceWarraperObj.outputResponseJSON;
                        if(logServiceWarraperObj.batchLogId != null){
                            logObj.Id = logServiceWarraperObj.batchLogId;
                        }
                        Database.upsert(logObj);
                        //ALSN-151 Create a txt document if length exceeds 262144 characters
                        if(logObj.id != null && logServiceWarraperObj.processName == 'Accounts Receivable' && logServiceWarraperObj.inputRequestJSON.length() > 262144){
                            ATI_Accounts_ReceivableBatch.uploadChunks(logServiceWarraperObj.inputRequestJSON,logObj.id);
                        }
                        responseWrapperobj.data = JSON.serialize(logObj);
                        responseWrapperobj.status = true;
                    } else {
                        responseWrapperobj.errormessage = System.Label.ATI_Log_Insufficient_access;
                        responseWrapperobj.status = true;
                    }
        } catch (exception e) {
            responseWrapperObj.errormessage = e.getMessage();
            System.debug(' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return responseWrapperobj;
    }
    
    
    public static Boolean checkCreateAccess(String objectName, List<String> fieldAPINamesList) {
        ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObj = ATI_Utils.fetchCreateAccess(objectName,fieldAPINamesList);
        if(noAccessObjectFieldWrapperObj.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObj.noAccessFieldList.size() == 0) {
            return true;
        } else {
            System.debug('Insufficient BatchLog Create Access>> '+noAccessObjectFieldWrapperObj);
            return false;
        }
    }
}