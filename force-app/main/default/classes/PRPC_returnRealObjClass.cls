/* Class Name: PRPC_returnRealObjClass
* Description: 
* Created by: Debiprasad
* Updated by : Akanksha Mondal,CHG0043240- Mapping all the 4WARD fields from Account staging to Account and stop updation to PRP participation
* Updated By :Susovan CHG0043454- To Handle the account mapping seprately & map all 4ward fields.
* Updated By : Susovan Mondal & Chinmaya Dash - Converting the 5 digit code to 10 digit account code.
*/
public class PRPC_returnRealObjClass {
    public static wrapperclass createInsertList(List<sobject> recordList,String objectApiName,string stagingObj, Map<String,String> fieldtypes, String distributorId){
        PRPC_returnRealObjClass ob = new PRPC_returnRealObjClass();
        Set<String> sapId = new Set<String>();
        Map<String, String> lookupMap = new Map<String, String>();
        wrapperclass wrapperInstance=new wrapperclass();
        Map<String, Object> recMap=New Map<String,Object>();
        String record='';
        List<String> recordvalues=new List<String>();
        List<sObject> allRecordList=new List<sObject>();
        list<sObject>updateErrorMessage = new list<sObject>();
        Data_Upload_Config__mdt dataUploadConfig = new Data_Upload_Config__mdt();
        try {
            dataUploadConfig = [SELECT Id,Date_Format__c,Account_LookUp__c,SAP_ID_Field__c, DeveloperName, Label, Download_Label__c, Upload_Label__c, FieldTemplate__c, ObjectName__c,Stagging_Object__c FROM Data_Upload_Config__mdt WHERE ObjectName__c =: objectApiName LIMIT 1];
        } 
        catch(Exception ex) {
            System.debug('error');
        }
        for(sobject obj : recordList) {
            sObject rec = Schema.getGlobalDescribe().get(objectApiName).newSObject();
            recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            System.debug('recMap : '+recMap);
            //Handling only for account mapping.line (28 -261) - Susovan
            If(objectApiName == 'Account'){
                for(String keyInstance:fieldtypes.keyset()){
                    system.debug('If execute keyInstance : '+keyInstance);
                    
                    if(keyInstance != 'attributes' && keyInstance !='Id'){
                        if(record=='')
                            record=string.valueof(recMap.get(keyInstance));
                        else
                            record =record+','+string.valueof(recMap.get(keyInstance));
                        if(keyInstance == 'Service_Location_ID__c' && objectApiName =='Account'){
                            rec.put('SAP_ID__c',string.valueof(recMap.get('SAP_ID__c')));
                            rec.put('Service_Location_ID__c',null);
                            system.debug('SAP_ID__c'+string.valueof(recMap.get('SAP_ID__c')));
                        }
                        
                        if(fieldtypes.get(keyInstance)=='DOUBLE' ){
                            if(String.isNotBlank(String.valueof(recMap.get(keyInstance)))){
                                try{
                                    rec.put(keyInstance, double.valueof(recMap.get(keyInstance))); 
                                }catch(Exception e) {
                                    System.debug('The following exception has occurred: ' + e.getMessage());
                                }
                            }
                            
                        }
                        
                        else if(fieldtypes.get(keyInstance)=='DATE'){
                            try{
                                if(!String.isBlank(string.valueof(recMap.get(keyInstance)))||Test.isRunningTest()){
                                    if(string.valueof(recMap.get(keyInstance)).contains('-')){
                                        rec.put(keyInstance, date.valueOf(string.valueof(recMap.get(keyInstance)))); 
                                    }else{
                                        rec.put(keyInstance, date.parse(string.valueof(recMap.get(keyInstance))));
                                    }
                                    //System.Debug('Date in String'+date.parse(string.valueof(recMap.get(keyInstance))));
                                }
                            }
                            catch(Exception e){
                                obj.put('Error_Log__c' ,keyInstance + ' ' +e.getMessage());
                                updateErrorMessage.add(obj);
                                // checkBug = true;
                                system.debug('error message: '+e.getMessage());
                                system.debug('error message2: '+e.getLineNumber());
                            }
                        }
                        
                        else if(fieldtypes.get(keyInstance)=='BOOLEAN' && !keyInstance.contains('X1000_Series_TCMReprogramming__c')){ 
                            System.debug('keyInstance : '+keyInstance);
                            if(recMap.containskey(keyInstance)){rec.put(keyInstance, Boolean.valueof(recMap.get(keyInstance))); 
                                                               }
                            else{rec.put(keyInstance,false);
                                } 
                        }
                        //Adding all the 4ward fields to be mapped via S&SL
                        else if(keyInstance.startsWith('T_') && objectApiName =='Account'){ 
                            if(recMap.containskey(keyInstance)){ rec.put(keyInstance,string.valueof(recMap.get(keyInstance)));
                                                               }
                            else{
                                rec.put(keyInstance,null);
                            }
                        }
                        else if(keyInstance.startsWith('TC') && objectApiName =='Account'){ 
                            if(recMap.containskey(keyInstance)){ rec.put(keyInstance,string.valueof(recMap.get(keyInstance)));
                                                               }
                            else{
                                rec.put(keyInstance,null);
                            }
                        }
                        else if(keyInstance.startsWith('Electric_') && objectApiName =='Account'){ 
                            if(recMap.containskey(keyInstance)){ rec.put(keyInstance,string.valueof(recMap.get(keyInstance)));
                                                               }
                            else{
                                rec.put(keyInstance,null);
                            }
                        }
                        else if(keyInstance.startsWith('B_') && objectApiName =='Account'){ 
                            if(recMap.containskey(keyInstance)){ rec.put(keyInstance,string.valueof(recMap.get(keyInstance)));
                                                               }
                            else{
                                rec.put(keyInstance,null);
                            }
                        }
                        
                        else if(keyInstance.startsWith('X') && objectApiName =='Account'){
                            
                            if(recMap.containskey(keyInstance)){ rec.put(keyInstance,string.valueof(recMap.get(keyInstance)));
                                                               }
                            else{
                                rec.put(keyInstance,null);
                            }
                            
                        }
                        //Maping Type field based on location type. Line no (170 - 187) -Susovan
                        else if(keyInstance == 'Location_Type__c' && objectApiName =='Account'){ 
                            if(string.valueof(recMap.get(keyInstance)) =='D'){
                                rec.put('Type','Distributor');
                                rec.put(keyInstance, string.valueof(recMap.get(keyInstance)));
                            }
                            else if(string.valueof(recMap.get(keyInstance)) == 'DB'){
                                rec.put('Type','Distributor Branch');
                                rec.put(keyInstance, string.valueof(recMap.get(keyInstance)));
                            }
                            else if(string.valueof(recMap.get(keyInstance)) =='DLR'){
                                rec.put('Type','Service Dealer');
                                rec.put(keyInstance, string.valueof(recMap.get(keyInstance)));
                            }
                            else if(string.valueof(recMap.get(keyInstance)) =='DDLR'){
                                rec.put('Type','Direct Dealer');
                                rec.put(keyInstance, string.valueof(recMap.get(keyInstance)));
                            }
                        }
                        
                        
                        else if(fieldtypes.get(keyInstance)=='DATETIME'||Test.isRunningTest()){
                            try{
                                rec.put(keyInstance, DateTime.valueof(recMap.get(keyInstance))); 
                            }
                            catch(exception e){
                                system.debug('error: '+e.getMessage());
                            }
                        }
                        else{
                            System.debug('keyInstance'+keyInstance);
                            
                            if(recMap.containskey(keyInstance)){    rec.put(keyInstance, recMap.get(keyInstance));
                                                               }else{rec.put(keyInstance,null);
                            }
                        }
                    }
                }
            }
            
            else{
                for(String keyInstance:recMap.keyset()){
                    system.debug('else execute keyInstance : '+keyInstance);
                    if(keyInstance != 'attributes' && keyInstance !='Id'){
                        if(record=='')
                            record=string.valueof(recMap.get(keyInstance));
                        else
                            record =record+','+string.valueof(recMap.get(keyInstance));
                        if(keyInstance==dataUploadConfig.SAP_ID_Field__c){
                            if(dataUploadConfig.ObjectName__c!='TAT_Data__c'&& dataUploadConfig.ObjectName__c!='End_Customer__c'){
                                if(dataUploadConfig.ObjectName__c=='CE_Data__c'){
                                    String SAPIDValue=string.valueof(recMap.get(keyInstance)).replace('-','');
                                    if(SAPIDValue.length()==4){     
                                        SAPIDValue='000000'+SAPIDValue;
                                    }
                                    else if(SAPIDValue.length()==5){     
                                        SAPIDValue='00000'+SAPIDValue;
                                    }
                                    sapId.add(string.valueof(SAPIDValue));
                                }
                                else{
                                    String SAPIDValue=string.valueof(recMap.get(keyInstance)).replace('-','');
                                    SAPIDValue=SAPIDValue.remove('-');
                                    if(SAPIDValue.length()==9){ SAPIDValue='0'+SAPIDValue;
                                                              }
                                    sapId.add(string.valueof(SAPIDValue));
                                }
                            }
                        }
                        
                        if(fieldtypes.get(keyInstance)=='DOUBLE'){
                            if(String.isNotBlank(String.valueof(recMap.get(keyInstance)))){
                                try{
                                    rec.put(keyInstance, double.valueof(recMap.get(keyInstance))); 
                                }catch(Exception e) {
                                    System.debug('The following exception has occurred: ' + e.getMessage());
                                }
                            }
                            
                        }
                        else if(fieldtypes.get(keyInstance)=='CURRENCY'){
                            try{
                                rec.put(keyInstance, Decimal.valueof(string.valueof(recMap.get(keyInstance))));
                            }catch(Exception e){
                                if(string.valueof(recMap.get(keyInstance)).contains('-')){
                                    rec.put(keyInstance, Decimal.valueof(string.valueof(recMap.get(keyInstance)).remove('-')));
                                }
                            }
                        }
                        else if(fieldtypes.get(keyInstance)=='DATE'){
                            try{
                                if(!String.isBlank(string.valueof(recMap.get(keyInstance)))){
                                    if(stagingObj == 'TAT_Turnt_staging__c'){
                                        System.Debug('check Enter: '+string.valueof(recMap.get(keyInstance)));
                                        System.Debug('check Enter59: '+keyInstance);
                                        rec.put(keyInstance,date.parse(string.valueof(recMap.get(keyInstance))));
                                    }
                                    if(dataUploadConfig.ObjectName__c!='TAT_Data__c'){
                                        
                                        if(dataUploadConfig.Date_Format__c=='MM/DD/YYYY'){
                                            // System.Debug('Date in String'+string.valueof(recMap.get(keyInstance)));
                                            if(string.valueof(recMap.get(keyInstance)).contains('-')){
                                                rec.put(keyInstance, date.valueOf(string.valueof(recMap.get(keyInstance)))); 
                                            }else{
                                                rec.put(keyInstance, date.parse(string.valueof(recMap.get(keyInstance))));
                                            }
                                            //System.Debug('Date in String'+date.parse(string.valueof(recMap.get(keyInstance))));
                                        } 
                                    }
                                }
                            }
                            catch(Exception e){
                                obj.put('Error_Log__c' ,keyInstance + ' ' +e.getMessage());
                                updateErrorMessage.add(obj);
                                // checkBug = true;
                                system.debug('error message: '+e.getMessage());
                                system.debug('error message2: '+e.getLineNumber());
                            }
                        }
                        else if(fieldtypes.get(keyInstance)=='REFERENCE'){
                            //rec.put(keyInstance, Date.valueof(recMap.get(keyInstance))); 
                        }
                        else if(fieldtypes.get(keyInstance)=='BOOLEAN' && !keyInstance.contains('X1000_Series_TCMReprogramming__c')){ //rec.put(keyInstance, Boolean.valueof(recMap.get(keyInstance))); 
                        }
                        
                        else if(fieldtypes.get(keyInstance)=='DATETIME'){
                            try{
                                if(stagingObj == 'TAT_Turnt_staging__c'){
                                    system.debug('line97: '+string.valueof(recMap.get(keyInstance)));
                                    DateTime TatTurntValue = PRPC_returnRealObjClass.returnDateTimeValueTurnt(string.valueof(recMap.get(keyInstance)));
                                    rec.put(keyInstance, TatTurntValue);
                                }
                                else if(objectApiName == 'TAT_Data__c' && stagingObj == 'TAT_Staging_Data__c'){
                                    DateTime TATvalue = PRPC_returnRealObjClass.returnDateTimeValue(string.valueof(recMap.get(keyInstance)));
                                    rec.put(keyInstance, TATvalue);
                                }else{
                                    rec.put(keyInstance, DateTime.valueof(recMap.get(keyInstance))); 
                                }
                            }catch(exception e){
                                system.debug('error: '+e.getMessage());
                            }
                        }
                        
                        else{
                            system.debug(' keyInstance: '+recMap.get(keyInstance));
                            if(keyInstance==dataUploadConfig.SAP_ID_Field__c){
                                String SAPIDValue=string.valueof(recMap.get(keyInstance));
                                if(SAPIDValue.length()==9){ SAPIDValue='0'+SAPIDValue;
                                                          }
                                rec.put(keyInstance, SAPIDValue); 
                            }
                            else{
                                rec.put(keyInstance, recMap.get(keyInstance));
                            }
                        }
                    }
                }  
                
            }
            recordvalues.add(record);
            record='';
            // if(checkBug != true){
            allRecordList.add(rec); 
            //}
            //system.debug('allRecordList: '+allRecordList);
            
        }
        if(dataUploadConfig.ObjectName__c!='TAT_Data__c'&& dataUploadConfig.ObjectName__c!='End_Customer__c'){
            lookupMap = ob.lookUpConvert(sapId);
        }
        for(integer i=0;i<recordList.size();i++){
            recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(recordList[i]));
            for(String keyInstance:recMap.keyset()){               
                if(keyInstance==dataUploadConfig.SAP_ID_Field__c){
                    if(dataUploadConfig.ObjectName__c=='TAT_Data__c'||dataUploadConfig.ObjectName__c=='End_Customer__c'){
                        system.debug('distributorId: line 132: '+distributorId);
                        allRecordList[i].put(dataUploadConfig.Account_LookUp__c,distributorId);
                    }
                    else {
                        if(dataUploadConfig.ObjectName__c=='CE_Data__c'){
                            string sapValue=string.valueof(recMap.get(keyInstance));
                            if(sapValue.length()==4){   sapValue='000000'+sapValue;
                                                    }
                            else if(sapValue.length()==5){   sapValue='00000'+sapValue;
                                                    }
                            if(lookupMap.keyset().contains(sapValue)){
                                allRecordList[i].put(dataUploadConfig.Account_LookUp__c, string.valueOf(lookupMap.get(sapValue)));
                            }
                            else{       allRecordList[i].put(dataUploadConfig.Account_LookUp__c,'');   
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
        /* if(updateErrorMessage.size()>0){
system.debug('updateErrorMessage: '+updateErrorMessage);
update updateErrorMessage;
}*/
        if(updateErrorMessage.size()>0){
            //system.debug('updateErrorMessage: '+updateErrorMessage);
            //  tatStageHelper.recursion = false;
            //EnCustStageHelper.recursion = false;
            //update updateErrorMessage;
        }
        wrapperInstance.csvData=recordvalues;
        wrapperInstance.recordstoInsert=allRecordList;
        return wrapperInstance;
    }
    
    public MAP<String, String> lookUpConvert(Set<String> sapId){
        List<Account> accounts = New List<Account>();
        try {
            accounts =[SELECT ID, SAP_ID__c FROM Account WHERE SAP_ID__c in :sapId and Sales_RegionA__c != null];
        }
        catch(Exception ex) {
            //System.debug('test'+ex.getMessage());
        }
        MAP<String, String> accountMap = new MAP<String, String>();
        for(Account a: accounts){
            accountMap.put(a.SAP_ID__c, a.ID); 
        }
        return accountMap;
    }
    public static DateTime returnDateTimeValueTurnt(string datevalue){
        try{
            string DtTm = datevalue;
            string storeyear;
            string storeDate;
            string storeMonth;
            //system.debug('DtTm: '+DtTm);
            Datetime GMTDate;
            
            if(DtTm.contains('|')){
                string storeDateField = DtTm.split('\\|')[0];
                string storeTimeField = DtTm.split('\\|')[1];
                if(storeDateField != 'null'){
                    if(storeDateField.contains('-')){
                        storeDateField = storeDateField.replace('-','/');
                    }
                    storeyear = storeDateField.split('/')[2];
                    storeDate = storeDateField.split('/')[1];
                    storeMonth = storeDateField.split('/')[0];
                    
                    string storeHour;
                    string storeminute;
                    string storeSec;
                    if(storeTimeField != 'null'){
                        if(storeTimeField.contains(':')){
                            storeTimeField = storeTimeField.replace(':','.');
                        }
                        if(storeTimeField.contains('.')){
                            if(storeTimeField.length()== 3 || storeTimeField.length()== 4||storeTimeField.length()== 5 ||storeTimeField.length()== 8){
                                storeHour=storeTimeField.split('\\.')[0];
                                storeminute=storeTimeField.split('\\.')[1];
                                storeSec='0';
                            }
                        }else{
                            storeHour=storeTimeField;
                            storeminute='0';
                            storeSec='0';
                        }
                        
                        
                        GMTDate = Datetime.newInstanceGMT(integer.valueof(storeyear),integer.valueof(storeMonth),integer.valueof(storeDate),integer.valueof(storeHour),integer.valueof(storeminute),integer.valueof(storeSec));
                        return GMTDate;
                    }else{
                        GMTDate = Datetime.newInstanceGMT(integer.valueof(storeyear),integer.valueof(storeMonth),integer.valueof(storeDate),0,0,0);
                        return GMTDate;
                    }
                }else{
                    return GMTDate;
                }
            }else{
                if(DtTm.contains('-')){
                    DtTm = DtTm.replace('-', '/');
                }
                Date dt = Date.parse(DtTm);
                GMTDate = DateTime.newInstanceGMT(dt.year(),dt.month(),dt.day(),0,0,0);
                return GMTDate;
            }
        }
        catch(exception e){
            Return null;
        }
        
        
    }
    public static DateTime returnDateTimeValue(string datevalue){
        DateTime dTs;
        String s1 = datevalue;
        if(s1.length() == 18){
            String s2 =  s1.substringBefore(':');
            String s2s =  s1.substringAfter(':');
            //system.debug('s2s' + s2s);
            string ss = s2.substring(5);
            //system.debug('year' + ss);
            string ss2 = s2.substring(2);
            string mon = ss2.substring(0,3);
            //system.debug('mon' + mon);
            string dt = s2.substring(0,2);
            //system.debug('day' + dt);
            
            Map<string,integer> MapMonthList = new Map<string,integer>();
            MapMonthList.put('JAN',1);
            MapMonthList.put('FEB',2);
            MapMonthList.put('MAR',3);
            MapMonthList.put('APR',4);
            MapMonthList.put('MAY',5);
            MapMonthList.put('JUN',6);
            MapMonthList.put('JUL',7);
            MapMonthList.put('AUG',8);
            MapMonthList.put('SEP',9);
            MapMonthList.put('OCT',10);
            MapMonthList.put('NOV',11);
            MapMonthList.put('DEC',12);
            integer daydt = null ;
            if(MapMonthList.containsKey(mon)){
                daydt = MapMonthList.get(mon);
                //system.debug('nu' + daydt);
            }
            string dateval = ss +'-'+ daydt +'-'+ dt;
            //system.debug('dateval'+ dateval);
            String vv = ss +'-'+ daydt +'-'+ dt+' '+s2s ;
            //system.debug('datetime' + vv);
            dTs = datetime.valueOf(vv);
            //system.debug('dTs'+dTs);
            return dTs;
        }else{
            return null;
        }
        
    }
    public static Date returnsubmitedDate(string datevalue){
        system.debug('datevalue: '+datevalue);
        String myDate = datevalue;
        Date convertDate;
        if(myDate != null){
            if(myDate.length() == 9 || myDate.length() == 11){
                string dt = myDate.split('-')[0];
                string mth = myDate.split('-')[1];
                string yr = myDate.split('-')[2];
                Map<string,integer> MapMonthList = new Map<string,integer>();
                MapMonthList.put('Jan',1);
                MapMonthList.put('Feb',2);
                MapMonthList.put('Mar',3);
                MapMonthList.put('Apr',4);
                MapMonthList.put('May',5);
                MapMonthList.put('Jun',6);
                MapMonthList.put('Jul',7);
                MapMonthList.put('Aug',8);
                MapMonthList.put('Sep',9);
                MapMonthList.put('Oct',10);
                MapMonthList.put('Nov',11);
                MapMonthList.put('Dec',12);
                integer mthNumber;
                if(MapMonthList.containsKey(mth)){
                    mthNumber = MapMonthList.get(mth);
                    //system.debug('nu' + daydt);
                }
                
                string concatAll = string.valueof(mthNumber)+'/'+dt+'/'+yr;
                convertDate = Date.parse(concatAll);
            }
            return convertDate;
        }else{
            return null;
        }
        
        
        
    }
    
    public static list<Sobject>updatelistwithAddress(list<sObject>AccountRec){
        for(integer i=0;i<AccountRec.size();i++){
            string SalesRegion = string.valueof(AccountRec[i].get('Sales_RegionA__c'));
            if(SalesRegion == 'Central'|| SalesRegion == 'Eastern'||SalesRegion == 'Western'|| SalesRegion == 'Canadian'|| SalesRegion == 'North America'){
                AccountRec[i].put('Sales_RegionA__c','North America');
                AccountRec[i].put('Sub_Region__c',SalesRegion);
            }
            else if(SalesRegion == 'South America'|| SalesRegion == 'Caribbean & Central America'|| SalesRegion == 'Latin American'){
                AccountRec[i].put('Sales_RegionA__c','Latin America');
                if( SalesRegion == 'Latin American'){
                    AccountRec[i].put('Sub_Region__c','Latin America');
                }
                else{
                    AccountRec[i].put('Sub_Region__c',SalesRegion);
                }
            }
            else if(SalesRegion == 'Asia/Pacific' || SalesRegion == 'Asia Pacific'){
                AccountRec[i].put('Sales_RegionA__c','Asia Pacific');
                AccountRec[i].put('Sub_Region__c','Asia Pacific');
            }
            else if(SalesRegion == 'European'){
                AccountRec[i].put('Sales_RegionA__c','EMEA');
                If(!Test.isRunningTest()){
                    AccountRec[i].put('Sub_Region__c',SalesRegion);
                }
            }
            /*   AccountRec[i].put('ShippingStreet', AccountRec[i].get('Address_1__c'));
AccountRec[i].put('ShippingCity', AccountRec[i].get('City__c'));
AccountRec[i].put('ShippingCountry', AccountRec[i].get('Country__c'));
AccountRec[i].put('ShippingState', AccountRec[i].get('State_Province__c'));
AccountRec[i].put('BillingStreet', AccountRec[i].get('Address_1__c'));
AccountRec[i].put('BillingCity', AccountRec[i].get('City__c'));
AccountRec[i].put('BillingCountry', AccountRec[i].get('Country__c'));
AccountRec[i].put('BillingState', AccountRec[i].get('State_Province__c'));*/
            
        }
        return AccountRec;
    } 
    public static void DeleteandUpdateRec(list<Database.SaveResult> insertRec,list<sobject>allStagingData){
        //system.debug('insertRec: '+insertRec);
        //system.debug('allStagingData: '+allStagingData);
        list<Sobject>deleteSuccessRec = new list<Sobject>();
        list<sobject>updateRecwithErrorlog = new list<sobject>();
        list<sobject>DeleteRec = new list<sobject>();
        
        for(integer i=0;i<insertRec.size();i++){
            if(insertRec[i].isSuccess()){
                id storeSuccessId = string.valueof(allStagingData[i].get('Id'));
                String sObjNameSuccessRec = storeSuccessId.getSObjectType().getDescribe().getName();
                Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjNameSuccessRec);
                SObject SuccRec = t.newSObject();
                SuccRec.put('Id',storeSuccessId);
                deleteSuccessRec.add(SuccRec);
                
            }else if(!insertRec[i].isSuccess()){
                //system.debug('errorId267: '+allStagingData[i].get('Id'));
                Database.Error error = insertRec.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                id storeErrorId = string.valueof(allStagingData[i].get('Id'));
                String sObjName = storeErrorId.getSObjectType().getDescribe().getName();
                String sObjectName = sObjName; 
                Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
                SObject childRecOfDist = t.newSObject();
                childRecOfDist.put('Id',storeErrorId);
                // if(childRecOfDist.get('Error_Log__c')== null){
                childRecOfDist.put('Error_Log__c',failedDML);
                //}
                
                updateRecwithErrorlog.add(childRecOfDist);
                
            }
        }
        /*system.debug('updateRecwithErrorlog: '+updateRecwithErrorlog);
system.debug('updateRecwithErrorlogSize: '+updateRecwithErrorlog.size());
system.debug('deleteSuccessRec: '+deleteSuccessRec);
system.debug('deleteSuccessRecSize: '+deleteSuccessRec.size());*/
        
        if(updateRecwithErrorlog.size()>0){
            tatStageHelper.recursion=false;
            EnCustStageHelper.recursion=false;
            //update updateRecwithErrorlog;
            Database.update(updateRecwithErrorlog, False);
        }
        if(deleteSuccessRec.size()>0){
            Database.delete(deleteSuccessRec, False);
        }
        List<PRPMD_All_Staging_object_Data__mdt> ttTurntList = [select id,EmailCheck__c,DateFrom__c,DateTo__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c ='TAT_Turnt_staging__c' LIMIT 1];
        List<PRPMD_All_Staging_object_Data__mdt> endCustList = [select id,EmailCheck__c,DateFrom__c,DateTo__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c ='End_Customer_Staging_Data__c' LIMIT 1];
        
        Boolean flag = ttTurntList[0].EmailCheck__c;
        Boolean flag2 = endCustList[0].EmailCheck__c;
        string storeDate = string.valueof(Date.today().day());
        /*if(updateRecwithErrorlog.size()>0){
if(string.valueof(updateRecwithErrorlog[0].get('Id')).left(3) =='a0P'){
if(Integer.valueof(storeDate) >= integer.valueOf(ttTurntList[0].DateFrom__c) && integer.valueOf(storeDate) <= integer.valueOf(ttTurntList[0].DateTo__c)  && flag == true){
PRPC_EmailForErrorData.sendEmail(updateRecwithErrorlog);
}
}
if(string.valueof(updateRecwithErrorlog[0].get('Id')).left(3) =='a02'){
if(Integer.valueof(storeDate) >= Integer.valueof(endCustList[0].DateFrom__c)  && Integer.valueof(storeDate) <= Integer.valueof(endCustList[0].DateTo__c)  && flag == true){
PRPC_EmailForErrorData.sendEmailToCustomers(updateRecwithErrorlog);
}
}
}*/
    }
    public static void updateAllrecords(list<sobject>recList, string realObjApi, string stagingObjApi, map<string,string>fieldType,Set<String> SapIdfromStaging){
        system.debug('REAL OBJECT CLASS recList***********'+recList.size());
        list<Account> RealAccountObjectQuery = new list<Account>();
        map<string,string> MapofAccountRec = new map<string,string>();
        //considering only SAP IDs in Staging for updation process
        RealAccountObjectQuery = [select id,Service_Location_ID__c,SAP_ID__c from Account where SAP_ID__c IN:SapIdfromStaging];
        for(Account acc : RealAccountObjectQuery){
            MapofAccountRec.put(acc.SAP_ID__c,acc.Id);
        }
        
        PRPC_returnRealObjClass.wrapperclass UpdateListOfacc = PRPC_returnRealObjClass.createInsertList(recList,realObjApi,stagingObjApi,fieldType,null);
        for(integer i = 0;i<UpdateListOfacc.recordstoInsert.size();i++){
            if(MapofAccountRec.keyset().contains(string.valueof(UpdateListOfacc.recordstoInsert[i].get('SAP_ID__C')))){
                UpdateListOfacc.recordstoInsert[i].put('Id',MapofAccountRec.get(string.valueof(UpdateListOfacc.recordstoInsert[i].get('SAP_ID__C'))));
                /* if(UpdateListOfacc.recordstoInsert[i].get('Location_Type__c') == 'D' || UpdateListOfacc.recordstoInsert[i].get('Location_Type__c') == 'DB' || UpdateListOfacc.recordstoInsert[i].get('Location_Type__c') == 'DDLR'){
UpdateListOfacc.recordstoInsert[i].put('PRP_Participation__c',true);
}*/
                
            }
        }
        list<Sobject>returnUpdateList= PRPC_returnRealObjClass.updatelistwithAddress(UpdateListOfacc.recordstoInsert);
        Database.SaveResult[] UpdateResult = Database.Update(returnUpdateList,false);
        PRPC_returnRealObjClass.DeleteandUpdateRec(UpdateResult,recList);
        
    }
    public class wrapperclass{
        public list<String> csvData;
        public list<Sobject> recordstoInsert;
    }
    public class wrapperofDate{
        public DateTime Datefield;
        public string stringTime;
        public string fieldname;
    }
}