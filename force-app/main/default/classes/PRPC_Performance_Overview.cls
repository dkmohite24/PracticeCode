/*
 * Update : CHG44065 -Update the profile check for PRP Admin & CSM User to custom permissions.
 * Update By : 08/23/2023, Susovan Mondal & Chinmaya Dash
 * 
 * Update : ENHC0011584 -Make "Performance Overview with Metrics" the Dashboard as a dynamic Dashboard that based on the year the ETC or SDM metric will be visible.
 * Update By : 12/10/2023, Susovan Mondal & Chinmaya Dash
 */

public  without sharing class PRPC_Performance_Overview {
    
    @AuraEnabled
    public static List<pickListWrapper> findRegions(){
        List<pickListWrapper> regionNames = new List<pickListWrapper>();
        List<String> regions = new List<String>{'North America','Latin America','Asia Pacific','EMEA'};
            for(String  reg : regions){
                regionNames.add(new pickListWrapper(reg,reg));                      
            }
        return regionNames;
    }
    
    @AuraEnabled
    public static wrapperClass getDistributors(List<String> selectedRegion, String partnerTypeApex){
        List<String> Years=new List<String>();
        Integer currentYear = System.Today().year();
        for(Integer i= currentYear; i>=2013; i--){
            Years.add(String.valueof(i));
        }
        List<Account> distLists = new List<Account>();
        List<String> months = new List<String>{'January','February','March','April','May','June','July','August','September','October','November','December'};
            if(partnerTypeApex == 'Distributor'){
                distLists=[Select id,AccountSAPField__c from Account where Type='Distributor' and Sales_RegionA__c IN :selectedRegion order by AccountSAPField__c];
            }
        else if(partnerTypeApex == 'Direct Dealer'){
            distLists=[Select id,AccountSAPField__c from Account where Type='Direct Dealer' and Sales_RegionA__c IN :selectedRegion order by AccountSAPField__c];
        }
        System.debug('Years'+Years);
        System.debug('Distributor'+distLists);
        return new wrapperClass(Years,distLists, months);       
    }
    
    @AuraEnabled
    public static List<Account> getBranch(String distributor){
        List<Account> branchLists=New List<Account>([Select id,AccountSAPField__c, SAP_ID__c, ShippingCity from Account where Type='Distributor Branch' and parentId = :distributor order by ShippingCity]); 
        return branchLists;
    }
    
    @AuraEnabled
    public Static responseWrapper returnDashboardDetails(Integer YearSelected,String SelectedBranch, String monthSelected,string storedistributor,list<string>regionlist,String partnerTypeApex){
        System.debug('Year'+String.valueof(YearSelected));
        System.debug('SelectedBranch'+SelectedBranch);
        System.debug('regionlist: '+regionlist);
        System.debug('storedistributor: '+storedistributor);
        String year = String.valueOf(YearSelected);
        Integer yearNum = Integer.valueOf(YearSelected);
        Account branch = new Account();
        Account Dist = new Account();
        List<Account> branchKPI = new List<Account>();
        PRP_Setup__c prp=New PRP_Setup__c();
        KPI__c kpi = new KPI__c();
        List<KPI_Range_Settings__c> kpiRange = new List<KPI_Range_Settings__c>();
        Id profileId=userinfo.getProfileId(); 
        String profileName=[Select Id,Name from Profile where Id=: profileId].Name;
        //CHG44065 Removing the PRP_Profile__mdt metadata.
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
        //CHG44065 Check the Custom permission
        Boolean isCSMPermission = FeatureManagement.checkPermission('ATI_PRP_CSM');
        Boolean isPRPAdminPermission = FeatureManagement.checkPermission('ATI_PRP_Admin');
        
        String kpiId;
        String DistAVg='0.00';
        String RegAvg='0.00';
        String NatAvg='0.00';
        try {
            if(SelectedBranch!=null && SelectedBranch !=''){
                branch = [SELECT ID, AccountSAPField__c, Distributor__c, ShippingCity, ShippingCountry, parentId, Sales_RegionA__c,Type FROM Account WHERE ID = :SelectedBranch LIMIT 1];
            }
            Dist = [SELECT ID, AccountSAPField__c, Distributor__c, ShippingCity, ShippingCountry, parentId, Sales_RegionA__c,Type FROM Account WHERE ID = :storedistributor LIMIT 1];
            if(branch.Sales_RegionA__c == 'North America'){
                prp = [SELECT (SELECT id, Name, Low_Range__c, High_Range__c FROM PRP_Range_Settings__r 
                               ORDER BY createdDate DESC LIMIT 3) 
                       FROM PRP_Setup__c WHERE Region__c = :branch.Sales_RegionA__c AND year__c = :year AND Month__c = :monthSelected AND Partner_Type__c='Distributor' LIMIT 1];
            }
            if(branch.Type=='Distributor Branch' &&  Dist.Sales_RegionA__c == 'Latin America' ||Dist.Sales_RegionA__c == 'Asia Pacific'|| Dist.Sales_RegionA__c == 'EMEA' ){
                prp = [SELECT (SELECT id, Name, Low_Range__c, High_Range__c FROM PRP_Range_Settings__r 
                               ORDER BY createdDate DESC LIMIT 3) 
                       FROM PRP_Setup__c WHERE Region__c = :Dist.Sales_RegionA__c AND year__c = :year AND Month__c = :monthSelected AND Partner_Type__c='Distributor' LIMIT 1];
            }
            if(branch.Type == 'Distributor' && branch.Sales_RegionA__c == 'Latin America' ||branch.Sales_RegionA__c == 'Asia Pacific'|| branch.Sales_RegionA__c == 'EMEA'){
                prp = [SELECT (SELECT id, Name, Low_Range__c, High_Range__c FROM PRP_Range_Settings__r 
                               ORDER BY createdDate DESC LIMIT 3) 
                       FROM PRP_Setup__c WHERE Region__c = :Dist.Sales_RegionA__c AND year__c = :year AND Month__c = :monthSelected AND Partner_Type__c='Distributor' LIMIT 1];
            }
            if(Dist.Type == 'Direct Dealer'){
                System.debug('Inside DDLR PRP');
                prp = [SELECT (SELECT id, Name, Low_Range__c, High_Range__c FROM PRP_Range_Settings__r 
                               ORDER BY createdDate DESC LIMIT 3) 
                       FROM PRP_Setup__c WHERE Region__c = :Dist.Sales_RegionA__c AND year__c = :year AND Month__c = :monthSelected AND Partner_Type__c='Direct Dealer' LIMIT 1];
            }
            system.debug('prp: '+prp);
           
            //if(profileName == 'PRP Partner' || profileName == 'Custom Platform User'){
            if(profileName == 'PRP Partner'  || isCSMPermission==true){
                if(regionlist.contains('North America')){
                    
                    kpi = [SELECT ID, CSI_Dealer__c, CSI_Parts__c,Service_Dealer_Development__c,ETC__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :SelectedBranch AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Released__c = 'X' and Period__c = 'YTD' LIMIT 1];
                }
                if(Dist.Type != 'Direct Dealer' && branch.Type != 'Distributor' && (regionlist.contains('Latin America') || regionlist.contains('Asia Pacific') || regionlist.contains('EMEA'))){
                    
                    kpi = [SELECT ID,CSI__c, CSI_Dealer__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :SelectedBranch AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=false and Released__c = 'X' and Period__c = 'YTD' LIMIT 1];
                }
                if(Dist.Type != 'Direct Dealer' && branch.Type == 'Distributor' && (regionlist.contains('Latin America') || regionlist.contains('Asia Pacific') || regionlist.contains('EMEA'))){
                    
                    kpi = [SELECT ID,CSI__c, CSI_Dealer__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :SelectedBranch AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Released__c = 'X' and Period__c = 'YTD' LIMIT 1];
                }
                if(Dist.Type == 'Direct Dealer'){
                    System.debug('Inside DDLR KPI');
                    kpi = [SELECT ID,CSI__c, CSI_Dealer__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :storedistributor AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD' LIMIT 1];
                }
            }else if( profileName == 'System Administrator'|| isPRPAdminPermission==true){
                if(regionlist.contains('North America')){
                    kpi = [SELECT ID, CSI_Dealer__c,Service_Dealer_Development__c,ETC__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :SelectedBranch AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD' LIMIT 1];
                }
                if(Dist.Type != 'Direct Dealer' && branch.Type != 'Distributor' && (regionlist.contains('Latin America') || regionlist.contains('Asia Pacific') || regionlist.contains('EMEA'))){
                    
                    kpi = [SELECT ID,CSI__c, CSI_Dealer__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :SelectedBranch AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=false and Period__c = 'YTD' LIMIT 1];
                }
                if(Dist.Type != 'Direct Dealer' && branch.Type == 'Distributor' && (regionlist.contains('Latin America') || regionlist.contains('Asia Pacific') || regionlist.contains('EMEA'))){
                    
                    kpi = [SELECT ID,CSI__c, CSI_Dealer__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :SelectedBranch AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD' LIMIT 1];
                }
                if(Dist.Type == 'Direct Dealer'){
                    System.debug('Inside DDLR KPI');
                    kpi = [SELECT ID,CSI__c, CSI_Dealer__c, CSI_Parts__c, CSI_Service__c, Total_Parts_Sold_ReTran__c, TPS__c, 
                           Training__c, Turnaround_Time_I__c, Turnaround_Time_M__c, Turnaround_Time_O__c, PRP_Score__c, PRP_Level__c,
                           Facility_Audit__c, Parts_Ordering__c, Distributor_Avg__c, Region_Avg__c, North_America_Avg__c
                           FROM KPI__c WHERE Customer__c = :storedistributor AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD' LIMIT 1];
                }
            }
            System.debug('kpi- ' + kpi);
            
            if(regionlist.contains('North America')){
                //Based on the year value, the ETC or SDM will be visible
                system.debug('line 170 yearNum'+yearNum);
                List<String> kpiNames = new List<String>();
                If(yearNum <= 2023){
                    kpiNames = new List<String>{'CSI Parts', 'CSI Service', 'Total Parts Sold ReTran', 
                    'TPS', 'Training', 'Turnaround Time I', 'Turnaround Time M', 'Turnaround Time O','Annual Dealer Experience','Service Dealer Development'}; 
                }
                else{
                    kpiNames = new List<String>{'CSI Parts', 'CSI Service', 'Total Parts Sold ReTran', 
                    'TPS', 'Training', 'Turnaround Time I', 'Turnaround Time M', 'Turnaround Time O','Annual Dealer Experience','Extended Transmission Coverage'}; 
                }
                  
                        kpiRange = [Select Name, Points__c, KPI_Setup__r.Name, KPI_Setup__r.KPI_Type__c from KPI_Range_Settings__c 
                                    where name = 'Reward Level 1' AND KPI_Setup__r.KPI_Type__c IN :kpiNames AND 
                                    KPI_Setup__r.Year__c = :year AND KPI_Setup__r.Region__c = 'North America' and KPI_Setup__r.Partner_Type__c = 'Distributor'];
                system.debug('kpiRange127: '+kpiRange.size());
            }
            if(regionlist.contains('Latin America')){
                List<String> kpiNames = new List<String>{'CSI','Facility Audit', 'Parts Ordering', 'TPS', 'Training', 'Turnaround Time I',
                    'Turnaround Time O'}; 
                        
                        kpiRange = [Select Name,Points__c, KPI_Setup__r.Name, KPI_Setup__r.KPI_Type__c from KPI_Range_Settings__c 
                                    where name = 'Reward Level 1' AND KPI_Setup__r.KPI_Type__c IN :kpiNames AND 
                                    KPI_Setup__r.Year__c = :year AND KPI_Setup__r.Region__c = 'Latin America' and KPI_Setup__r.Partner_Type__c =:partnerTypeApex];
            }
            if(regionlist.contains('Asia Pacific')){
                List<String> kpiNames = new List<String>{'CSI','Facility Audit', 'Parts Ordering', 'TPS', 'Training', 'Turnaround Time I',
                    'Turnaround Time O'}; 
                        
                        kpiRange = [Select Name,Points__c, KPI_Setup__r.Name, KPI_Setup__r.KPI_Type__c from KPI_Range_Settings__c 
                                    where name = 'Reward Level 1' AND KPI_Setup__r.KPI_Type__c IN :kpiNames AND 
                                    KPI_Setup__r.Year__c = :year AND KPI_Setup__r.Region__c = 'Asia Pacific' and KPI_Setup__r.Partner_Type__c =: partnerTypeApex];
            }
            if(regionlist.contains('EMEA')){
                List<String> kpiNames = new List<String>{'CSI','Facility Audit', 'Parts Ordering', 'TPS', 'Training', 'Turnaround Time I',
                    'Turnaround Time O'}; 
                        
                        kpiRange = [Select Name,Points__c, KPI_Setup__r.Name, KPI_Setup__r.KPI_Type__c from KPI_Range_Settings__c 
                                    where name = 'Reward Level 1' AND KPI_Setup__r.KPI_Type__c IN :kpiNames AND 
                                    KPI_Setup__r.Year__c = :year AND KPI_Setup__r.Region__c = 'EMEA' and KPI_Setup__r.Partner_Type__c =:partnerTypeApex];
                system.debug('kpiRange127: '+kpiRange.size());
            }
            
            if(regionlist.contains('North America')){
                branchKPI = [select name, sap_id__c, ShippingCity, (select name, customer__r.sap_id__c, prp_score__c from kpis__r 
                                                                    where MonthName__c = :monthSelected AND Year__c = :YearSelected AND isPartOfPRP__c=true order by createddate limit 1) from Account 
                             where parentid = :branch.ParentId and type = 'Distributor Branch'];
            }
            if(Dist.Type != 'Direct Dealer' && branch.Type != 'Distributor' && (regionlist.contains('Latin America') || regionlist.contains('Asia Pacific') || regionlist.contains('EMEA'))){
                branchKPI = [select name, sap_id__c, ShippingCity, (select name, customer__r.sap_id__c, prp_score__c from kpis__r 
                                                                    where MonthName__c = :monthSelected AND Year__c = :YearSelected AND isPartOfPRP__c=false order by createddate limit 1) from Account 
                             where parentid = :branch.ParentId and type = 'Distributor Branch'];
                system.debug('branchKPI: '+branchKPI.size());
            }
            if(branch.Type == 'Distributor' && (regionlist.contains('Latin America') || regionlist.contains('Asia Pacific') || regionlist.contains('EMEA'))){
                branchKPI = [select name, sap_id__c, ShippingCity, (select name, customer__r.sap_id__c, prp_score__c from kpis__r 
                                                                    where MonthName__c = :monthSelected AND Year__c = :YearSelected AND isPartOfPRP__c=true order by createddate limit 1) from Account 
                             where id = :branch.Id and type = 'Distributor'];
                
            }
            if(Dist.Type == 'Direct Dealer'){
                branchKPI = [select name, sap_id__c, ShippingCity, (select name, customer__r.sap_id__c, prp_score__c from kpis__r 
                                                                    where MonthName__c = :monthSelected AND Year__c = :YearSelected AND isPartOfPRP__c=true order by createddate limit 1) from Account 
                             where id = :Dist.Id and type = 'Direct Dealer'];
                system.debug('branchKPI193: '+branchKPI.size());
            }
            AggregateResult[] groupedResults;
            AggregateResult[] groupedResults2;
            if(branch.Sales_RegionA__c == 'North America'){
                groupedResults= [Select AVG(PRP_Score__c) from KPI__c where Region__c=:branch.Sales_RegionA__c AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD'];
            }else{
                groupedResults= [Select AVG(PRP_Score__c) from KPI__c where Region__c=:Dist.Sales_RegionA__c AND Customer__r.Type=:Dist.Type AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD'];
            }
            System.debug('Average'+groupedResults);
            for (AggregateResult ar : groupedResults)  {
                System.debug('Campaign ID' + ar.get('expr0'));
                RegAvg=String.valueof(ar.get('expr0'));
            }
            AggregateResult[] groupedResults1= [Select AVG(PRP_Score__c) from KPI__c where Customer__r.ShippingCountry =:branch.ShippingCountry AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true];
            System.debug('Average'+groupedResults1);
            for (AggregateResult ar : groupedResults1)  {
                System.debug('Campaign ID' + ar.get('expr0'));
                NatAvg=String.valueof(ar.get('expr0'));
            }
            if(branch.Sales_RegionA__c == 'North America'){
                groupedResults2= [Select AVG(PRP_Score__c) from KPI__c where Customer__r.parentId =:branch.parentId AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c ='YTD'];
            }else{
                if(branch.Type == 'Distributor Branch'){
                    groupedResults2= [Select AVG(PRP_Score__c) from KPI__c where Customer__r.parentId=:Dist.Id AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=false and Period__c = 'YTD'];
                }else if(Dist.Type == 'Direct Dealer'){
                    groupedResults2 = [Select AVG(PRP_Score__c) from KPI__c where Customer__c=:Dist.Id AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD'];
                }else{
                    groupedResults2= [Select AVG(PRP_Score__c) from KPI__c where Customer__c=:branch.Id AND Year__c = :YearSelected AND MonthName__c = :monthSelected AND isPartOfPRP__c=true and Period__c = 'YTD'];
                    
                }
            }
            System.debug('Average'+groupedResults2);
            for (AggregateResult ar : groupedResults2)  {
                System.debug('Campaign ID' + ar.get('expr0'));
                DistAVg=String.valueof(ar.get('expr0'));
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }
        
        
        return new responseWrapper(prp, kpi, branch, kpiRange, branchKPI, RegAvg, DistAVg, NatAvg);
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
        //CHG44065 Removing the PRP_Profile__mdt metadata.
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
    
    public class wrapperClass{
        @AuraEnabled public List<String> YearList{get;set;}
        @AuraEnabled public List<Account> DistList{get;set;}
        @AuraEnabled public List<String> MonthList{get;set;}
        public wrapperClass(List<String> YearLists,List<Account> DistLists, List<String> MonthList){
            this.YearList=YearLists;
            this.DistList=DistLists;
            this.MonthList=MonthList;
        }
    }
    
    public class responseWrapper{
        @AuraEnabled public PRP_Setup__c prp;
        @AuraEnabled public KPI__c kpi;
        @AuraEnabled public Account branch;
        @AuraEnabled public List<KPI_Range_Settings__c> kpiRange;
        @AuraEnabled public List<Account> branchKPI;
        @AuraEnabled public String RegAvg;
        @AuraEnabled public String DistAVg;
        @AuraEnabled public String NatAvg;
        public responseWrapper(PRP_Setup__c prp, KPI__c kpi, Account branch, List<KPI_Range_Settings__c> kpiRange, 
                               List<Account> branchKPI, String RegAvg, String DistAVg, String NatAvg){
                                   this.prp=prp;
                                   this.kpi = kpi;
                                   this.branch = branch;
                                   this.kpiRange = kpiRange;
                                   this.branchKPI = branchKPI;
                                   this.RegAvg = RegAvg;
                                   this.DistAVg = DistAVg;
                                   this.NatAvg = NatAvg;
                               }
    }
    
    public Class pickListWrapper{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        public pickListWrapper(String Idx,String Namex){
            this.Id=Idx;
            this.Name = Namex;         
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