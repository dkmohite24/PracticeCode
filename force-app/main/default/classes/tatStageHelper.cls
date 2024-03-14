public class tatStageHelper {
    
    public static Boolean recursion = true;    
    public static Set<Id> tatRecordSet = new set<Id>();
    public static Set<Id> UpdateRecordSet = new set<Id>();
    public static void afterHelper(List<TAT_Staging_Data__c > newTat) {
        /*Set<String> allPartnerCode = new Set<String>();
        Set<String> allDistributor = new Set<String>();
        List<Account> allBranch = new List<Account>(); 
        List<Contact> allContact = new List<Contact>(); 
        List<User> allUser = new List<User>(); 
        
        Map<String, String> tatPartnerCodeMap = new Map<String, String>();
        Map<String, String> partnerCOdeAccountMap = new Map<String, String>();
        Map<String, List<String>> accountUserMap = new Map<String, List<String>>();
        List<TAT_Staging_Data__Share> tatSharingList = new List<TAT_Staging_Data__Share>();
        
        for(TAT_Staging_Data__c tatStage : newTat) {
            String partnerCode = tatStage.Partner_Code__c;
            tatPartnerCodeMap.put(tatStage.Id, partnerCode.leftPad(10,'0'));
            allPartnerCode.add(partnerCode.leftPad(10,'0'));
        }
        System.debug('Checkpoint 20: ' + tatPartnerCodeMap);
        allBranch = [SELECT Id, Name, ParentId,SAP_ID__c,Type FROM Account WHERE SAP_ID__c IN :allPartnerCode];
        System.debug('Checkpoint 22: ' + allBranch);
        for(Account acct : allBranch) {
            if(acct.ParentId != null) {
                allDistributor.add(acct.ParentId);
            }
            else if(acct.Type == 'Direct Dealer') {
                allDistributor.add(acct.Id);
            }  
            partnerCOdeAccountMap.put(acct.SAP_ID__c, acct.ParentId);
        }
        System.debug('Checkpoint 32: ' + partnerCOdeAccountMap);
        allContact = [SELECT Id FROM Contact WHERE AccountId IN :allDistributor];
        allUser = [SELECT Id, Contact.AccountId FROM User WHERE ContactId IN :allContact];
        
        for(User u : allUser) {
            
            if(!accountUserMap.containskey(u.contact.AccountId)) accountUserMap.put(u.contact.AccountId, new List<String>());
            accountUserMap.get(u.contact.AccountId).add(u.Id);
        }
        
        for(String tatId : tatPartnerCodeMap.keySet()) {
            String partnerCode = tatPartnerCodeMap.get(tatId);
            String acctId;
            List<String> allUserList = new List<String>();
            if(partnerCOdeAccountMap.containsKey(partnerCode)) acctId = partnerCOdeAccountMap.get(partnerCode);
            if(accountUserMap.containsKey(acctId)) allUserList = accountUserMap.get(acctId);
            for(String userid : allUserList) {
                TAT_Staging_Data__Share sharingObj = new TAT_Staging_Data__Share();
                sharingObj.ParentId = tatId;
                sharingObj.AccessLevel = 'Edit';
                sharingObj.UserOrGroupId = userid;
                tatSharingList.add(sharingObj);
                
            }
        }
        System.debug('Checkpoint 54: ' + tatSharingList);
        Database.insert(tatSharingList, false);*/
        
        
        
    }
    
    public static void beforeUpdateHelper(List<TAT_Turnt_staging__c > tatList) {
        if(recursion == true){
          system.debug('INSIDE TAT STAGE HELPER');
			
            set<String> SAPList = new set<String>();
            for(TAT_Turnt_staging__c ttrec :tatList ){
                SAPList.add(ttrec.Distributor_Ship_To__c);
            }
            system.debug('TATLIST:'+tatList);
            system.debug('SET:'+SAPList);
            list<string> staggingFieldApi = new list<string>();
            Map<String, Object> recMap=New Map<String,Object>();
            //List<TAT_Staging_Data__c> tatList = (List<TAT_Staging_Data__c>)JSON.deserialize(tat, List<TAT_Staging_Data__c>.class);
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
            
            system.debug('Queryvariable++++'+Query );
            list<sObject> QueryResults = Database.query(Query);
            
            //List<String> apiNameList =  new List<String>();
            List<Sobject> allStagingRec =  new List<Sobject>();
            map<String,Sobject> tatStagingObjRecord = new map<String,Sobject>();
            
            for(Sobject errorId : QueryResults){
                tatStagingObjRecord.put(string.valueof(errorId.get('Id')),errorId); 
            }
            for(TAT_Turnt_staging__c TAT:tatList){
                sObject rec = Schema.getGlobalDescribe().get('TAT_Turnt_staging__c').newSObject();
                recMap= (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(TAT));
                for(String keyInstance:recMap.keyset()){
                    system.debug('keyInstance: '+keyInstance);
                    if(keyInstance!='date_cust_request_service__c'&& keyInstance!='Time_customer_desires_service_to_begin__c'&& keyInstance!='Date_Distributor_schedules_for_service__c'&& keyInstance!='Time_Distributor_schedules_for_service__c' && keyInstance != 'attributes' && keyInstance !='Id' && keyInstance!= 'LastModifiedDate' && keyInstance!='IsDeleted' && keyInstance!= 'Name' && keyInstance !='SystemModstamp' && keyInstance !='CreatedById' && keyInstance != 'Month__c' && keyInstance!='Year__c' && keyInstance != 'CreatedDate' && keyInstance != 'LastModifiedById' && keyInstance!='Error_Log__c'){
                        rec.put(keyInstance,recMap.get(keyInstance));
                    }
                }
                system.debug('recline108: '+rec);
                allStagingRec.add(rec);
            }
            //allStagingRec.add(TAT);
            //}
            
            /*for(TAT_Turnt_staging__c errorlogId : tatList){

system.debug('Line no 57'+ errorlogId.Id);
if(tatStagingObjRecord.keyset().contains(string.valueof(errorlogId.Id))){
system.debug('line number 62'+errorlogId.Id);

allStagingRec.add(tatStagingObjRecord.get(errorlogId.Id));

}
}*/
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
            set<String> regionset = new set<String>();
            regionset.add('EMEA');
            regionset.add('North America');
            regionset.add('Latin America');
            regionset.add('Asia Pacific');
            
            for(Account acc:[select id,SAP_ID__c,name from Account where Sales_RegionA__c IN :regionset AND SAP_ID__c IN :SAPList]){
                mapofacc.put(acc.SAP_ID__c,acc);
            }
            system.debug('MAP OF ACCOUNT:'+mapofacc);
            system.debug('SIZE OF MAP:'+mapofacc.size());
            
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
            //PRPC_returnRealObjClass.DeleteandUpdateRec(saveErrorDetails,allStagingRec);
            //system.debug('line 145'+ saveErrorDetails);
            //system.debug('insertRec: '+insertRec);
            //system.debug('allStagingData: '+allStagingData);
            //list<Sobject>deleteSuccessRec = new list<Sobject>();
            //list<sobject>updateRecwithErrorlog = new list<sobject>();
            //list<sobject>DeleteRec = new list<sobject>();
            
            for(integer i=0;i<saveErrorDetails.size();i++){
                system.debug('line 156: '+ saveErrorDetails[i].isSuccess());
                if(saveErrorDetails[i].isSuccess()){  
                    system.debug('enter success');
                    tatList[i].Error_Log__c = '';
                    tatRecordSet.add(tatList[i].Id);
                }
                
                else if(!saveErrorDetails[i].isSuccess()){
                    system.debug('enter error');
                    Database.Error error = saveErrorDetails.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    system.debug('line 164'+ failedDML);
                    tatList[i].Error_Log__c = failedDML;
                    //UpdateRecordSet.add(tatList[i].id);
                    //updateRecwithErrorlog.add(childRecOfDist);
                    
                }
            }
            //recursion = false;    
        }
        //DeleteRec.addAll((List<sObject>)(deleteSuccessRec));
        //update updateRecwithErrorlog;
        //delete deleteSuccessRec;
        
        
    }
    public static void deleteTatStaging() {
      
        system.debug('enter:215');
        if(recursion == true){
              system.debug('INSIDE TAT STAGE HELPER');
            system.debug('tatRecordSet :'+tatRecordSet);
            List<TAT_Turnt_staging__c> tatListToDelete = new List<TAT_Turnt_staging__c>();
            List<TAT_Turnt_staging__c> tatListToupdate= new List<TAT_Turnt_staging__c>();
            if(tatRecordSet.size()>0){
                for(Id tatId : tatRecordSet) {
                    TAT_Turnt_staging__c tatRec = new TAT_Turnt_staging__c();
                    tatRec.Id = tatId;
                    tatListToDelete.add(tatRec);
                }
            }
            if(tatListToDelete.size() > 0) {
                String hour = String.valueOf(Datetime.now().hour());
                String min = String.valueOf(Datetime.now().minute() ); 
                String ss = String.valueOf(Datetime.now().second()+6);
               // PRPC_DeleteStagingRecord.tatList = tatListToDelete;
                //parse to cron expression
               string storeName= 'Job Started At ' + String.valueOf(Datetime.now());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                if(59>=Integer.valueOf(ss)){
              
                PRPC_DeleteStagingRecord s = new PRPC_DeleteStagingRecord(); 
                s.tatList = tatListToDelete;
                s.cronName=storeName;
                System.schedule(storeName, nextFireTime, s);
                //DELETE tatListToDelete;
                }
            }
            /*system.debug('listline 212: '+[select Error_Log__c from TAT_Turnt_staging__c where id In:UpdateRecordSet]);
            if(UpdateRecordSet.size()>0){
                for(Id tatId : UpdateRecordSet){
                    TAT_Turnt_staging__c tatRec = new TAT_Turnt_staging__c();
                    tatRec.Id = tatId;
                    tatListToupdate.add(tatRec);
                }
            }
            if(tatListToupdate.size()>0){
                update tatListToupdate;
            }*/
            recursion = false;    
        }
    }
    
}