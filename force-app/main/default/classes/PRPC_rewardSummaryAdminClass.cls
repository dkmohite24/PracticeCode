public class PRPC_rewardSummaryAdminClass {
	@AuraEnabled
    public static List<String> getType(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Type.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
      }
    @AuraEnabled
    public static List<KPI__c> getAllValues(){
        List<KPI__c> getValue = new List<KPI__c>();
        getValue = [SELECT PRP_Level__c,PRP_Score__c,Region__c,KPI_Calculation_Date__c,Customer__r.Name,Customer__r.Location_Name__c,Customer__r.SAP_ID__c FROM KPI__c];
        return getValue;
    }
}