/* Class Name: PRPC_dataMovementForPartsOrder
* Description: 
* Created by: Debiprasad
*/
global class PRPC_dataMovementForPartsOrder implements Database.Batchable<sObject> {
    global list<Sobject> start(Database.BatchableContext BC) {
        string Query ='select Delivery_Priority__c,Line_Item__c,Material_Entered__c,Order_Type__c,Report_Execution_Date__c,Sales_Order__c,Distributor_Ship_To__c from Parts_Order_Staging__c';
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
        
        /*for(sobject sob:MetaDataList){
            Date month = Date.parse(string.valueof(sob.get('Report_Execution_Date__c')));
            integer storemonth;
            if(month.month() == 1){
                storemonth =12;
            }else{
                storemonth=(month.month()-1);
            }
            storeMonthset.add(storemonth);
            Integer storeyear;
            IF(month.month() == 1){
                storeyear = (month.year()-1);
            }else{
                storeyear=(month.year());
            }
            storeYearSet.add(storeyear);
            if(string.valueof(sob.get('Distributor_Ship_To__c')).length() == 9){
                storeDist.add('0'+string.valueof(sob.get('Distributor_Ship_To__c')));
            }
            if(string.valueof(sob.get('Distributor_Ship_To__c')).length() == 10){
                storeDist.add(string.valueof(sob.get('Distributor_Ship_To__c')));
            }
        }*/
        
        list<string> staggingFieldApi = new list<string>();
        staggingFieldApi.add('Delivery_Priority__c');
        staggingFieldApi.add('Line_Item__c');
        staggingFieldApi.add('Material_Entered__c');
        staggingFieldApi.add('Order_Type__c');
        staggingFieldApi.add('Report_Execution_Date__c');
        staggingFieldApi.add('Sales_Order__c');
        staggingFieldApi.add('Distributor_Ship_To__c');
        list<sObject> allStagingRec = new list<sObject>(MetaDataList);
        string RealObjApiName = 'Parts_Ordering__c';
        string StagingApiName = 'Parts_Order_Staging__c';
        
        
        //FieldType with Field Name
        
        map<string,string>FieldType = new map<string,string>();
        SObjectType objType = Schema.getGlobalDescribe().get('Parts_Ordering__c');
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
        
        /*for(Parts_Ordering__c tps : [select id,Material_Entered__c,Sales_Order__c,Line_Item__c,Month__c,Year__c,Distributor_Ship_To__c from Parts_Ordering__c where Month__c IN:storeMonthset and Year__c IN:storeYearSet and Distributor_Ship_To__c IN: storeDist]){
            mapofPartorder.put(string.valueof(tps.Distributor_Ship_To__c)+'-'+string.valueof(tps.Month__c)+'-'+string.valueof(tps.Year__c)+'-'+string.valueof(tps.Material_Entered__c)+'-'+string.valueof(tps.Sales_Order__c)+'-'+string.valueof(tps.Line_Item__c),tps.Id);
            
        }*/
        
        PRPC_returnRealObjClass.wrapperclass AllValueRec = PRPC_returnRealObjClass.createInsertList(allStagingRec,RealObjApiName,StagingApiName,FieldType,null);
        system.debug('AllValueRecrecordstoInsert: '+AllValueRec.recordstoInsert);
        list<Sobject> returnObjData = new list<Sobject>();
        returnObjData = AllValueRec.recordstoInsert;
        
        for(integer i=0;i<returnObjData.size();i++){
            
            if(returnObjData[i].get('Distributor_Ship_To__c') != null){
                if(mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))) != null){
                    returnObjData[i].put('Ship_To__c',mapofacc.get(string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))).id);
                    
                }
            }
            /*Date month = Date.valueof(returnObjData[i].get('Report_Execution_Date__c'));
            string storeyear;
            string storemonth;
            if(month != null){
                
                if(month.month() == 1){
                    storemonth ='12';
                }else{
                    storemonth=string.valueof(month.month()-1);
                }
                
                IF(month.month() == 1){
                    storeyear = string.valueof(month.year()-1);
                }else{
                    storeyear=string.valueof(month.year());
                }
            }else{
                storeyear = '';
                storemonth = '';
            }
            string uniquekey = string.valueof(returnObjData[i].get('Distributor_Ship_To__c'))+'-'+string.valueof(storemonth)+'-'+string.valueof(storeyear)+'-'+string.valueof(returnObjData[i].get('Material_Entered__c'))+'-'+string.valueof(returnObjData[i].get('Sales_Order__c'))+'-'+string.valueof(returnObjData[i].get('Line_Item__c'));
            system.debug('checkline 479: '+uniquekey);
            if(!mapofPartorder.keyset().contains(uniquekey)){
                insertStaginglist.add(returnObjData[i]);
            }else{
                system.debug('checkline 483');
                id storeSuccessId = string.valueof(mapofPartorder.get(uniquekey));
                String sObjNameSuccessRec = storeSuccessId.getSObjectType().getDescribe().getName();
                Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjNameSuccessRec);
                SObject SuccRec = t.newSObject();
                SuccRec.put('Id',storeSuccessId);
                if(!updateStagingSet.contains(string.valueof(SuccRec.get('Id')))){
                    updateStagingSet.add(string.valueof(SuccRec.get('Id')));
                    updateStaginglist.add(SuccRec);
                }
                
            }*/
            
        }
        
        Database.SaveResult[] insertOtherStagingRec = Database.insert(returnObjData,false);
        PRPC_returnRealObjClass.DeleteandUpdateRec(insertOtherStagingRec,allStagingRec);
        
    }
    global void finish(Database.BatchableContext BC) {
        if(!Test.isRunningTest()){
        PRPC_dataMovementForPartsOderINT myBatchObject = new PRPC_dataMovementForPartsOderINT(); 
        Id batchId = Database.executeBatch(myBatchObject,700);
        }
    }
}