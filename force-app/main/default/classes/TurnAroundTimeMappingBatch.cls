//Class Name: TurnAroundTimeMappingBatch
//Description: Batch to move data from WOD_2__Claim__c Object to TAT_Staging_Data__c Object for the previous month.
//Developer Name: Akanksha Mondal, Ritu Raj Singh



public class TurnAroundTimeMappingBatch implements Database.Batchable<sObject>,Schedulable{
    public list<Sobject> start(Database.BatchableContext BC){
        
        Integer Month = Date.Today().Month();
        
        Integer Year =Date.Today().Year();
        Integer ActualMonth= Month-1;
        if(Month== 1)
        {
            ActualMonth=12;  
            Year--;
        }
        system.debug('ActualMonth' +ActualMonth);
        system.debug('Year' +Year);
        String query2;
        
        if(!test.isRunningTest()){
            query2='SELECT ATI_VIN__c,ATI_Replaced_Inventory__c,ATI_Claim_Number__c,Name,ATI_Claim_Subtype__c,WOD_2__Account__r.PRP_Participation__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Model_Number__r.WOD_2__Product_Name__c ,WOD_2__Inventory__r.name,ATI_Customer_Requests_Service_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Date_Of_Repair__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,ATI_First_Labor_Applied_Date_Time__c,ATI_Last_Labor_Recorded_Time__c,ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Technician_Name__c,WOD_2__Work_Order__c,WOD_2__Submit_Date__c,Submit_Date_Month__c,Submit_Date_Year__c,ATI_Claim_Status_Codes__c,WOD_2__Approved_Rejected_Date__c,WOD_2__Inventory__c,(select id,WOD_2__Total_Labor_Hours__c,Name from WOD_2__Claim_Service_Informations__r   ) ,(select id,WOD_2__Cost_Category_Type__c,WOD_2__Approved_Quantity__c from WOD_2__Financial_Line_Items__r ) FROM WOD_2__Claim__c WHERE CALENDAR_MONTH(WOD_2__Approved_Rejected_Date__c)=:ActualMonth  AND  CALENDAR_YEAR(WOD_2__Approved_Rejected_Date__c)=:Year AND ATI_Claim_Status_Codes__c =\'40-APPROVED\' AND (ATI_Claim_Subtype__c=\'01\' OR ATI_Claim_Subtype__c=\'02\' OR ATI_Claim_Subtype__c=\'09\')  AND  WOD_2__Account__r.PRP_Participation__c=true AND ( (WOD_2__Inventory__r.Name LIKE \'05%\' OR WOD_2__Inventory__r.Name LIKE \'24%\' OR WOD_2__Inventory__r.Name LIKE \'32%\' OR WOD_2__Inventory__r.Name LIKE \'63%\' OR WOD_2__Inventory__r.Name LIKE \'65%\' OR WOD_2__Inventory__r.Name LIKE \'66%\' OR WOD_2__Inventory__r.Name LIKE \'91%\' OR WOD_2__Inventory__r.Name LIKE \'92%\' OR WOD_2__Inventory__r.Name LIKE \'93%\' OR WOD_2__Inventory__r.Name LIKE \'94%\' OR WOD_2__Inventory__r.Name LIKE \'95%\' OR WOD_2__Inventory__r.Name LIKE \'96%\' OR WOD_2__Inventory__r.Name LIKE \'97%\' OR WOD_2__Inventory__r.Name LIKE \'98%\'  ) OR (WOD_2__Inventory__r.Name LIKE \'25%\' AND WOD_2__Model_Number__r.WOD_2__Product_Name__c LIKE \'HT%\' )  ) AND  (id NOT IN (select WOD_2__Claim__c from WOD_2__Claim_Service_Information__c where WOD_2__Service_Job_Code__r.Name=\'11111111\' AND WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c < \'9200000000\' )) AND (id NOT IN (select WOD_2__Claim__c from WOD_2__Other_Cost__c where WOD_2__Cost_Category_Type__c=\'Travel By Distance\' AND WOD_2__UnitsUsage__c > 0 AND WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c < \'9200000000\' ))  ' ;
            // FOR UAT TESTING
            //  query2='SELECT ATI_VIN__c,ATI_Replaced_Inventory__c,ATI_Claim_Number__c,Name,ATI_Claim_Subtype__c,WOD_2__Account__r.PRP_Participation__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Model_Number__r.WOD_2__Product_Name__c ,WOD_2__Inventory__r.name,ATI_Customer_Requests_Service_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Date_Of_Repair__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,ATI_First_Labor_Applied_Date_Time__c,ATI_Last_Labor_Recorded_Time__c,ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Technician_Name__c,WOD_2__Work_Order__c,WOD_2__Submit_Date__c,Submit_Date_Month__c,Submit_Date_Year__c,ATI_Claim_Status_Codes__c,WOD_2__Approved_Rejected_Date__c,WOD_2__Inventory__c,(select id,WOD_2__Total_Labor_Hours__c,Name from WOD_2__Claim_Service_Informations__r   ) ,(select id,WOD_2__Cost_Category_Type__c,WOD_2__Approved_Quantity__c from WOD_2__Financial_Line_Items__r ) FROM WOD_2__Claim__c WHERE CALENDAR_MONTH(WOD_2__Approved_Rejected_Date__c)=:ActualMonth  AND  CALENDAR_YEAR(WOD_2__Approved_Rejected_Date__c)=:Year AND ATI_Claim_Status_Codes__c =\'40-APPROVED\' AND (ATI_Claim_Subtype__c=\'01\' OR ATI_Claim_Subtype__c=\'02\' OR ATI_Claim_Subtype__c=\'09\')  AND  WOD_2__Account__r.PRP_Participation__c=true AND ( (WOD_2__Inventory__r.Name LIKE \'05%\' OR WOD_2__Inventory__r.Name LIKE \'24%\' OR WOD_2__Inventory__r.Name LIKE \'32%\' OR WOD_2__Inventory__r.Name LIKE \'63%\' OR WOD_2__Inventory__r.Name LIKE \'65%\' OR WOD_2__Inventory__r.Name LIKE \'66%\' OR WOD_2__Inventory__r.Name LIKE \'91%\' OR WOD_2__Inventory__r.Name LIKE \'92%\' OR WOD_2__Inventory__r.Name LIKE \'93%\' OR WOD_2__Inventory__r.Name LIKE \'94%\' OR WOD_2__Inventory__r.Name LIKE \'95%\' OR WOD_2__Inventory__r.Name LIKE \'96%\' OR WOD_2__Inventory__r.Name LIKE \'97%\' OR WOD_2__Inventory__r.Name LIKE \'98%\'  ) OR (WOD_2__Inventory__r.Name LIKE \'25%\' AND WOD_2__Model_Number__r.WOD_2__Product_Name__c LIKE \'HT%\' )  ) AND  (id NOT IN (select WOD_2__Claim__c from WOD_2__Claim_Service_Information__c where WOD_2__Service_Job_Code__r.Name=\'11111111\' AND WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c < \'9200000000\' )) AND (id NOT IN (select WOD_2__Claim__c from WOD_2__Other_Cost__c where WOD_2__Cost_Category_Type__c=\'Travel By Distance\' AND WOD_2__UnitsUsage__c > 0 AND WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c < \'9200000000\' )) AND (Name=\'AT0533076\' OR Name=\'AT0533077\' OR Name=\'AT0533079\');            
        }
        else{
            query2='SELECT ATI_VIN__c,ATI_Replaced_Inventory__c,ATI_Claim_Number__c,Name,ATI_Claim_Subtype__c,WOD_2__Account__r.PRP_Participation__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Model_Number__r.WOD_2__Product_Name__c ,WOD_2__Inventory__r.name,ATI_Customer_Requests_Service_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Date_Of_Repair__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,ATI_First_Labor_Applied_Date_Time__c,ATI_Last_Labor_Recorded_Time__c,ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Technician_Name__c,WOD_2__Work_Order__c,WOD_2__Submit_Date__c,Submit_Date_Month__c,Submit_Date_Year__c,ATI_Claim_Status_Codes__c,WOD_2__Approved_Rejected_Date__c,WOD_2__Inventory__c,(select id,WOD_2__Total_Labor_Hours__c,Name from WOD_2__Claim_Service_Informations__r   ) ,(select id,WOD_2__Cost_Category_Type__c,WOD_2__Approved_Quantity__c from WOD_2__Financial_Line_Items__r ) FROM WOD_2__Claim__c WHERE CALENDAR_MONTH(WOD_2__Approved_Rejected_Date__c)=:ActualMonth  AND  CALENDAR_YEAR(WOD_2__Approved_Rejected_Date__c)=:Year LIMIT 10 ' ;
                }
        list<Sobject> returnQuery2 = Database.query(query2);
        system.debug('RETURN QUERY****'+returnQuery2);
        
        return returnQuery2;
    }
    
    public void execute(SchedulableContext sc){
        TurnAroundTimeMappingBatch tatmb =new TurnAroundTimeMappingBatch();
        Database.executebatch(tatmb);
    }
    
    public void execute(Database.BatchableContext bc,  List<WOD_2__Claim__c> returnQuery2 ){
        
        list<TAT_Staging_Data__c> tatlist = new list<TAT_Staging_Data__c>();  
        
        
        map<string,string> claimmap= new map<string,string>();
        list<string> InventIDList = new list<string>();
        
        map<string,string> ReplaceClaimmap= new map<string,string>();
        list<string> ReplaceInventIDList = new list<string>();
        
        for(WOD_2__Claim__c claim: returnQuery2){
            InventIDList.add(string.valueof(claim.WOD_2__Inventory__c));
             InventIDList.add(string.valueof(claim.ATI_Replaced_Inventory__c));
        }
        
        list<ATI_VIN_Transmission_Mapper__c> vehicleQuery = [select ATI_Inventory__c,ATI_Vehicle_Information__c,ATI_Vehicle_Information__r.Name from ATI_VIN_Transmission_Mapper__c where ATI_Inventory__c in:InventIDList ];
        for(ATI_VIN_Transmission_Mapper__c vc:vehicleQuery){
            claimmap.put(string.valueof(vc.ATI_Inventory__c),string.valueof(vc.ATI_Vehicle_Information__r.Name));
        }
        
        for(WOD_2__Claim__c claim: returnQuery2){
            
            TAT_Staging_Data__c tat = new TAT_Staging_Data__c();
            tat.Claim_Number__c= claim?.Name;
            tat.Partner_Code__c=claim?.WOD_2__Account__r.SAP_ID__c;
            System.debug('DEBUG TEST'+claim?.ATI_Customer_Requests_Service_Date__c);
            tat.Transmission_serial_number__c=claim?.WOD_2__Inventory__r.name;
            tat.date_cust_request_service__c= StringConversion.SplitMethod(String.valueof(claim?.ATI_Customer_Requests_Service_Date__c));   
            tat.Date_Distributor_schedules_for_service__c   =StringConversion.SplitMethod(String.valueof(claim?.ATI_Distributor_schedules_cust_Serv_Date__c));
            string a=StringConversion.SplitMethod(String.valueof(claim?.ATI_Distributor_schedules_cust_Serv_Date__c));
            System.debug('TESTING'+a);
            system.debug('DATE FIELD'+String.valueof(claim?.ATI_Distributor_schedules_cust_Serv_Date__c));
            tat.date_vehicle_first_arrived__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_Vehicle_Arrival_Date_Time__c));
            
            tat.Repair_Order_open_date__c= StringConversion.SplitMethod(String.valueof(claim?.ATI_Repair_Order_Open_Time__c));
            
            tat.Repair_Order_closed_date__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_Repair_Order_Closed_Date_Time__c));
            tat.customer_notified__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_Completed_Repair_Cust_Noti_Date__c));
            tat.Date_first_labor_applied__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_First_Labor_Applied_Date_Time__c));
            
            tat.Date_last_labor_applied__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_Last_Labor_Recorded_Time__c));
            
            tat.Date_First_Part_Ordered__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_First_Part_Ordered_Date_Time__c));
            tat.PART_ARRIVAL_DATE__c=StringConversion.SplitMethod(String.valueof(claim?.ATI_Last_Part_Arrival_Date_Time__c));
            
            tat.submit_date__c=StringConversion.SplitMethod4(String.valueof(claim?.WOD_2__Approved_Rejected_Date__c));
            String sd =StringConversion.SplitMethod4(String.valueof(claim?.WOD_2__Submit_Date__c));
            System.debug('ORIGINAL SUBMIT DATE: '+String.valueof(claim?.WOD_2__Submit_Date__c));
            system.debug('SUBMIT DATE AFTER UPDATE: '+sd);

            tat.Technician_Name__c=claim?.ATI_Technician_Name__c;
            tat.repair_order_number__c=claim?.WOD_2__Work_Order__c;
            string laboropps = '';
            
            for(sobject c:claim.WOD_2__Claim_Service_Informations__r){
                laboropps+=  string.valueof( c.get('name'))+' ' ;
            }
            tat.all_labor_ops__c=laboropps;
            
            Decimal laborhrs=0;
            
            for(sobject c:claim.WOD_2__Financial_Line_Items__r){
                if(c.get('WOD_2__Cost_Category_Type__c')=='Labor'){
                    laborhrs+= double.valueOf((c.get('WOD_2__Approved_Quantity__c')));
                }
            }
            tat.total_hours__c=string.valueof(laborhrs);
            
            if(claim?.ATI_VIN__c != null)
            {
                tat.vin__c=claim?.ATI_VIN__c;
            }
            else if(claim?.ATI_VIN__c == null)
            { 
                if(string.valueof(claimmap.get(string.valueof(Claim?.WOD_2__Inventory__c)))!=null){
                 tat.vin__c= string.valueof(claimmap.get(string.valueof(Claim?.WOD_2__Inventory__c))); 
                   }
                else{
                tat.vin__c= string.valueof(claimmap.get(string.valueof(Claim?.ATI_Replaced_Inventory__c)));                     
                }
               
            }
          
            
            if(claim.WOD_2__Claim_Service_Informations__r.size()>0){
                tatlist.add(tat);   
            }
        }
        if(tatlist.size()>0){
            system.debug('TATLIST SIZE'+tatlist.size());
            system.debug('TATLIST:'+tatlist);
            
            insert tatlist;
            
        } 
    }
    public void finish(Database.BatchableContext bc){
    }
    
    
}