Global class PRPC_dataMovementForTTData implements Database.Batchable<sObject>{
    
    global list<Sobject> start(Database.BatchableContext BC) {
        DateTime dt = system.now();
        dt = dt.addDays(-360);
        list<Sobject> returnQuery = [Select Allison_Serial__c,customer_notified__c,Date_first_labor_applied__c,Date_First_Part_Ordered__c,Date_last_labor_applied__c,Date_of_File_Submission__c,PART_ARRIVAL_DATE__c,date_vehicle_first_arrived__c,Distributor_Ship_To__c,Repair_Order_closed_date__c,Repair_Order_closed_time_of_day__c,Repair_Order_open_date__c,Repair_Order_open_time_of_day__c,repair_order_number__c,Repair_Payment__c,Repair_Type__c,Technician_Name__c,Time_customer_notified_vehicle_available__c,Time_of_day_first_labor_applied__c,Time_of_day_last_labor_applied__c,Time_of_day_vehicle_first_arrived__c,Total_labor_hours__c,vin__c from TAT_Turnt_staging__c Where CreatedDate >:dt];
        return returnQuery;
    }
    
    
    global void execute(Database.BatchableContext BC, List<Sobject> MetaDataList){
        string RealObjApiName = 'TAT_Data__c';
        string StagingApiName = 'TAT_Turnt_staging__c';
        list<sObject> allStagingRec = new list<sObject>(MetaDataList);
        list<string> staggingFieldApi = new list<string>();
        set<string>checkDuplicateRec = new set<string>();
        list<sObject>deleteDuplicateRec = new list<sObject>();
        list<sObject>removeDuplicatestagingRec = new list<sObject>();
        map<string,Account> mapofacc = new map<string,Account>();
        string partnercode;
        System.debug('------------ Metadata Size : '+allStagingRec.size());
        
        list<PRPMD_All_Staging_object_Data__mdt> TTTurntFieldList = [select Staging_Object_Fields_Api_Name__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c = 'TAT_Turnt_staging__c' limit 1];
        
        string check = TTTurntFieldList[0].Staging_Object_Fields_Api_Name__c;
        for(integer i=0;i<check.split(',').size();i++){
            staggingFieldApi.add(check.split(',')[i]);
        }
        
        map<string,string>FieldType = new map<string,string>();
        SObjectType objType = Schema.getGlobalDescribe().get('TAT_Data__c');
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        Set<String> AccountSAPidSet = new Set<String>();
        system.debug('mfields: '+mfields);
        for(string fld : mfields.keyset()){
            Schema.DisplayType fielddataType = mfields.get(fld).getDescribe().getType();
            if(staggingFieldApi.contains(string.valueof(mfields.get(fld)))){
                FieldType.put(string.valueof(mfields.get(fld)),string.valueof(fielddataType));
            }
        }
        
        for(integer i=0;i<allStagingRec.size();i++){
            allStagingRec[i].put('date_vehicle_first_arrived__c',string.valueof(allStagingRec[i].get('date_vehicle_first_arrived__c'))+'|'+string.valueof(allStagingRec[i].get('Time_of_day_vehicle_first_arrived__c')));
            allStagingRec[i].put('Date_first_labor_applied__c',string.valueof(allStagingRec[i].get('Date_first_labor_applied__c'))+'|'+string.valueof(allStagingRec[i].get('Time_of_day_first_labor_applied__c')));
            allStagingRec[i].put('Date_last_labor_applied__c',string.valueof(allStagingRec[i].get('Date_last_labor_applied__c'))+'|'+string.valueof(allStagingRec[i].get('Time_of_day_last_labor_applied__c')));
            allStagingRec[i].put('Repair_Order_closed_date__c',string.valueof(allStagingRec[i].get('Repair_Order_closed_date__c'))+'|'+string.valueof(allStagingRec[i].get('Repair_Order_closed_time_of_day__c')));
            allStagingRec[i].put('Repair_Order_open_date__c',string.valueof(allStagingRec[i].get('Repair_Order_open_date__c'))+'|'+string.valueof(allStagingRec[i].get('Repair_Order_open_time_of_day__c')));
            allStagingRec[i].put('customer_notified__c',string.valueof(allStagingRec[i].get('customer_notified__c'))+'|'+string.valueof(allStagingRec[i].get('Time_customer_notified_vehicle_available__c')));
            
            If(allStagingRec[i].get('Distributor_Ship_To__c')!=null){
                if(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')).length() == 9){
                    partnercode =  '0'+string.valueof(allStagingRec[i].get('Distributor_Ship_To__c'));
                    AccountSAPidSet.add(partnercode);
                }
                else{
                    AccountSAPidSet.add(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')));
                }
            }
        }
        
        for(Account acc:[select id,SAP_ID__c,name,Sales_RegionA__c from Account WHERE SAP_ID__c IN : AccountSAPidSet]){
            mapofacc.put(acc.SAP_ID__c,acc);
        }
        
        for(integer i=0;i<allStagingRec.size();i++)
        {
            if(allStagingRec[i].get('Distributor_Ship_To__c') != null && allStagingRec[i].get('Date_of_File_Submission__c') != null && allStagingRec[i].get('Allison_Serial__c') != null && allStagingRec[i].get('Vin__c') != null){
                string uniqueKey;
                if(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')).length()==9){
                    
                    uniqueKey = '0'+string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Date_of_File_Submission__c'))+'-'+ string.valueof(allStagingRec[i].get('Allison_Serial__c'))+'-'+string.valueof(allStagingRec[i].get('Vin__c')+'-'+string.valueof(allStagingRec[i].get('Total_labor_hours__c')));
                }else{
                    uniqueKey = string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Date_of_File_Submission__c'))+'-'+ string.valueof(allStagingRec[i].get('Allison_Serial__c'))+'-'+string.valueof(allStagingRec[i].get('Vin__c')+'-'+string.valueof(allStagingRec[i].get('Total_labor_hours__c')));
                }
                
                if(!checkDuplicateRec.contains(uniqueKey)){
                    checkDuplicateRec.add(uniqueKey);
                    removeDuplicatestagingRec.add(allStagingRec[i]);
                }else{
                    deleteDuplicateRec.add(allStagingRec[i]);
                }
            }else{
                removeDuplicatestagingRec.add(allStagingRec[i]);
            }
        }
        Delete deleteDuplicateRec;
        
        PRPC_returnRealObjClass.wrapperclass AllValueRec = PRPC_returnRealObjClass.createInsertList(removeDuplicatestagingRec,RealObjApiName,StagingApiName,FieldType,null);
        system.debug('AllValueRecrecordstoInsert: '+AllValueRec.recordstoInsert);
        list<Sobject> returnObjData = new list<Sobject>();
        returnObjData = AllValueRec.recordstoInsert;
        
        for(integer i=0;i<returnObjData.size();i++)
        {
            //if(MetaDataList[0].Real_Object_Api_Name__c == 'TAT_Data__c'){}
            list<PRPC_returnRealObjClass.wrapperofDate> returnWrapperdate = new list<PRPC_returnRealObjClass.wrapperofDate>();
            map<string,PRPC_returnRealObjClass.wrapperofDate> mapOfTat = new map<string,PRPC_returnRealObjClass.wrapperofDate>();
            
            //if(MetaDataList[0].Staging_Object_Api_Name__c == 'TAT_Turnt_staging__c'){}
            returnObjData[i].put('Source_Type__c','Distributor');
            returnObjData[i].put('total_hours__c',returnObjData[i].get('Total_labor_hours__c'));
            returnObjData[i].put('Extraction_Date__c',returnObjData[i].get('Date_of_File_Submission__c'));
            if(returnObjData[i].get('Allison_Serial__c')!=null || returnObjData[i].get('Allison_Serial__c')!=''){
                returnObjData[i].put('Allison_Serial__c',string.valueof(returnObjData[i].get('Allison_Serial__c')));
            }else{
                returnObjData[i].put('Allison_Serial__c','');
            }
            
            if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')) != null){
                if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')).length() == 9){
                    returnObjData[i].put('Distributor_Ship_To__c','0'+ string.valueof(returnObjData[i].get('Distributor_Ship_To__c')));
                    if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                        returnObjData[i].put('Dealer_Id__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                    }
                }
                else 
                {
                    if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                        returnObjData[i].put('Dealer_Id__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                    }
                }
            }
        }
        Database.SaveResult[] insertOtherStagingRec = Database.insert(returnObjData,false);
        PRPC_returnRealObjClass.DeleteandUpdateRec(insertOtherStagingRec,removeDuplicatestagingRec);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        PRPC_DeleteDuplicateRecordFromReal myBatchObject = new PRPC_DeleteDuplicateRecordFromReal(); 
        Id batchId = Database.executeBatch(myBatchObject,1);
    }    
}