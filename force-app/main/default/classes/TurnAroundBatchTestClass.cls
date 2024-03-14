@IsTest(seeAllData=true)
public class TurnAroundBatchTestClass {
    
    @IsTest
    public static void Method1(){
        Integer month = system.today().month();
        Integer m= month-1;
        Integer y =Date.Today().Year();
        if(month==1)
        {  
            m=12;
            y--;
        }

        List<WOD_2__Claim__c>  claimlist = [SELECT id,ATI_Claim_Number__c,Name, WOD_2__Approved_Rejected_Date__c, ATI_Claim_Subtype__c,WOD_2__Account__r.PRP_Participation__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Model_Number__r.WOD_2__Product_Name__c ,WOD_2__Inventory__r.name,ATI_Customer_Requests_Service_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Date_Of_Repair__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,ATI_First_Labor_Applied_Date_Time__c,ATI_Last_Labor_Recorded_Time__c,ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Technician_Name__c,WOD_2__Work_Order__c,WOD_2__Submit_Date__c,Submit_Date_Month__c,Submit_Date_Year__c,ATI_Claim_Status_Codes__c,WOD_2__Inventory__c ,(select id,WOD_2__Total_Labor_Hours__c,name from WOD_2__Claim_Service_Informations__r )FROM WOD_2__Claim__c WHERE CALENDAR_MONTH(WOD_2__Approved_Rejected_Date__c)=:m AND CALENDAR_YEAR(WOD_2__Approved_Rejected_Date__c)=:y LIMIT 10];
   
       /* List<WOD_2__Claim__c>  claimlist = [SELECT id,ATI_Claim_Number__c,Name, WOD_2__Approved_Rejected_Date__c, ATI_Claim_Subtype__c,WOD_2__Account__r.PRP_Participation__c,WOD_2__Account__r.SAP_ID__c,WOD_2__Model_Number__r.WOD_2__Product_Name__c ,WOD_2__Inventory__r.name,ATI_Customer_Requests_Service_Date__c,ATI_Distributor_schedules_cust_Serv_Date__c,ATI_Vehicle_Arrival_Date_Time__c,ATI_Repair_Order_Open_Time__c,WOD_2__Date_Of_Repair__c,ATI_Repair_Order_Closed_Date_Time__c,ATI_Completed_Repair_Cust_Noti_Date__c,ATI_First_Labor_Applied_Date_Time__c,ATI_Last_Labor_Recorded_Time__c,ATI_First_Part_Ordered_Date_Time__c,ATI_Last_Part_Arrival_Date_Time__c,ATI_Technician_Name__c,WOD_2__Work_Order__c,WOD_2__Submit_Date__c,Submit_Date_Month__c,Submit_Date_Year__c,ATI_Claim_Status_Codes__c,WOD_2__Inventory__c ,(select id,WOD_2__Total_Labor_Hours__c,name from WOD_2__Claim_Service_Informations__r )FROM WOD_2__Claim__c WHERE CALENDAR_MONTH(WOD_2__Approved_Rejected_Date__c)=:m AND CALENDAR_YEAR(WOD_2__Approved_Rejected_Date__c)=:y AND ATI_Claim_Status_Codes__c = '40-APPROVED' AND (ATI_Claim_Subtype__c='01' OR ATI_Claim_Subtype__c='02' OR ATI_Claim_Subtype__c='09') AND WOD_2__Account__r.PRP_Participation__c=true AND ((
            WOD_2__Inventory__r.Name LIKE '05%' OR
            WOD_2__Inventory__r.Name LIKE '24%' OR
            WOD_2__Inventory__r.Name LIKE '32%' OR
            WOD_2__Inventory__r.Name LIKE '63%' OR
            WOD_2__Inventory__r.Name LIKE '65%' OR
            WOD_2__Inventory__r.Name LIKE '66%' OR
            WOD_2__Inventory__r.Name LIKE '91%' OR
            WOD_2__Inventory__r.Name LIKE '92%' OR
            WOD_2__Inventory__r.Name LIKE '93%' OR
            WOD_2__Inventory__r.Name LIKE '94%' OR
            WOD_2__Inventory__r.Name LIKE '95%' OR
            WOD_2__Inventory__r.Name LIKE '96%' OR
            WOD_2__Inventory__r.Name LIKE '97%' OR
            WOD_2__Inventory__r.Name LIKE '98%')OR       
          (WOD_2__Inventory__r.Name LIKE '25%' AND WOD_2__Model_Number__r.WOD_2__Product_Name__c LIKE 'HT%')) AND (id NOT IN (select WOD_2__Claim__c from WOD_2__Claim_Service_Information__c where WOD_2__Service_Job_Code__r.Name='11111111'  AND WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c < '9200000000')) 
          AND (id NOT IN (select WOD_2__Claim__c from WOD_2__Other_Cost__c where WOD_2__Cost_Category_Type__c='Travel By Distance' AND WOD_2__UnitsUsage__c > 0 AND WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c < '9200000000')) ];
       
        */
        
        test.startTest();
        
        TurnAroundTimeMappingBatch myBatchObject = new TurnAroundTimeMappingBatch();
        Database.executeBatch(myBatchObject);
      
        test.stopTest();
    }    
}