public class PRPC_TPSError_Report {
    
    @AuraEnabled
    public static regionAndFields objectFields(String reportName) {
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name = :reportName];
        List<String> obj = new List<String>();
        for(Reporting_Type__c r : rp){
            obj.add(r.Report_Object__c);
        }
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
        Integer Year = Date.Today().Year();
        for(Integer i= Year; i>=2013; i--){
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
        return new regionAndFields(wrapfieldsList, regionNames, defaultfieldsList, obj, monthField, yearField);
    }
    
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributors(List<String> selectedRegion) 
    {
        system.debug('region'+selectedRegion);
        List<Account> accountList = new List<Account>([Select id,name,AccountSAPField__c, Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Distributor' Order By AccountSAPField__c]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributorsByPartner(List<String> selectedRegion,String partnervalue) 
    {
        system.debug('region'+selectedRegion);
        system.debug('Dealer type :::'+partnervalue);
        List<Account> accountList = new List<Account>([Select id,name,Type,AccountSAPField__c from Account where Sales_RegionA__c IN: selectedRegion AND Type=:partnervalue Order By AccountSAPField__c]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> FetchBranch(List<String> DistributorList) 
    {
        system.debug('serviceLocationList'+DistributorList);
        List<Account> accountList = new List<Account>([Select id, ShippingCity, AccountSAPField__c,name,SAP_ID__c from Account where parentId IN: DistributorList AND Type='Distributor Branch' Order By AccountSAPField__c]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            String city = acc.ShippingCity+'('+acc.SAP_ID__c+')';
            AccountNames.add(new pickListWrapper(acc.id,city));
        }
        return AccountNames;
    }
    
    @AuraEnabled
    public static DataAndAccount FetchRecordsforTable(List<String> DistributorList, String partnerType, List<String> branches, 
                                                      List<String> regionList,String columns,List<String> SelectedObject,
                                                      List<String> monthValue, List<String> yearValue) 
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
        
        List<SObject> tableData1 = new List<SObject>();
        List<SObject> tableData2 = new List<SObject>();
        List<SObject> tableData3 = new List<SObject>();
        List<SObject> finalTableData = new List<SObject>();
        system.debug('DistributorList'+DistributorSet);
        System.debug('Distributor Branch ' + DistributorBranch);
        system.debug('lookUpField'+regionSet);
        system.debug('monthValue'+MonthSet);
        system.debug('yearValue'+YearSet);
        
        List<Account> a = new List<Account>();
        if(partnerType == 'Distributor')
        	a = [select name, Sap_Id__c, Sub_Region__c, Distributor__c from Account where ID in :DistributorBranch];
        else
            a = [select name, Sap_Id__c, Sub_Region__c, Distributor__c from Account where ID in :DistributorSet];
        Set<String> SAP_ID  = new Set<String>();
        for(Account sp : a){
            SAP_ID.add(sp.Sap_Id__c);
        }
        
        String query1, query2, query3;
        if(columns != null){
            query1 = 'Select ' +columns +  ' from ' + SelectedObject[0] + ' where Distributor_Ship_To__c IN :SAP_ID AND Month__c IN :MonthSet AND Year__c IN :YearSet AND Error_Log__c != null';
            query2 = 'Select ' +columns +  ' from ' + SelectedObject[1] + ' where Distributor_Ship_To__c IN :SAP_ID AND Month__c IN :MonthSet AND Year__c IN :YearSet AND Error_Log__c != null';
            query3 = 'Select ' +columns +  ' from ' + SelectedObject[2] + ' where Distributor_Ship_To__c IN :SAP_ID AND Month__c IN :MonthSet AND Year__c IN :YearSet AND Error_Log__c != null';
        }
        system.debug('query'+query1); 
        try{
        	tableData1 = database.query(query1);
        }
        catch(Exception e){}
        System.debug('data' + tableData1);
        try{
        	tableData2 = database.query(query2);
        }
        catch(Exception e){}
        System.debug('data' + tableData2);
        try{
       		tableData3 = database.query(query3);
        }
        catch(Exception e){}
        System.debug('data' + tableData3);
        for(SObject t : tableData1){
            finalTableData.add(t);
        }
        for(SObject t : tableData2){
            finalTableData.add(t);
        }
        for(SObject t : tableData3){
            finalTableData.add(t);
        } 
        
        System.debug('data' + finalTableData);
        System.debug('accounts' + a);
        
        return new DataAndAccount(finalTableData, a);
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
        @AuraEnabled public List<String> objectName;
        @AuraEnabled public List<pickListWrapper> months;
        @AuraEnabled public List<pickListWrapper> years;
        public regionAndFields(List<pickListWrapper> fields,List<pickListWrapper> RegionNames,
                               List<pickListWrapper> defaultFields, List<String> objectName,
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
        @AuraEnabled public List<SObject> tps;
        @AuraEnabled public List<Account> acc;
        public DataAndAccount(List<SObject> tps, List<Account> acc){
            this.tps = tps;
            this.acc = acc;         
        }
    }
    
    
}