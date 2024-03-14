/*
* Update : DMND4624 - Revoke the use of PRP_Profile__mdt metadata.
* Update By : Susovan Mondal & Chinmaya Das
* Update Date : 08/23/2023
* Update : CHG44908 - We are displaying ETC points in the Reward Summary and Reward Summary Admin reports.
* Updated By : Susovan Mondal & Chinmaya Dash
*
*/



public without sharing class PRPC_rewardSummaryDisClass {
    
    //For Generating Incentive File
    
    @AuraEnabled
    public static String generateIncentiveFile(String YearApex, String MonthApex){
        System.debug('Month'+MonthApex);
        System.debug('Year'+YearApex);
        PRPC_incentiveCalculationClass batchable = new PRPC_incentiveCalculationClass();
        batchable.setYear(Integer.valueOf(YearApex));
        batchable.setMonth(Integer.valueOf(MonthApex));
        Database.executeBatch(batchable,2000);
        return 'SUCCESS';
    }
    
    //For Submitting the File to SAP
    
    @AuraEnabled
    public static String submitToSAPFile(String YearApex, String MonthApex){
        System.debug('Year'+YearApex);
        System.debug('Month'+MonthApex);
        PRPC_submitToSapClass.submitToSAPFile(YearApex,MonthApex);
        return 'SUCCESS';
    }
    
    //For Generating the KPI
    
    @AuraEnabled
    public static String executePRPCalculation(Date StartDate, Date EndDate, List<String> SelectedRegions){
        PRPC_prpCalculationScheduler pcs = new PRPC_prpCalculationScheduler();
        pcs.SelectedRegions = SelectedRegions;
        return pcs.executePRPCalculation(StartDate,EndDate);
    }
    
    //For Releasing KPI of the month
    
    public static List<KPI__C> checkForReleaseOfKPI(String month, String year, List<String> SelectedRegionsApex){
        System.debug('Year :'+Year);
        System.debug('Month :'+month);
        System.debug('SelectedRegions :'+SelectedRegionsApex);
        List<KPI__c> recordsToUpdate = new List<KPI__C>();
        List<Incentive__c> recordsToUpdateForIncentives = new List<Incentive__c>();
        recordsToUpdate = [Select id from KPI__C where Released__c != 'X' AND MonthName__c = :month AND Year_Text__c = :year AND Customer__r.Sales_RegionA__c IN:SelectedRegionsApex];
        System.debug('Integer Value'+Integer.valueOf(year));
        recordsToUpdateForIncentives = [Select id from Incentive__c where Release_Incentive__c!= 'X' AND Month__c = :month AND Year__c =:Integer.valueOf(year) AND IncentiveAcc__r.Sales_RegionA__c IN:SelectedRegionsApex];
        System.debug('Recodrds KPI '+recordsToUpdate.size());
        System.debug('Recodrds Incentive '+recordsToUpdateForIncentives.size());
        return recordsToUpdate;
    }
    
    public static List<Incentive__c> checkForReleaseOfIncentive(String month, String year){
        System.debug('Year :'+Year);
        System.debug('Month :'+month);
        List<Incentive__c> recordsToUpdateForIncentives = new List<Incentive__c>();
        System.debug('Integer Value'+Integer.valueOf(year));
        recordsToUpdateForIncentives = [Select id from Incentive__c where Release_Incentive__c!= 'X' AND Month__c = :month AND Year__c =:Integer.valueOf(year)];
        System.debug('Recodrds Incentive '+recordsToUpdateForIncentives.size());
        return recordsToUpdateForIncentives;
    }
    
    @AuraEnabled
    public static String updateKPIsForRelease(String month, String year, List<String> SelectedRegionsApex){
        System.debug('Inside this update Function');
        System.debug('Year = '+year+' month = '+month);
        System.debug('SelectedRegionsApex :'+SelectedRegionsApex);
        List<KPI__C> kpisToUpdate = checkForReleaseOfKPI(month, year,SelectedRegionsApex);
        List<Incentive__c> recordsToUpdateForIncentives = checkForReleaseOfIncentive(month, year);
        for(KPI__c tmp : kpisToUpdate){
            tmp.Released__c = 'X';
        }
        for(Incentive__c tmp1 : recordsToUpdateForIncentives){
            tmp1.Release_Incentive__c = 'X';
        }
        System.debug('Updated KPIS : '+kpisToUpdate);
        System.debug('Updated Incentives : '+recordsToUpdateForIncentives);
        update kpisToUpdate;
        update recordsToUpdateForIncentives;
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static String InstantLoadApex(){
        //CHG0043240 - Account data mapping through Instant dataload from staging
        PRPC_ScheduleDataMovementClass batchable = new PRPC_ScheduleDataMovementClass();
        batchable.execute(null);
        // DataMovementBatch batchable = new DataMovementBatch();
        //  Database.executeBatch(batchable, 1);
        return 'SUCCESS';
    }
    
    //Reward Summary 
    
    @AuraEnabled
    public static List<Account> getName(){
        List<AccountContactRelation> accRel = new List<AccountContactRelation>();
        Set<Id> IdOfAccounts = new Set<Id>();
        List<Account> account = new List<Account>();
        ID userId = UserInfo.getUserId();
        System.debug('userId'+userId);
        User u = [select id, contactId,contact.Account.name,contact.AccountId,contact.Account.AccountSAPField__c,contact.Account.Type,contact.Account.Sales_RegionA__c from User where id = : UserId];
        accRel = [SELECT id,AccountId, ContactId FROM AccountContactRelation where contactId= :u.contactId];
        for(AccountContactRelation ac : accRel){
            IdOfAccounts.add(ac.AccountId);
        }
        account = [SELECT ID,Sales_RegionA__c,Type,Name,SAP_ID__c,AccountSAPField__c FROM Account WHERE ID IN :IdOfAccounts AND Sales_RegionA__c != null];
        
        return account;
    }
    
    @AuraEnabled 
    public static LocationWrapper getAllBranches(String DistId, String PartTypeApex){
        LocationWrapper locationWrapper = new LocationWrapper();
        //Logic for boolean is inside north america
        Boolean isNorthAmerica=false;
        List<Account> acc = new List<Account>();
        if(PartTypeApex == 'Distributor'){
            acc = [SELECT ID,Type,Name,SAP_ID__c,AccountSAPField__c,CitySAPField__c,Sales_RegionA__c FROM Account WHERE Type ='Distributor Branch' AND ParentId = :DistId AND Sales_RegionA__c != null];
        }
        else if(PartTypeApex == 'Direct Dealer'){
            acc = [SELECT ID,Type,Name,SAP_ID__c,AccountSAPField__c,CitySAPField__c,Sales_RegionA__c FROM Account WHERE Type ='Direct Dealer' AND Id = :DistId AND Sales_RegionA__c != null];
        }
        if(!acc.isEmpty()){
            isNorthAmerica = acc[0].Sales_RegionA__c == 'North America';
        }
        System.debug('acc ::'+acc);
        locationWrapper.isNorthAmerica = isNorthAmerica;
        locationWrapper.locationOptions = acc;
        System.debug('Location Wrapper : ' + locationWrapper);
        return locationWrapper;
    }
    
    @AuraEnabled
    public static WrapperPRPRewardLevels getAllValue(String accId, String SearchKeyApex,String PartnerTypeApex, String RegionApex){
        //accId = '0010r00000Q2tBFAAZ';
        System.debug('SearchKey'+SearchKeyApex);
        System.debug('AccId'+accId);
        KPI__c getValue = new KPI__c();
        Integer Year = Date.today().Year();
        if(PartnerTypeApex == 'Distributor'){
            if(RegionApex == 'North America'){
                try{
                    if(Year<=2023){
                        getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                                   Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                                   Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState,Customer__r.ShippingCountry, Customer__r.ShippingCity,KPI_Calculation_Date__c
                                   FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.CitySAPField__c=:SearchKeyApex AND Year__c =:Year ORDER BY Month__c DESC
                                   LIMIT 1];
                        System.debug('getValue'+ getValue);
                    }
                    //CHG44908 - Based on the year, we are fetching ETC Data from KPI
                    //Start
                    else{
                        getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                               Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                               Training__c,ETC_Score__c,ETC__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState,Customer__r.ShippingCountry, Customer__r.ShippingCity,KPI_Calculation_Date__c
                               FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.CitySAPField__c=:SearchKeyApex AND Year__c =:Year ORDER BY Month__c DESC
                               LIMIT 1];
                    }
                    //End
                }
                catch(System.QueryException e){
                    getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                               Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                               Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState,Customer__r.ShippingCountry, Customer__r.ShippingCity,KPI_Calculation_Date__c
                               FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.CitySAPField__c=:SearchKeyApex AND Year__c =:Year-1 ORDER BY Month__c DESC
                               LIMIT 1];
                    System.debug('getValue'+ getValue);
                    //System.debug('Error '+e.getMessage()); 
                    //throw new AuraHandledException('The selected Location does not contain a KPI assigned to it yet.');    
                }
            }
            else{
                try{
                    getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                               Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                               Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState,Customer__r.ShippingCountry, Customer__r.ShippingCity,KPI_Calculation_Date__c
                               FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.Id=:accId AND Year__c =:Year ORDER BY Month__c DESC
                               LIMIT 1];
                    System.debug('getValue'+ getValue);
                }
                catch(System.QueryException e){
                    getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                               Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                               Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState,Customer__r.ShippingCountry, Customer__r.ShippingCity,KPI_Calculation_Date__c
                               FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.Id=:accId AND Year__c =:Year-1 ORDER BY Month__c DESC
                               LIMIT 1];
                    System.debug('getValue'+ getValue);   
                }
            }
        }
        else if(PartnerTypeApex == 'Direct Dealer'){
            try{
                getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                           Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                           Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState, Customer__r.ShippingCity,Customer__r.ShippingCountry,KPI_Calculation_Date__c
                           FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.Id=:accId AND Year__c =:Year ORDER BY Month__c 
                           DESC LIMIT 1];
                System.debug('getValue'+ getValue);
            }
            catch(System.QueryException e){
                getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                           Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                           Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,Month__c,Customer__r.Type,Customer__r.ShippingStreet,Customer__r.ShippingState, Customer__r.ShippingCity,Customer__r.ShippingCountry,KPI_Calculation_Date__c
                           FROM KPI__c WHERE Period__c = 'YTD' AND isPartOfPRP__c = TRUE AND Released__c ='X' AND Customer__r.Id=:accId AND Year__c =:Year-1 ORDER BY Month__c 
                           DESC LIMIT 1];
                System.debug('getValue'+ getValue);   
            }
        }
        return getRange(getValue,PartnerTypeApex);
    }
    public class KPIWrapperClass{
        @AuraEnabled public List<KPI_Range_Settings__c> rangeSet = new List<KPI_Range_Settings__c>();
        @AuraEnabled public WrapperPRPRewardLevels kpi{get;set;}
    }
    
    @AuraEnabled
    public static WrapperPRPRewardLevels getRange(KPI__c AllKPITypes, String SelectedPartner){
        //KPI__c kpiname = AllKPITypes[0];
        
        List<KPI_Range_Settings__c> getRangeValues = new List<KPI_Range_Settings__c>();
        String Year = String.valueOf(AllKPITypes.Year__c);
        String Region = String.valueOf(AllKPITypes.Region__c);
        Integer currentMonth = Integer.valueOf(AllKPITypes.Month__c);
        Integer year1= Integer.valueof(Year);
        String Month = '';
        System.debug('initial'+AllKPITypes.TPS__c);
        System.debug('Month Selected :::'+currentMonth);
        System.debug('Region :::'+Region);
        System.debug('Year :::'+Year);
        System.debug('SelectedPartner :::'+SelectedPartner);
        Switch on currentMonth {
            when 1{
                Month = 'JANUARY';}
            when 2{
                Month = 'FEBRUARY';}
            when 3{
                Month = 'MARCH';}
            when 4{
                Month = 'APRIL';}
            when 5{
                Month = 'MAY';}
            when 6{
                Month = 'JUNE';}
            when 7{
                Month = 'JULY';}
            when 8{
                Month = 'AUGUST';}
            when 9{
                Month = 'SEPTEMBER';}
            when 10{
                Month = 'OCTOBER';}
            when 11{
                Month = 'NOVEMBER';}
            when 12{
                Month = 'DECEMBER';}
        }
        System.debug('Month String :'+Month);
        List<KPI_Range_Settings__c> kpirs=[SELECT Name,
                                           KPI_Setup__r.KPI_Type__c,
                                           Reward_Level__c,
                                           Low_Range_Value__c,
                                           High_Range_Value__c,
                                           KPI_Setup__r.Region__c,
                                           Points__c FROM KPI_Range_Settings__c WHERE
                                           KPI_Setup__r.Region__c = :Region AND KPI_Setup__r.Year__c = :Year];
        System.debug('kpirs'+kpirs);
        List<PRP_Setup__c> kpiSelected = [SELECT KPI_Selection__c FROM PRP_Setup__c WHERE PRP_Setup__c.Region__c =:AllKPITypes.Region__c AND PRP_Setup__c.Year__c = :Year AND PRP_Setup__c.Month__c = :Month AND PRP_Setup__c.Partner_Type__c =: SelectedPartner];
        System.debug('KPISELECTED'+kpiSelected);
        WrapperPRPRewardLevels result = new WrapperPRPRewardLevels();
        result.acctype= AllKPITypes.Customer__r.Type;
        result.Address = AllKPITypes.Customer__r.ShippingCity;
        result.City = AllKPITypes.Customer__r.ShippingState;
        result.Country = AllKPITypes.Customer__r.ShippingCountry;
        result.region = String.valueOf(AllKPITypes.Region__c);
        result.pRPLevel = String.valueOf(AllKPITypes.PRP_Level__c);
        result.pRPScore = String.valueOf(AllKPITypes.PRP_Score__c);
        result.CurrentMonth = Month;
        System.debug('Check point 53: '+kpirs);
        
        System.debug('Before entering CSIBoolean'+result.CSIBoolean);
        System.debug('Before entering CSIDealerBoolean'+result.CSIDealerBoolean);
        System.debug('Before entering CSIServiceBoolean'+result.CSIServiceBoolean);
        System.debug('Before entering CSIPartsBoolean'+result.CSIPartsBoolean);
        System.debug('Before entering PartsOrderingBoolean'+result.PartsOrderingBoolean);
        System.debug('Before entering tpsBoolean'+result.tpsBoolean);
        System.debug('Before entering tpsRetranBoolean'+result.tpsRetranBoolean);
        System.debug('Before entering trainingBoolean'+result.trainingBoolean);
        for(PRP_Setup__c prp : kpiSelected){
            if(prp.KPI_Selection__c.contains('CSI')){
                result.CSIBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Annual Dealer Experience')){
                result.CSIDealerBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('CSI Service')){
                result.CSIServiceBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('CSI Parts')){
                result.CSIPartsBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Parts Ordering')){
                result.PartsOrderingBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('TPS')){
                result.tpsBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('TPS ReTran')){
                result.tpsRetranBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Training')){
                result.trainingBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Facility Audit')){
                result.facilityAuditBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Turn Around Time M')){
                result.tatMBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Turn Around Time I')){
                result.tatIBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Turn Around Time O')){
                result.tatOBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Service Dealer Development')){
                result.serviceDealerDevBoolean = true;
            }
            if(prp.KPI_Selection__c.contains('Extended Transmission Coverage')){
                result.ETCBoolean = true;
            }
        }
        System.debug('After entering CSIBoolean'+result.CSIBoolean);
        System.debug('After entering CSIDealerBoolean'+result.CSIDealerBoolean);
        System.debug('After entering CSIServiceBoolean'+result.CSIServiceBoolean);
        System.debug('After entering CSIPartsBoolean'+result.CSIPartsBoolean);
        System.debug('After entering PartsOrderingBoolean'+result.PartsOrderingBoolean);
        System.debug('After entering tpsBoolean'+result.tpsBoolean);
        System.debug('After entering tpsRetranBoolean'+result.tpsRetranBoolean);
        System.debug('After entering trainingBoolean'+result.trainingBoolean);
        
        for(KPI_Range_Settings__c elt : kpirs){
            //Populationg Csi :
            if(elt.KPI_Setup__r.KPI_Type__c=='CSI' && checkInRange(elt,AllKPITypes.CSI__c)){
                result.CSIPoints = String.valueOf(AllKPITypes.CSI__c);
                result.CSIRewardLevel = elt.Name;
                result.CSIToolTip = elt.Reward_Level__c;
            }
            //Populating TPS
            if(elt.KPI_Setup__r.KPI_Type__c=='TPS' && checkInRange(elt,AllKPITypes.TPS__c )){
                result.tPSPoints = String.valueOf(AllKPITypes.TPS__c);
                result.tPSRewardLevel = elt.Name;
                result.tPSToolTip = elt.Reward_Level__c;
            }
            //Populating Facility Audit
            if(elt.KPI_Setup__r.KPI_Type__c=='Facility Audit' && checkInRange(elt,AllKPITypes.Facility_Audit__c  )){
                result.facilityAuditRewardLevel = elt.Name;
                result.facilityAuditPoints = String.valueOf(AllKPITypes.Facility_Audit__c);
                result.facilityAuditToolTip = elt.Reward_Level__c;
            }
            //Populating TAT I
            if(elt.KPI_Setup__r.KPI_Type__c=='Turnaround Time I' && checkInRange(elt,AllKPITypes.Turnaround_Time_I__c  )){
                result.turnAroundTimeIRewardLevel = elt.Name;
                result.turnAroundTimeIPoints = String.valueOf(AllKPITypes.Turnaround_Time_I__c);
                result.turnAroundTimeIToolTip = elt.Reward_Level__c;
            }
            //Populating TAT O
            if(elt.KPI_Setup__r.KPI_Type__c=='Turnaround Time O' && checkInRange(elt,AllKPITypes.Turnaround_Time_O__c  )){
                result.turnAroundTimeORewardLevel = elt.Name;
                result.turnAroundTimeOPoints = String.valueOf(AllKPITypes.Turnaround_Time_O__c);
                result.turnAroundTimeOToolTip = elt.Reward_Level__c;
            }
            //Populating TAT M
            if(elt.KPI_Setup__r.KPI_Type__c=='Turnaround Time M' && checkInRange(elt,AllKPITypes.Turnaround_Time_M__c  )){
                result.turnAroundTimeMRewardLevel = elt.Name;
                result.turnAroundTimeMPoints = String.valueOf(AllKPITypes.Turnaround_Time_M__c);
                result.turnAroundTimeMToolTip = elt.Reward_Level__c;
            }
            //Populating CSI Dealer
            if(elt.KPI_Setup__r.KPI_Type__c == 'Annual Dealer Experience' && checkInRange(elt,AllKPITypes.CSI_Dealer__c) ){
                result.CSIDealerRewardLevel = elt.Name;
                result.CSIDealerPoints = String.valueOf(AllKPITypes.CSI_Dealer__c);
                result.CSIDealerToolTip = elt.Reward_Level__c;
            }
            //Populating CSI Parts
            if(elt.KPI_Setup__r.KPI_Type__c == 'CSI Parts' && checkInRange(elt,AllKPITypes.CSI_Parts__c) ){
                result.CSIPartsRewardLevel = elt.Name;
                result.CSIPartsPoints = String.valueOf(AllKPITypes.CSI_Parts__c);
                result.CSIPartsToolTip = elt.Reward_Level__c;
            }
            //Populating CSI Service
            if(elt.KPI_Setup__r.KPI_Type__c == 'CSI Service' && checkInRange(elt,AllKPITypes.CSI_Service__c) ){
                result.CSIServiceRewardLevel = elt.Name;
                result.CSIServicePoints = String.valueOf(AllKPITypes.CSI_Service__c);
                result.CSIServiceToolTip = elt.Reward_Level__c;
            }
            //Populating TPS 
            if(elt.KPI_Setup__r.KPI_Type__c == 'Total Parts Sold' && checkInRange(elt,AllKPITypes.Total_Parts_Sold__c)){
                result.totalPartsSoldRewardLevel = elt.Name;
                result.totalPartsSoldPoints = String.valueOf(AllKPITypes.Total_Parts_Sold__c);
                result.totalPartsSoldToolTip = elt.Reward_Level__c;
            } 
            //Populating TPS Retran
            if(elt.KPI_Setup__r.KPI_Type__c == 'Total Parts Sold ReTran' && checkInRange(elt,AllKPITypes.Total_Parts_Sold_ReTran__c)){
                result.totalPartsSoldReTranRewardLevel = elt.Name;
                result.totalPartsSoldRetranPoints = String.valueOf(AllKPITypes.Total_Parts_Sold_ReTran__c);
                result.totalPartsSoldReTranToolTip = elt.Reward_Level__c;
            }
            //Populating Training
            if(elt.KPI_Setup__r.KPI_Type__c == 'Training' && checkInRange(elt,AllKPITypes.Training__c )){
                result.trainingRewardLevel = elt.Name;
                result.trainingPoints = String.valueOf(AllKPITypes.Training__c);
                result.trainingToolTip = elt.Reward_Level__c;
            }
            //Populating Parts Ordering
            if(elt.KPI_Setup__r.KPI_Type__c == 'Parts Ordering' && checkInRange(elt,AllKPITypes.Parts_Ordering__c )){
                result.partsOrderingRewardLevel = elt.Name;
                result.partsOrderingPoints = String.valueOf(AllKPITypes.Parts_Ordering__c);
                result.partsOrderingToolTip = elt.Reward_Level__c;
            }
            //CHG44908 - Based on the year value, setup the Service Dealer Development points
            //Start
            if(year1<=2023){
                //Populating Service Dealer Development
                if(elt.KPI_Setup__r.KPI_Type__c == 'Service Dealer Development' && checkInRange(elt,AllKPITypes.Service_Dealer_Development__c)){
                    result.serviceDealerDevRewardLevel = elt.Name;
                    result.serviceDealerDevPoints = String.valueOf(AllKPITypes.Service_Dealer_Development__c);
                    result.serviceDealerDevToolTip = elt.Reward_Level__c;
                }
            }
            //CHG44908 - Based on the year value, setup the ETC points
            if(year1 > 2023){
                //Populating Extended Transmission Coverage
                if((elt.KPI_Setup__r.KPI_Type__c == 'Extended Transmission Coverage') && checkInRange(elt,AllKPITypes.ETC__c)){
                    result.ETCDevRewardLevel = elt.Name;
                    result.ETCDevPoints = String.valueOf(AllKPITypes.ETC__c);
                    result.ETCDevToolTip = elt.Reward_Level__c;
                    System.debug('Checking Dealer :'+AllKPITypes.ETC__c);
                }
            }
            //End
        }
        //CalcAverage(result);
        CalcAverageRegional(result);
        system.debug('result.AVERAGE-----'+result.Average);
        system.debug('result.KPILIST SIZE-----'+result.Kpilistsize);
        system.debug('result.SUM OF SCORE-----'+result.Sumofscore);
        return result;
    }
    
    private static Boolean checkInRange(KPI_Range_Settings__c elt , Decimal value){
        if(elt != null && value != null){
            return value.setScale(1,System.RoundingMode.HALF_UP) == elt.Points__c.setScale(1,System.RoundingMode.HALF_UP);
        }
        return false;
    }
    public class WrapperPRPRewardLevels {
        //Added to debug
        @AuraEnabled public Double Kpilistsize{get;set;}
        @AuraEnabled public Double Sumofscore{get;set;}
        //
        @AuraEnabled public String CSIRewardLevel{get;set;}
        @AuraEnabled public String CSIPoints{get;set;}
        @AuraEnabled public String CSIToolTip{get;set;}
        @AuraEnabled public String CSIDealerRewardLevel{get;set;}
        @AuraEnabled public String CSIDealerPoints{get;set;}       
        @AuraEnabled public String CSIDealerToolTip{get;set;}
        @AuraEnabled public String CSIPartsRewardLevel{get;set;}  
        @AuraEnabled public String CSIPartsPoints{get;set;}
        @AuraEnabled public String CSIPartsToolTip{get;set;}
        @AuraEnabled public String CSIServiceRewardLevel{get;set;}
        @AuraEnabled public String CSIServicePoints{get;set;}       
        @AuraEnabled public String CSIServiceToolTip{get;set;}
        @AuraEnabled public String facilityAuditRewardLevel{get;set;}
        @AuraEnabled public String facilityAuditPoints{get;set;}
        @AuraEnabled public String facilityAuditToolTip{get;set;}
        @AuraEnabled public String partsOrderingRewardLevel{get;set;}
        @AuraEnabled public String partsOrderingPoints{get;set;}
        @AuraEnabled public String partsOrderingToolTip{get;set;}
        @AuraEnabled public String totalPartsSoldRewardLevel{get;set;}
        @AuraEnabled public String totalPartsSoldPoints{get;set;}     
        @AuraEnabled public String totalPartsSoldToolTip{get;set;}
        @AuraEnabled public String turnAroundTimeIRewardLevel{get;set;}
        @AuraEnabled public String turnAroundTimeIPoints{get;set;}     
        @AuraEnabled public String turnAroundTimeIToolTip{get;set;}
        @AuraEnabled public String turnAroundTimeORewardLevel{get;set;}
        @AuraEnabled public String turnAroundTimeOPoints{get;set;}
        @AuraEnabled public String turnAroundTimeOToolTip{get;set;}
        @AuraEnabled public String turnAroundTimeMRewardLevel{get;set;}
        @AuraEnabled public String turnAroundTimeMPoints{get;set;}
        @AuraEnabled public String turnAroundTimeMToolTip{get;set;}
        @AuraEnabled public String trainingRewardLevel{get;set;}
        @AuraEnabled public String trainingPoints{get;set;}
        @AuraEnabled public String trainingToolTip{get;set;}
        @AuraEnabled public String totalPartsSoldReTranRewardLevel{get;set;}
        @AuraEnabled public String totalPartsSoldReTranPoints{get;set;}
        @AuraEnabled public String totalPartsSoldReTranToolTip{get;set;}
        @AuraEnabled public String tPSRewardLevel{get;set;}
        @AuraEnabled public String tPSPoints{get;set;}
        @AuraEnabled public String tPSToolTip{get;set;}
        @AuraEnabled public String serviceDealerDevRewardLevel{get;set;}
        @AuraEnabled public String serviceDealerDevPoints{get;set;}
        @AuraEnabled public String serviceDealerDevToolTip{get;set;}
        @AuraEnabled public String region{get;set;}
        @AuraEnabled public String pRPLevel{get;set;}
        @AuraEnabled public String pRPScore{get;set;}
        @AuraEnabled public String Address{get;set;}
        @AuraEnabled public String City{get;set;}
        @AuraEnabled public String Country{get;set;}
        @AuraEnabled public Double Average{get;set;}
        @AuraEnabled public String ErrorMessage{get;set;}
        @AuraEnabled public String kPISelected{get;set;}
        @AuraEnabled public Boolean CSIBoolean{get;set;}
        @AuraEnabled public Boolean CSIPartsBoolean{get;set;}
        @AuraEnabled public Boolean CSIDealerBoolean{get;set;}
        @AuraEnabled public Boolean CSIServiceBoolean{get;set;}
        @AuraEnabled public Boolean PartsOrderingBoolean{get;set;}
        @AuraEnabled public Boolean tpsBoolean{get;set;}
        @AuraEnabled public Boolean tpsRetranBoolean{get;set;}
        @AuraEnabled public Boolean trainingBoolean{get;set;}
        @AuraEnabled public Boolean facilityAuditBoolean{get;set;}
        @AuraEnabled public Boolean tatIBoolean{get;set;}
        @AuraEnabled public Boolean tatOBoolean{get;set;}
        @AuraEnabled public Boolean tatMBoolean{get;set;}
        @AuraEnabled public Boolean serviceDealerDevBoolean{get;set;}
        @AuraEnabled public String CurrentMonth{get;set;}
        @AuraEnabled public String acctype{get;set;}
        @AuraEnabled public Boolean ETCBoolean{get;set;}
        @AuraEnabled public String ETCDevRewardLevel{get;set;}
        @AuraEnabled public String ETCDevPoints{get;set;}
        @AuraEnabled public String ETCDevToolTip{get;set;}
        public WrapperPRPRewardLevels(){
            //Added to debug
            Kpilistsize=0;
            Sumofscore=0;
            //
            acctype='';
            CSIBoolean = false;
            CSIPartsBoolean = false;
            CSIDealerBoolean = false;
            CSIServiceBoolean = false;
            PartsOrderingBoolean = false;
            tpsBoolean = false;
            tpsRetranBoolean = true;
            trainingBoolean = false;
            facilityAuditBoolean = false;
            tatIBoolean = false;
            tatOBoolean = false;
            tatMBoolean = false;
            CSIRewardLevel='';
            CSIPoints='';
            CSIDealerRewardLevel='';
            CSIDealerPoints='';
            CSIPartsRewardLevel='';
            CSIPartsPoints='';
            CSIServiceRewardLevel='';
            CSIServicePoints='';
            facilityAuditRewardLevel='';
            facilityAuditPoints='';
            partsOrderingRewardLevel='';
            partsOrderingPoints='';
            totalPartsSoldRewardLevel='';
            totalPartsSoldPoints='';
            turnAroundTimeIRewardLevel='';
            turnAroundTimeIPoints='';
            turnAroundTimeORewardLevel='';
            turnAroundTimeOPoints='';
            turnAroundTimeMRewardLevel='';
            turnAroundTimeMPoints='';
            trainingRewardLevel='';
            trainingPoints='';
            totalPartsSoldReTranRewardLevel='';
            totalPartsSoldReTranPoints='';
            tPSRewardLevel='';
            tPSPoints='';
            region='';
            pRPLevel='';
            pRPScore = '';
            tPSToolTip = '';
            totalPartsSoldReTranToolTip = '';
            trainingToolTip = '';
            turnAroundTimeMToolTip = '';
            turnAroundTimeIToolTip = '';
            turnAroundTimeOToolTip ='';
            totalPartsSoldToolTip = '';
            partsOrderingToolTip = '';
            facilityAuditToolTip = '';
            CSIDealerToolTip = '';
            CSIToolTip = '';
            CSIDealerToolTip = '';
            CSIToolTip = '';
            CSIPartsToolTip = '';
            CSIServiceToolTip = '';
            ErrorMessage = '';
            CurrentMonth = '';
            serviceDealerDevToolTip = '';
            serviceDealerDevPoints = '';
            serviceDealerDevRewardLevel = '';
            ETCDevRewardLevel = '';
            ETCDevPoints = '';
            ETCDevToolTip = '';
        }
    }
    public static void CalcAverageRegional(WrapperPRPRewardLevels calc){
        List<KPI__c> kpiForCalc = new List<KPI__c>();
        Decimal sumOfScore=0.0;
        Decimal averageOfScore=0.0;
        if(calc.region == 'North America'){
            kpiForCalc = [SELECT Name,PRP_Score__c,Region__c,Customer__c,Month__c, Year__c FROM KPI__c WHERE Customer__r.Type ='Distributor Branch' AND Region__c = :calc.region AND isPartOfPRP__c = TRUE AND Period__c = 'YTD'];
        }
        else{
            kpiForCalc = [SELECT Name,PRP_Score__c,Region__c,Customer__c,Month__c, Year__c FROM KPI__c WHERE Customer__r.Type =:calc.acctype AND Region__c = :calc.region AND isPartOfPRP__c = TRUE AND Period__c = 'YTD'];
        }
        for(KPI__c kpi:kpiForCalc){
            sumOfScore = sumOfScore+kpi.PRP_Score__c;
        }
        averageOfScore = sumOfScore/kpiForCalc.size();
        averageOfScore = averageOfScore.setScale(2);
        calc.Average = averageOfScore;
        Double x,y;
        x= kpiForCalc.size();
        y= sumOfScore;
        calc.Kpilistsize=x;
        calc.Sumofscore=y;
    }
    @AuraEnabled
    public static List<String> getPickListValuesIntoList()
    {
        List<String> pickListValuesList= new List<String>();
        List<YearMetaData__mdt> Yearlist= new List<YearMetaData__mdt>();
        Yearlist= [select Year__c from YearMetaData__mdt ORDER BY Year__c DESC ];
        for( YearMetaData__mdt val : Yearlist){
            pickListValuesList.add(val.Year__c);
        }   
        system.debug('pickListValuesList'+pickListValuesList);
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
            account = [SELECT ID,Sales_RegionA__c,Type,name,SAP_ID__c,AccountSAPField__c FROM Account WHERE ID IN :IdOfAccounts AND Sales_RegionA__c != null];
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
    public class LocationWrapper{
        @AuraEnabled public Boolean isNorthAmerica{get;set;}
        @AuraEnabled public List<Account> locationOptions{get;set;}
        
    }
    
}