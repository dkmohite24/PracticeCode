public class PRPC_overallFileSubmissionApex {
    
    @AuraEnabled
    public static regionAndFields objectFields(String PartnerTypeApex) {
        System.debug('Inside 1st method');
        List<pickListWrapper> distributor = new List<pickListWrapper>();
        List<pickListWrapper> month = new List<pickListWrapper>();
        List<pickListWrapper> year = new List<pickListWrapper>();
        List<Account> acctDetails = new List<Account>();
        if(PartnerTypeApex == 'Distributor'){
        acctDetails = [SELECT Id,Name,Type FROM Account  WHERE PRP_Participation__c = true AND Type = 'Distributor' Order By Name];
        }
        else if(PartnerTypeApex == 'Direct Dealer'){
        acctDetails = [SELECT Id,Name,Type FROM Account  WHERE PRP_Participation__c = true AND Type = 'Direct Dealer'Order By Name];
        }
        for(Account acc : acctDetails){
            distributor.add(new pickListWrapper(acc.id,acc.Name,acc.Type));
        }
        
        List<String> mv = new List<String>{'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
            for(String m : mv){
                month.add(new pickListWrapper(m,m,m));
            }
        
        
        List<Integer> yer = new List<Integer>();
        Integer CurrentYear = System.Today().year();
        for(Integer i= CurrentYear; i>=2013; i--){
            year.add(new pickListWrapper(String.valueOf(i),String.valueOf(i),String.valueOf(i)));
        }
        return new regionAndFields(distributor,month,year);
        
    }
    
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributors(List<String> selectedRegion, String report) 
    {
        system.debug('region'+selectedRegion);
        System.debug('report ' + report);
        List<Account> accountList = new List<Account>();
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        if(report == 'Total Parts Sold Data - International DDLR'){
            accountList = [Select id,name,AccountSAPField__c, Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Direct Dealer' AND ParentId = null];
            for(Account acc : accountList){
                AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c,acc.Type));
            }
        }
        else{
            accountList = [Select id,name,AccountSAPField__c, Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Distributor'];
            for(Account acc : accountList){
                AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c,acc.Type));
            }
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
   
    @AuraEnabled
    public static List<Sobject> FetchRecordsforTable(List<String> DistributorList,String PartnerTypeApex,
                                                     List<String> monthValue, List<Decimal> yearValue) 
    {
        System.debug('PartnerTypeApex :'+PartnerTypeApex);
        List<Overall_File_Submission__c> fileData = new List<Overall_File_Submission__c>();
        if(PartnerTypeApex == 'Distributor'){
        System.debug('Inside Distributor');
        fileData = [SELECT Id, name,Distributor_Branch__r.name,Distributor_Branch__r.SAP_ID__c,Distributor_Branch__r.Parent.SAP_ID__c,Distributor_Branch__r.Sales_RegionA__c,Month_Text__c,Year__c,Training__c,Turnaround_Time__c,ETC_Data__c,TPS__c,Total_Parts_Sold_ReTran__c,Survey__c,Parts_Ordering__c,Functional_Comp__c,Facility_Audit__c,Turnaround_Time_Aware__c,End_Customer_Data__c FROM Overall_File_Submission__c WHERE Year__c IN: yearValue AND Month_Text__c IN: monthValue AND Distributor_Branch__r.ParentId IN: DistributorList];
        }
        else if(PartnerTypeApex == 'Direct Dealer'){
        System.debug('Inside Direct Dealer');
        fileData = [SELECT Id, name,Distributor_Branch__r.name,Distributor_Branch__r.SAP_ID__c,Distributor_Branch__r.Parent.SAP_ID__c,Distributor_Branch__r.Sales_RegionA__c,Month_Text__c,Year__c,Training__c,Turnaround_Time__c,ETC_Data__c,TPS__c,Total_Parts_Sold_ReTran__c,Survey__c,Parts_Ordering__c,Functional_Comp__c,Facility_Audit__c,Turnaround_Time_Aware__c,End_Customer_Data__c FROM Overall_File_Submission__c WHERE Year__c IN: yearValue AND Month_Text__c IN: monthValue AND Distributor_Branch__r.Id IN: DistributorList];
        }
        system.debug('Line number 62' +fileData);
        return fileData;
        
    }
    
    public Class pickListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Type;
        public pickListWrapper(String Idx,String Namex,String Typex){
            this.Id=Idx;
            this.Name = Namex;
            this.Type = Typex;
        }
    }
    
    public Class regionAndFields{
        @AuraEnabled public List<pickListWrapper> distributor;
        @AuraEnabled public List<pickListWrapper> month;
        @AuraEnabled public List<pickListWrapper> year;
        //@AuraEnabled public List<pickListWrapper> defaultfieldsList;
        public regionAndFields(List<pickListWrapper> distributor,List<pickListWrapper> month,
                               List<pickListWrapper> year){
                                   this.distributor = distributor;
                                   this.month = month;
                                   this.year = year;
                                   
                               }
    }
    
}