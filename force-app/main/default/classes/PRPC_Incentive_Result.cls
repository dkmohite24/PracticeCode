/*
 * Update : CHG44065-Update the profile check for PRP Admin & CSM User to custom permissions. 
  * Update By : 08/23/2023,Susovan Mondal & Chinmaya Das
 */

public class PRPC_Incentive_Result {
    
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
        
        List<pickListWrapper> regionNames = new List<pickListWrapper>();
        List<String> reg = new List<String>{'North America', 'Latin America','EMEA','Asia Pacific'};
            for(String m : reg){
                regionNames.add(new pickListWrapper(m,m));
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
            if(sfield.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                system.debug('sfield.getDescribe().getReferenceTo()'+sfield.getDescribe().getReferenceTo());
                if(String.valueof(sfield.getDescribe().getReferenceTo()[0]) == 'Account'){
                    lookUpField = String.valueOf(sfield);
                    lookUpField = lookUpField.replace('__c', '__r.');
                    Map<String , Schema.SObjectType> globalDescriptionP = Schema.getGlobalDescribe();
                    Schema.sObjectType objTypeP = globalDescription.get('Account'); 
                    Schema.DescribeSObjectResult r2 = objTypeP.getDescribe(); 
                    Map<String , Schema.SObjectField> fieldMap1 = r2.fields.getMap(); 
                    for(Schema.SObjectField sfield1 : fieldMap1.Values())
                    {
                        schema.describefieldresult dfield1 = sfield1.getDescribe();
                        wrapfieldsList.add(new pickListWrapper(String.valueOf(lookUpField+dfield1.getname()),dfield1.getLabel()));
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
        
        System.debug('Default Fields- ' + defaultfieldsList);
        
        return new regionAndFields(wrapfieldsList, regionNames, defaultfieldsList, rp[0].Report_Object__c, lookUpField, monthField, yearField);
    }
    
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributorsByPartner(List<String> selectedRegion,String partnervalue) 
    {
        system.debug('region'+selectedRegion);
        system.debug('Dealer type :::'+partnervalue);
        List<Account> accountList = new List<Account>([Select id,name,Type,AccountSAPField__c from Account where Sales_RegionA__c IN: selectedRegion AND Type=:partnervalue order by AccountSAPField__c]);
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
        List<Account> accountList = new List<Account>([Select id,name, ShippingCity, Type, AccountSAPField__c, SAP_ID__c  from Account where parentId IN: distributors AND Type='Distributor Branch' AND (Sales_RegionA__c !=null or Location_Type__c !=null) order by ShippingCity]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            String city = acc.ShippingCity+'('+acc.SAP_ID__c+')';
            AccountNames.add(new pickListWrapper(acc.id,city));
        }
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<Sobject> FetchRecordsforTable(List<String> DistributorList, String partnerType, List<String> branches, 
                                                     List<String> regionList, String columns,String SelectedObject, String lookUpField,
                                                     List<String> monthValue, List<String> yearValue,String profileName,String report) 
    {
        
        system.debug('In here ');
        System.debug('Columns- ' + columns);
        System.debug('report ' + report);
        System.debug('profileName'+ profileName);
        // CHG44065 Removing the PRP_Profile__mdt metadata.
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
        Set<ID> DistributorSet = new Set<ID>();
        Set<ID> DistributorBranch = new Set<ID>();
        Set<String> regionSet = new Set<String>();
        Set<String> MonthSet = new Set<String>();
        Set<Decimal> YearSet = new Set<Decimal>();
        List<Account> subparentacc = [Select id,ParentId,Name from Account where Name LIKE '%Subparent%'];
      
        Map<Id,Set<Id>> parentmap = new Map<Id,Set<Id>>();
       // CHG-42909 by Akanksha [Start]
        for(Account a:subparentacc){
            if(parentmap.containskey(a.ParentId)){
                 parentmap.get(a.ParentId).add(a.id);
            }
            else{
                 Set<Id> subparentlist = new Set<Id>();
                subparentlist.add(a.id);
                parentmap.put(a.ParentId, subparentlist);
            }
           
        }
        // CHG-42909 by Akanksha [End]
        for(String str : DistributorList){
            DistributorSet.add(str);
            if(parentmap.containsKey(str)){
                DistributorSet.addAll(parentmap.get(str));
            }
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
        
        List<SObject> tableData = new List<SObject>();
        system.debug('DistributorList'+DistributorSet);
        system.debug('DistributorBranch'+DistributorBranch);
        system.debug('columns'+columns);
        system.debug('Regions'+regionSet);
        system.debug('monthValue'+MonthSet);
        system.debug('yearValue'+YearSet);
        String query;
        if(report == 'Warranty Parts Consumed Data'){
            if(partnerType == 'Distributor'){
            query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'parentId IN :DistributorSet AND Year__c IN :YearSet AND Parts_Sold_Type__c =\'WPC\'';
            }
            else if(partnerType == 'Direct Dealer'){
            query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'Id IN :DistributorSet AND Year__c IN :YearSet AND Parts_Sold_Type__c =\'WPC\'';
            }
        }
        else if(report == 'Incentive Summary'){
            System.debug('profileName IS'+ profileName);
       
            if(profileName == 'PRP Admin' || profileName == 'System Administrator'){
                System.debug('Inside Admin');
            query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'parentId IN :DistributorSet AND Year__c IN :YearSet';
            }
            else{
                System.debug('Inside Partner');
            query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'parentId IN :DistributorSet AND Year__c IN :YearSet AND Release_Incentive__c=\'X\'';
            }
        }
        else{
            if(columns != null && DistributorBranch.size()>0 && MonthSet.size()>0){
                lookUpField = lookUpField.replace('__r.', '__c');
                if(report == 'Total Parts Sold Data - International DDLR'){
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + ' IN :DistributorBranch AND Year__c IN :YearSet AND Month_Name__c IN :MonthSet';
                }
                else{
                    System.debug('157');
                    if(profileName == 'PRP Admin' || profileName == 'System Administrator'){
                        System.debug('Inside Admin');
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + ' IN :DistributorBranch AND Year__c IN :YearSet AND Month__c IN :MonthSet';   
                    }
                    else{
                        System.debug('Inside Partner');
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + ' IN :DistributorBranch AND Year__c IN :YearSet AND Month__c IN :MonthSet';   
                    }
                }
            }
            else if(columns != null && DistributorBranch.size()<1 && MonthSet.size()>0){
                System.debug('163');
                if(partnerType == 'Distributor'){
                    if(profileName == 'PRP Admin' || profileName == 'System Administrator'){
                        System.debug('Inside Admin');
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'parentId IN :DistributorSet AND Year__c IN :YearSet AND Month__c IN :MonthSet';
                    }
                    else{
                        System.debug('Inside Partner');
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'parentId IN :DistributorSet AND Year__c IN :YearSet AND Month__c IN :MonthSet AND Release_Incentive__c=\'X\'';
                    }
                }
                    else{
                    System.debug('166');
                    lookUpField = lookUpField.replace('__r.', '__c');
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + ' IN :DistributorSet AND Year__c IN :YearSet AND Month__c IN :MonthSet';
                }
            }
            else if(columns != null && DistributorBranch.size()<1 && MonthSet.size()<1){
                if(partnerType == 'Distributor'){
                    if(report == 'FC Claims Sales Data'){
                        query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'Id IN :DistributorSet AND Year__c IN :YearSet';
                    }
                    else
                        System.debug('178');
                        query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + 'Id IN :DistributorSet AND Year__c IN :YearSet';
                }
                else{
                    System.debug('182');
                    lookUpField = lookUpField.replace('__r.', '__c');
                    query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + ' IN :DistributorSet AND Year__c IN :YearSet';
                    
                }
            }
            else if(columns != null && DistributorBranch.size()>0 && MonthSet.size()<1){
                System.debug('189');
                lookUpField = lookUpField.replace('__r.', '__c');
                query = 'Select ' +columns +  ' from ' + SelectedObject + ' where ' + lookUpField + ' IN :DistributorBranch AND Year__c IN :YearSet';
            }
        }
        system.debug('query'+query); 
        tableData = database.query(query);
        
        return tableData;
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
        // CHG44065 Removing the PRP_Profile__mdt metadata
        /*
        List<PRP_Profile__mdt> plist = [select Profile_Name__c,Associated_Profile_Name__c from PRP_Profile__mdt ];
        Map<String,String> pmap = new Map<String,String>();
        for(PRP_Profile__mdt mdt:plist){
            pmap.put(mdt.Profile_Name__c,mdt.Associated_Profile_Name__c);
        }
        for(String s:pmap.keyset()){
            if(s==profileName){
               profileName=pmap.get(s);
            }
        }*/
        
        // CHG44065 Check the Custom permission
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        If(isPRPAdminPermission==true ){
            profileName='PRP Admin';
        }
        
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
        @AuraEnabled public String lookUpField;
        @AuraEnabled public List<pickListWrapper> months;
        @AuraEnabled public List<pickListWrapper> years;
        
        public regionAndFields(List<pickListWrapper> fields,List<pickListWrapper> RegionNames,
                               List<pickListWrapper> defaultFields, String objectName,
                               String lookUpField, List<pickListWrapper> months, List<pickListWrapper> years){
                                   this.fields = fields;
                                   this.RegionNames = RegionNames;
                                   this.defaultFields = defaultFields;
                                   this.objectName = objectName;
                                   this.lookUpField = lookUpField;
                                   this.months = months;
                                   this.years = years;
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