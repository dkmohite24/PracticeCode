/*
 * Desc : CHG0043864: Corrected Location values & show results retrived under type ‘Direct Dealer Location’ for Training. 
 * Updated By : Susovan Mondal.
 * Updated Date : 08/18/2023
 *
 * Update : DMND4624 - Revoke the use of PRP_Profile__mdt metadata.
 * Update By : Susovan Mondal & Chinmaya Dash
 * Update Date : 08/23/2023
 *  
 * Update : CHG44863 - Fetch data for ETC Data Reports and send them to the “PRPL_TrainingDataReport” component.
 * Update By : Susovan Mondal & Chinmaya Dash
 * Update Date : 02/22/2023
 */

public without sharing class  PRPC_transacErrorApexClass {   
    @AuraEnabled
    public static regionAndFields objectFields(String reportName) {
        list<Metric_Detail__mdt> Metric = new list<Metric_Detail__mdt>([select API_name__c,MasterLabel from Metric_Detail__mdt]);
        List<pickListWrapper> MetricValue = new List<pickListWrapper>();
        for(Metric_Detail__mdt mtr : Metric){
            MetricValue.add(new pickListWrapper(mtr.API_name__c,mtr.MasterLabel));
        }
        List<Account> account = new List<Account>();
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        List<pickListWrapper> DistributorNames = new List<pickListWrapper>();
        Id profileId=userinfo.getProfileId(); 
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
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
            User u = [select id, contact.AccountId from User where id = : UserId LIMIT 1];
            account = [SELECT ID FROM Account WHERE ID = :u.contact.AccountId LIMIT 1];
            if(account.size() > 0){
                DistributorNames.add(new pickListWrapper(account[0].Id,account[0].Id));
            }
            List<Account> accountList = new List<Account>([Select id,name,Type, AccountSAPField__c  from Account where parentId = :DistributorNames[0].ID]);
            for(Account acc : accountList){
                AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
            }  
        }
        
        String lookupVar='';
        System.debug('reportName'+reportName);
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name = :reportName LIMIT 1];
        System.debug('rp'+rp);
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
            if(sfield.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                system.debug('sfield.getDescribe().getReferenceTo()'+sfield.getDescribe().getReferenceTo());
                if(String.valueof(sfield.getDescribe().getReferenceTo()[0]) == 'Account'){
                    lookupVar = String.valueOf(sfield);
                    System.debug('Original Lookup Field ::'+lookupVar);
                    lookupVar = lookupVar.replace('__c', '__r.');
                    System.debug('Replaced Lookup Field ::'+lookupVar);
                    Map<String , Schema.SObjectType> globalDescriptionP = Schema.getGlobalDescribe();
                    Schema.sObjectType objTypeP = globalDescription.get('Account'); 
                    Schema.DescribeSObjectResult r2 = objTypeP.getDescribe(); 
                    Map<String , Schema.SObjectField> fieldMap1 = r2.fields.getMap(); 
                    for(Schema.SObjectField sfield1 : fieldMap1.Values())
                    {
                        schema.describefieldresult dfield1 = sfield1.getDescribe();
                        wrapfieldsList.add(new pickListWrapper(String.valueOf(lookupVar+dfield1.getname()),dfield1.getLabel()));
                        system.debug('wrapfieldsList'+wrapfieldsList);
                    }
                } 
            }
            
        }
        List<pickListWrapper> defaultfieldsList = new List<pickListWrapper>();
        for(String defaults : defaultColumns){
            for(pickListWrapper field1 : wrapfieldsList){
                if(field1.Id == defaults){
                    defaultfieldsList.add(field1);
                }
            }
        }System.debug('Default Fields- ' + defaultfieldsList);
        return new regionAndFields(wrapfieldsList, regionNames, defaultfieldsList, rp[0].Report_Object__c,lookupVar,monthField,yearField,AccountNames,DistributorNames,profileName,MetricValue);
    }
    
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributors(List<String> selectedRegion) 
    {
        system.debug('region'+selectedRegion);
        List<Account> accountList = new List<Account>([Select id,name,Type from Account where Sales_RegionA__c IN: selectedRegion AND Type='Distributor']);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.name));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributorsByPartner(List<String> selectedRegion,String partnervalue) 
    {
        system.debug('region'+selectedRegion);
        system.debug('Dealer type :::'+partnervalue);
        List<Account> accountList = new List<Account>([Select id,name,Type,AccountSAPField__c from Account where Sales_RegionA__c IN: selectedRegion AND Type=:partnervalue ORDER BY AccountSAPField__c]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.AccountSAPField__c));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> FetchBranch(List<String> disList, String reportname) 
    {
        system.debug('serviceLocationList'+disList);
        List<Account> accountList = new List<Account>();
        if(reportname == 'Training Data_DLR'){
            System.debug('Inside DLR');
            accountList =([Select id,name,Type,city__c  from Account where Parent.name IN: disList AND Type='Service Dealer'AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY city__c]);        
        }
        else{
            accountList =([Select id,name,Type,city__c  from Account where Parent.name IN: disList AND Type='Distributor Branch' AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY city__c]);        
        }
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.city__c));
        }
        return AccountNames;
    }
    
    
    
    @AuraEnabled
    public static regionAndFieldsv1 FetchBranchTraining(List<String> disList, String branchType,List<String> regionList, String ReportsNames)
    {
        System.debug('Distributor'+disList);
        System.debug('Branch Type'+branchType);
        System.debug('regionList'+regionList);
        List<pickListWrapper> wrapfieldsList = new List<pickListWrapper>();
        //String reportName='';
        //reportName='Training Data';
        
        List<Account> accountList = new List<Account>();
        if(branchType=='Direct Dealer Location'){//43864- Updated to fetch DD
            accountList=[Select id,name,Type,city__c,CitySAPField__c from Account where id IN: disList and Type='Direct Dealer'AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY CitySAPField__c];
        }
        else{
            accountList =[Select id,name,Type,city__c,CitySAPField__c  from Account where Parent.id IN: disList and Type='Distributor Branch' AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY CitySAPField__c];  
        }
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.CitySAPField__c));
        }
        String lookupVar='';
        System.debug('reportName'+ReportsNames);
        List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name = :ReportsNames LIMIT 1];
        System.debug('rp'+rp);
        List<String> defaultColumns = rp[0].Report_Columns__c.split(',');
        System.debug('defaultColumns- ' + defaultColumns);
        List<String> fields = new List<String>();
        Schema.SObjectType RefParObj;
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        Schema.sObjectType objType = globalDescription.get(rp[0].Report_Object__c); 
        Schema.DescribeSObjectResult r1 = objType.getDescribe(); 
        Map<String , Schema.SObjectField> fieldMap = r1.fields.getMap(); 
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            Schema.DisplayType FldType = sfield.getDescribe().getType();
            wrapfieldsList.add(new pickListWrapper(dfield.getname(),dfield.getLabel()));
            if(sfield.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                system.debug('sfield.getDescribe().getReferenceTo()'+sfield.getDescribe().getReferenceTo());
                if(String.valueof(sfield.getDescribe().getReferenceTo()[0]) == 'Account'){
                    lookupVar = String.valueOf(sfield);
                    System.debug('Original Lookup Field ::'+lookupVar);
                    lookupVar = lookupVar.replace('__c', '__r.');
                    System.debug('Replaced Lookup Field ::'+lookupVar);
                    Map<String , Schema.SObjectType> globalDescriptionP = Schema.getGlobalDescribe();
                    Schema.sObjectType objTypeP = globalDescription.get('Account'); 
                    Schema.DescribeSObjectResult r2 = objTypeP.getDescribe(); 
                    Map<String , Schema.SObjectField> fieldMap1 = r2.fields.getMap(); 
                    for(Schema.SObjectField sfield1 : fieldMap1.Values())
                    {
                        schema.describefieldresult dfield1 = sfield1.getDescribe();
                        wrapfieldsList.add(new pickListWrapper(String.valueOf(lookupVar+dfield1.getname()),dfield1.getLabel()));
                        system.debug('wrapfieldsList'+wrapfieldsList);
                    }
                } 
            }
            
        }
        List<pickListWrapper> defaultfieldsList = new List<pickListWrapper>();
        for(String defaults : defaultColumns){
            for(pickListWrapper field1 : wrapfieldsList){
                if(field1.Id == defaults){
                    defaultfieldsList.add(field1);
                }
            }
        }
        return new regionAndFieldsv1(AccountNames,defaultfieldsList,wrapfieldsList);
        
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
            accountList =([Select id,name,Type,city__c,CitySAPField__c,AccountSAPField__c  from Account where Parent.Id IN: disList AND Type='Distributor Branch' AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY CitySAPField__c]);        
        }
        else if(partner == 'Distributor' && reportname== 'Training Data_DLR'){
            accountList =([Select id,name,Type,city__c,CitySAPField__c,AccountSAPField__c  from Account where Parent.Id IN: disList AND Type='Service Dealer' AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY CitySAPField__c]);        
        }
        else if(partner == 'Direct Dealer'){
            accountList =([Select id,name,Type,city__c,AccountSAPField__c,CitySAPField__c  from Account where Id IN: disList AND (Sales_RegionA__c !=null or Location_Type__c !=null) ORDER BY CitySAPField__c]);                
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
    public static List<Sobject> FetchRecordsforTable(List<string> locationList,List<String> DistributorList,List<String> BranchList,List<String>metricdetails,List<String> regionList,String columns,String SelectedObject, String lookupVar, List<String> monthValue, List<String> yearValue,String reportname,String dateStart, String DateEnd,String partnerType) 
    {
        String FromDate='';
        string ToDate='';     
        if(reportname=='Training Data' && !regionList.contains('North America')){
            
            Datetime dtFrom = Date.ValueOf(DateStart);
            FromDate = dtFrom.formatGMT('yyyy-DLRMM-dd\'T\'hh:mm:ss\'Z\'');
            Datetime dtTo = Date.ValueOf(DateEnd);
            ToDate = dtTo.formatGMT('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        }
        system.debug('In here ');
        System.debug('Columns- ' + columns);
        System.debug('SelectedObject in Fetch ::'+SelectedObject);
        System.debug('SelectedObject in Fetch');
        System.debug('reportName'+reportname);
        Set<ID> locationset = new Set<ID>();
        Set<ID> DistributorSet = new Set<ID>();
        Set<ID> BranchSet = new Set<ID>();
        Set<String> regionSet = new Set<String>();
        Set<String> MonthSet = new Set<String>();
        Set<Decimal> YearSet = new Set<Decimal>();
        for(String str : locationList){
            locationset.add(str);
        }
        for(String str : DistributorList){
            DistributorSet.add(str);
        }
        for(String str : BranchList){
            BranchSet.add(str);
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
        List<SObject> tableData = new List<SObject>();
        system.debug('BranchList'+BranchList);
        system.debug('DistributorList'+DistributorSet);
        system.debug('LocationSet'+locationset);
        String query;
        lookupVar = lookupVar.replace('__r.', '__c');
        System.debug('monthValue'+MonthSet);
        System.debug('yearValue'+YearSet);
        if(columns != null){
            /*if(reportname=='Training Data' && !regionList.contains('North America')){
columns='';
List<Reporting_Type__c> rp = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name ='Metrics Total'];
columns=rp[0].Report_Columns__c+',';
for(integer i = 0; i<metricdetails.size();i++){
columns += metricdetails[i]+',';
}
columns=columns.substring(0,columns.length()-1); 
query = 'Select ' +columns +  ' from ' + 'KPI__c' + ' where Customer__r.parent.Id IN: DistributorList And CreatedDate <='+ ToDate +' And CreatedDate >='+ FromDate +'\'';
query = query.substring(0,query.length()-1);
}
if(reportname =='Total Parts Sold-Retran' && !regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'RET\'';
}
else if(reportname =='Total Parts Sold-Retran' && regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'RET\'';
}
else  if(reportname=='Total Parts Sold Data' && !regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'TPS\'';
}
else if(reportname =='Total Parts Sold Data' && regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'TPS\'';
}
else if(reportname == 'Total Parts Sold AND Total Retran' && !regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND (Parts_Sold_Type__c =\'TPS\' OR Parts_Sold_Type__c =\'RET\') LIMIT 200';
}
else if(reportname == 'Total Parts Sold AND Total Retran' && regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND (Parts_Sold_Type__c =\'TPS\' OR Parts_Sold_Type__c =\'RET\')';
}
else if(reportname == 'CSI Data' && !regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet';
}
else if(reportname == 'CSI Data' && regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet';
}
else if(reportname == 'PO Data' && !regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet';
}
else if(reportname == 'PO Data' && regionList.contains('North America')){
System.debug('reportname'+reportname);
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet';
}
else{
System.debug('Default');
query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet';
}*/
            if(reportname =='Total Parts Sold-Retran' && partnerType == 'Direct Dealer'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'RET\' ORDER BY Customer__r.SAP_ID__c';
            }
            else if(reportname =='Total Parts Sold-Retran' && partnerType == 'Distributor'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'RET\' ORDER BY Customer__r.SAP_ID__c';
            }
            else  if(reportname=='Total Parts Sold Data' && partnerType == 'Direct Dealer'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'TPS\' ORDER BY Customer__r.SAP_ID__c';
            }
            else if(reportname =='Total Parts Sold Data' && partnerType == 'Distributor'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Parts_Sold_Type__c =\'TPS\' ORDER BY Customer__r.SAP_ID__c';
            }
            else if(reportname == 'Total Parts Sold AND Total Retran' && partnerType == 'Direct Dealer'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND (Parts_Sold_Type__c =\'TPS\' OR Parts_Sold_Type__c =\'RET\') ORDER BY Customer__r.SAP_ID__c LIMIT 200';
            }
            else if(reportname == 'Total Parts Sold AND Total Retran' && partnerType == 'Distributor'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND (Parts_Sold_Type__c =\'TPS\' OR Parts_Sold_Type__c =\'RET\') ORDER BY Customer__r.SAP_ID__c';
            }
            else if(reportname == 'CSI Data' && partnerType == 'Direct Dealer'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet ORDER BY Customer_Dealer_Id__r.SAP_ID__c';
            }
            else if(reportname == 'CSI Data' && partnerType == 'Distributor'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet ORDER BY Customer_Dealer_Id__r.SAP_ID__c';
            }
            else if(reportname == 'PO Data' && partnerType == 'Direct Dealer'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet ORDER BY Ship_To__r.SAP_ID__c';
            }
            else if(reportname == 'PO Data' && partnerType == 'Distributor'){
                System.debug('reportname'+reportname);
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet ORDER BY Ship_To__r.SAP_ID__c';
            }
            else{
                System.debug('Default');
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet';
            }
        }
        system.debug('query'+query); 
        tableData = database.query(query);
        system.debug('Data :::::'+tableData);
        return tableData;
    }
    
    
    @AuraEnabled
    public static List<Sobject> FetchRecordsforTrainingTable(String reportnames,List<String> DistributorList,List<String> BranchList,List<String> regionList,String columns,List<String> monthValue, List<Integer> yearValue,String partnerType){
        List<SObject> tableData = new List<SObject>();
        System.debug('report name: '+reportnames);
        System.debug('Distributors: '+DistributorList);
        System.debug('Branches: '+BranchList);
        System.debug('Regions: '+regionList);
        System.debug('Selected columns'+ columns);
        System.debug('Months: '+monthValue);
        System.debug('partnerType: '+ partnerType);
        
        List<Reporting_Type__c> reportDetails = [SELECT Name, Report_Object__c, Report_Columns__c FROM Reporting_Type__c WHERE Name = :reportnames LIMIT 1];
        String query;
        //43864 - Added partner type
        if(reportnames=='Training Data' && partnerType !='Direct Dealer Location'){
            query = 'Select ' +columns +  ' from ' + reportDetails[0].Report_Object__c + ' where Customer__c IN: BranchList AND Month_Name__c IN: monthValue AND Year__c IN: yearValue AND Customer__r.parentId IN:DistributorList';
        }
        else if(reportnames=='Training Data' && partnerType =='Direct Dealer Location'){
            query = 'Select ' +columns +  ' from ' + reportDetails[0].Report_Object__c + ' where Customer__c IN: BranchList AND Month_Name__c IN: monthValue AND Year__c IN: yearValue';
        }//43864 [End]
        // CHG44863 - Fetch data for ETC Data Reports
        if(reportnames=='ETC Data' && partnerType !='Direct Dealer Location'){
            query = 'Select ' +columns +  ' from ' + reportDetails[0].Report_Object__c + ' where Customer__c IN: BranchList AND Month_Name__c IN: monthValue AND Year__c IN: yearValue AND Customer__r.parentId IN:DistributorList';
        }
        System.debug('Query'+query);
        tableData = database.query(query);
        system.debug('Data :::::'+tableData);
        system.debug('Data Size:::::'+tableData.size());
        return tableData;
    }
    
    
    @AuraEnabled
    public static CommunityDetails regionList(){ 
        CommunityDetails returnResponse=new CommunityDetails();
        List<pickListWrapper> BranchListWrap= new List<pickListWrapper>();
        List<AccountContactRelation> accRel = new List<AccountContactRelation>();
        List<Account> accountstr = new List<Account>();
        String regionVal='Test';
        //String DistValVal='Test';
        list<pickListWrapper>DistValVal = new list<pickListWrapper>();
        Set<Id> IdOfAccounts = new Set<Id>();
        String DistValId='Test';
        User currentuser=new User();
        currentuser=[Select Id,ContactId,ProfileId from User where Id=:userinfo.getuserId()];
        If([Select Name from profile where id=:currentuser.profileId].Name=='PRP Partner'){
            ID userId = UserInfo.getUserId();
            //User u = [select id, contact.AccountId from User where id = '0050r000001GlO4AAK' LIMIT 1];
            User u = [select id, contactId,contact.AccountId from User where id =: userId LIMIT 1];
            accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where contactId= :u.ContactId];
            for(AccountContactRelation ac : accRel){
                IdOfAccounts.add(ac.AccountId);
            }
            accountstr = [SELECT ID,Sales_RegionA__c,Type,name,SAP_ID__c,AccountSAPField__c FROM Account WHERE ID IN :IdOfAccounts];
            List<Account> BranchList =New List<Account>([Select id,name,Type,CitySAPField__c  from Account where Parent.id IN: IdOfAccounts]);  
        if(accountstr.size() > 0){
                for(Account acc:accountstr){
                DistValVal.add(new pickListWrapper(acc.Id,acc.AccountSAPField__c));
                regionVal = accountstr[0].Sales_RegionA__c;
                //RegionName.add(new pickListWrapper(acc.Sales_RegionA__c,acc.Sales_RegionA__c));
                //PartnerType = account[0].Type;
                }
        }
            for(Account acc : BranchList){
                BranchListWrap.add(new pickListWrapper(acc.id,acc.CitySAPField__c));
            }
        /*System.debug('Logged Is User Details'+[Select Name from profile where id=:currentuser.profileId].Name);
        If([Select Name from profile where id=:currentuser.profileId].Name=='PRP Partner'){
            Contact conDetails=[Select AccountId,Account.AccountSAPField__c,Account.Sales_RegionA__c from Contact where Id=:currentuser.ContactId];
            DistValVal=conDetails.Account.AccountSAPField__c;
            regionVal=conDetails.Account.Sales_RegionA__c;
            List<Account> BranchList =New List<Account>([Select id,name,Type,CitySAPField__c  from Account where Parent.id=:conDetails.AccountId]);  
            DistValId=conDetails.AccountId;
            for(Account acc : BranchList){
                BranchListWrap.add(new pickListWrapper(acc.id,acc.CitySAPField__c));
            }
            
        }*/
                               }
        List<pickListWrapper> pickListValuesList= new List<pickListWrapper>();
        Schema.DescribeFieldResult fieldResult = Account.Sales_RegionA__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(new pickListWrapper(pickListVal.getLabel(),pickListVal.getLabel()));
        } 
        System.debug(pickListValuesList);
        returnResponse.RegionDetails=pickListValuesList;
        returnResponse.BranchDetails=BranchListWrap;
        returnResponse.RegionName=regionVal;
        returnResponse.DistributorName=DistValVal;
        returnResponse.DistributorId=DistValId;
        return returnResponse;
    }
    
     @AuraEnabled
    public static profilewrapp profileCheck(){
        List<Account> account = new List<Account>();
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        List<pickListWrapper> DistributorNames = new List<pickListWrapper>();
        list<pickListWrapper> RegionName = new list<pickListWrapper>();
        Set<String> RegionNameSet = new Set<String>();
        string PartnerType;
        
        Set<Id> IdOfAccounts = new Set<Id>();
        Id profileId=userinfo.getProfileId(); 
        List<AccountContactRelation> accRel = new List<AccountContactRelation>();
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
            User u = [select id, contactId,contact.AccountId from User where id =: userId LIMIT 1];
            accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where contactId= :u.ContactId];
            for(AccountContactRelation ac : accRel){
                IdOfAccounts.add(ac.AccountId);
            }
            account = [SELECT ID,Sales_RegionA__c,Type,name,SAP_ID__c,AccountSAPField__c FROM Account WHERE ID IN :IdOfAccounts];
            if(account.size() > 0){
                for(Account acct : account){
			    DistributorNames.add(new pickListWrapper(acct.Id,acct.AccountSAPField__c));
                RegionNameSet.add(acct.Sales_RegionA__c);
                //RegionName.add(new pickListWrapper(acct.Sales_RegionA__c,acct.Sales_RegionA__c));
                PartnerType = account[0].Type;                
                 }
            }
            for(String pw : RegionNameSet){
                RegionName.add(new pickListWrapper(pw,pw));
            }
           System.debug('DistributorNames:: '+DistributorNames);
           System.debug('RegionName:: '+RegionName);
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
        @AuraEnabled public String lookupVar;
        @AuraEnabled public List<pickListWrapper> monthFields;
        @AuraEnabled public List<pickListWrapper> yearFields;
        @AuraEnabled public List<pickListWrapper> branch;
        @AuraEnabled public List<pickListWrapper> AccountId;
        @AuraEnabled public List<picklistWrapper> metricdetails;
        @AuraEnabled public String profileName;
        public regionAndFields(List<pickListWrapper> fields,List<pickListWrapper> RegionNames, List<pickListWrapper> defaultFields, String objectName, String lookupVar,List<pickListWrapper> monthFields,List<pickListWrapper> yearFields,List<pickListWrapper> branch,List<pickListWrapper> AccountId,String profileName,List<picklistWrapper> metricdetails){
            this.fields = fields;
            this.metricdetails=metricdetails;
            this.RegionNames = RegionNames;
            this.defaultFields = defaultFields;
            this.objectName = objectName;
            this.lookupVar = lookupVar;
            this.monthFields = monthFields;
            this.yearFields = yearFields;
            this.branch = branch;
            this.AccountId = AccountId;
            this.profileName = profileName;
        }
    }
    public Class regionAndFieldsv1{
        @AuraEnabled public List<pickListWrapper> AccountDetails;
        @AuraEnabled public List<pickListWrapper> FieldDetails;
        @AuraEnabled public List<pickListWrapper> fields;
        public regionAndFieldsv1(List<pickListWrapper>AccountDetails,List<pickListWrapper>FieldDetails,List<pickListWrapper> fields){
            this.AccountDetails=AccountDetails;
            this.FieldDetails=FieldDetails;
            this.fields=fields;
        }
    }
    
    public Class CommunityDetails{
        @AuraEnabled public List<pickListWrapper> RegionDetails;
        @AuraEnabled Public List<pickListWrapper> BranchDetails;
        @AuraEnabled public String RegionName;
        @AuraEnabled public List<pickListWrapper>DistributorName;
        @AuraEnabled public String DistributorId;
        
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