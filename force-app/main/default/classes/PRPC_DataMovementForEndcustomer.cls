global class PRPC_DataMovementForEndcustomer implements Database.Batchable<sObject> {
    global list<Sobject> start(Database.BatchableContext BC) {
        string Query ='select Customer_Address_1__c,Customer_Address_2__c,City__c,Company_Name__c,Country__c,Customer_Email_Adress__c,Customer_Name__c,Date_Of_Submission__c,Distributor_Ship_To__c,Parts_Invoice__c,Phone_Number__c,Zip__c,Repair_Order__c,Repair_Type__c,Type__c,State__c,Street__c,Date_Of_Type__c,Repair_Order_or_Parts_Invoice__c,Language__c from End_Customer_Staging_Data__c';
        list<Sobject>returnQuery = Database.query(Query);
        return returnQuery;
    }
    global void execute(Database.BatchableContext BC, List<Sobject> MetaDataList) {
        set<integer>storeMonthset = new set<integer>();
        set<integer>storeYearSet = new set<integer>();
        Set<string>storeDist = new set<string>();
        list<sobject>updateFunclist = new list<sobject>();
        list<sobject>insertStaginglist = new list<sobject>();
        set<Id>updateStagingSet = new set<Id>();
        list<sobject>updateStaginglist = new list<sobject>();
        
        list<PRPMD_All_Staging_object_Data__mdt> endCustFieldList = [select Staging_Object_Fields_Api_Name__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c = 'End_Customer_Staging_Data__c' limit 1];
        list<string> staggingFieldApi = new list<string>();
        string check = endCustFieldList[0].Staging_Object_Fields_Api_Name__c;
        for(integer i=0;i<check.split(',').size();i++){
            staggingFieldApi.add(check.split(',')[i]);
        }
        
        list<sObject> allStagingRec = new list<sObject>(MetaDataList);
        string RealObjApiName = 'End_Customer__c';
        string StagingApiName = 'End_Customer_Staging_Data__c';
        
        
        //FieldType with Field Name
        
        map<string,string>FieldType = new map<string,string>();
        SObjectType objType = Schema.getGlobalDescribe().get('End_Customer__c');
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        system.debug('mfields: '+mfields);
        for(string fld : mfields.keyset()){
            Schema.DisplayType fielddataType = mfields.get(fld).getDescribe().getType();
            if(staggingFieldApi.contains(string.valueof(mfields.get(fld)))){
                FieldType.put(string.valueof(mfields.get(fld)),string.valueof(fielddataType));
            }
            
        }
        map<string,Account> mapofacc = new map<string,Account>();
        Set<String> AccountSAPidSet = new Set<String>();
        String partnercode;
        for(integer i=0;i<allStagingRec.size();i++){
            system.debug('line 45 : '+allStagingRec[i].get('Distributor_Ship_To__c'));
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
        map<string,id>mapofPartorder = new map<string,Id>();
        
        
        
        PRPC_returnRealObjClass.wrapperclass AllValueRec = PRPC_returnRealObjClass.createInsertList(allStagingRec,RealObjApiName,StagingApiName,FieldType,null);
        //system.debug('AllValueRecrecordstoInsert: '+AllValueRec.recordstoInsert);
        list<Sobject> returnObjData = new list<Sobject>();
        returnObjData = AllValueRec.recordstoInsert;
        
        for(integer i=0;i<returnObjData.size();i++){
            //string partnercode;
            if(returnObjData[i].get('Distributor_Ship_To__c') != null){
                if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')).length() == 9){
                    partnercode =  '0'+string.valueof(returnObjData[i].get('Distributor_Ship_To__c'));
                    if(mapofacc.get(partnercode) != null){
                        returnObjData[i].put('Customer__c',mapofacc.get(partnercode).id);
                    }
                }else{
                    if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                        returnObjData[i].put('Customer__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                    }
                }
            }
            
        }
        
        Database.SaveResult[] insertOtherStagingRec = Database.insert(returnObjData,false);
        PRPC_returnRealObjClass.DeleteandUpdateRec(insertOtherStagingRec,allStagingRec);
        
    }
    global void finish(Database.BatchableContext BC) {
        If(!Test.isRunningTest()){
        /*PRPC_DeleteDuplicateRecordFromReal myBatchObject = new PRPC_DeleteDuplicateRecordFromReal(); 
		Id batchId = Database.executeBatch(myBatchObject,1);*/
           PRPC_dataMovementForTTData myBatchObject = new PRPC_dataMovementForTTData(); 
			Id batchId = Database.executeBatch(myBatchObject,600);
        }
    }
}