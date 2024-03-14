public without sharing class PRPC_StagingDataTable {
    @AuraEnabled
    public static List<PRPC_transacErrorApexClass.pickListWrapper> findAllDistributor() {
        List<PRPC_transacErrorApexClass.pickListWrapper> distributorNames = new List<PRPC_transacErrorApexClass.pickListWrapper>();
        distributorNames = PRPC_transacErrorApexClass.profileCheck().DistributorNames;
        return distributorNames;
    }
    
    @AuraEnabled
    public static List<String> deleteRecords(List<String> listToDelete){
        System.debug('listToDelete :'+listToDelete);
        List < String > oErrorMsg = new List < String > ();
        List<TAT_Turnt_staging__c> listToDeleteTAT = [SELECT Id FROM TAT_Turnt_staging__c WHERE ID IN :listToDelete];
        System.debug('Size of listToDeleteTAT :'+listToDeleteTAT.size());
        delete listToDeleteTAT;
        return oErrorMsg;
    }
    
    @AuraEnabled
    public static List<TAT_Turnt_staging__c> findAllTATData(String distId){
        try{
            String typeOfAccount = [SELECT type FROM Account WHERE Id = :distId].type;
            //User findLoggedInUserDetails = new User();
            //findLoggedInUserDetails = [select id, ContactId, Contact.AccountId from User Where id = :UserInfo.getUserId()];
            //system.debug('check user'+findLoggedInUserDetails);
            List<Account> findBranchAcctDetails = new List<Account>();
            Set<String> branchSAPIdSet = new Set<String>();
             if(typeOfAccount == 'Distributor'){
                findBranchAcctDetails = [select id, ParentId, SAP_ID__c from Account Where ParentId = :distId];
            }
            else if(typeOfAccount == 'Direct Dealer'){
                findBranchAcctDetails = [select id, ParentId, SAP_ID__c from Account Where Id = :distId];
            }
            
            for(Account acct: findBranchAcctDetails){
                if(acct.SAP_ID__c.length() == 9){
                    acct.SAP_ID__c = ' ' + acct.SAP_ID__c;
                    branchSAPIdSet.add(acct.SAP_ID__c);
                }
                else
                    branchSAPIdSet.add(acct.SAP_ID__c);
                
            }
            List<TAT_Turnt_staging__c> tatList = new List<TAT_Turnt_staging__c>();
            tatList = [select id, Name, Distributor_Ship_To__c, Allison_Serial__c, repair_order_number__c, Repair_Type__c, Error_Log__c from TAT_Turnt_staging__c WHERE Error_Log__c != null AND Distributor_Ship_To__c IN: branchSAPIdSet]; 
            
            return tatList;
            
            
        } 
        
        catch(exception e){
            system.debug('Error: '+ e.getMessage()); 
            return new List<TAT_Turnt_staging__c>();
        } 
    }
    
    @AuraEnabled
    public static void updateTATData(string tat){
        system.debug('line no 38');
        system.debug('line no 37' + tat);
        list<string> staggingFieldApi = new list<string>();
        List<TAT_Turnt_staging__c> tatList = (List<TAT_Turnt_staging__c>)JSON.deserialize(tat, List<TAT_Turnt_staging__c>.class);
        system.debug('Line no 40'+ tatList);
        update tatList;
        List<PRPMD_All_Staging_object_Data__mdt> taterrorobj =  new List<PRPMD_All_Staging_object_Data__mdt>();
        taterrorobj = [select Real_Object_Api_Name__c,Staging_Object_Api_Name__c,Sequence__c,Staging_Object_Fields_Api_Name__c from PRPMD_All_Staging_object_Data__mdt where Staging_Object_Api_Name__c='TAT_Turnt_staging__c' limit 1];
        string Query = 'select ';
        string check = taterrorobj[0].Staging_Object_Fields_Api_Name__c;
        for(integer i=0;i<check.split(',').size();i++){
            staggingFieldApi.add(check.split(',')[i]);
        }
        
        
        for(string stageFld : staggingFieldApi){
            Query += stageFld+',';
            
        }
        
        Query = Query.substring(0,Query.length()-1);
        Query += ' from '+ taterrorobj[0].Staging_Object_Api_Name__c;
        
        //system.debug('Queryvariable++++'+Query.substring(750,Query.length()) );
        list<sObject> QueryResults = Database.query(Query);
        System.debug('Check queryResult: '+QueryResults);
        System.debug('Check queryResult: '+taterrorobj[0].Staging_Object_Api_Name__c);
        system.debug('Line 20:'+ [SELECT count() FROM TAT_Turnt_staging__c]);
        //List<String> apiNameList =  new List<String>();
        List<Sobject> allStagingRec =  new List<Sobject>();
        map<String,Sobject> tatStagingObjRecord = new map<String,Sobject>();
        
        for(Sobject errorId : QueryResults){
            tatStagingObjRecord.put(string.valueof(errorId.get('Id')),errorId); 
        }
        for(TAT_Turnt_staging__c errorlogId : tatList){
            
            system.debug('Line no 57'+ errorlogId.Id);
            if(tatStagingObjRecord.keyset().contains(string.valueof(errorlogId.Id))){
                system.debug('line number 62'+errorlogId.Id);
                
                allStagingRec.add(tatStagingObjRecord.get(errorlogId.Id));
                
            }
        }
        for(integer i=0;i<allStagingRec.size();i++){
            //allStagingRec[i].put('date_cust_request_service__c',string.valueof(allStagingRec[i].get('date_cust_request_service__c'))+'|'+string.valueof(allStagingRec[i].get('Time_customer_desires_service_to_begin__c')));
            //allStagingRec[i].put('Date_Distributor_schedules_for_service__c',string.valueof(allStagingRec[i].get('Date_Distributor_schedules_for_service__c'))+'|'+string.valueof(allStagingRec[i].get('Time_Distributor_schedules_for_service__c')));
            allStagingRec[i].put('date_vehicle_first_arrived__c',string.valueof(allStagingRec[i].get('date_vehicle_first_arrived__c'))+'|'+string.valueof(allStagingRec[i].get('Time_of_day_vehicle_first_arrived__c')));
            allStagingRec[i].put('Date_first_labor_applied__c',string.valueof(allStagingRec[i].get('Date_first_labor_applied__c'))+'|'+string.valueof(allStagingRec[i].get('Time_of_day_first_labor_applied__c')));
            allStagingRec[i].put('Date_last_labor_applied__c',string.valueof(allStagingRec[i].get('Date_last_labor_applied__c'))+'|'+string.valueof(allStagingRec[i].get('Time_of_day_last_labor_applied__c')));
            //allStagingRec[i].put('PART_ARRIVAL_DATE__c',string.valueof(allStagingRec[i].get('PART_ARRIVAL_DATE__c'))+'|'+string.valueof(allStagingRec[i].get('Time_customer_desires_service_to_begin__c')));
            //allStagingRec[i].put('Date_First_Part_Ordered__c',string.valueof(allStagingRec[i].get('Date_First_Part_Ordered__c'))+'|'+string.valueof(allStagingRec[i].get('Time_customer_desires_service_to_begin__c')));
            allStagingRec[i].put('Repair_Order_closed_date__c',string.valueof(allStagingRec[i].get('Repair_Order_closed_date__c'))+'|'+string.valueof(allStagingRec[i].get('Repair_Order_closed_time_of_day__c')));
            allStagingRec[i].put('Repair_Order_open_date__c',string.valueof(allStagingRec[i].get('Repair_Order_open_date__c'))+'|'+string.valueof(allStagingRec[i].get('Repair_Order_open_time_of_day__c')));
            allStagingRec[i].put('customer_notified__c',string.valueof(allStagingRec[i].get('customer_notified__c'))+'|'+string.valueof(allStagingRec[i].get('Time_customer_notified_vehicle_available__c')));
        }
        system.debug('line number 63'+tatStagingObjRecord);
        map<string,string>FieldType = new map<string,string>();
        SObjectType objType = Schema.getGlobalDescribe().get('TAT_Data__c');
        Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        system.debug('mfields: '+mfields);
        for(string fld : mfields.keyset()){
            Schema.DisplayType fielddataType = mfields.get(fld).getDescribe().getType();
            if(staggingFieldApi.contains(string.valueof(mfields.get(fld)))){
                FieldType.put(string.valueof(mfields.get(fld)),string.valueof(fielddataType));
            }
            
        }
        system.debug('line number 79 '+FieldType);
        //system.debug('line number 80 '+sObj);
        PRPC_returnRealObjClass.wrapperclass AccountRecForD = PRPC_returnRealObjClass.createInsertList(allStagingRec,'TAT_Data__c','TAT_Turnt_staging__c',FieldType,null);
        
        
        list<Sobject> returnObjData = new list<Sobject>();
        string partnercode;
        map<string,Account> mapofacc = new map<string,Account>();
        
        for(Account acc:[select id,SAP_ID__c,name from Account]){
            mapofacc.put(acc.SAP_ID__c,acc);
        }
        returnObjData = AccountRecForD.recordstoInsert;
        for(integer i=0;i<returnObjData.size();i++){
            returnObjData[i].put('Source_Type__c','Distributor');
            returnObjData[i].put('total_hours__c',returnObjData[i].get('Total_labor_hours__c'));
            returnObjData[i].put('Extraction_Date__c',returnObjData[i].get('Date_of_File_Submission__c'));
            if(returnObjData[i].get('Allison_Serial__c')!=null || returnObjData[i].get('Allison_Serial__c')!=''){
                            returnObjData[i].put('Allison_Serial__c',string.valueof(returnObjData[i].get('Allison_Serial__c')));
                        }else{
                            returnObjData[i].put('Allison_Serial__c','');
                        }
            if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')) != null){
                system.debug('line 468: '+returnObjData[i].get('Distributor_Ship_To__c'));
                if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                    returnObjData[i].put('Dealer_Id__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                    //returnObjData[i].put('Distributor_Ship_To__c',partnercode);
                }
            }
        }
        
        database.SaveResult[] saveErrorDetails = database.insert(AccountRecForD.recordstoInsert,false);
        
        PRPC_returnRealObjClass.DeleteandUpdateRec(saveErrorDetails,allStagingRec);
        
        
    }
}