/*
 * Description : Deleting the duplicate TT Turnt records from the system. After the deletion an email was sent to Raeanne with Deleted TT Turnt Data.
 * Created By : Chinmaya Dash and Susovan Mondal
 * Created Date : 03/14/2024
 */

global class PRPC_DeleteDuplicateTTDistributorRecord implements Database.Batchable<sObject>,Database.stateful,Schedulable  {
    
    global static string queryInclude;
    global final set<string> uniqueKey = new set<string>();
    global final list<TAT_Data__C>deleteDuplicateRec = new list<TAT_Data__C>();
    public list<Sobject> start(Database.BatchableContext BC) {
        Integer storeMonth = Date.today().month();
        Integer storeYear = Date.today().year();
        
        if(storeMonth == 1){
            storeYear = storeYear -1;
        }
        
        string Query ='SELECT Id, Dealer_Id__c, Dealer_Id__r.Sales_RegionA__c, Dealer_Id__r.PRP_Participation__c, Dealer_Id__r.Location_Type__c, all_labor_ops__c, Name, Repair_Type__c, Vehicle_Arrived_Earlier__c, Service_End_Date_Formula__c, Service_Start_Date_Formula__c, Year__c, Month__c, Source_Type__c, Repair_Payment__c, Meets_TT_Goal__c, Extraction_Date__c, Distributor_Ship_To__c, Vin__c, Allison_Serial__c, Total_labor_hours__c FROM TAT_Data__C where Source_Type__c=\'Distributor\'AND Year__c=:storeYear ORDER BY CreatedDate ASC';
        If(Test.isRunningTest()){
            // Query += ' where Real_Object_Api_Name__c=\''+ queryInclude +'\'';
        }
        list<Sobject>returnQuery = Database.query(Query);
        return returnQuery;
        
    }
    public void execute(SchedulableContext sc){
        PRPC_DeleteDuplicateTTDistributorRecord tatmb =new PRPC_DeleteDuplicateTTDistributorRecord();
        Database.executebatch(tatmb,1000);
    }
    
    global void execute(Database.BatchableContext BC, List<TAT_Data__C> ttlist) {
        
        System.debug('QueryResults: '+ttlist);
        for( TAT_Data__C tt : ttlist){
            String unique='';  
            String x1 = string.valueof(tt.Vin__c);
            String y1 = x1.replaceFirst( '^0+','');
            system.debug('tt.Distributor_Ship_To__c: '+string.valueof(tt.Distributor_Ship_To__c));
            if(tt.Total_labor_hours__c != NULL){
                unique = string.valueof(tt.Distributor_Ship_To__c)+'-'+ string.valueof(tt.Allison_Serial__c)+'-'+string.valueof(tt.Month__c)+'-'+string.valueof(tt.Year__c)+'-'+double.valueof(tt.Total_labor_hours__c)+'-'+y1;
            }
            if(!uniqueKey.contains(unique)){
                uniqueKey.add(unique);
            }else{
                deleteDuplicateRec.add(tt);
            }
        }      
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('SIZE----'+deleteDuplicateRec.size());
        
        if(deleteDuplicateRec.size()>0){
            system.debug('SIZE----'+deleteDuplicateRec.size());
            String recipientEmail = 'susovan.mondal@gyansys.com';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {recipientEmail});
            mail.setSubject('TT Distributor Duplicate Records Deleted');
            mail.setPlainTextBody('The batch job has deleted ' + deleteDuplicateRec.size() + ' records.');
            
            // Create a CSV file with the deleted data
            String csv = 'Id, Dealer_Id__c, Dealer_Id__r.Sales_RegionA__c, Dealer_Id__r.PRP_Participation__c, Dealer_Id__r.Location_Type__c, all_labor_ops__c, Name, Repair_Type__c, Vehicle_Arrived_Earlier__c, Service_End_Date_Formula__c, Service_Start_Date_Formula__c, Year__c, Month__c, Source_Type__c, Repair_Payment__c, Meets_TT_Goal__c, Extraction_Date__c,Distributor_Ship_To__c,Allison_Serial__c,Total_labor_hours__c,Vin__c\n';
            for (TAT_Data__C tt : deleteDuplicateRec) {
                csv += tt.Id + ',' + tt.Dealer_Id__c + ',' + tt.Dealer_Id__r.Sales_RegionA__c  + ',' + tt.Dealer_Id__r.PRP_Participation__c + ',' +tt.Dealer_Id__r.Location_Type__c + ',' + tt.all_labor_ops__c + ',' + tt.Name  + ',' + tt.Repair_Type__c + ',' +tt.Vehicle_Arrived_Earlier__c + ',' + tt.Service_End_Date_Formula__c + ',' + tt.Service_Start_Date_Formula__c  + ',' + tt.Year__c + ',' +tt.Month__c + ',' + tt.Source_Type__c + ',' + tt.Repair_Payment__c  + ',' + tt.Meets_TT_Goal__c +',' +string.valueOf(tt.Extraction_Date__c) + ','+tt.Distributor_Ship_To__c + ',' + tt.Allison_Serial__c + ',' + tt.Total_labor_hours__c  + ',' + tt.Vin__c +'\n';
            }
            csv = csv.replace('null', '');          
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('DeletedRecords.csv');
            attachment.setBody(Blob.valueOf(csv));
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            Delete deleteDuplicateRec;
        }
        
    }   
    
}