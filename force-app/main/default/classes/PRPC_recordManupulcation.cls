public class PRPC_recordManupulcation {
    public static wrapperclass createInsertList(List<object> recordList,String objectApiName, Map<String,String> fieldtypes, String distributorId){
        PRPC_recordManupulcation ob = new PRPC_recordManupulcation();
        Set<String> sapId = new Set<String>();
        Map<String, String> lookupMap = new Map<String, String>();
        wrapperclass wrapperInstance=new wrapperclass();
        Map<String, Object> recMap=New Map<String,Object>();
        String record='';
        String record2='';
        List<String> recordvalues=new List<String>();
        List<sObject> allRecordList=new List<sObject>();
        Data_Upload_Config__mdt dataUploadConfig = new Data_Upload_Config__mdt();
        try {
            dataUploadConfig = [SELECT Id,Date_Format__c,Account_LookUp__c,SAP_ID_Field__c, DeveloperName, Label, Download_Label__c, Upload_Label__c, FieldTemplate__c, Stagging_Object__c FROM Data_Upload_Config__mdt WHERE Stagging_Object__c =: objectApiName LIMIT 1];
        }
        catch(Exception ex) {
            System.debug('error');
        }
        System.debug('ObjectApiName'+objectApiName);
        System.debug('recordList'+recordList);
        for(object obj : recordList) {
            sObject rec = Schema.getGlobalDescribe().get(objectApiName) != null ? Schema.getGlobalDescribe().get(objectApiName).newSObject() : null;
            recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            for(String keyInstance:recMap.keyset()){
                if(keyInstance != 'attributes' && keyInstance !='Id'){
                    if(record=='')
                        record=string.valueof(recMap.get(keyInstance));
                    else
                        record =record+','+string.valueof(recMap.get(keyInstance));
                    /*
                    if(keyInstance==dataUploadConfig.SAP_ID_Field__c){
                        System.debug('test'+keyinstance);
                        if(dataUploadConfig.ObjectName__c!='TAT_Turnt_staging__c'&& dataUploadConfig.ObjectName__c!='End_Customer__c'){
                            if(dataUploadConfig.ObjectName__c=='CE_Data__c'){
                                String SAPIDValue=string.valueof(recMap.get(keyInstance)).replace('-','');
                                  if(SAPIDValue.length()==4){
                                    SAPIDValue='0'+SAPIDValue;
                                }
                                sapId.add(string.valueOf(SAPIDValue.substring(SAPIDValue.length()-5,SAPIDValue.length())));
                            }
                            else{
                                String SAPIDValue=string.valueof(recMap.get(keyInstance)).replace('-','');
                                SAPIDValue=SAPIDValue.remove('-');
                                if(SAPIDValue.length()==9){
                                    SAPIDValue='0'+SAPIDValue;
                                }
                                sapId.add(string.valueof(SAPIDValue));
                            }
                        }
                    }
                    */
                    if(fieldtypes.get(keyInstance)=='DOUBLE'){
                        if(String.isNotBlank(String.valueof(recMap.get(keyInstance)))){
                            System.debug('1'+keyInstance);
                            rec.put(keyInstance, double.valueof(recMap.get(keyInstance))); 
                        }
                        
                    }
                    else if(fieldtypes.get(keyInstance)=='CURRENCY'){
                        rec.put(keyInstance, double.valueof(recMap.get(keyInstance)));
                                                    System.debug('2'+keyInstance);
                    }
                    else if(fieldtypes.get(keyInstance)=='DATE'){
                        if(!String.isBlank(string.valueof(recMap.get(keyInstance)))){
                            if(dataUploadConfig.Date_Format__c=='MM/DD/YYYY'){
                                System.Debug('Date in String'+string.valueof(recMap.get(keyInstance)));
                                                            System.debug('3'+keyInstance);
                                rec.put(keyInstance, date.parse(string.valueof(recMap.get(keyInstance)))); 
                                System.Debug('Date in String'+date.parse(string.valueof(recMap.get(keyInstance))));
                            }   
                        }
                    }
                    else if(fieldtypes.get(keyInstance)=='REFERENCE'){
                        //rec.put(keyInstance, Date.valueof(recMap.get(keyInstance))); 
                    }
                    else if(fieldtypes.get(keyInstance)=='BOOLEAN'){
                        rec.put(keyInstance, Boolean.valueof(recMap.get(keyInstance))); 
                    }
                    else if(fieldtypes.get(keyInstance)=='DATETIME'){
                        rec.put(keyInstance, DateTime.valueof(recMap.get(keyInstance))); 
                    }
                    else if(keyInstance == 'Phone_Number__c' && objectApiName =='Account'){                        
                        rec.put('Phone',string.valueof(recMap.get(keyInstance)));
                    }else if(fieldtypes.get(keyInstance)=='EMAIL'){
                        rec.put(keyInstance,string.valueof(recMap.get(keyInstance)));
                    }
                    else{
                        if(keyInstance==dataUploadConfig.SAP_ID_Field__c){	
                                                    System.debug('test 1'+keyinstance);
                            String SAPIDValue=string.valueof(recMap.get(keyInstance));
                            if(SAPIDValue.length()==9){
                                SAPIDValue='0'+SAPIDValue;
                            }
                            rec.put(keyInstance, SAPIDValue); 
                        }
                        else{
                                                                                System.debug('test 91'+keyinstance);
                            if(recMap.containsKey(keyInstance)) rec.put(keyInstance, recMap.get(keyInstance));
                        }
                    }
                }
            }  
            
            for(Integer i = record.split(',').size() - 1; i >= 0; i--){
               record2+= record.split(',')[i]+',';
            }
            record2 = record2.Substring(0,record2.length()-1);
            recordvalues.add(record2);
            record2 = '';
            record='';
            allRecordList.add(rec);		
            
        }
        /*
        if(dataUploadConfig.ObjectName__c!='TAT_Turnt_staging__c'&& dataUploadConfig.ObjectName__c!='End_Customer__c'){
            System.debug('test 91'+dataUploadConfig.ObjectName__c);
            lookupMap = ob.lookUpConvert(sapId);
        }
        if(dataUploadConfig.ObjectName__c!='TAT_Turnt_staging__c'){
            System.debug('IN 110');
        for(integer i=0;i<recordList.size();i++){
            recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(recordList[i]));
            for(String keyInstance:recMap.keyset()){               
                if(keyInstance==dataUploadConfig.SAP_ID_Field__c){
                    if(dataUploadConfig.ObjectName__c=='End_Customer__c'){
                        System.debug('Objects 1');
                        allRecordList[i].put(dataUploadConfig.Account_LookUp__c,distributorId);
                    }
                    else {
                        if(dataUploadConfig.ObjectName__c=='CE_Data__c'){
                                                    string sapValue=string.valueof(recMap.get(keyInstance));
                                     if(sapValue.length()==4){
                                    sapValue='0'+sapValue;
                                }
                            if(lookupMap.keyset().contains(sapValue.substring(sapValue.length()-5,sapValue.length()))){
                                allRecordList[i].put(dataUploadConfig.Account_LookUp__c, string.valueOf(lookupMap.get(sapValue.substring(sapValue.length()-5,sapValue.length()))));
                            }
                            else{
                                allRecordList[i].put(dataUploadConfig.Account_LookUp__c,'');   
                            }
                        }
                        else{
                            String SAPIDValue=string.valueof(recMap.get(keyInstance)).replace('-','');
                            SAPIDValue=SAPIDValue.remove('-');
                            if(SAPIDValue.length()==9){
                                SAPIDValue='0'+SAPIDValue;
                            }
                            if(lookupMap.keyset().contains(SAPIDValue)){
                                allRecordList[i].put(dataUploadConfig.Account_LookUp__c, string.valueOf(lookupMap.get(SAPIDValue)));
                            }
                            else{
                                allRecordList[i].put(dataUploadConfig.Account_LookUp__c, ''); 
                            }
                        }
                    }
                }
                
            }
        }
        }*/
        wrapperInstance.csvData=recordvalues;
        wrapperInstance.recordstoInsert=allRecordList;
        return wrapperInstance;
    }
    
    public MAP<String, String> lookUpConvert(Set<String> sapId){
        List<Account> accounts = New List<Account>();
        try {
            accounts =[SELECT ID, SAP_ID__c FROM Account WHERE SAP_ID__c in :sapId];
        }
        catch(Exception ex) {
            System.debug('test'+ex.getMessage());
        }
        MAP<String, String> accountMap = new MAP<String, String>();
        for(Account a: accounts){
            accountMap.put(a.SAP_ID__c, a.ID); 
        }
        return accountMap;
    }
    public class wrapperclass{
        public list<String> csvData;
        public list<Sobject> recordstoInsert;
    }
}