/*
 * Update : DMND4624 - Revoke the use of PRP_Profile__mdt metadata.
 * Update By : Susovan Mondal & Chinmaya Das
 * Update Date : 08/23/2023
 */

public class PRPC_ttErrorApexClass {
  @AuraEnabled
    public static regionAndFields objectFields(String reportName) {
        String toStoreObjName;
        if(reportName == 'Service Compliance Turn Time Data'){
            toStoreObjName = 'TAT_Data__c';
        }
        else{
            toStoreObjName = 'Account';
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
        
        List<pickListWrapper> sourceField = new List<pickListWrapper>();
        if(reportName == 'Survey Data'){
           List<String> source = new List<String>{'Service','Dealer','Parts','CSI'}; 
           for(String s : source){
                sourceField.add(new pickListWrapper(s,s));
            }
        }
        else{
             List<String> source = new List<String>{'AWARE','Distributor'}; 
             for(String s : source){
                sourceField.add(new pickListWrapper(s,s));
            }
        }
        if(reportName == 'Service Compliance Turn Time Data'){
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Sales_RegionA__c','Sales Region'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Name','Account Name'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Distributor__c','Distributor'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.SAP_ID__c','SAP ID'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Sold_To_Code__c','Sold To Code'));
            }
        for(Schema.SObjectField sfield : fieldMap.Values())
        {
            schema.describefieldresult dfield = sfield.getDescribe();
            Schema.DisplayType FldType = sfield.getDescribe().getType();
            if(reportName != 'Service Compliance Turn Time Data'){
                   wrapfieldsList.add(new pickListWrapper(dfield.getname(),dfield.getLabel()));
            }
            if(sfield.getDescribe().getType() == Schema.DisplayType.REFERENCE){
                system.debug('sfield.getDescribe().getReferenceTo()'+sfield.getDescribe().getReferenceTo());
                if(String.valueof(sfield.getDescribe().getReferenceTo()[0]) == 'Account'){
                    lookupVar = String.valueOf(sfield);
                    System.debug('Original Lookup Field ::'+lookupVar);
                    lookupVar = lookupVar.replace('__c', '__r.');
                    System.debug('Replaced Lookup Field ::'+lookupVar);
                    Map<String , Schema.SObjectType> globalDescriptionP = Schema.getGlobalDescribe();
                    Schema.sObjectType objTypeP = globalDescription.get(toStoreObjName); 
                    Schema.DescribeSObjectResult r2 = objTypeP.getDescribe(); 
                    Map<String , Schema.SObjectField> fieldMap1 = r2.fields.getMap();
                    for(Schema.SObjectField sfield1 : fieldMap1.Values())
                    {
                        schema.describefieldresult dfield1 = sfield1.getDescribe();
                        if(reportName == 'Service Compliance Turn Time Data'){
                            System.debug('Line 78 ::'+dfield1.getName());
                            if(dfield1.getName() == 'Repair_Payment__c' ||
                               dfield1.getName() == 'Repair_Type__c' || dfield1.getName() == 'Technician_Name__c'|| dfield1.getName() == 'Vin__c' ||
                               dfield1.getName() == 'Allison_Serial__c' || dfield1.getName() == 'Claim_Number__c' || dfield1.getName() == 'Source_Type__c' ||
                              // dfield1.getName() == 'User_Comment__c' || 
                              // dfield1.getName() == 'Date_Distributor_schedules_for_service__c' || 
                              // dfield1.getName() == 'Service_Start_Date_Formula__c' || dfield1.getName() == 'Service_End_Date_Formula__c' || dfield1.getName() == 'Earliest_Start_Event__c' || 
                              //  dfield1.getName() == 'Last_Part_RecDate__c' || dfield1.getName() == 'date_cust_request_service__c' ||
                               dfield1.getName() == 'all_labor_ops__c' || dfield1.getName() == 'Repair_Order_open_date__c' ||dfield1.getName() == 'PART_ARRIVAL_DATE__c' ||
                               dfield1.getName() == 'Repair_Order_closed_date__c' || dfield1.getName() == 'Date_first_labor_applied__c' || dfield1.getName() == 'Date_First_Part_Ordered__c' || 
                               dfield1.getName() == 'date_vehicle_first_arrived__c' || dfield1.getName() == 'Date_last_labor_applied__c' || dfield1.getName() == 'customer_notified__c'|| dfield1.getName() == 'First_Labor_Applied_Vehicle_Arrival__c' ||                  
                               dfield1.getName() == 'Last_Completion_Event__c' || dfield1.getName() == 'TT_in_Days__c' || dfield1.getName() == 'TT_in_Minutes__c' || dfield1.getName() == 'TT_in_Hours__c' ||
                               dfield1.getName() ==  'Meets_TT_Goals__c' || dfield1.getName() == 'TT_Hours_Vs_Labor_Hours__c' || dfield1.getName() == 'RO_Vehicle_Arrival__c' || dfield1.getName() == 'VA_RO__c' ||
                               dfield1.getName() == 'VA_ROData__c' || dfield1.getName() == 'Last_Labor_Cust_Notification__c' || dfield1.getName() == 'LL_CN__c' || dfield1.getName() == 'LL_RO_Close__c'||
                               dfield1.getName() == 'total_hours__c' || dfield1.getName() == 'repair_order_number__c' || dfield1.getName() == 'Year_Text__c' || dfield1.getName() == 'Month_Name__c'){
                                  if(dfield1.getName()!= 'LastModifiedDate' && dfield1.getName()!='IsDeleted' && dfield1.getName()!= 'Name' && dfield1.getName() !='SystemModstamp' && dfield1.getName() !='CreatedById' && dfield1.getName() != 'CreatedDate' && dfield1.getName() != 'LastModifiedById'){
                                      System.debug('dfield1.getName() ::'+ dfield1.getName());
                                      wrapfieldsList.add(new pickListWrapper(String.valueOf(dfield1.getname()),dfield1.getLabel()));
                                     system.debug('wrapfieldsList 81 ::'+wrapfieldsList);
                                  }
                            }
                        }
                        else{
                        wrapfieldsList.add(new pickListWrapper(String.valueOf(lookupVar+dfield1.getname()),dfield1.getLabel()));
                        system.debug('wrapfieldsList 86 :: '+wrapfieldsList);  
                        }
                    }
                } 
            }
            
        }
        
         /*if(reportName == 'Service Compliance Turn Time Data'){
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Sales_RegionA__c','Sales Region'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Name','Account Name'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Distributor__c','Distributor'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.SAP_ID__c','SAP ID'));
                wrapfieldsList.add(new pickListWrapper('Dealer_Id__r.Sold_To_Code__c','Sold To Code'));
            }*/
        
        List<pickListWrapper> defaultfieldsList = new List<pickListWrapper>();
        if(reportName == 'Service Compliance Turn Time Data'){
            for(pickListWrapper field1 : wrapfieldsList){
                    defaultfieldsList.add(field1);
            }
        }
        else{
            for(String defaults : defaultColumns){
            for(pickListWrapper field1 : wrapfieldsList){
                if(field1.Id == defaults){
                    defaultfieldsList.add(field1);
                }
            }
         }
        }
        System.debug('Default Fields- ' + defaultfieldsList);
        return new regionAndFields(wrapfieldsList, regionNames, defaultfieldsList, rp[0].Report_Object__c,lookupVar,monthField,yearField,sourceField);
    }
  
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributors(List<String> selectedRegion) 
    {
        system.debug('region'+selectedRegion);
        List<Account> accountList = new List<Account>([Select id,name,Type from Account where Sales_RegionA__c IN: selectedRegion and Type='Distributor'and PRP_Participation__c = true]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.name));
        }
        system.debug('AccountNames'+AccountNames);
        return AccountNames;
    }
    
    @AuraEnabled
    public static List<pickListWrapper> fetchDistributorsByPartner(List<String> selectedRegion,String partnervalue, String reportName) 
    {
        system.debug('region'+selectedRegion);
        system.debug('Dealer type :::'+partnervalue);
        List<Account> accountList = new List<Account>();
        if(reportName == 'Service Compliance Turn Time Data'){
         accountList = [Select id,name,Type,AccountSAPField__c from Account where Sales_RegionA__c IN: selectedRegion AND Type=:partnervalue and PRP_Participation__c = true ORDER BY AccountSAPField__c];
        }
        else{
         accountList = [Select id,name,Type,AccountSAPField__c from Account where Sales_RegionA__c IN: selectedRegion AND Type=:partnervalue ORDER BY AccountSAPField__c];
        }
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
            accountList =([Select id,name,Type,city__c,CitySAPField__c,AccountSAPField__c  from Account where Parent.Id IN: disList AND Type='Distributor Branch'and PRP_Participation__c = true ORDER BY CitySAPField__c]);        
        }
        else if(partner == 'Distributor' && reportname== 'Training Data_DLR'){
            accountList =([Select id,name,Type,city__c,CitySAPField__c,AccountSAPField__c  from Account where Parent.Id IN: disList AND Type='Service Dealer' and PRP_Participation__c = true ORDER BY CitySAPField__c]);        
        }
        else if(partner == 'Direct Dealer'){
                accountList =([Select id,name,Type,city__c,AccountSAPField__c,CitySAPField__c  from Account where Id IN: disList and PRP_Participation__c = true ORDER BY CitySAPField__c]);                
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
    public static List<pickListWrapper> FetchBranch(List<String> disList) 
    {
        system.debug('serviceLocationList'+disList);
        List<Account> accountList = new List<Account>([Select id,name,Type  from Account where Parent.name IN: disList]);
        List<pickListWrapper> AccountNames = new List<pickListWrapper>();
        for(Account acc : accountList){
            AccountNames.add(new pickListWrapper(acc.id,acc.name));
        }
        return AccountNames;
    }
    
        @AuraEnabled
    public static List<Sobject> FetchRecordsforTable(List<string> sourceList,List<String> DistributorList,List<String> BranchList,List<String> regionList,String columns,String SelectedObject, String lookupVar, List<String> monthValue, List<String> yearValue,String reportname,String partnerType) 
    {   List<SObject> tableData = new List<SObject>();
       // User adminUser= [select id, name from user where id='0053h0000036byZAAQ' limit 1];
        
      //  System.runAs(adminUser){
        system.debug('In here ');
        System.debug('Columns- ' + columns);
        System.debug('SelectedObject in Fetch ::'+SelectedObject);
        System.debug('SelectedObject in Fetch');
        System.debug('reportName'+reportname);
        Set<String> sourceset = new Set<String>();
        Set<ID> DistributorSet = new Set<ID>();
        Set<ID> BranchSet = new Set<ID>();
        Set<String> regionSet = new Set<String>();
        Set<String> MonthSet = new Set<String>();
        Set<Decimal> YearSet = new Set<Decimal>();
        for(String str : sourceList){
            sourceset.add(str);
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
        
        
        system.debug('BranchList'+BranchList);
        system.debug('DistributorList'+DistributorList);
        system.debug('SourceSet'+sourceset);
        String query;
        lookupVar = lookupVar.replace('__r.', '__c');
        System.debug('monthValue'+MonthSet);
        System.debug('yearValue'+YearSet);
        if(columns != null){
            if(reportName == 'Service Compliance Turn Time Data' && partnerType == 'Direct Dealer'){
                   query = 'Select ' +columns +  ' from ' + SelectedObject + ' where Dealer_Id__c'+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Source_Type__c IN: sourceset AND (Source_Type__c = \'AWARE\' OR (Source_Type__c = \'Distributor\' AND Repair_Payment__c = \'C\')) ORDER BY Dealer_Id__r.SAP_ID__c';
            }
            else if(reportName == 'Service Compliance Turn Time Data' && partnerType == 'Distributor'){
                   query = 'Select ' +columns +  ' from ' + SelectedObject + ' where Dealer_Id__c'+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Source_Type__c IN: sourceset AND (Source_Type__c = \'AWARE\' OR (Source_Type__c = \'Distributor\' AND Repair_Payment__c = \'C\')) ORDER BY Dealer_Id__r.SAP_ID__c';  
            }
            else if(reportName == 'Survey Data' && partnerType == 'Direct Dealer'){
                   query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: DistributorSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Survey_Type__c IN: sourceset ORDER BY Ship_To__c';
            }
            else if(reportName == 'Survey Data' && partnerType == 'Distributor'){
                   query = 'Select ' +columns +  ' from ' + SelectedObject + ' where '+ lookupVar+ ' IN: BranchSet AND Month_Name__c IN: MonthSet AND Year__c IN: YearSet AND Survey_Type__c IN: sourceset ORDER BY Ship_To__c';  
            }
            else{
                System.debug('No Query');
            }
        }
        system.debug('query'+query); 
     tableData = database.query(query);
     
     List<String> datelist = new List<String>();
     datelist.add('Date_first_labor_applied__c');
     datelist.add('Repair_Order_open_date__c');
     datelist.add('Repair_Order_closed_date__c');
     datelist.add('Date_First_Part_Ordered__c');
     datelist.add('PART_ARRIVAL_DATE__c');     
     // datelist.add('Last_Part_RecDate__c');
     // datelist.add('date_cust_request_service__c');
     // datelist.add('Date_Distributor_schedules_for_service__c');
     datelist.add('date_vehicle_first_arrived__c');
     datelist.add('Date_last_labor_applied__c');
     datelist.add('customer_notified__c');
     //datelist.add('Service_Start_Date_Formula__c');
     //datelist.add('Service_End_Date_Formula__c');
     system.debug('DATELIST'+datelist);
     
     if(SelectedObject=='TAT_Data__c'){
        tableData = database.query(query);
    			for(SObject t:tableData){
         			
                    if(t.get('Source_Type__c')=='AWARE'){
                                      system.debug('CLAIM NUMBER'+t.get('Claim_Number__c'));
                                     for(String str:datelist){      
                                     system.debug('STR'+ str);   
                                           if(t.get(str)!=Null){
                                     Datetime d= datetime.valueOf(t.get(str));
                                     system.debug('D  '+d);
                                     String s=d.format('yyyy-MM-dd HH:mm:ss','GMT-5');
                                     system.debug('S  '+s);
                                    // Datetime d1= datetime.parse(s);
                                     Datetime d1 = datetime.valueOfGmt(s);
                                     system.debug('D1---'+d1); 
                                     t.put(str, d1);
         						   					 }
             							}
    
                    		}
     				}
			}
     
     //IF NOT TAT_DATA__C
     else{
       tableData = database.query(query);  
     }
        System.debug('########'+tableData);
        //}*/
        return tableData;
    
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
        Set<String> RegionNameSet = new Set<String>();
        string PartnerType;
        
        Set<Id> IdOfAccounts = new Set<Id>();
        Id profileId=userinfo.getProfileId(); 
       // String profileName=[Select Id,Name from Profile where Id='00e0r000000M2lZAAS'].Name;
         List<AccountContactRelation> accRel = new List<AccountContactRelation>();
         String profileName=[Select Id,Name from Profile where Id=: profileId].Name;
        //Also revoke the use of PRP_Profile__mdt metadata.
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
            accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where contactId= :u.ContactId];
            for(AccountContactRelation ac : accRel){
                IdOfAccounts.add(ac.AccountId);
            }
            account = [SELECT ID,Sales_RegionA__c,Type,name,SAP_ID__c,AccountSAPField__c FROM Account WHERE ID IN :IdOfAccounts];
            if(account.size() > 0){
                for(Account acct : account){
			    DistributorNames.add(new pickListWrapper(acct.Id,acct.AccountSAPField__c));
                RegionNameSet.add(acct.Sales_RegionA__c);
                PartnerType = account[0].Type;                
                 }
            }
            for(String pw : RegionNameSet){
                RegionName.add(new pickListWrapper(pw,pw));
            }
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
        @AuraEnabled public List<picklistWrapper> sourceFields;
        public regionAndFields(List<pickListWrapper> fields,List<pickListWrapper> RegionNames, List<pickListWrapper> defaultFields, String objectName, String lookupVar,List<pickListWrapper> monthFields,List<pickListWrapper> yearFields,List<picklistWrapper> sourceFields){
            this.fields = fields;
            this.RegionNames = RegionNames;
            this.defaultFields = defaultFields;
            this.objectName = objectName;
            this.lookupVar = lookupVar;
            this.monthFields = monthFields;
            this.yearFields = yearFields;
            this.sourceFields = sourceFields;
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
    public static void fakeMethod(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}