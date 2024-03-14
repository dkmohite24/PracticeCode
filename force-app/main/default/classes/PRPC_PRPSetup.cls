public class PRPC_PRPSetup {
    
    @AuraEnabled
    public static void allRanges(String PRPRangeItems) {
        List<PRP_Range_Settings__c> rangeList = new List<PRP_Range_Settings__c>();
        
        rangeList = (List<PRP_Range_Settings__c>)JSON.deserialize(PRPRangeItems, List<PRP_Range_Settings__c>.class);
        
        upsert rangeList;
         }
  
    @AuraEnabled
    public static PRP_Setup__c searchAllFields(String Region, String Year, String PartnerType, String Month) {
        
        PRP_Setup__c fetchAllRecords = new PRP_Setup__c();
        
        try{
             //added Manual_Override__c 
            fetchAllRecords = [SELECT id, Name, Region__c, Year__c, Partner_Type__c, KPI_Selection__c, Month__c,Manual_Override__c, (SELECT id, Name, Low_Range__c, High_Range__c, Level_Discount__c, Functional_Comp_Range__c from PRP_Range_Settings__r) from PRP_Setup__c WHERE Region__c = :Region AND Year__c = :Year AND Partner_Type__c = :PartnerType AND Month__c = :Month LIMIT 1];
            system.debug('line no 23' + fetchAllRecords);
            return fetchAllRecords;
           
        }
        
        catch(exception e){
            system.debug(e.getMessage());
            
        }
        return null;
        
    }
    
    
}