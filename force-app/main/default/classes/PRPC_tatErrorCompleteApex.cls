/*
 * Update : DMND4624 - Revoke the use of PRP_Profile__mdt metadata.
 * Update By : Susovan Mondal & Chinmaya Das
 * Update Date : 08/23/2023
 */


public class PRPC_tatErrorCompleteApex {
    
    @AuraEnabled
    public static regionAndFields objectFields(String reportName) {
        String lookUpField='';
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name = :reportName LIMIT 1];
        List<String> defaultColumns = rp[0].Report_Columns__c.split(',');
        System.debug('defaultColumns- ' + defaultColumns);
        List<String> fields = new List<String>();
        Schema.SObjectType RefParObj;
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.sObjectType objType = globalDescription.get(rp[0].Report_Object__c); 
        Schema.DescribeSObjectResult r1 = objType.getDescribe(); 
        
        Map<String , Schema.SObjectField> fieldMap = r1.fields.getMap(); 
        System.debug('fieldMap- ' + fieldMap);
        List<pickListWrapper> wrapfieldsList = new List<pickListWrapper>();
        //List<All_Regions__mdt> allRegionList = new List<All_Regions__mdt>([Select id,MasterLabel,DeveloperName,IsInternational__c from All_Regions__mdt]);
        List<pickListWrapper> regionNames = new List<pickListWrapper>();
        List<String> regions = new List<String>{'North America','Latin America','Asia Pacific','EMEA'};
        for(String  reg : regions){
                   regionNames.add(new pickListWrapper(reg,reg));                      
        }  
         List<pickListWrapper> monthField = new List<pickListWrapper>();
       List<String> mv = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
           for(String m : mv){
               monthField.add(new pickListWrapper(m,m));
           }
       
       List<pickListWrapper> yearField = new List<pickListWrapper>();
       List<Integer> yer = new List<Integer>();
       Integer startYear = Date.Today().Year();
       for(Integer i= startYear; i>=2003; i--){
               yearField.add(new pickListWrapper(String.valueOf(i),String.valueOf(i)));
       }
        
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            Schema.DisplayType FldType = sfield.getDescribe().getType();
            wrapfieldsList.add(new pickListWrapper(dfield.getname(),dfield.getLabel()));
        }
        List<pickListWrapper> defaultfieldsList = new List<pickListWrapper>();
        for(String defaults : defaultColumns){
            for(pickListWrapper field1 : wrapfieldsList){
                if(field1.Id == defaults){
                    defaultfieldsList.add(field1);
                }
            }
        }System.debug('Default Fields- ' + defaultfieldsList);
        return new regionAndFields(wrapfieldsList, regionNames, defaultfieldsList, rp[0].Report_Object__c, monthField, yearField);
    }
  
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributors(List<String> selectedRegion) 
    {
        system.debug('region'+selectedRegion);
        List<Account> accountList = new List<Account>([Select id,name,AccountSAPField__c, Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Distributor']);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> FetchBranch(List<String> distributors) 
    {
        system.debug('serviceLocationList'+distributors);
        List<Account> accountList = new List<Account>([Select id,name,Type,city__c,AccountSAPField__c  from Account where parent.AccountSAPField__c IN: distributors]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.city__c));
        }
        return AccountNames;
    }
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributorsByPartner(List<String> selectedRegion,String partnervalue) 
    {
        system.debug('region'+selectedRegion);
        system.debug('Dealer type :::'+partnervalue);
        List<Account> accountList = new List<Account>([Select id,name,Type,AccountSAPField__c,Sales_RegionA__c from Account where Sales_RegionA__c IN: selectedRegion AND Type=:partnervalue ORDER BY AccountSAPField__c]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> FetchBranchForTPS(List<String> disList, String reportname,List<String> selectedRegions,String partner) 
    {
        SYstem.debug('Inside FetchBranchForTPS');
        system.debug('serviceLocationList'+disList);
        system.debug('Selected Regions'+selectedRegions);
        List<Account> accountList = new List<Account>();
        Set<String> internationlRegions = new Set<String>();
        internationlRegions.add('Latin America');
        internationlRegions.add('Asia Pacific');
        internationlRegions.add('EMEA');
        if(partner == 'Distributor' && reportname!= 'Training Data_DLR'){
            accountList =([Select id,name,Type,city__c,CitySAPField__c,AccountSAPField__c  from Account where Parent.AccountSAPField__c IN: disList AND Type='Distributor Branch' ORDER BY CitySAPField__c]);        
        }
        else if(partner == 'Distributor' && reportname== 'Training Data_DLR'){
            accountList =([Select id,name,Type,city__c,CitySAPField__c,AccountSAPField__c  from Account where Parent.AccountSAPField__c IN: disList AND Type='Service Dealer' ORDER BY CitySAPField__c]);        
        }
        else if(partner == 'Direct Dealer'){
                accountList =([Select id,name,Type,city__c,AccountSAPField__c,CitySAPField__c  from Account where AccountSAPField__c IN: disList ORDER BY CitySAPField__c]);                
        }
        else{
            System.debug('No Query');
        }
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.CitySAPField__c));
        }
        return AccountNames;
    }
    
    @AuraEnabled
    public static DataAndAccount FetchRecordsforTable(List<String> DistributorList,List<String> branches, List<String> regionList,
                                                     String columns,String SelectedObject,
                                                     List<String> monthValue, List<String> yearValue, String reportName,String partnerType) 
    {
        system.debug('In here ');
        System.debug('Columns- ' + columns);
        Set<ID> DistributorSet = new Set<ID>();
        Set<ID> DistributorBranch = new Set<ID>();
        Set<String> regionSet = new Set<String>();
        Set<String> MonthSet = new Set<String>();
        Set<Decimal> YearSet = new Set<Decimal>();
        
        for(String str : DistributorList){
            DistributorSet.add(str);
        }
        
        for(String str : branches){
            DistributorBranch.add(str);
        }
        
        for(String str : regionList){
            regionSet.add(str);
        }
        
        for(String str : monthValue){
           MonthSet.add(str);
       }
       for(String str : yearValue){
           YearSet.add(Decimal.valueOf(str));
       }
        
        List<Account> acc = new List<Account>([SELECT Name,SAP_ID__c,Sales_RegionA__c FROM Account WHERE id IN: DistributorBranch]);
        Set<String> sapId = new Set<String>();
		for(Account a : acc){
           sapId.add(a.SAP_ID__c);
       	}
        List<Account> acc1 = new List<Account>([SELECT Name,SAP_ID__c,Sales_RegionA__c FROM Account WHERE id IN: DistributorSet]);
        Set<String> sapId1 = new Set<String>();
		for(Account a : acc1){
           sapId1.add(a.SAP_ID__c);
       	}
        System.debug('sap id::'+sapId);
        List<SObject> tableData = new List<SObject>();
        system.debug('DistributorList'+DistributorSet);
        system.debug('lookUpField'+regionSet);
        system.debug('monthValue'+MonthSet);
        system.debug('yearValue'+YearSet);
        String query;
        if(columns != null && DistributorBranch.size()>0 && reportName == 'TT Error Data - AWAARE' && partnerType == 'Direct Dealer'){
            System.debug('1');
        	query = 'Select ' +columns +  ' from ' + SelectedObject + ' where  Partner_Code__c IN :sapId1 AND Year__c IN :YearSet AND Month__c IN :MonthSet AND Error_Log__c != null';
        }
        else if(columns != null && DistributorBranch.size()>0 && reportName == 'TT Error Data - AWAARE' && partnerType == 'Distributor'){
        	            System.debug('2');
            query = 'Select ' +columns +  ' from ' + SelectedObject + ' where  Partner_Code__c IN :sapId AND Year__c IN :YearSet AND Month__c IN :MonthSet AND Error_Log__c != null';
        }
        else if(columns != null && DistributorBranch.size()>0 && reportName == 'TT Error Data - Distributor' && partnerType == 'Direct Dealer'){
        	            System.debug('3');
            query = 'Select ' +columns + ', Distributor_Ship_To__c  from ' + SelectedObject + ' where Distributor_Ship_To__c IN :sapId1 AND Month__c IN :MonthSet AND Error_Log__c != null';
        }
        else if(columns != null && DistributorBranch.size()>0 && reportName == 'TT Error Data - Distributor' && partnerType == 'Distributor'){
        	            System.debug('4');
            query = 'Select ' +columns + ', Distributor_Ship_To__c  from ' + SelectedObject + ' where Distributor_Ship_To__c IN :sapId AND Month__c IN :MonthSet AND Error_Log__c != null';
        }
        else{
            System.debug('No Query');
        }
        system.debug('query'+query); 
        tableData = database.query(query);
        List<Account> a = [select name, Sap_Id__c, Sales_RegionA__c, Distributor__c from Account where sap_id__c in :sapId];  
        System.debug('data' + tableData);      
        System.debug('accounts' + a);              
        return new DataAndAccount(tableData, a);
    }
    
    @AuraEnabled
    public static List<String> regionList(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.Sales_RegionA__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		} 
        System.debug(pickListValuesList);
		return pickListValuesList;
    }

        
    @AuraEnabled
    public static profilewrapp profileCheck(){
        List<Account> account = new List<Account>();
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        List<pickListWrapper> DistributorNames = new List<pickListWrapper>();
        list<pickListWrapper> RegionName = new list<pickListWrapper>();
        string PartnerType;
        
        Id profileId=userinfo.getProfileId(); 
       // String profileName=[Select Id,Name from Profile where Id='00e0r000000M2lZAAS'].Name;
         String profileName=[Select Id,Name from Profile where Id=: profileId].Name;
        //Revoke the use of PRP_Profile__mdt metadata.
        /*List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               profileName=pmap.get(s);
            }
        }*/
        if(profileName == 'PRP Partner'){
            ID userId = UserInfo.getUserId();
            //User u = [select id, contact.AccountId from User where id = '0050r000001GlO4AAK' LIMIT 1];
            User u = [select id, contact.AccountId from User where id =: userId LIMIT 1];
            account = [SELECT ID,Sales_RegionA__c,Type,name,SAP_ID__c FROM Account WHERE ID = :u.contact.AccountId LIMIT 1];
            if(account.size() > 0){
                DistributorNames.add(new pickListWrapper(account[0].Id,account[0].name+'('+account[0].SAP_ID__c+')'));
                RegionName.add(new pickListWrapper(account[0].Sales_RegionA__c,account[0].Sales_RegionA__c));
                PartnerType = account[0].Type;
                
            }
            /*List<Account> accountList = new List<Account>([Select id,name,Type, AccountSAPField__c  from Account where parentId = :DistributorNames[0].ID]);
            for(Account acc : accountList){
                AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
            } */ 
        }
        return new profilewrapp(DistributorNames,RegionName,PartnerType,profileName);
    }
    
    public Class pickListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        public pickListWrapper(String Idx,String Namex){
            this.Id=Idx;
            this.Name = Namex;         
        }
    }

    public Class regionAndFields{
        @AuraEnabled public List<pickListWrapper> fields;
        @AuraEnabled public List<pickListWrapper> RegionNames;
        @AuraEnabled public List<pickListWrapper> defaultFields;
        @AuraEnabled public String objectName;
        @AuraEnabled public List<pickListWrapper> months;
        @AuraEnabled public List<pickListWrapper> years;
        public regionAndFields(List<pickListWrapper> fields,List<pickListWrapper> RegionNames,
                               List<pickListWrapper> defaultFields, String objectName,
                                List<pickListWrapper> months, List<pickListWrapper> years){
            this.fields = fields;
            this.RegionNames = RegionNames;
            this.defaultFields = defaultFields;
            this.objectName = objectName;
            this.months = months;
            this.years = years;
        }
    }
    public Class DataAndAccount{      
        @AuraEnabled public List<SObject> tat; 
        @AuraEnabled public List<Account> acc; 
        public DataAndAccount(List<SObject> tat, List<Account> acc){  
            this.tat = tat;  
            this.acc = acc;  
        }
    }
    public class profilewrapp{
         @AuraEnabled public List<pickListWrapper> DistributorNames;
        @AuraEnabled public List<pickListWrapper> RegionName;
        @AuraEnabled public String PartnerType;
        @AuraEnabled public String profileName;
        public profilewrapp(List<pickListWrapper> DistributorNames,List<pickListWrapper> RegionName,String PartnerType,String profileName){
            this.DistributorNames = DistributorNames;
            this.RegionName = RegionName;
            this.PartnerType = PartnerType;
             this.profileName = profileName;
        }
    }
}