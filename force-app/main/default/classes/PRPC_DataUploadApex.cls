/*
* Update : CHG44065 -Update the profile check for PRP Admin & CSM User to custom permissions.
* Update By : 08/23/2023, Susovan Mondal & Chinmaya Das
*/

public class PRPC_DataUploadApex {
    public class findMetadataDetailsWrapper {
        public String status;
        public String msg;
        public String fieldApiDetails;
        public String fieldlabelDetails;
        public String fielddetails;
        public String attachmentId;
        //public String fileProcessId;
    }
    public class fieldDetailWrapper{
        public String apiName;
        public String fieldType;
        public string fieldLabel;
    }  
    public class returnToJS{
        public String recordid;
        public String StatusMessage;
    }
    public class setFileDetail{
        public String status;
        public String attId;
        public String devlopName;
    }
    //public returnToJS responseWrapper;
    @AuraEnabled
    public static String findMetadataDetails(String developerName) {
        System.debug('Developer Name'+developerName);
        
        Data_Upload_Config__mdt dataUploadConfig = new Data_Upload_Config__mdt();
        findMetadataDetailsWrapper responseBody = new findMetadataDetailsWrapper();   
        List<fieldDetailWrapper> fieldwrapperInstance=new List<fieldDetailWrapper>();
        try {
            dataUploadConfig = [SELECT Id, DeveloperName, Label, Download_Label__c, Upload_Label__c, FieldTemplate__c, Stagging_Object__c FROM Data_Upload_Config__mdt WHERE DeveloperName =: developerName LIMIT 1];
        }
        catch(Exception ex) {
            
        }
        System.debug('Metadata Records'+dataUploadConfig);
        //Available file ID
        List<String> metadataFieldList=dataUploadConfig.FieldTemplate__c.split(',');
        File_Processing__c att=new File_Processing__c();
        String attachmentId='test1';
        String processfileid='test2';
        try {
            att=[Select id,createddate,(Select id,createddate from Attachments order by createddate DESC limit 1 ) from File_Processing__c where File_Type__c=:dataUploadConfig.label order by createddate DESC limit 1];              
            responseBody.attachmentId=att.Attachments[0].Id; 
        }
        catch(Exception ex) {
            System.debug('test'+ex.getMessage());
            responseBody.attachmentId='Failed';
        }        
        List<String> apinameList=new List<String>();
        List<String> labelList=new List<String>();
        Map<String,String> fielddetailsMap=New Map<String,String>();        
        String type= dataUploadConfig.Stagging_Object__c;      
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName:metadataFieldList) {  
            //It provides to get the object fields label.
            fieldDetailWrapper wrapperinstance=new fieldDetailWrapper();
            apinameList.add(String.valueof(fieldName));
            if(fieldMap.containskey(fieldName)){
                labelList.add(String.valueof(fieldMap.get(fieldName).getDescribe().getLabel()));
            }
            wrapperinstance.apiName=String.valueof(fieldName);
            wrapperinstance.fieldType=String.valueof(fieldMap.get(fieldName).getDescribe().getType());
            wrapperinstance.fieldLabel=fieldMap.get(fieldName).getDescribe().getLabel();
            fieldwrapperInstance.add(wrapperinstance);
        }
        System.debug('Field'+fieldwrapperInstance);
        responseBody.status = 'Success';
        responseBody.msg = JSON.serialize(dataUploadConfig);
        responseBody.fieldApiDetails=JSON.serialize(apinameList);
        responseBody.fieldlabelDetails=JSON.serialize(labelList);
        responseBody.fielddetails=JSON.serialize(fieldwrapperInstance);
        
        return JSON.serialize(responseBody);
    }
    @AuraEnabled
    public static void insertRecords(String recordData, String objApiName, String fieldtypes, String addOnData, String fileName){
        //String listType = 'List<' + objApiName + '>';
        //List<List<object>> objectlist=new  List<List<object>>();
        System.debug('record data'+recordData);
        System.debug('record data 1'+objApiName);
        System.debug('record data 2'+fieldtypes);
        System.debug('record data 3'+addOnData);
        System.debug('record data 4'+fileName);
        
        PRPC_DataUploadApex.insertRecordsInFuture(recordData,objApiName,fieldtypes,addOnData,fileName);
        //return responseWrapper;
    }
    @future
    public static void insertRecordsInFuture(String recordData, String objApiName, String fieldtypes, String addOnData, String fileName ){
        system.debug('recordData: '+recordData);
        system.debug('addOnData: '+addOnData);
        returnToJS responseWrapper= new returnToJS();
        File_Processing__c filerecord=new File_Processing__c();
        PRPC_recordManupulcation.wrapperclass recordwrapperInstance=new PRPC_recordManupulcation.wrapperclass();
        String csvdata='';
        String record='';
        List<String> csvRowValues = new List<String>();
        List<String> FormatedcsvRowValues = new List<String>();
        String csvHeaders='';
        string csvHeaders2='';
        Map<String, Object> recMap=New Map<String,Object>();
        Map<String, Object> dataMap=New Map<String,Object>();
        List<Object> adddata=new List<Object>();
        List<Object> castRecords = (List<Object>)JSON.deserializeUntyped(recordData);
        system.debug('castRecords: '+castRecords);
        List<fieldDetailWrapper> fieldwrapperInstance=(List<fieldDetailWrapper>)JSON.deserialize(fieldtypes,List<fieldDetailWrapper>.class);
        Map<String,String> fieldmap=new Map<String,String>();
        Map<String,String> fieldmapLabel=new Map<String,String>();
        List<String> recordvalues=new List<String>();
        List<sObject> allRecordList=new List<sObject>();
        Data_Upload_Config__mdt dataUploadConfig = new Data_Upload_Config__mdt();
        try {
            dataUploadConfig = [SELECT Id,Date_Format__c,Account_LookUp__c,SAP_ID_Field__c, DeveloperName, Label, Download_Label__c, Upload_Label__c, FieldTemplate__c, Stagging_Object__c FROM Data_Upload_Config__mdt WHERE Stagging_Object__c =: objApiName LIMIT 1];
        }
        catch(Exception ex) {
            System.debug('error');
        }
        system.debug('dataUploadConfig: '+dataUploadConfig);
        /* If(addOnData!=''){
adddata = (List<Object>)JSON.deserializeUntyped(addOnData); 
}*/       system.debug('castRecords: '+castRecords);
        recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(castRecords[0]));
        system.debug('recMap: '+recMap);
        
        for(fieldDetailWrapper wrapperInstance:fieldwrapperInstance){
            fieldmap.put(wrapperInstance.apiName,wrapperInstance.fieldType);
            fieldmapLabel.put(wrapperInstance.apiName,wrapperInstance.fieldLabel);
        }
        
        recordwrapperInstance=PRPC_recordManupulcation.createInsertList(castRecords,objApiName,fieldmap,addOnData);
        System.debug('Returned'+recordwrapperInstance);
        allRecordList=recordwrapperInstance.recordstoInsert;
        recordvalues=recordwrapperInstance.csvData;
        
        
        //Rollback save point
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] saveresult = Database.insert(allRecordList,false); 
        /*if(dataUploadConfig.ObjectName__c!='TAT_Turnt_staging__c'){
            
            For( integer i=0;i<saveresult.size();i++){
                if(!saveresult[i].isSuccess()){
                    for(Database.Error err : saveresult[i].getErrors()) {
                        csvdata=csvdata.trim()+recordvalues[i]+',' +'Error: '+ string.valueof(err.getMessage());
                        csvRowValues.add(csvdata);
                        csvdata='';
                        
                    }  
                } 
                else if(allRecordList[i].get(dataUploadConfig.Account_LookUp__c)==''){
                    csvdata=csvdata.trim()+recordvalues[i]+',' +'Error: '+ 'Distribuotr is not found';
                    csvRowValues.add(csvdata);
                    csvdata='';
                }
                else{
                    csvdata=csvdata.trim()+recordvalues[i]+',' + 'success'; 
                    csvRowValues.add(csvdata);
                    csvdata='';
                }
            }
            
        }*/
            //  else{
        system.debug('saveresult: '+saveresult.size());
        For( integer i=0;i<saveresult.size();i++){
            if(!saveresult[i].isSuccess()){
                for(Database.Error err : saveresult[i].getErrors()) {
                    csvdata=csvdata.trim()+recordvalues[i]+',' +'Error: '+ string.valueof(err.getMessage()) +','+ userInfo.getName() +','+ System.now();
                    csvRowValues.add(csvdata);
                    csvdata='';
                    
                }  
            } 
            else{
                csvdata=csvdata.trim()+recordvalues[i]+',' + 'success'+','+ userInfo.getName() +','+ System.now(); 
                csvRowValues.add(csvdata);
                csvdata='';
            }
        }
        //}
        If(csvRowValues.size()>0){
            for(String keyInstance:recMap.keyset()){
                if(csvHeaders==''){
                    csvHeaders=fieldmapLabel.get(keyInstance);
                    system.debug('csvHeaders188: '+csvHeaders);
                }else{
                    csvHeaders=csvHeaders+','+fieldmapLabel.get(keyInstance);
                    system.debug('csvHeaders192: '+csvHeaders);
                }
            }
            //new changes
            for(Integer i = csvHeaders.split(',').size() - 1; i >= 0; i--){
                csvHeaders2+=csvHeaders.split(',')[i]+',';
            }
            csvHeaders2 = csvHeaders2.Substring(0,csvHeaders2.length()-1);
            csvHeaders2=csvHeaders2+','+'Upload Status'+','+'Uploaded By'+','+'Timestamp';
            //csvHeaders = csvHeaders.reverse();
            if(String.join(csvRowValues,'\n').contains('Error')){
                for(String str:csvRowValues){
                    if(str.substring(str.length()-7,str.length())=='success'){
                        str=str.replace(str.substring(str.length()-7,str.length()), 'Passed');
                        FormatedcsvRowValues.add(str.replace(str.substring(str.length()-7,str.length()), ',Passed'));
                    }
                    else{
                        FormatedcsvRowValues.add(str);  
                    }
                }
            }
            else{
                FormatedcsvRowValues=csvRowValues;
            }
            String csvFile = csvHeaders2.trim()+'\n' + String.join(FormatedcsvRowValues,'\n');
            //system.debug('');
            responseWrapper.StatusMessage='success';
            if(csvFile.contains('Error')){
                responseWrapper.StatusMessage='errorLog';
                Database.rollback(sp);
            }
            if(addOnData!='Test'){
                filerecord.Customer__c=addOnData;
            }
            filerecord.File_Type__c=dataUploadConfig.label;
            filerecord.Name=fileName;
            filerecord.Uploaded_By__c = UserInfo.getName();
            try {
                insert filerecord;
            } catch(DmlException e) {
            }
            Attachment attachmentCsv = new Attachment();
            attachmentCsv.parentId = filerecord.id;    
            attachmentCsv.name =  'Status'+'.csv';    
            attachmentCsv.body = blob.valueof(csvFile.trim());      
            try {
                insert attachmentCsv;
                filerecord.File_Id__c=attachmentCsv.id;
                update filerecord;
            } catch(DmlException e) {
                responseWrapper.StatusMessage='Failed';
                //return 'Failed';
                // return JSON.serialize(responseWrapper);
                
            }
            responseWrapper.recordid=attachmentCsv.id;
            //return JSON.serialize(responseWrapper);            
        }
        //return JSON.serialize(responseWrapper);
    }
    @AuraEnabled
    public static string GetFileProcessId(string devName,string accId){
        system.debug('devName: '+devName);
        system.debug('accId: '+accId);
        setFileDetail wrapperLog = new setFileDetail();
        //wrapperLog.devlopName=devName;
        Data_Upload_Config__mdt dataUploadConfig = new Data_Upload_Config__mdt();
        string profileName =  [select id,name from profile where id=:userinfo.getProfileId()].name;
        //CHG44065 Removing the PRP_Profile__mdt metadata & check the custom permission.
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
                profileName=pmap.get(s);
            }
        }*/
            string att;
        //File_Processing__c att=new File_Processing__c();
        try {
            dataUploadConfig = [SELECT Id, DeveloperName, Label, Download_Label__c, Upload_Label__c, FieldTemplate__c, Stagging_Object__c FROM Data_Upload_Config__mdt WHERE DeveloperName =: devName LIMIT 1];
        }
        catch(Exception ex) {
            
        }
        try {
            if(isPRPAdminPermission!=true && profileName != 'System Administrator'){
                if(devName == 'AdminTAT' || devName == 'AdminCustomer2' || devName == 'AdminCustomer'){
                    system.debug('dataUploadConfig:259 '+dataUploadConfig.label);
                    att=[Select id,createddate,File_Id__c from File_Processing__c where File_Type__c=:dataUploadConfig.label and Customer__c=:accId and createdById=:userinfo.getUserId() order by createddate DESC limit 1].File_Id__c;              
                    //responseBody.attachmentId=att.Attachments[0].Id;
                    //wrapperLog.attId=att;
                }
                else{
                    system.debug('dataUploadConfig:265 '+dataUploadConfig.label);
                    att=[Select id,createddate,File_Id__c from File_Processing__c where File_Type__c=:dataUploadConfig.label order by createddate DESC limit 1].File_Id__c;
                    
                    //wrapperLog.attId=att;
                } 
            }else if(isPRPAdminPermission==true || profileName == 'System Administrator'){
                att=[Select id,createddate,File_Id__c from File_Processing__c where File_Type__c=:dataUploadConfig.label and createdById=:userinfo.getUserId() order by createddate DESC limit 1].File_Id__c;
            }
        }
        catch(Exception ex) {
            System.debug('test'+ex.getMessage());
            System.debug('test2'+ex.getLineNumber());
            System.debug('test3'+userinfo.getName());
        }
        system.debug('att: '+att);
        return att;
    }
    @AuraEnabled
    public static string GetFileIdForAdmin(string devName,string accId){
        Data_Upload_Config__mdt dataUploadConfig = new Data_Upload_Config__mdt();
        string att;
        try {
            dataUploadConfig = [SELECT Id, DeveloperName, Label, Download_Label__c, Upload_Label__c, FieldTemplate__c, Stagging_Object__c FROM Data_Upload_Config__mdt WHERE DeveloperName =: devName LIMIT 1];
        }
        catch(Exception ex) {
            
        }
        string profileName =  [select id,name from profile where id=:userinfo.getProfileId()].name;
        //CHG44065 Check the Custom permission & remove the metadata
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
Map<String,String> pmap = new Map<String,String>();
for(PRP_Profile__mdt mdt:plist){
pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
}
for(String s:pmap.keyset()){
if(s==profileName){
profileName=pmap.get(s);
}
}*/
        try{
            if( isPRPAdminPermission == true || profileName == 'System Administrator'){
                att=[Select id,createddate,File_Id__c from File_Processing__c where File_Type__c=:dataUploadConfig.label and Customer__c=:accId order by createddate DESC limit 1].File_Id__c; 
            }
            return att;
        }
        catch(Exception e){
            return 'error';
        }
    }
}