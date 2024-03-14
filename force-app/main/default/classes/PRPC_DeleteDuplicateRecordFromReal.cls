/*
 * Update : TT Duplication logic is not needed here. There is a separate batch for it.
 * Update By : Susovan Mondal & Chinmaya Das
 */

global class PRPC_DeleteDuplicateRecordFromReal implements Database.Batchable<sObject>  {
    
    global static string queryInclude;
    global list<Sobject> start(Database.BatchableContext BC) {
        
        string Query ='select Real_Object_Api_Name__c,Field_API_Name__c from Real_Object_Update__mdt';
        If(Test.isRunningTest()){
            Query += ' where Real_Object_Api_Name__c=\'End_Customer__c\'';
        }
        list<Sobject>returnQuery = Database.query(Query);
        
        return returnQuery;
        
    }
    
    global void execute(Database.BatchableContext BC, List<Real_Object_Update__mdt> MetaDataList) {
        Integer storeMonth = Date.today().month();
        Integer storeYear = Date.today().year();
        integer actualMonth = storeMonth-1;
        if(storeMonth == 1)
        {
            actualMonth = 12;
            storeYear = storeYear -1;
        }
        
        string fieldApiName =string.valueof(MetaDataList[0].Field_API_Name__c);
        string Query = 'select ';
        Query+= fieldApiName + ' from '+ MetaDataList[0].Real_Object_Api_Name__c + ' where month__c =' + actualMonth + ' and year__c ='+ storeYear;
        //TT Turnt Duplication logic is not required.
        /*if(MetaDataList[0].Real_Object_Api_Name__c == 'TAT_Data__C'){
            Query += ' and Source_Type__c =\'Distributor\'';
        }*/
        
        set<string> uniqueKey = new set<string>();
        list<sobject>deleteDuplicateRec = new list<sObject>();
        set<string>checkDuplicateRec = new set<string>();
        set<string>checkDuplicateRec2 = new set<string>();
        set<string>checkDuplicateRec3 = new set<string>();
        list<sObject> QueryResults = Database.query(Query);
        system.debug('---------- QueryResults  :  '+QueryResults);
        system.debug('------------------Query  :  '+Query);
        
        
        for(sObject sob : QueryResults){
            //TT Turnt Duplication logic is not required.
            /*if(MetaDataList[0].Real_Object_Api_Name__c == 'TAT_Data__C')
            {
                String unique='';  
				String x1 = string.valueof(sob.get('Vin__c'));
				String y1 = x1.replaceFirst( '^0+','');
                unique = string.valueof(sob.get('Distributor_Ship_To__c'))+'-'+ string.valueof(sob.get('Allison_Serial__c'))+'-'+string.valueof(sob.get('Month__c'))+'-'+string.valueof(sob.get('Year__c'))+'-'+double.valueof(sob.get('Total_labor_hours__c'))+'-'+y1;
                if(!uniqueKey.contains(unique)){
                    uniqueKey.add(unique);
                }else{
                   deleteDuplicateRec.add(sob);
                }
            }
            else if(MetaDataList[0].Real_Object_Api_Name__c == 'End_Customer__c'){*/
                if(sob.get('Distributor_Ship_To__c') != null && sob.get('Repair_Order_or_Parts_Invoice__c') !=null ){
                    string uniqueKey1 = string.valueof(sob.get('Distributor_Ship_To__c')) +'-'+string.valueof(sob.get('Repair_Order_or_Parts_Invoice__c'));
                    if(!checkDuplicateRec.contains(uniqueKey1)){
                        checkDuplicateRec.add(uniqueKey1);
                        
                    }else{
                        deleteDuplicateRec.add(sob);
                    }
                }else{
                    if(sob.get('Distributor_Ship_To__c') != null && sob.get('Repair_Order__c') !=null){
                        string uniqueKey2 = string.valueof(sob.get('Distributor_Ship_To__c')) +'-'+string.valueof(sob.get('Repair_Order__c'));
                        if(!checkDuplicateRec2.contains(uniqueKey2)){
                            checkDuplicateRec2.add(uniqueKey2);
                            
                        }else{
                            deleteDuplicateRec.add(sob);
                        }
                    }else{
                        if(sob.get('Distributor_Ship_To__c') != null && sob.get('Parts_Invoice__c') !=null){
                            string uniqueKey3 = string.valueof(sob.get('Distributor_Ship_To__c')) +'-'+string.valueof(sob.get('Parts_Invoice__c'));
                            if(!checkDuplicateRec3.contains(uniqueKey3)){
                                checkDuplicateRec3.add(uniqueKey3);
                                
                            }else{
                                deleteDuplicateRec.add(sob);
                            }
                        }
                    }
                }
            //}
        }
        if(deleteDuplicateRec.size()>0){
            Delete deleteDuplicateRec;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        
    }
    
}