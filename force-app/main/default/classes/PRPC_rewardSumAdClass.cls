public class PRPC_rewardSumAdClass {
    
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
    public static List<KPIWrapperClass> getAllValues(String disType, Date StartDate, Date EndDate, String SelectedName, String SelectedLoc){
        System.debug(disType);
        System.debug(SelectedName);
        System.debug(SelectedLoc);
        Integer Startmonth;
        Integer StartYear;
        Integer Endmonth;
        Integer EndYear;
        List<KPI__c> getValue = new List<KPI__c>();
        if(StartDate != null){
			 Startmonth = StartDate.month();
             StartYear = StartDate.year();
            System.debug('Startmonth'+Startmonth);
            System.debug('StartYear'+StartYear);
        }
        if(EndDate != null){
			 Endmonth = EndDate.month();
             EndYear = EndDate.year();
            System.debug('Endmonth'+Endmonth);
            System.debug('EndYear'+EndYear);
        }
        
        //DISTRIBUTOR
        if(disType == 'Distributor'){
            //Name
        if(String.isNotBlank(SelectedName) && String.isBlank(SelectedLoc) && (StartDate==NULL) && (EndDate== Null))
        {
            System.debug('Inside Name');
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (KPI__c.Customer__r.Parent.AccountSAPField__c =:SelectedName) AND (KPI__c.Customer__r.Parent.Type =:disType)];
            System.debug('getValue Inside'+getValue);
        }
        //Branch
        if(String.isNotBlank(SelectedLoc) && String.isBlank(SelectedName) && (StartDate==NULL) && (EndDate== Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)];
        }
        //Date Range
        if(String.isBlank(SelectedLoc) && String.isBlank(SelectedName) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Parent.Type =:disType)];
        }
        //Name + Branch
        if(String.isNotBlank(SelectedName) && String.isNotBlank(SelectedLoc) && (StartDate == NULL) && (EndDate ==Null))
        {
            System.debug('Inside Name and Branch');
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c , Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)];
        }
        //Name + Date
        if(String.isNotBlank(SelectedName) && String.isBlank(SelectedLoc) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c , Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (KPI__c.Customer__r.Parent.AccountSAPField__c =:SelectedName)  AND (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Parent.Type =:disType)];
        }
        //Branch + Date
        if(String.isNotBlank(SelectedLoc) && String.isBlank(SelectedName) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)  AND (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Parent.Type =:disType)];
        }
        //Name + Branch + Date
        if(String.isNotBlank(SelectedLoc) && String.isNotBlank(SelectedName) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.Parent.AccountSAPField__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)  AND (KPI__c.Customer__r.Parent.AccountSAPField__c =:SelectedName) AND (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND  (KPI__c.Customer__r.Parent.Type =:disType)];
        }
        System.debug(getValue);
        }
        //DIRECT DEALER
        else if(disType == 'Direct Dealer'){
            //Name
        if(String.isNotBlank(SelectedName) && String.isBlank(SelectedLoc) && (StartDate==NULL) && (EndDate== Null))
        {
            System.debug('Inside Name');
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (KPI__c.Customer__r.AccountSAPField__c =:SelectedName) AND (KPI__c.Customer__r.Type =:disType)];
            System.debug('getValue Inside'+getValue);
        }
        //Branch
        if(String.isNotBlank(SelectedLoc) && String.isBlank(SelectedName) && (StartDate==NULL) && (EndDate== Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)];
        }
        //Date Range
        if(String.isBlank(SelectedLoc) && String.isBlank(SelectedName) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Type =:disType)];
        }
        //Name + Branch
        if(String.isNotBlank(SelectedName) && String.isNotBlank(SelectedLoc) && (StartDate == NULL) && (EndDate ==Null))
        {
            System.debug('Inside Name and Branch');
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)];
        }
        //Name + Date
        if(String.isNotBlank(SelectedName) && String.isBlank(SelectedLoc) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (KPI__c.Customer__r.AccountSAPField__c =:SelectedName)  AND (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Type =:disType)];
        }
        //Branch + Date
        if(String.isNotBlank(SelectedLoc) && String.isBlank(SelectedName) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)  AND (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Type =:disType)];
        }
        //Name + Branch + Date
        if(String.isNotBlank(SelectedLoc) && String.isNotBlank(SelectedName) && (StartDate != NULL) && (EndDate !=Null))
        {
            getValue = [SELECT Id,Customer_SAP_Id__c, Customer__c, PRP_Score__c, PRP_Level__c,Period__c, Customer__r.ParentId, Customer__r.AccountSAPField__c,Customer__r.CitySAPField__c,MonthName__c,Month__c,Year__c FROM KPI__c WHERE (Customer__r.CitySAPField__c =:SelectedLoc)  AND (KPI__c.Customer__r.AccountSAPField__c =:SelectedName) AND (Month__c<=: Endmonth) AND (Month__c>=: Startmonth) AND (Year__c<=: EndYear) AND (Year__c>=: StartYear) AND (KPI__c.Customer__r.Type =:disType)];
        }
        System.debug(getValue);
        }
        List<KPIWrapperClass> result = new List<KPIWrapperClass>();
        for(KPI__c elt : getValue){
            KPIWrapperClass temp = new KPIWrapperClass();
            if(disType == 'Distributor'){
            temp.distributorName = elt.Customer__r.Parent.AccountSAPField__c==null?'':String.valueOf(elt.Customer__r.Parent.AccountSAPField__c);
            temp.distributorId = elt.Customer__r.ParentId == null ? '' : String.valueOf(elt.Customer__r.ParentId);
            temp.location = elt.Customer__r.AccountSAPField__c==null?'':String.valueOf(elt.Customer__r.AccountSAPField__c);
            temp.locationId = elt.Customer__c == null ? '' : String.valueOf(elt.Customer__c);
            temp.locationNumber = elt.Customer_SAP_Id__c==null?'':String.valueOf(elt.Customer_SAP_Id__c);
            temp.PRPScore = elt.PRP_Score__c == null ? '' : String.valueOf(elt.PRP_Score__c);
            temp.PRPLevel = elt.PRP_Level__c == null ? '' : String.valueOf(elt.PRP_Level__c);
            temp.Year = elt.Year__c == null? '' : String.valueOf(elt.Year__c);
            temp.Month = elt.MonthName__c ==null? '' : String.valueOf(elt.MonthName__c);
            temp.PRPId = elt.Id == null ? '' : String.valueOf(elt.Id);
            temp.CitySAPId = elt.Customer__r.CitySAPField__c == null?'' : String.valueOf(elt.Customer__r.CitySAPField__c);
            temp.Period = elt.Period__c == null? '' : String.valueOf(elt.Period__c);
            result.add(temp);
            }
            else if(disType == 'Direct Dealer'){
            temp.distributorName = elt.Customer__r.AccountSAPField__c==null?'':String.valueOf(elt.Customer__r.AccountSAPField__c);
            temp.distributorId = elt.Customer__r == null ? '' : String.valueOf(elt.Customer__r);
            temp.location = elt.Customer__r.AccountSAPField__c==null?'':String.valueOf(elt.Customer__r.AccountSAPField__c);
            temp.locationId = elt.Customer__c == null ? '' : String.valueOf(elt.Customer__c);
            temp.locationNumber = elt.Customer_SAP_Id__c==null?'':String.valueOf(elt.Customer_SAP_Id__c);
            temp.PRPScore = elt.PRP_Score__c == null ? '' : String.valueOf(elt.PRP_Score__c);
            temp.PRPLevel = elt.PRP_Level__c == null ? '' : String.valueOf(elt.PRP_Level__c);
            temp.Year = elt.Year__c == null? '' : String.valueOf(elt.Year__c);
            temp.Month = elt.MonthName__c ==null? '' : String.valueOf(elt.MonthName__c);
            temp.PRPId = elt.Id == null ? '' : String.valueOf(elt.Id);
            temp.CitySAPId = elt.Customer__r.CitySAPField__c == null?'' : String.valueOf(elt.Customer__r.CitySAPField__c);
            temp.Period = elt.Period__c == null? '' : String.valueOf(elt.Period__c);
            result.add(temp); 
            }
        }
        return result;
    }
    public class KPIWrapperClass{
        @AuraEnabled public String distributorName{get;set;}
        @AuraEnabled public String distributorId{get;set;}
        @AuraEnabled public String location{get;set;}
        @AuraEnabled public String locationId{get;set;}
        @AuraEnabled public String locationNumber{get;set;}
        @AuraEnabled public String PRPScore{get;set;}
        @AuraEnabled public String PRPLevel{get;set;}
        @AuraEnabled public String Year{get;set;}
        @AuraEnabled public String Month{get;set;}
        @AuraEnabled public String PRPId{get;set;}
        @AuraEnabled public String CitySAPId{get;set;}
        @AuraEnabled public String Period{get;set;}
    }
}