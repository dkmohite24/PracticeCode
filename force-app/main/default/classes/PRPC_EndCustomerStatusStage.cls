/*
 * Update : CHG44065 - Revoke the use of PRP_Profile__mdt metadata.
 * Update By : Susovan Mondal & Chinmaya Das
 * Update Date : 08/23/2023
 */


public class PRPC_EndCustomerStatusStage {
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
    public static DataAndAccount FetchRecordsforTable(List<String> DistributorList, List<String> regionList, String partnerType,
                                                      String columns,List<String> SelectedObject,
                                                      List<String> monthValue, List<String> yearValue, String reportName) 
    {
        system.debug('In here ');
        System.debug('Columns- ' + columns);
        Set<ID> DistributorSet = new Set<ID>();
        Set<String> regionSet = new Set<String>();
        Set<String> MonthSet = new Set<String>();
        Set<Decimal> YearSet = new Set<Decimal>();
        
        for(String str : DistributorList){
            DistributorSet.add(str);
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
        
        List<SObject> finalTableData = new List<SObject>();
        system.debug('DistributorList'+DistributorSet);
        system.debug('lookUpField'+regionSet);
        system.debug('monthValue'+MonthSet);
        system.debug('yearValue'+YearSet);
        system.debug('Report Name is : '+reportName);
        String query;
        String branch = 'Distributor Branch';
        Account account = new Account();
        if(columns != null){
            if(partnerType == 'Distributor')
                query = 'Select ' +columns +  ' from ' + SelectedObject[0] + ' where parentId IN :DistributorSet AND Type=:branch';
            else
                query = 'Select ' +columns +  ' from ' + SelectedObject[0] + ' where Id IN :DistributorSet';
            try{
                finalTableData = database.query(query);
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        
        List<SObject> tt = new List<SObject>();
         if(reportName == 'End Customer Status_Stage'){
             System.debug('Inside End Customer Status_Stage');
            List<End_Customer_Staging_Data__c> endCust = [SELECT ID, Distributor_Ship_To__c,Month__c,Year__c FROM End_Customer_Staging_Data__c WHERE Month__c IN :MonthSet AND Year__c IN :YearSet];
             System.debug('endCust :'+endCust);
             for(End_Customer_Staging_Data__c t : endCust){
                tt.add(t);
            }
        }
        System.debug('data' + finalTableData);
        System.debug('tat' + tt);   
        return new DataAndAccount(finalTableData, tt);
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
        // CHG44065  Revoke the use of PRP_Profile__mdt metadata.
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
        @AuraEnabled public List<SObject> acc;
        @AuraEnabled public List<SObject> tat;
        public DataAndAccount(List<SObject> acc, List<SObject> tat){
            this.acc = acc;
            this.tat = tat;
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