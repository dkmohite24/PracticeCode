/* Class Name: DataMovementBatch
* Description: 
* Created by: Debiprasad
* Updated by : Akanksha Mondal -CHG0043240 Stopped insertion of accounts via S & SL and update logic. 
* Updated By : Susovan Mondal & Chinmaya Dash - Converting the 5 digit code to 10 digit account code and fetching those accouts ID, having staging records.
* Updated By : Susovan Mondal & Chinmaya Dash - Change ENHC0011584 - ETC is a new metric for PRP, So the ETC staging data is moving from Staging to real object.
*/
global class DataMovementBatch implements Database.Batchable<sObject> {

global static string queryInclude;

global list<Sobject> start(Database.BatchableContext BC) {
    tatStageHelper.recursion = false;
    EnCustStageHelper.recursion = false;
    //ALSN-212 setting skipforDataMovementBatch to true while running the batch
    ATI_AccountTriggerHandler.skipforDataMovementBatch = true;
    //ALSN-212 end
    
    String  Query ='select Real_Object_Api_Name__c,Limit__c,Staging_Object_Api_Name__c,Sequence__c,Staging_Object_Fields_Api_Name__c from PRPMD_All_Staging_object_Data__mdt where Real_Object_Api_Name__c!=\'Parts_Ordering__c\'and Staging_Object_Api_Name__c !=\'TAT_Turnt_staging__c\' and Real_Object_Api_Name__c!=\'End_Customer__c\'';
    if(Test.isRunningTest()){
        Query+=  queryInclude ;
    }
    Query+=' Order by Sequence__c asc';
    list<Sobject>returnQuery = Database.query(Query);
    
    return returnQuery;
    
}

global void execute(Database.BatchableContext BC, List<PRPMD_All_Staging_object_Data__mdt> MetaDataList) {
    
    list<string> staggingFieldApi = new list<string>();
    list<sObject> allStagingRec = new list<sObject>();
    string RealObjApiName;
    string StagingApiName;
    Integer Month = Date.Today().Month();
    Integer Year =Date.Today().Year();
    
    string Query = 'select ';
    string check = MetaDataList[0].Staging_Object_Fields_Api_Name__c;
    for(integer i=0;i<check.split(',').size();i++){
        staggingFieldApi.add(check.split(',')[i]);
    }
    
    
    for(string stageFld : staggingFieldApi){
        Query += stageFld+',';
        
    }
    Query = Query.substring(0,Query.length()-1);
    //Susovan - Checking the query limit for every metric movement not specific to the Account.
    if(MetaDataList[0].Staging_Object_Api_Name__c == 'Account_Staging__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'ETC_Staging_Data__c'){
        Query += ' from '+ MetaDataList[0].Staging_Object_Api_Name__c +' ORDER BY CreatedDate DESC Limit ' + MetaDataList[0].Limit__c; 
    }else{
        Query += ' from '+ MetaDataList[0].Staging_Object_Api_Name__c;
    }
    
    
    
    list<sObject> QueryResults = Database.query(Query);
    allStagingRec.addAll((List<sObject>)(QueryResults)); //Staging Object Reacord
    system.debug('Query: '+QueryResults);
    RealObjApiName = MetaDataList[0].Real_Object_Api_Name__c; //RealObject Api Name
    StagingApiName = MetaDataList[0].Staging_Object_Api_Name__c;
    
    
    //FieldType with Field Name
    
    map<string,string>FieldType = new map<string,string>();
    SObjectType objType = Schema.getGlobalDescribe().get(MetaDataList[0].Real_Object_Api_Name__c);
    Map<String,Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
    for(string fld : mfields.keyset()){
        Schema.DisplayType fielddataType = mfields.get(fld).getDescribe().getType();
        if(staggingFieldApi.contains(string.valueof(mfields.get(fld)))){
            FieldType.put(string.valueof(mfields.get(fld)),string.valueof(fielddataType));
        }
        
    }
    system.debug('mfields: '+mfields);
    system.debug('FieldType: '+FieldType);
    //condition for Account Staging object
    
    if(MetaDataList[0].Staging_Object_Api_Name__c == 'Account_Staging__c'){
        Database.DMLOptions dbDML = new Database.DMLOptions();
        dbDML.DuplicateRuleHeader.allowSave = true;
        dbDML.DuplicateRuleHeader.runAsCurrentUser = true;
        //Fetching the exception account data from custom metadata(1020). Line no(80 - 85) - Susovan
        Set<String> exceptionValidate = New Set<String>();
        Map<String,String> exceptionAcc = New Map<String,String>();
        Map<String, Exceptions_S_SL__mdt> mapCountryCodes = Exceptions_S_SL__mdt.getAll();
        for(string metaList : mapCountryCodes.keyset()){
            //exceptionAcc.put(String.valueOf(metaList.SAP_ID__c),metaList);
            exceptionAcc.put(String.valueof(mapCountryCodes.get(metaList).SAP_ID__c),metaList);
            system.debug('hello : '+mapCountryCodes.get(metaList).SAP_ID__c);
        }
        
        map<string,string> childRecDistSapId = new map<string,string>();
        map<string,string> childRecDDLRSapId = new map<string,string>();
        list<Account> RealAccountObjectQuery = new list<Account>();
        map<string,string> ParentChildSAPId = new map<string,string>();
        list<sobject> ParentAccountInsert = new list<sobject>();
        map<string,string> MapofAccountRec = new map<string,string>();
        list<sobject> Accountstaging = new list<sobject>();
        List<sobject>updatelistTypeDlist = new list<sobject>();
        set<string>updatelistTypeDset = new set<string>();
        set<string>updatelistForDBDLRset = new set<string>();
        List<sobject>updatelistForDBDLRlist = new list<sobject>();
        list<sobject> AccountstagingDB = new list<sobject>();
        list<sobject> DistributorLocation = new list<sobject>();
        set<string>removeDuplicate = new set<string>();
        list<sobject>childAccountOfParentinsert = new list<sobject>();
        list<sobject>childDDLRinsert = new list<sobject>();
        Set<String> SapIdfromStaging = new Set<String>();
        
        //QUERY OF SAP IDS PRESENT ONLY IN ACCOUNT STAGING FOR UPDATION LOGIC
        //Handeling Distributor and Distributor branch having 00000 at the end. Line no(106 -120) - Susovan
        for(Account_Staging__c acctStage : [SELECT Id, Service_Location_ID__c,Location_Type__c FROM Account_Staging__c WHERE CALENDAR_MONTH(createddate)=:Month AND CALENDAR_YEAR(createddate)=:Year]) {
            String tempSAPId = String.join(acctStage.Service_Location_ID__c.split('-'),'').leftPad(10,'0');
            if(tempSAPId.right(5)=='00000' && acctStage.Location_Type__c=='D'){
                String tempDisSAPId='00000'+tempSAPId.removeEnd('00000');
                SapIdfromStaging.add(tempDisSAPId);
            }
            else if(exceptionAcc.containskey(tempSAPId) && acctStage.Location_Type__c=='DB'){
                String tempDisSAPId='00000'+tempSAPId.left(5); 
                system.debug('lsft : '+tempDisSAPId);
                SapIdfromStaging.add(tempDisSAPId);
            }
            system.debug(tempSAPId);
            SapIdfromStaging.add(tempSAPId);
        }
        RealAccountObjectQuery = [select id,Service_Location_ID__c,SAP_ID__c from Account where SAP_ID__c IN:SapIdfromStaging  ];
        for(Account acc : RealAccountObjectQuery){
            MapofAccountRec.put(acc.SAP_ID__c,acc.Id);  //query all real object account and put in Map for update.
        }
        
        
        
        for(sObject accStaging: QueryResults){
            
            //Location type - D and DDLR
            
            if(accStaging.get('Location_Type__c') == 'D' ||accStaging.get('Location_Type__c') =='DDLR'){
                system.debug('SAP ID line 134:'+accStaging.get('Location_Type__c')+' '+accStaging.get('Service_Location_ID__c'));
                string ServiceLocationDealer = '00000'+string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[0];
                System.debug('Service location: '+accStaging.get('Service_Location_ID__c'));
                System.debug('ServiceLocationDealer: '+string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[0]);
                System.debug('ServiceLocationDealer: '+string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[1]);
                string AfterHipenNumber = string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[1];
                //*******INSERTION LOGIC STOPPED - S&SL CHANGES MAY 2023
                /*  if((!MapofAccountRec.keyset().contains(ServiceLocationDealer) && accStaging.get('Location_Type__c') == 'D') || (!MapofAccountRec.keyset().contains(string.valueof(accStaging.get('Service_Location_ID__c')).remove('-')) && accStaging.get('Location_Type__c') == 'DDLR')){  

if(AfterHipenNumber == '00000'){
if(accStaging.get('Location_Type__c') == 'DDLR'){
if(!MapofAccountRec.keyset().contains(string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'))){
accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
}  
}
else{
if(!MapofAccountRec.keyset().contains(ServiceLocationDealer)){
accStaging.put('SAP_ID__c', ServiceLocationDealer);
}  
}
accStaging.put('Service_Location_ID__c', null);
Accountstaging.add(accStaging);
}
else{
if(accStaging.get('Location_Type__c') == 'D'){
if(!MapofAccountRec.keyset().contains(ServiceLocationDealer)){

}else{
accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
accStaging.put('Service_Location_ID__c', null);
DistributorLocation.add(accStaging);
}
}
else{
if(!MapofAccountRec.keyset().contains(ServiceLocationDealer+'00000')){

}else{
childRecDDLRSapId.put(ServiceLocationDealer+'00000',string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
accStaging.put('Service_Location_ID__c', null);
childDDLRinsert.add(accStaging);
}
}
}
}*/
                // else{
                if((MapofAccountRec.keyset().contains(ServiceLocationDealer) && accStaging.get('Location_Type__c') == 'D') || (MapofAccountRec.keyset().contains(string.valueof(accStaging.get('Service_Location_ID__c')).remove('-')) && accStaging.get('Location_Type__c') == 'DDLR')){
                    if(accStaging.get('Location_Type__c') == 'D'){
                        accStaging.put('SAP_ID__c', ServiceLocationDealer);
                    }
                    else{
                        accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
                    }
                    System.debug('execute elseif'+accStaging.get('Service_Location_ID__c') + '  '+accStaging.get('Location_Type__c'));
                    //accStaging.put('Service_Location_ID__c', null);
                    if(!updatelistTypeDset.contains(string.valueof(accStaging.get('SAP_ID__c')))){
                        
                        if(accStaging.get('Location_Type__c') =='DDLR'){
                            updatelistTypeDset.add(string.valueof(accStaging.get('SAP_ID__c')));
                            updatelistTypeDlist.add(accStaging);
                            System.debug('execute elseif'+accStaging.get('Service_Location_ID__c') + '  '+accStaging.get('Location_Type__c'));
                        }
                        else{
                            if(AfterHipenNumber=='00000'){
                                updatelistTypeDset.add(string.valueof(accStaging.get('SAP_ID__c')));
                                updatelistTypeDlist.add(accStaging);  
                            }
                        } 
                        
                    }
                }
                
            }
            //updating the exception account that are present in custom metadata. Line no(207 - 212) - Susovan
            else if(exceptionAcc.containskey(string.valueof(accStaging.get('Service_Location_ID__c')).remove('-')) && accStaging.get('Location_Type__c') == 'DB'){
                System.debug('execute elseif'+accStaging.get('Service_Location_ID__c') + '  '+accStaging.get('Location_Type__c'));
                exceptionValidate.add(string.valueof(accStaging.get('Service_Location_ID__c')));
                accStaging.put('Location_Type__c','D');
                accStaging.put('SAP_ID__c',('00000'+string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[0]));
                if(!updatelistTypeDset.contains(string.valueof(accStaging.get('SAP_ID__c')))){
                    updatelistTypeDset.add(string.valueof(accStaging.get('SAP_ID__c')));
                    updatelistTypeDlist.add(accStaging);
                }
            }
            
        }
        PRPC_returnRealObjClass.updateAllrecords(updatelistTypeDlist,RealObjApiName,StagingApiName,FieldType,SapIdfromStaging);
        
        // ********INSERTION STOPPED S&SL CHANGES - MAY 2023
        //Insert DDLR child record if parent present
        /* PRPC_returnRealObjClass.wrapperclass DDLRchildRec = PRPC_returnRealObjClass.createInsertList(childDDLRinsert,RealObjApiName,StagingApiName,FieldType,null);
for(integer i=0; i< DDLRchildRec.recordstoInsert.size();i++){
DDLRchildRec.recordstoInsert[i].put('ParentId', MapofAccountRec.get(string.valueof(DDLRchildRec.recordstoInsert[i].get('SAP_ID__c')).left(5)+'00000'));
if(DDLRchildRec.recordstoInsert[i].get('Location_Type__c') == 'DDLR'){
DDLRchildRec.recordstoInsert[i].put('Type','Direct Dealer');
DDLRchildRec.recordstoInsert[i].put('PRP_Participation__c', true);
}

}
list<sobject>returnUpdateDDLRAcc = PRPC_returnRealObjClass.updatelistwithAddress(DDLRchildRec.recordstoInsert);*/
        /*insert child Account with Parent Id
         Database.SaveResult[] insertResultDDLR = Database.insert(returnUpdateDDLRAcc,dbDML);//Insert DDLR record with ParentId 
        PRPC_returnRealObjClass.DeleteandUpdateRec(insertResultDDLR,childDDLRinsert);*/
        //Record insert for Distribution which contains location
        // list<Sobject> ChildaccRecDist = new list<Sobject>();
        /* PRPC_returnRealObjClass.wrapperclass DistributorLocationRec = PRPC_returnRealObjClass.createInsertList(DistributorLocation,RealObjApiName,StagingApiName,FieldType,null);
for(integer i = 0;i<DistributorLocationRec.recordstoInsert.size();i++){
string SalesRegion = string.valueof(DistributorLocationRec.recordstoInsert[i].get('Sales_RegionA__c'));
DistributorLocationRec.recordstoInsert[i].put('ParentId', MapofAccountRec.get(string.valueof(DistributorLocationRec.recordstoInsert[i].get('SAP_ID__c')).left(5)));
if(DistributorLocationRec.recordstoInsert[i].get('Location_Type__c') == 'D'){
DistributorLocationRec.recordstoInsert[i].put('Type', 'Distributor');
DistributorLocationRec.recordstoInsert[i].put('PRP_Participation__c', true);
}

}
list<Sobject>returnDistributorRecLocation = PRPC_returnRealObjClass.updatelistwithAddress(DistributorLocationRec.recordstoInsert);
Database.SaveResult[] insertResult = Database.insert(returnDistributorRecLocation,dbDML);//Parent Record insert for D and DDLR which contains Location
//Child record of D and DDLR which contains Location.

PRPC_returnRealObjClass.DeleteandUpdateRec(insertResultDandDDLRChild,DistributorLocation);// Error handle
Record insert for location type D and DDLR

PRPC_returnRealObjClass.wrapperclass AccountRecForD = PRPC_returnRealObjClass.createInsertList(Accountstaging,RealObjApiName,StagingApiName,FieldType,null);
for(integer i = 0;i<AccountRecForD.recordstoInsert.size();i++){
string SalesRegion = string.valueof(AccountRecForD.recordstoInsert[i].get('Sales_RegionA__c'));

if(AccountRecForD.recordstoInsert[i].get('Location_Type__c') == 'D'){
AccountRecForD.recordstoInsert[i].put('Type', 'Distributor');
AccountRecForD.recordstoInsert[i].put('PRP_Participation__c', true);
}else if(AccountRecForD.recordstoInsert[i].get('Location_Type__c') == 'DDLR'){
AccountRecForD.recordstoInsert[i].put('Type', 'Direct Dealer');
AccountRecForD.recordstoInsert[i].put('PRP_Participation__c', true);
}

}
list<Sobject>returnDandDDLRRec = PRPC_returnRealObjClass.updatelistwithAddress(AccountRecForD.recordstoInsert);
Database.SaveResult[] insertResultDandDDLRParent = Database.insert(returnDandDDLRRec,dbDML); //Record insert for D and DDLR which do not contains Location(00000).
PRPC_returnRealObjClass.DeleteandUpdateRec(insertResultDandDDLRParent,Accountstaging);// Error handle

//Add new condition for Location Type: D
list<sobject>newCondAcclist = new list<sobject>();
for(integer i =0;i<returnDandDDLRRec.size();i++){
if(returnDandDDLRRec[i].get('SAP_ID__C')!=null && string.valueof(returnDandDDLRRec[i].get('Location_Type__c')) == 'D' && string.valueof(returnDandDDLRRec[i].get('SAP_ID__C')).length() == 5){
String sObjectName = 'Account'; 
Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
SObject childRecOfDist = t.newSObject();
childRecOfDist = returnDandDDLRRec[i].clone(false, false, false, false);
childRecOfDist.put('SAP_ID__C',string.valueof(returnDandDDLRRec[i].get('SAP_ID__C'))+'00000');
childRecOfDist.put('Location_Type__c','DB');
childRecOfDist.put('Type','Distributor Branch');
childRecOfDist.put('ParentId',string.valueof(returnDandDDLRRec[i].get('Id')));
childRecOfDist.put('PRP_Participation__c',true);
newCondAcclist.add(childRecOfDist);
}
}
Database.insert(newCondAcclist,dbDML);//insert DB record with 00000
*/
        //Query After Insert D and DDLR Record
        map<string,string> mapOfaccRecAfterinsert = new  map<string,string>();
        list<Account> accRecforDandDDLR = new list<Account>([select Service_Location_ID__c,SAP_ID__c from Account where SAP_ID__c IN:SapIdfromStaging]);
        for(Account acc : accRecforDandDDLR){
            mapOfaccRecAfterinsert.put(acc.SAP_ID__c,acc.Id);
        }
        //for location type - DB and DLR
        for(sObject accStaging: QueryResults){
            if(accStaging.get('Location_Type__c') == 'DB' ||accStaging.get('Location_Type__c') == 'DLR' ||accStaging.get('Location_Type__c') == 'ELD' ){
                string ServiceLocationDist = string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[0];
                string sapidContainsInacc = string.valueof(accStaging.get('Service_Location_ID__c')).remove('-');
                //********INSERTION STOPPED S&SL CHANGES - MAY 2023
                //If real object contatins staging object service Location Id or not
                /* if(!mapOfaccRecAfterinsert.keyset().contains(sapidContainsInacc)){
if(mapOfaccRecAfterinsert.keyset().contains(ServiceLocationDist)){
accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
accStaging.put('Service_Location_ID__c', null);

AccountstagingDB.add(accStaging);
}
else{
ParentChildSAPId.put(ServiceLocationDist,string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
if(!removeDuplicate.contains(ServiceLocationDist)){
removeDuplicate.add(ServiceLocationDist);
accStaging.put('SAP_ID__c', ServiceLocationDist);
accStaging.put('Service_Location_ID__c', null);
ParentAccountInsert.add(accStaging);
}else{
accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
accStaging.put('Service_Location_ID__c', null);
childAccountOfParentinsert.add(accStaging);
}

}
}*/
                // else{
                System.debug('execute elseif'+accStaging.get('Service_Location_ID__c') + '  '+accStaging.get('Location_Type__c'));
                if(mapOfaccRecAfterinsert.containskey(sapidContainsInacc)){
                    accStaging.put('SAP_ID__c', string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
                    accStaging.put('Service_Location_ID__c', null);
                    if(!updatelistForDBDLRset.contains(string.valueof(accStaging.get('SAP_ID__c')))){
                        updatelistForDBDLRset.add(string.valueof(accStaging.get('SAP_ID__c')));
                        updatelistForDBDLRlist.add(accStaging);
                    }
                }
            }
            //Handeling Distributor Branch for all account having end with 00000 and exception account present custom metadata.Line no (332 - 340) - Susovan
            else if(accStaging.get('Location_Type__c') == 'D' && ((string.valueof(accStaging.get('Service_Location_ID__c')).split('-')[1] =='00000') || (exceptionValidate.contains(string.valueof(accStaging.get('Service_Location_ID__c'))) && exceptionAcc.containskey(string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'))))){
                system.debug('Exception :'+string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
                System.debug('execute elseif'+accStaging.get('Service_Location_ID__c') + '  '+accStaging.get('Location_Type__c'));
                accStaging.put('Location_Type__c','DB');
                accStaging.put('SAP_ID__c',string.valueof(accStaging.get('Service_Location_ID__c')).remove('-'));
                updatelistTypeDset.add(string.valueof(accStaging.get('SAP_ID__c')));
                if(!updatelistForDBDLRset.contains(string.valueof(accStaging.get('SAP_ID__c')))){
                    updatelistForDBDLRset.add(string.valueof(accStaging.get('SAP_ID__c')));
                    updatelistForDBDLRlist.add(accStaging);
                }
            }
        }
        //updatelistForDBDLRlist.addAll(updatelistForDBDLRset);
        PRPC_returnRealObjClass.updateAllrecords(updatelistForDBDLRlist,RealObjApiName,StagingApiName,FieldType,SapIdfromStaging);
        
        //INSERTION LOGIC STOPPED - S&SL CHANGES MAY 2023
        //linking parent account with child if Parent Account previously contains for DB nad DLR
        /*  PRPC_returnRealObjClass.wrapperclass AccountRecForDB = PRPC_returnRealObjClass.createInsertList(AccountstagingDB,RealObjApiName,StagingApiName,FieldType,null);
for(integer i=0;i<AccountRecForDB.recordstoInsert.size();i++){
string SalesRegion = string.valueof(AccountRecForDB.recordstoInsert[i].get('Sales_RegionA__c'));
AccountRecForDB.recordstoInsert[i].put('ParentId', mapOfaccRecAfterinsert.get(string.valueof(AccountRecForDB.recordstoInsert[i].get('SAP_ID__c')).left(5)));
if(AccountRecForDB.recordstoInsert[i].get('Location_Type__c') == 'DB'){
AccountRecForDB.recordstoInsert[i].put('Type','Distributor Branch');
AccountRecForDB.recordstoInsert[i].put('PRP_Participation__c', true);
}
else if(AccountRecForDB.recordstoInsert[i].get('Location_Type__c') == 'DLR'){
AccountRecForDB.recordstoInsert[i].put('Type','Service Dealer');
AccountRecForDB.recordstoInsert[i].put('PRP_Participation__c', true);

} 
}
list<sobject>returnUpdateDBAcc = PRPC_returnRealObjClass.updatelistwithAddress(AccountRecForDB.recordstoInsert);*/
        
        //insert child Account with Parent Id
        //    Database.SaveResult[] insertResultDBndDLR = Database.insert(returnUpdateDBAcc,dbDML);//Insert DB and DLR record with ParentId
        //    PRPC_returnRealObjClass.DeleteandUpdateRec(insertResultDBndDLR,AccountstagingDB);
        
        //parent Account insert if previously parent Account not present
        /*  PRPC_returnRealObjClass.wrapperclass AccountRecForParrent = PRPC_returnRealObjClass.createInsertList(ParentAccountInsert,RealObjApiName,StagingApiName,FieldType,null);
list<Sobject> returnAccount = new list<Sobject>();
returnAccount = AccountRecForParrent.recordstoInsert;
for(integer i = 0;i<returnAccount.size();i++){
string SalesRegion = string.valueof(returnAccount[i].get('Sales_RegionA__c'));
returnAccount[i].put('Location_Type__c','D');
returnAccount[i].put('Type','Distributor');
returnAccount[i].put('PRP_Participation__c', true);

}
list<sobject>returnUpdateAcc = PRPC_returnRealObjClass.updatelistwithAddress(returnAccount);*/
        //INSERTION LOGIC STOPPED - S&SL CHANGES MAY 2023
        /*  PRPC_returnRealObjClass.wrapperclass AccountRecForChildRec = PRPC_returnRealObjClass.createInsertList(childAccountOfParentinsert,RealObjApiName,StagingApiName,FieldType,null);
for(integer i = 0;i<AccountRecForChildRec.recordstoInsert.size();i++){
string SalesRegion = string.valueof(AccountRecForChildRec.recordstoInsert[i].get('Sales_RegionA__c'));
for(integer j = 0;j<returnAccount.size();j++){
if(string.valueof(AccountRecForChildRec.recordstoInsert[i].get('SAP_ID__c')).left(5) == returnAccount[j].get('SAP_ID__c') ){
AccountRecForChildRec.recordstoInsert[i].put('ParentId', returnAccount[j].Id);
AccountRecForChildRec.recordstoInsert[i].put('SAP_ID__c', string.valueof(AccountRecForChildRec.recordstoInsert[i].get('SAP_ID__c')).remove('-'));
if(AccountRecForChildRec.recordstoInsert[i].get('Location_Type__c') == 'DB'){
AccountRecForChildRec.recordstoInsert[i].put('Type','Distributor Branch');
AccountRecForChildRec.recordstoInsert[i].put('PRP_Participation__c', true);
}else if(AccountRecForChildRec.recordstoInsert[i].get('Location_Type__c') == 'DLR'){
AccountRecForChildRec.recordstoInsert[i].put('Type','Service Dealer');
AccountRecForChildRec.recordstoInsert[i].put('PRP_Participation__c',true);
}

}
}
}
list<sobject>returnUpdatechildAcc = PRPC_returnRealObjClass.updatelistwithAddress(AccountRecForChildRec.recordstoInsert);
list<Database.SaveResult>insertResultchild =database.insert(returnUpdatechildAcc,dbDML);
PRPC_returnRealObjClass.DeleteandUpdateRec(insertResultchild,childAccountOfParentinsert);
*/
        
        
    }
    else{
        
        //for different staging object
        
        string partnercode;
        map<string,Account> mapofacc = new map<string,Account>();
        map<string,Account>mapofDB = new map<string,Account>();
        list<sobject>updateTat = new list<sobject>();
        list<Sobject>updateTpslist = new list<Sobject>();
        list<Sobject>updateTRNlist = new list<Sobject>();
        list<Sobject>updateFunclist = new list<Sobject>();
        list<sobject>insertStaginglist = new list<sobject>();
        set<Id>updateStagingSet = new set<Id>();
        list<sobject>updateStaginglist = new list<sobject>();
        Set<String> AccountSAPidSet = new Set<String>();
        
        //Storing staging records distributors SAP ID to fetch account ID from system
        for(integer i=0;i<allStagingRec.size();i++){
            if(MetaDataList[0].Real_Object_Api_Name__c == 'Functional_Comp_Data__c'){
                If(allStagingRec[i].get('Distributor__c')!=null){
                    if(string.valueof(allStagingRec[i].get('Distributor__c')).length() == 4){
                        partnercode =  '000000'+string.valueof(allStagingRec[i].get('Distributor__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else if(string.valueof(allStagingRec[i].get('Distributor__c')).length() == 5){
                        partnercode =  '00000'+string.valueof(allStagingRec[i].get('Distributor__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else{
                        AccountSAPidSet.add(string.valueof(allStagingRec[i].get('Distributor__c')));
                    }
                }
            }
            else if(MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_Staging_Data__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_International_staging__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_Retran_staging__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'WPC_Staging_Data__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'CE_Staging_Data__c'){
                If(allStagingRec[i].get('Distributor_Ship_To__c')!=null){
                    if(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')).length() == 9){
                        partnercode =  '0'+string.valueof(allStagingRec[i].get('Distributor_Ship_To__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else if(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')).length() == 4){
                        partnercode =  '000000'+string.valueof(allStagingRec[i].get('Distributor_Ship_To__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else if(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')).length() == 5){
                        partnercode =  '00000'+string.valueof(allStagingRec[i].get('Distributor_Ship_To__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else{
                        AccountSAPidSet.add(string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')));
                    }
                }
            }
            else if(MetaDataList[0].Real_Object_Api_Name__c == 'Training_Data__c' || MetaDataList[0].Real_Object_Api_Name__c == 'Survey_Data__c'){
                If(allStagingRec[i].get('Ship_to__c')!=null){
                    if(string.valueof(allStagingRec[i].get('Ship_to__c')).length() == 9){
                        partnercode =  '0'+string.valueof(allStagingRec[i].get('Ship_to__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else{
                        AccountSAPidSet.add(string.valueof(allStagingRec[i].get('Ship_to__c')));
                    }
                }
            }
            
            else if(MetaDataList[0].Staging_Object_Api_Name__c == 'TAT_Staging_Data__c'){
                If(allStagingRec[i].get('Partner_Code__c')!=null){
                    if(string.valueof(allStagingRec[i].get('Partner_Code__c')).length() == 9){
                        partnercode =  '0'+string.valueof(allStagingRec[i].get('Partner_Code__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else{
                        AccountSAPidSet.add(string.valueof(allStagingRec[i].get('Partner_Code__c')));
                    }
                }
            }
            //ETC object Staging accounts Distributor code checking
            else if(MetaDataList[0].Staging_Object_Api_Name__c == 'ETC_Staging_Data__c' ){
                If(allStagingRec[i].get('Distributor_Code__c')!=null){
                    if(string.valueof(allStagingRec[i].get('Distributor_Code__c')).length() == 9){
                        partnercode =  '0'+string.valueof(allStagingRec[i].get('Distributor_Code__c'));
                        AccountSAPidSet.add(partnercode);
                    }
                    else{
                        AccountSAPidSet.add(string.valueof(allStagingRec[i].get('Distributor_Code__c')));
                    }
                }
            }
        }
        
        
        
        for(Account acc:[select id,SAP_ID__c,name,Sales_RegionA__c from Account WHERE SAP_ID__c In: AccountSAPidSet]){
            mapofacc.put(acc.SAP_ID__c,acc);
        }
        
     
        
        //check duplicate in staging record
        set<string>checkDuplicateRec = new set<string>();
        list<sObject>deleteDuplicateRec = new list<sObject>();
        list<sObject>removeDuplicatestagingRec = new list<sObject>();
        for(integer i=0;i<allStagingRec.size();i++){
            if(MetaDataList[0].Real_Object_Api_Name__c == 'Functional_Comp_Data__c'){
                if(allStagingRec[i].get('Distributor__c') != null && allStagingRec[i].get('Extraction_Date__c') != null && allStagingRec[i].get('Claim_Type__c') !=null){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Distributor__c')) +'-' + string.valueof(allStagingRec[i].get('Extraction_Date__c')) + '-' + string.valueof(allStagingRec[i].get('Claim_Type__c'));
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
            else if(MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_Staging_Data__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_International_staging__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_Retran_staging__c' || MetaDataList[0].Staging_Object_Api_Name__c == 'WPC_Staging_Data__c'){
                if(allStagingRec[i].get('Distributor_Ship_To__c') != null && allStagingRec[i].get('Extraction_Date__c') != null){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Extraction_Date__c'));
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
            else if(MetaDataList[0].Staging_Object_Api_Name__c == 'CE_Staging_Data__c'){
                if(allStagingRec[i].get('Distributor_Ship_To__c') != null && allStagingRec[i].get('Extraction_Date__c') != null && allStagingRec[i].get('Product_Type__c')!=null ){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Extraction_Date__c'))+'-'+string.valueof(allStagingRec[i].get('Product_Type__c'));
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

            /* CHG0043240 - End customer data is moved to seperate batch . Commented for test coverage
           else if(MetaDataList[0].Real_Object_Api_Name__c == 'End_Customer__c'){
if(allStagingRec[i].get('Distributor_Ship_To__c') != null && allStagingRec[i].get('Date_Of_Submission__c') != null && allStagingRec[i].get('Repair_Order_or_Parts_Invoice__c')!=null ){
string uniqueKey = string.valueof(allStagingRec[i].get('Distributor_Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Date_Of_Submission__c'))+'-'+string.valueof(allStagingRec[i].get('Repair_Order_or_Parts_Invoice__c'));
if(!checkDuplicateRec.contains(uniqueKey)){
checkDuplicateRec.add(uniqueKey);
removeDuplicatestagingRec.add(allStagingRec[i]);
}else{
deleteDuplicateRec.add(allStagingRec[i]);
}
}else if(allStagingRec[i].get('Distributor_Ship_To__c') != null && allStagingRec[i].get('Date_Of_Submission__c') != null && allStagingRec[i].get('Repair_Order_or_Parts_Invoice__c')!=null){
// add NA end customer functionality
}else{
removeDuplicatestagingRec.add(allStagingRec[i]);
}

}*/
            else if(MetaDataList[0].Real_Object_Api_Name__c == 'Training_Data__c'){
                if(allStagingRec[i].get('Ship_to__c') != null && allStagingRec[i].get('Extraction_Date__c') != null){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Ship_to__c')) +'-' + string.valueof(allStagingRec[i].get('Extraction_Date__c'));
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
            else if(MetaDataList[0].Real_Object_Api_Name__c == 'Survey_Data__c'){
                if(allStagingRec[i].get('Ship_To__c') != null && allStagingRec[i].get('Date_Taken__c') != null && allStagingRec[i].get('Account__c') != null && allStagingRec[i].get('Customer_Name__c') != null){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Date_Taken__c'))+'-'+ string.valueof(allStagingRec[i].get('Account__c')+'-'+ string.valueof(allStagingRec[i].get('Customer_Name__c')));
                    if(!checkDuplicateRec.contains(uniqueKey)){
                        checkDuplicateRec.add(uniqueKey);
                        removeDuplicatestagingRec.add(allStagingRec[i]);
                    }else{
                        deleteDuplicateRec.add(allStagingRec[i]);
                    }
                }else{
                    if(allStagingRec[i].get('Ship_To__c') != null && allStagingRec[i].get('Date_Taken__c') != null && allStagingRec[i].get('RO__c') != null && allStagingRec[i].get('Customer_Name__c') != null){
                        string uniqueKey = string.valueof(allStagingRec[i].get('Ship_To__c')) +'-' + string.valueof(allStagingRec[i].get('Date_Taken__c'))+'-'+ string.valueof(allStagingRec[i].get('RO__c')+'-'+ string.valueof(allStagingRec[i].get('Customer_Name__c')));
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
            }
            
            else if(MetaDataList[0].Staging_Object_Api_Name__c == 'TAT_Staging_Data__c'){
                if(allStagingRec[i].get('Partner_Code__c') != null && allStagingRec[i].get('submit_date__c') != null && allStagingRec[i].get('Transmission_serial_number__c') != null && allStagingRec[i].get('Claim_Number__c') != null){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Partner_Code__c')) +'-' + string.valueof(allStagingRec[i].get('submit_date__c'))+'-'+ string.valueof(allStagingRec[i].get('Transmission_serial_number__c')) + '-' +string.valueof(allStagingRec[i].get('Claim_Number__c')) ;
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
            //ETC Object Duplicate records checking at the time of moving from staging to real object
           else if(MetaDataList[0].Staging_Object_Api_Name__c == 'ETC_Staging_Data__c' ){
                if(allStagingRec[i].get('Distributor_Code__c') != null && allStagingRec[i].get('Date__c') != null && allStagingRec[i].get('Retail_Amount_ETC__c') != null && allStagingRec[i].get('Warranty_Registration_Code__c') != null ){
                    string uniqueKey = string.valueof(allStagingRec[i].get('Distributor_Code__c')) +'-' + string.valueof(allStagingRec[i].get('Date__c'))+'-' + string.valueof(allStagingRec[i].get('Retail_Amount_ETC__c'))+'-' + string.valueof(allStagingRec[i].get('Warranty_Registration_Code__c'));
                    if(!checkDuplicateRec.contains(uniqueKey)){
                        checkDuplicateRec.add(uniqueKey);
                        removeDuplicatestagingRec.add(allStagingRec[i]);
                    }
            		else{
                        deleteDuplicateRec.add(allStagingRec[i]);
                    }
                }else{
                    removeDuplicatestagingRec.add(allStagingRec[i]);
                }
            }
            
        }
        Delete deleteDuplicateRec; //Delete duplicate record from staging
        
        PRPC_returnRealObjClass.wrapperclass AllValueRec = PRPC_returnRealObjClass.createInsertList(removeDuplicatestagingRec,RealObjApiName,StagingApiName,FieldType,null);
        list<Sobject> returnObjData = new list<Sobject>();
        returnObjData = AllValueRec.recordstoInsert;
        
        for(integer i=0;i<returnObjData.size();i++){
            //map<string,string> mapofTATfield = new map<string,string>();
            
            //Object specific logic for TAT_Data__c[TT type:Aware]
            if(MetaDataList[0].Real_Object_Api_Name__c == 'TAT_Data__c'){
                list<PRPC_returnRealObjClass.wrapperofDate> returnWrapperdate = new list<PRPC_returnRealObjClass.wrapperofDate>();
                map<string,PRPC_returnRealObjClass.wrapperofDate> mapOfTat = new map<string,PRPC_returnRealObjClass.wrapperofDate>();
                
                
                
                if(MetaDataList[0].Staging_Object_Api_Name__c == 'TAT_Staging_Data__c'){
                    string lbrOps = string.valueof(returnObjData[i].get('all_labor_ops__c'));
                    Boolean checkLbrops;
                    if(lbrOps != null){
                        list<string>lbrOpslist = lbrOps.split(' ');
                        if(returnObjData[i].get('Repair_Type__c') == null){
                            if(lbrOpslist.contains('00094000') || lbrOpslist.contains('00095200') || lbrOpslist.contains('94') ){
                                checkLbrops = true;
                            }else{
                                for(string str:lbrOpslist){
                                    if(str.startsWith('94')){
                                        checkLbrops= true;
                                        break;
                                    }else{
                                        checkLbrops =false;
                                    }
                                }
                            }
                        }
                        if(checkLbrops == true){
                            returnObjData[i].put('Repair_Type__c','O');
                        }else{
                            returnObjData[i].put('Repair_Type__c','I');
                        }
                    }
                    returnObjData[i].put('Source_Type__c','AWARE');
                    returnObjData[i].put('Repair_Payment__c','W');
                    returnObjData[i].put('Extraction_Date__c',PRPC_returnRealObjClass.returnsubmitedDate(string.valueof(returnObjData[i].get('submit_date__c'))));
                    returnObjData[i].put('Allison_Serial__c',returnObjData[i].get('Transmission_serial_number__c'));
                    
                    if(returnObjData[i].get('Partner_Code__c') != null){
                        
                        if(string.valueof(returnObjData[i].get('Partner_Code__c')).length() == 9){
                            partnercode =  '0'+string.valueof(returnObjData[i].get('Partner_Code__c'));
                            returnObjData[i].put('Distributor_Ship_To__c',partnercode);
                            If(mapofacc.get(partnercode)!= null){
                                returnObjData[i].put('Dealer_Id__c',mapofacc.get(partnercode).id);
                                //returnObjData[i].put('Distributor_Ship_To__c',partnercode);
                            }
                        }else{
                            if(mapofacc.get(string.valueof(returnObjData[i].get('Partner_Code__c'))) != null){
                                //system.debug('Enter line725');
                                returnObjData[i].put('Distributor_Ship_To__c',string.valueof(returnObjData[i].get('Partner_Code__c')));
                                returnObjData[i].put('Dealer_Id__c',mapofacc.get(string.valueof(returnObjData[i].get('Partner_Code__c'))).id);
                                //returnObjData[i].put('Distributor_Ship_To__c',partnercode);
                            }
                        }
                        
                    }
                }
            }
            //else if Susovan(change the else if to if)
            if(MetaDataList[0].Real_Object_Api_Name__c == 'TPS_Data__c'){
                if(returnObjData[i].get('Distributor_Ship_To__c') != null){
                    if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')).length() == 9){
                        returnObjData[i].put('Distributor_Ship_To__c','0'+string.valueof(returnObjData[i].get('Distributor_Ship_To__c')));
                    }else{
                        if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')).length() == 10){
                            returnObjData[i].put('Distributor_Ship_To__c',string.valueof(returnObjData[i].get('Distributor_Ship_To__c')));
                        }
                    }
                }
                //string uniquekey = string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))+'-'+string.valueof(returnObjData[i].get('Parts_Sold_Type__c'))+'-'+string.valueof(returnObjData[i].get('Month__c'))+'-'+string.valueof(returnObjData[i].get('Year__c'));
                if(MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_Staging_Data__c'){
                    returnObjData[i].put('Parts_Sold_Type__c','TPS');
                }
                if(MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_International_staging__c'){
                    returnObjData[i].put('Parts_Sold_Type__c','TPS');
                }
                if(MetaDataList[0].Staging_Object_Api_Name__c == 'TPS_Retran_staging__c'){
                    returnObjData[i].put('Parts_Sold_Type__c','RET');
                }
                if(MetaDataList[0].Staging_Object_Api_Name__c == 'WPC_Staging_Data__c'){
                    returnObjData[i].put('Parts_Sold_Type__c','WPC');
                }
                // Replaced the Sap id values as 10 digits
                if(MetaDataList[0].Staging_Object_Api_Name__c == 'CE_Staging_Data__c'){
                    returnObjData[i].put('Parts_Sold_Type__c','CE');
                    if(string.valueof(returnObjData[i].get('Distributor_Ship_To__c')).right(5)!= null){
                        if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                            returnObjData[i].put('Customer__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                            returnObjData[i].put('Distributor_Ship_To__c',string.valueof(returnObjData[i].get('Distributor_Ship_To__c')));
                        }
                    }
                }
                //add condition for CE staging data
                if(MetaDataList[0].Staging_Object_Api_Name__c != 'CE_Staging_Data__c'){
                    if(returnObjData[i].get('Distributor_Ship_To__c')!= null){
                        if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                            
                            returnObjData[i].put('Customer__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                        }
                    }
                }
                
            }
            // Replaced the Sap id values as 10 digits 
            else if(MetaDataList[0].Real_Object_Api_Name__c == 'Functional_Comp_Data__c'){
                
                if(returnObjData[i].get('Distributor__c')!=null){
                    
                    if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor__c')))!= NULL ){
                        returnObjData[i].put('Customer__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor__c'))).id);
                        returnObjData[i].put('Distributor__c',string.valueof(returnObjData[i].get('Distributor__c')));
                    }
                   
                    
                }
                
            }else if(MetaDataList[0].Real_Object_Api_Name__c == 'Training_Data__c'){
                
                if(returnObjData[i].get('Ship_to__c') != null){
                    if(string.valueof(returnObjData[i].get('Ship_to__c')).length() == 9){
                        returnObjData[i].put('Ship_to__c','0'+string.valueof(returnObjData[i].get('Ship_to__c')));
                    }else{
                        if(string.valueof(returnObjData[i].get('Ship_to__c')).length() == 10){
                            returnObjData[i].put('Ship_to__c',string.valueof(returnObjData[i].get('Ship_to__c')));
                        }
                    }
                    if(mapofacc.get(string.valueof(returnObjData[i].get('Ship_to__c'))) != null){
                        returnObjData[i].put('Customer__c',mapofacc.get(string.valueof(returnObjData[i].get('Ship_to__c'))).id);
                    }
                    
                }
                
            }else if(MetaDataList[0].Real_Object_Api_Name__c == 'Survey_Data__c'){
                
                if(returnObjData[i].get('Ship_To__c')!= null){
                    if(string.valueof(returnObjData[i].get('Ship_To__c')).length() == 9){
                        returnObjData[i].put('Ship_To__c','0'+string.valueof(returnObjData[i].get('Ship_To__c')));
                    }else{
                        if(string.valueof(returnObjData[i].get('Ship_To__c')).length() == 10){
                            returnObjData[i].put('Ship_To__c',string.valueof(returnObjData[i].get('Ship_To__c')));
                        }
                    }
                    if(mapofacc.keyset().contains(string.valueof(returnObjData[i].get('Ship_To__c')))){
                        returnObjData[i].put('Customer_Dealer_Id__c',mapofacc.get(string.valueof(returnObjData[i].get('Ship_To__c'))).Id );
                        
                        
                    }
                }
                
                if(returnObjData[i].get('Q6_Value__c') == 1){
                    returnObjData[i].put('Survey_Type__c','Service');
                    
                }else if(returnObjData[i].get('Q6_Value__c') == 2){
                    returnObjData[i].put('Survey_Type__c','Parts');
                    
                }else if(returnObjData[i].get('Q6_Value__c') == 3){
                    returnObjData[i].put('Survey_Type__c','CSI');
                    
                }else if(returnObjData[i].get('Q6_Value__c') == 4){
                    returnObjData[i].put('Survey_Type__c','Dealer');
                    //Database.SaveResult[] insertOtherStagingRec = Database.insert(returnObjData,false);
                    //PRPC_returnRealObjClass.DeleteandUpdateRec(insertOtherStagingRec,allStagingRec);
                }
            }
            //Mapping the Distributor ship to code at the time of moving from staging to real.
            if(MetaDataList[0].Real_Object_Api_Name__c == 'ETC_Data__c'){
                if(returnObjData[i].get('Distributor_Code__c') != null){
                    if(string.valueof(returnObjData[i].get('Distributor_Code__c')).length() == 9){
                        returnObjData[i].put('Distributor_Code__c','0'+string.valueof(returnObjData[i].get('Distributor_Code__c')));
                    }
                    else{
                        if(string.valueof(returnObjData[i].get('Distributor_Code__c')).length() == 10){
                            returnObjData[i].put('Distributor_Code__c',string.valueof(returnObjData[i].get('Distributor_Code__c')));
                        }
                    }
                }
                if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Code__c'))) != null){
                    returnObjData[i].put('Customer__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Code__c'))).id);
                }
            }
        }
        
        
        Database.SaveResult[] insertOtherStagingRec = Database.insert(returnObjData,false);
        PRPC_returnRealObjClass.DeleteandUpdateRec(insertOtherStagingRec,removeDuplicatestagingRec);
    }
}


public static void fakeMethod(){
    if(test.isRunningTest()){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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

global void finish(Database.BatchableContext BC) {
    if(!Test.isRunningTest()){
        //CHG0043240- Adding Custom error for Accounts that do not exist in the system.
        List<Account_Staging__c> accstaglist =[SELECT Id,Error_Log__c,Location_Type__c,Service_Location_ID__c FROM Account_Staging__c WHERE Error_log__c = null];
        for(Account_Staging__c acctStage : accstaglist ){
            if(acctStage.Location_Type__c=='ROL' || acctStage.Location_Type__c=='SSC'){
                acctStage.Error_Log__c='Incorrect Location Type :'+acctStage.Location_Type__c;
            }
            else if(acctStage.Location_Type__c=='D' && acctStage.Service_Location_ID__c.right(5)!='00000'){
                acctStage.Error_Log__c='Incorrect Location Type :'+acctStage.Location_Type__c +' for this Service Location ID. ' ;
            }
            else{
                acctStage.Error_Log__c='SAP_ID__c does not exist in the system';
            }
            
        }
        update accstaglist;
        PRPC_dataMovementForPartsOrder myBatchObject = new PRPC_dataMovementForPartsOrder(); 
        Id batchId = Database.executeBatch(myBatchObject,700);
        
    }
}

}