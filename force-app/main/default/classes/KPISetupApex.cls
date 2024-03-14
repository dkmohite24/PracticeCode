public class KPISetupApex {
    @AuraEnabled
    public static KPI_Setup__c allRanges(String KPIRangeItems, String KPIDateItems, String region, String year, String type, String partnerType) {
        List<KPI_Range_Settings__c> rangeList = new List<KPI_Range_Settings__c>();
        rangeList = (List<KPI_Range_Settings__c>)JSON.deserialize(KPIRangeItems, List<KPI_Range_Settings__c>.class);
        upsert rangeList;
        List<KPI_Date_Settings__c> dateList = new List<KPI_Date_Settings__c>();
        dateList = (List<KPI_Date_Settings__c>)JSON.deserialize(KPIDateItems, List<KPI_Date_Settings__c>.class);
        upsert dateList;
        
        Map<String, KPI_Date_Settings__c> dateRangeMap = new Map<String, KPI_Date_Settings__c>();
        for(KPI_Date_Settings__c kpiDateElement : dateList) {
            dateRangeMap.put(kpiDateElement.Name, kpiDateElement);
        }
        
        
        List<KPI_Date_Settings__c > existingDateList = new List<KPI_Date_Settings__c>();
        existingDateList = [SELECT Id,Name,File_Submission_Date__c,KPI_Calculation_Date__c FROM KPI_Date_Settings__c WHERE KPI_Setup__r.Year__c = :year AND KPI_Setup__r.Region__c = :region ];
        for(KPI_Date_Settings__c existingKpiDate : existingDateList) {
            existingKpiDate.File_Submission_Date__c = dateRangeMap.get(existingKpiDate.Name).File_Submission_Date__c ;
            existingKpiDate.KPI_Calculation_Date__c = dateRangeMap.get(existingKpiDate.Name).KPI_Calculation_Date__c;
        }
        UPDATE existingDateList;
        return searchAllFields(region,year,type,partnerType);
        
    }    
    
    @AuraEnabled
    public static void allDates(String KPIDateItems) {
        //system.debug('line no 12'+ KPIDateItems);
        List<KPI_Date_Settings__c> dateList = new List<KPI_Date_Settings__c>();
        dateList = (List<KPI_Date_Settings__c>)JSON.deserialize(KPIDateItems, List<KPI_Date_Settings__c>.class);
        upsert dateList;
    } 
    
    @AuraEnabled
    public static KPI_Setup__c searchAllFields(String Region, String Year, String KPIType, String PartnerType) {
        KPI_Setup__c fetchAllRecords = new KPI_Setup__c();
        try{
            fetchAllRecords = [SELECT id, name, Region__c, Year__c, KPI_Type__c, Partner_Type__c,(SELECT id, name, Low_Range_Value__c, High_Range_Value__c, X2_Tech__c, Points__c from KPI_Range_Settings__r ORDER BY name ASC), (SELECT id, name, File_Submission_Date__c, KPI_Calculation_Date__c from KPI_Date_Settings__r order by MonthSequence__c ASC) from KPI_Setup__c WHERE Region__c = :Region AND Year__c = :Year AND KPI_Type__c = :KPIType AND Partner_Type__c = :PartnerType LIMIT 1];
            
            return fetchAllRecords;
            
        }
        
        catch(exception e){
            system.debug(e.getMessage());
            
        }
        return null;
        
    }
    
    @AuraEnabled
    public static KPI_Setup__c searchDateRange(String Region, String Year) {
        KPI_Setup__c fetchAllRecords = new KPI_Setup__c();
        try{
            fetchAllRecords = [SELECT id, name, Region__c, Year__c, KPI_Type__c, (SELECT id, name, Low_Range_Value__c, High_Range_Value__c, X2_Tech__c, Points__c from KPI_Range_Settings__r ORDER BY name ASC), (SELECT id, name, File_Submission_Date__c, KPI_Calculation_Date__c from KPI_Date_Settings__r order by MonthSequence__c ASC) from KPI_Setup__c WHERE Region__c = :Region AND Year__c = :Year LIMIT 1];
            
            return fetchAllRecords;
            
        }
        
        catch(exception e){
            system.debug(e.getMessage());
            
        }
        return null;
    }
    
    @AuraEnabled
    public static void sendData(String KPIKeyValues, String KPIDateItems) {
        KPI_Setup__c keyList = new KPI_Setup__c();
        keyList = (KPI_Setup__c)JSON.deserialize(KPIKeyValues, KPI_Setup__c.class);
        insert keyList;
        List<KPI_Date_Settings__c> dateList = new List<KPI_Date_Settings__c>();
        dateList = (List<KPI_Date_Settings__c>)JSON.deserialize(KPIDateItems, List<KPI_Date_Settings__c>.class);
        
        for(KPI_Date_Settings__c dates:dateList){
            dates.kpi_setup__c = keyList.Id;
        }
        insert dateList;
    } 
    
}