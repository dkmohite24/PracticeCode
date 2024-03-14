/*
 * Update : CHG44908 - We are displaying ETC points in the Reward Summary and Reward Summary Admin reports.
 * Updated By : Susovan Mondal & Chinmaya Dash
 * 
 */

public class PRPC_rewardSummaryDisClassAdmin {
    @AuraEnabled
    public static List<Account> getName(String accId){
        accId = '0010r00000Q2tBFAAZ';
        //accId= userInfo.getUserId();
        List<Account> getValue= [SELECT Name
                                 FROM Account WHERE Id=:accId ];
        //System.debug(accId);
        return getValue;
    }
    
    @AuraEnabled 
    public static LocationWrapper getAllBranches(String DistId, String PartTypeApex){
        LocationWrapper locationWrapper = new LocationWrapper();
        //Logic for boolean is inside north america
        Boolean isNorthAmerica=false;
        System.debug('Inside Apex');
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
    public static Map<Integer,String> intToMonthMap = new Map<Integer,String>{1=>'JANUARY',2=>'FEBRUAURY',3=>'MARCH',4=>'APRIL',5=>'MAY',6=>'JUNE',7=>'JULY',8=>'AUGUST',9=>'SEPTEMBER',10=>'OCTOBER',11=>'NOVEMBER',12=>'DECEMBER'};
    @AuraEnabled
    public static WrapperPRPRewardLevels getAllValue(String accId, String SearchKeyApex, String SelectedPickValueApex, String SelectedYearApex, String SelectedMonthApex){
        System.debug('accId'+accId);
        System.debug('SearchKey'+SearchKeyApex);
        System.debug('SelectedPickValueApex'+ SelectedPickValueApex);
        System.debug('SelectedMonthApex'+SelectedMonthApex);
        System.debug('SelectedYearApex'+SelectedYearApex);
        Decimal SelectedYearApex1;
        Decimal SelectedMonthApex1;
        SelectedYearApex1 = Decimal.valueOf(SelectedYearApex);
        String RegionOfDistributor = [SELECT Sales_RegionA__c FROM Account WHERE Id = :accId LIMIT 1].Sales_RegionA__c;
        KPI__c getValue ;
        if(SelectedPickValueApex == 'Distributor'){
            if(RegionOfDistributor == 'North America'){
                try{
                    if(SelectedYearApex1 <=2023){
                        getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                                   Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                                   Training__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Region__c,Year__c,MonthName__c,Customer__r.Type,Customer__r.ShippingCountry, Customer__r.ShippingCity,Customer__r.ShippingState,KPI_Calculation_Date__c
                                   FROM KPI__c WHERE Period__c = 'YTD' AND Customer__r.CitySAPField__c=:SearchKeyApex AND Year__c=:SelectedYearApex1 AND MonthName__c=:SelectedMonthApex ORDER BY KPI_Calculation_Date__c
                                   DESC LIMIT 1];
                        System.debug('getValue'+ getValue);
                    }else{
                        //CHG44908 - Based on the year, we are fetching ETC Data from KPI
                        //Start
                        getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                                   Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                                   Training__c,ETC_Score__c,ETC__c,Region__c,Year__c,MonthName__c,Customer__r.Type,Customer__r.ShippingCountry, Customer__r.ShippingCity,Customer__r.ShippingState,KPI_Calculation_Date__c
                                   FROM KPI__c WHERE Period__c = 'YTD' AND Customer__r.CitySAPField__c=:SearchKeyApex AND Year__c=:SelectedYearApex1 AND MonthName__c=:SelectedMonthApex ORDER BY KPI_Calculation_Date__c
                                   DESC LIMIT 1];
                        System.debug('getValue'+ getValue);
                    }
                    //End
                }
            catch(System.QueryException e){
                System.debug('Error '+e.getMessage()); 
                throw new AuraHandledException('The selected Location does not have any KPI');    
              }
            }
            else{
            System.debug('Inside Distributor');
            try{
                getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                           Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                           Training__c,Region__c,Year__c,MonthName__c,Customer__r.Type,Customer__r.BillingCountry, Customer__r.BillingCity,Customer__r.ShippingCountry, Customer__r.ShippingCity,Customer__r.ShippingState,KPI_Calculation_Date__c
                           FROM KPI__c WHERE Period__c = 'YTD' AND Customer__r.Id=:accId AND Year__c=:SelectedYearApex1 AND MonthName__c=:SelectedMonthApex ORDER BY KPI_Calculation_Date__c
                           DESC LIMIT 1];
                System.debug('getValue'+ getValue);
                //System.debug('getValue'+ getValue.Customer__r.Address_1__c);
                //System.debug('getValue'+ getValue.Customer__r.ShippingCity);    
            }
            catch(System.QueryException e){
                System.debug('Error '+e.getMessage()); 
                throw new AuraHandledException('The selected Location does not have any KPI');    
              }
            }
        }
        else if(SelectedPickValueApex == 'Direct Dealer'){
            System.debug('Inside Direct Dealer');
            try{
                getValue= [SELECT Facility_Audit__c,CSI__c,PRP_Score__c,PRP_Level__c,Turnaround_Time_I__c,Turnaround_Time_M__c,
                           Turnaround_Time_O__c,CSI_Dealer__c,CSI_Dealer_Score__c,CSI_Parts__c,CSI_Service__c,Service_Dealer_Development_Score__c,Service_Dealer_Development__c,Parts_Ordering__c,Total_Parts_Sold__c,Total_Parts_Sold_ReTran__c,TPS__c,
                           Training__c,Region__c,Year__c,MonthName__c,Customer__r.Type,Customer__r.BillingCountry, Customer__r.BillingCity,Customer__r.ShippingCountry, Customer__r.ShippingCity,Customer__r.ShippingState,KPI_Calculation_Date__c
                           FROM KPI__c WHERE Period__c = 'YTD' AND Customer__r.Id=:accId AND Year__c=:SelectedYearApex1 AND MonthName__c=:SelectedMonthApex ORDER BY KPI_Calculation_Date__c
                           DESC LIMIT 1];
                System.debug('getValue'+ getValue);
                //System.debug('getValue'+ getValue.Customer__r.Address_1__c);
                //System.debug('getValue'+ getValue.Customer__r.ShippingCity);
            }
            catch(System.QueryException e){
                System.debug('Error '+e.getMessage()); 
                throw new AuraHandledException('The selected Location does not contain a KPI assigned to it yet.');    
            }
        }
        return getRange(getValue,SelectedPickValueApex);
        
    }
    /*public class KPIWrapperClass{
        @AuraEnabled public List<KPI_Range_Settings__c> rangeSet = new List<KPI_Range_Settings__c>();
        @AuraEnabled public WrapperPRPRewardLevels kpi{get;set;}
    }*/
    
    @AuraEnabled
    public static WrapperPRPRewardLevels getRange(KPI__c AllKPITypes, String SelectedPartner){
        //KPI__c kpiname = AllKPITypes[0];
        System.debug('initial'+AllKPITypes.TPS__c);
        List<KPI_Range_Settings__c> getRangeValues = new List<KPI_Range_Settings__c>();
        String Year = String.valueOf(AllKPITypes.Year__c);
        String Month = AllKPITypes.MonthName__c;
        Integer year1= Integer.valueof(Year);
        System.debug('Month Selected :::'+Month);
        /*Switch on currentMonth {
            when 1{
                Month = 'JANUARY';}
            when 2{
                Month = 'FEBRUAURY';}
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
        }*/
        List<KPI_Range_Settings__c> kpirs=[SELECT Name,
                                           KPI_Setup__r.KPI_Type__c,
                                           Reward_Level__c,
                                           Low_Range_Value__c,
                                           High_Range_Value__c,
                                           KPI_Setup__r.Region__c,
                                           Points__c FROM KPI_Range_Settings__c WHERE
                                           KPI_Setup__r.Region__c = :AllKPITypes.Region__c AND KPI_Setup__r.Year__c = :Year];
        System.debug('AllKPITypes.Region__c'+AllKPITypes.Region__c);
        System.debug('SelectedPartner'+SelectedPartner);
        List<PRP_Setup__c> kpiSelected = [SELECT KPI_Selection__c FROM PRP_Setup__c WHERE PRP_Setup__c.Region__c =:AllKPITypes.Region__c AND PRP_Setup__c.Year__c = :Year AND PRP_Setup__c.Month__c = :Month AND PRP_Setup__c.Partner_Type__c =: SelectedPartner];
        System.debug('KPISELECTED'+kpiSelected);
        //System.debug('KPI SD :'+AllKPITypes.Service_Dealer_Development__c);
        WrapperPRPRewardLevels result = new WrapperPRPRewardLevels();
        result.acctype = AllKPITypes.Customer__r.Type;
        result.Address = AllKPITypes.Customer__r.ShippingCity;
        result.City = AllKPITypes.Customer__r.ShippingState;
        result.Country = AllKPITypes.Customer__r.ShippingCountry;
        System.debug('City ::'+result.City);
        result.region = String.valueOf(AllKPITypes.Region__c);
        result.pRPLevel = String.valueOf(AllKPITypes.PRP_Level__c);
        result.pRPScore = String.valueOf(AllKPITypes.PRP_Score__c);
        System.debug('Before entering CSIBoolean'+result.CSIBoolean);
        System.debug('Before entering CSIDealerBoolean'+result.CSIDealerBoolean);
        System.debug('Before entering CSIServiceBoolean'+result.CSIServiceBoolean);
        System.debug('Before entering CSIPartsBoolean'+result.CSIPartsBoolean);
        System.debug('Before entering PartsOrderingBoolean'+result.PartsOrderingBoolean);
        System.debug('Before entering tpsBoolean'+result.tpsBoolean);
        System.debug('Before entering tpsRetranBoolean'+result.tpsRetranBoolean);
        System.debug('Before entering trainingBoolean'+result.trainingBoolean);
        System.debug('Before entering Service Dealer'+result.serviceDealerDevBoolean);
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
        System.debug('After entering Service Dealer'+result.serviceDealerDevBoolean);
                    System.debug('#############'+AllKPITypes.Training__c);
        
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
            if(elt.KPI_Setup__r.KPI_Type__c == 'CSI Parts'){
                System.debug('Inside CSI Parts');
                       System.debug('Low Range'+elt.Low_Range_Value__c);
                       System.debug('High Range'+elt.High_Range_Value__c);
                       System.debug('************'+checkInRange(elt,AllKPITypes.CSI_Parts__c ));
                
            }
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
            if(elt.KPI_Setup__r.KPI_Type__c == 'Total Parts Sold'){
                System.debug('Inside TPS');
                       System.debug('Low Range'+elt.Low_Range_Value__c);
                       System.debug('High Range'+elt.High_Range_Value__c);
                       System.debug('************'+checkInRange(elt,AllKPITypes.Total_Parts_Sold__c ));
                
            }
            if(elt.KPI_Setup__r.KPI_Type__c == 'Total Parts Sold' && checkInRange(elt,AllKPITypes.Total_Parts_Sold__c)){
                result.totalPartsSoldRewardLevel = elt.Name;
                result.totalPartsSoldPoints = String.valueOf(AllKPITypes.Total_Parts_Sold__c);
                result.totalPartsSoldToolTip = elt.Reward_Level__c;
            } 
            if(elt.KPI_Setup__r.KPI_Type__c == 'Total Parts Sold ReTran'){
                System.debug('Inside Total Parts Sold ReTran');
                       System.debug('Low Range'+elt.Low_Range_Value__c);
                       System.debug('High Range'+elt.High_Range_Value__c);
                       System.debug('************'+checkInRange(elt,AllKPITypes.Total_Parts_Sold_ReTran__c ));
                
            }
            //Populating TPS Retran
            if(elt.KPI_Setup__r.KPI_Type__c == 'Total Parts Sold ReTran' && checkInRange(elt,AllKPITypes.Total_Parts_Sold_ReTran__c)){
                result.totalPartsSoldReTranRewardLevel = elt.Name;
                result.totalPartsSoldReTranPoints = String.valueOf(AllKPITypes.Total_Parts_Sold_ReTran__c);
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
                    System.debug('Inside Serv Dealer');
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
        return result;
    }
    
    private static Boolean checkInRange(KPI_Range_Settings__c elt , Decimal value){
        if(elt != null && value != null){
            return value.setScale(1,System.RoundingMode.HALF_UP) == elt.Points__c.setScale(1,System.RoundingMode.HALF_UP);
        }
        return false;
    }
    public class WrapperPRPRewardLevels {
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
        //Added to debug
        @AuraEnabled public Double Kpilistsize{get;set;}
        @AuraEnabled public Double Sumofscore{get;set;}
        //
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
        @AuraEnabled public Boolean ETCBoolean{get;set;}
        @AuraEnabled public String ETCDevRewardLevel{get;set;}
        @AuraEnabled public String ETCDevPoints{get;set;}
        @AuraEnabled public String ETCDevToolTip{get;set;}
        @AuraEnabled public String acctype{get;set;} 
            
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
            Country = '';
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
        //added to debug
         Decimal x = kpiForCalc.size();
        Decimal y = sumOfScore;
         calc.Kpilistsize=x;
        calc.Sumofscore=y;
       
    }
    /*public static void CalcAverage(WrapperPRPRewardLevels calc){
            Integer denominator = 0;
            Decimal Average = 0.0;
            //System.debug('Double.valueOf(calc.totalPartsSoldReTranPoints)'+(calc.totalPartsSoldReTranPoints));
            //System.debug('Double.valueOf(calc.turnAroundTimeMPoints)'+(calc.turnAroundTimeMPoints));
            //System.debug('Double.valueOf(calc.turnAroundTimeOPoints)'+(calc.turnAroundTimeOPoints));                                         System.debug('Double.valueOf(calc.turnAroundTimeIPoints)'+Double.valueOf(calc.turnAroundTimeIPoints));
            //System.debug('Double.valueOf(calc.CSIPartsPoints)'+(calc.CSIPartsPoints));
            //System.debug('Double.valueOf(calc.CSIServicePoints)'+(calc.CSIServicePoints));

            if(calc.region == 'North America'){
                if(calc.tpsRetranBoolean == true){
                    Average= Average+Decimal.valueOf(calc.totalPartsSoldReTranPoints);
                    denominator++;
                }
                if(calc.tatMBoolean == true){
                    Average= Average+Decimal.valueOf(calc.turnAroundTimeMPoints);
                    denominator++;
                }
				if(calc.trainingBoolean == true){
                    Average= Average+Decimal.valueOf(calc.trainingPoints);
                    denominator++;
                }
                if(calc.tatOBoolean == true){
                    Average= Average+Decimal.valueOf(calc.turnAroundTimeOPoints);
                    denominator++;
                }
                if(calc.tpsBoolean == true){
                    Average= Average+Decimal.valueOf(calc.tPSPoints);
                    denominator++;
                }
                if(calc.tatIBoolean == true){
                    Average= Average+Decimal.valueOf(calc.turnAroundTimeIPoints);
                    denominator++;
                }
                if(calc.CSIPartsBoolean == true){
                    Average= Average+Decimal.valueOf(calc.CSIPartsPoints);
                    denominator++;
                }
                if(calc.CSIServiceBoolean == true){
                    Average= Average+Decimal.valueOf(calc.CSIServicePoints);
                    denominator++;
                }
                if(denominator != 0){
                    System.debug('Average/denominator'+Average/denominator);
                	calc.Average = (Average/denominator).SetScale(2); 
                }
            }
            else{
                System.debug('Inside Acia Pacific');
                if(calc.facilityAuditBoolean == true){
                    Average= Average+Decimal.valueOf(calc.facilityAuditPoints);
                    denominator++;
                }
                if(calc.PartsOrderingBoolean == true){
                    Average= Average+Decimal.valueOf(calc.partsOrderingPoints);
                    denominator++;
                }
				if(calc.trainingBoolean == true){
                    Average= Average+Decimal.valueOf(calc.trainingPoints);
                    denominator++;
                }
                if(calc.tatOBoolean == true){
                    Average= Average+Decimal.valueOf(calc.turnAroundTimeOPoints);
                    denominator++;
                }
                if(calc.tpsBoolean == true){
                    Average= Average+Decimal.valueOf(calc.tPSPoints);
                    denominator++;
                }
                if(calc.tatIBoolean == true){
                    Average= Average+Decimal.valueOf(calc.turnAroundTimeIPoints);
                    denominator++;
                }
                if(calc.CSIBoolean == true){
                    Average= Average+Decimal.valueOf(calc.CSIPoints);
                    denominator++;
                }
                if(denominator != 0){
                	calc.Average = (Average/denominator).SetScale(2);    
                }
            }
    }*/
    public class LocationWrapper{
        @AuraEnabled public Boolean isNorthAmerica{get;set;}
        @AuraEnabled public List<Account> locationOptions{get;set;}
        
    }
}