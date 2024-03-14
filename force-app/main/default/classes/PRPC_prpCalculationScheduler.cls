/**
 * @Description: schedule the KPI Calculation on a specific date.
 * Created:  09/05/2020 – Nitish Gyansys
 * Updated:  01/08/2022 - Akanksha Mondal,Ritu Raj Singh
 * Updated By : 10/17/2023 - Susovan Mondal & Chinmaya Dash
 * Update : ENHC0011584 - ETC is added as a new metric for calculation and SDM metric was removed from the system.
**/
global class PRPC_prpCalculationScheduler implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    public Integer year;
    public Integer month;
    public Boolean isScheduled;
    public Map<String, List<KPI_Range_Settings__c>> kpiMap = new Map<String, List<KPI_Range_Settings__c>>();
    public Map<String, Decimal> surveyFormulaMap = new Map<String,Decimal>();
    public Integer startYear;
    public Integer startMonth;
    public Integer endYear;
    public Integer endMonth;
    public String period;
    public Map<String, List<String>> directDealerGroupMap = new Map<String, List<String>>();
    public Map<String, String> directDealerGroupRevMap = new Map<String, String>();
    public Set<String> excludeSapIdList;
    public Map<String, PRP_Setup__c> prpKpiTypeMap = new Map<String, PRP_Setup__c>();
    public List<String> SelectedRegions = new List<String>{'North America', 'Latin America', 'Asia Pacific', 'EMEA'};
    public static Map<String, String> allMonthMap = new Map<String, String>{'1' => 'January',
        '2' => 'February',
        '3' => 'March',
        '4' => 'April',
        '5' => 'May',
        '6' => 'June',
        '7' => 'July',
        '8' => 'August',
        '9' => 'September',
        '10' => 'October',
        '11' => 'November',
        '12' => 'December'};
            
  global void execute(SchedulableContext sc) {
      Integer isCalculationDay = 0;
        isCalculationDay = [SELECT count() FROM KPI_Date_Settings__c WHERE KPI_Calculation_Date__c = TODAY];
        if(isCalculationDay > 0) {
        isScheduled = true;
        year = Date.Today().year();
        month = Date.Today().month();
       if(month == 1) {
          month = 12;
            year = year - 1;
        }
       else month = month - 1;
          kpiMap = PRPC_prpCalculationClass.findAllKPISetup(); 
            surveyFormulaMap = PRPC_prpCalculationClass.findSurveyFormula(year);
            this.period = 'YTD';
            Database.executeBatch(this, 1);
        }
    }
    
    public string executePRPCalculation(Date startDate, Date endDate) {
        isScheduled = false;
        if(startDate != null && startDate <= Date.Today()) {
            startYear = startDate.year();
            startMonth = startDate.month();    
        }
        if(endDate != null && endDate <= Date.Today()) {
            endYear = endDate.year();
            endMonth = endDate.month();
        }
        if(startYear != null && startMonth != null) {
            year = startYear;
            month = startMonth;
        }
        else {
            return 'Select Valid Start Date';
        } 
        if(endYear == null || endMonth == null) {
            return 'Select Valid End Date';
        }
        
        Boolean isPRPAvailable = true;
        for(PRP_Setup__c prpSetUp : [SELECT Id, Name, Region__c, KPI_Selection__c, Partner_Type__c, Year__c, Month__c,Manual_Override__c FROM PRP_Setup__c WHERE Year__c =:String.valueOf(year) AND Month__c = :allMonthMap.get(String.valueOf(month))]) {
            String key = prpSetUp.Region__c+'-'+ prpSetUp.Partner_Type__c + '-'+ prpSetUp.Year__c + '-' +month;
            prpKpiTypeMap.put(key, prpSetUp);
        }
        System.debug('Check 81: prpKpiTypeMap '+prpKpiTypeMap);
        String keyPRP = 'North America-Distributor-'+String.valueOf(year)+'-'+String.valueOf(month);
        System.debug('Check 81: keyPRP '+keyPRP);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: NMD'+isPRPAvailable);
        keyPRP = 'Latin America-Distributor-'+String.valueOf(year)+'-'+String.valueOf(month);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: LAD'+isPRPAvailable);
        keyPRP = 'Latin America-Direct Dealer-'+String.valueOf(year)+'-'+String.valueOf(month);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: LADD'+isPRPAvailable);
        keyPRP = 'EMEA-Distributor-'+String.valueOf(year)+'-'+String.valueOf(month);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: ED'+isPRPAvailable);
        keyPRP = 'EMEA-Direct Dealer-'+String.valueOf(year)+'-'+String.valueOf(month);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: EDD'+isPRPAvailable);
        keyPRP = 'Asia Pacific-Distributor-'+String.valueOf(year)+'-'+String.valueOf(month);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: APD'+isPRPAvailable);
        keyPRP = 'Asia Pacific-Direct Dealer-'+String.valueOf(year)+'-'+String.valueOf(month);
        if(!prpKpiTypeMap.containsKey(keyPRP)) isPRPAvailable = false;
        System.debug('Check 81: '+isPRPAvailable);
        if(!isPRPAvailable) {
            System.debug('Check 81: '+isPRPAvailable);
            return 'PRP records are not created.';
        }
        try {
            kpiMap = PRPC_prpCalculationClass.findAllKPISetup(); 
            surveyFormulaMap = PRPC_prpCalculationClass.findSurveyFormula(year);
            this.period = 'YTD';
            Database.executeBatch(this, 1);
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
        return 'success';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        for(PRP_Setup__c prpSetUp : [SELECT Id, Name, Region__c, KPI_Selection__c, Partner_Type__c, Year__c, Month__c,Manual_Override__c FROM PRP_Setup__c WHERE Year__c =:String.valueOf(year) AND Month__c = :allMonthMap.get(String.valueOf(month))]) {
            String key = prpSetUp.Region__c+'-'+ prpSetUp.Partner_Type__c + '-'+ prpSetUp.Year__c + '-' +month;
            prpKpiTypeMap.put(key, prpSetUp);
        }
        excludeSapIdList = new Set<String>();
        List<Direct_Dealer_Group__mdt> dealerGroup = new List<Direct_Dealer_Group__mdt>();
        dealerGroup = [SELECT Id,Parent_Dealer__c, Child_Dealers__c FROM Direct_Dealer_Group__mdt];
        for(Direct_Dealer_Group__mdt directDealer : dealerGroup) {
            directDealerGroupMap.put(directDealer.Parent_Dealer__c, directDealer.Child_Dealers__c.split(','));
            directDealerGroupMap.get(directDealer.Parent_Dealer__c).add(directDealer.Parent_Dealer__c);
            excludeSapIdList.addAll(directDealer.Child_Dealers__c.split(','));
            excludeSapIdList.add(directDealer.Parent_Dealer__c);
        }
        
        for(String key : directDealerGroupMap.keySet() ) {
            for(String dealers : directDealerGroupMap.get(key)) {
                directDealerGroupRevMap.put(dealers,key);
            }
            
        }
        String query = 'SELECT Id, Name, Sales_RegionA__c, Type,Location_Type__c,SAP_Id__c FROM Account WHERE ';
        query += '(Type = \'Distributor\' OR Type = \'Direct Dealer\') and PRP_Participation__c = true';
        query += ' AND Sales_RegionA__c IN :SelectedRegions ';
        //if(!Test.isRunningTest())query += ' and Id = \'0012300000kpvfrAAA\'';
     // query += ' and Id IN (\'0013h00000QOCTLAA5\')';
      // query += ' and Sales_RegionA__c = \'Latin America\'';
        
        if(Test.isRunningTest()) query += ' order by CreatedDate DESC LIMIT 1';
        System.debug('Check 69: '+Database.query(query));
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext bc, List<Account> records){
        Boolean isInternational = records[0].Sales_RegionA__c != 'North America';
        PRPC_prpCalculationClass.findAllAccounts(records[0].Id, year, month,period /*, directDealerGroupMap */);
        Map<String, List<PRPC_prpCalculationClass.kpiScoreWrapper>> prpScoreMapMap = new Map<String, List<PRPC_prpCalculationClass.kpiScoreWrapper>>();
        String prpKpiTypekey = records[0].Sales_RegionA__c+'-'+ records[0].Type + '-'+ year + '-' +month;
        String availableKpiTypes = prpKpiTypeMap.containsKey(prpKpiTypekey) ? prpKpiTypeMap.get(prpKpiTypekey).KPI_Selection__c : '';
        List<String> availableKpiTypesSet = availableKpiTypes != null ? availableKpiTypes.split(',') : new List<String>();
        
        if(isInternational) {
            if(availableKpiTypesSet.contains('CSI')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateCSI(records[0].Id, kpiMap, prpScoreMapMap, surveyFormulaMap, year, month,period, 'CSI');
            }
            if(availableKpiTypesSet.contains('Training')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTraining(records[0].Id, kpiMap, year, prpScoreMapMap, month);
            }
            if(availableKpiTypesSet.contains('TPS New')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTPS(records[0].Id, kpiMap, year, prpScoreMapMap, month, 'TPS',period, true);
            }
            else if(availableKpiTypesSet.contains('TPS')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTPS(records[0].Id, kpiMap, year, prpScoreMapMap, month, 'TPS',period, false);
            }
            if(availableKpiTypesSet.contains('Parts Ordering')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculatePartsOrdering_INT(records[0].Id, kpiMap, year, prpScoreMapMap, month, period);
            }
            if(availableKpiTypesSet.contains('Turn Around Time I')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTAT(records[0].Id, kpiMap, year, prpScoreMapMap, month,period /*, directDealerGroupMap*/);
            }
            if(availableKpiTypesSet.contains('Facility Audit')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateFacilityAudit(records[0].Id, kpiMap, year, prpScoreMapMap, month, period);
            }
        }
        else {
            if(availableKpiTypesSet.contains('CSI Parts')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateCSI(records[0].Id, kpiMap, prpScoreMapMap, surveyFormulaMap, year, month, period, 'Parts');
            }
            if(availableKpiTypesSet.contains('CSI Service')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateCSI(records[0].Id, kpiMap, prpScoreMapMap, surveyFormulaMap, year, month, period, 'Service');
            }
            if(availableKpiTypesSet.contains('Annual Dealer Experience')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateAnnualDealerExperience(records[0].Id, kpiMap, prpScoreMapMap, year, month, period);
            }
            /*if(availableKpiTypesSet.contains('Service Dealer Development')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateServiceDealerDev(records[0].Id, kpiMap, prpScoreMapMap, year, month, period);
            }*/
            if(availableKpiTypesSet.contains('Training')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTraining(records[0].Id, kpiMap, year, prpScoreMapMap, month);
            }
            if(availableKpiTypesSet.contains('TPS New')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTPS(records[0].Id, kpiMap, year, prpScoreMapMap, month, 'TPS', period, true);
            }
            else if(availableKpiTypesSet.contains('TPS')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTPS(records[0].Id, kpiMap, year, prpScoreMapMap, month, 'TPS', period, false);
            }
            if(availableKpiTypesSet.contains('TPS ReTran New')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTPS(records[0].Id, kpiMap, year, prpScoreMapMap, month, 'RET', period, true);
            }
            else if(availableKpiTypesSet.contains('TPS ReTran')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTPS(records[0].Id, kpiMap, year, prpScoreMapMap, month, 'RET', period, false);
            }
            //ENHC0011584 - ETC calculation
            system.debug('availableKpiTypesSet' + availableKpiTypesSet);
            if(availableKpiTypesSet.contains('Extended Transmission Coverage')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateETC(records[0].Id, kpiMap, year, prpScoreMapMap, month, period);
           		system.debug('Entering Inner if and score map is -  ' + prpScoreMapMap);
            }
            if(availableKpiTypesSet.contains('Turn Around Time I')) {
                prpScoreMapMap = PRPC_prpCalculationClass.calculateTAT(records[0].Id, kpiMap, year, prpScoreMapMap, month, period);
            }
        }
        
        Map<String, String> existingKPIMap = new Map<String, String>();
        for(KPI__c kpiRec : [SELECT Id, Name, Customer__c,isPartOfPRP__c FROM KPI__c WHERE Year__c =:year AND Month__c = :month AND Period__c = :period AND (Customer__c =:records[0].Id OR Customer__r.ParentId =:records[0].Id )]) {
            existingKPIMap.put(kpiRec.Customer__c+'-'+kpiRec.isPartOfPRP__c, kpiRec.Id);
        }
        Map<String, KPI__c> prpScoremap = new Map<String, KPI__c>();
        Map<Id, Account> branchMap =new Map<Id, Account>([SELECT Id, SAP_Id__c FROM Account WHERE Id IN :prpScoreMapMap.keySet()]);
        system.debug('branchmap '+branchMap);
        Decimal totalCSI = 0.0;
        Decimal totalFA = 0.0;
        Decimal totalPO = 0.0;
        Decimal totalTPS = 0.0;
        Decimal totalTatI = 0.0;
        Decimal totalTatO = 0.0;
        Decimal totalTraining = 0.0;
        Decimal totalTrainingTwoTech = 0;
        Decimal CSIRecordCount = 0;
        for(String scoreKey: prpScoreMapMap.keySet()) {
            Boolean isPartOfPRP = false;
            if(!prpScoremap.containsKey(scoreKey)) {
                KPI__c kpiToUpsert = new KPI__c();
                kpiToUpsert.PRP_Score__c = 0.0;
                kpiToUpsert.Year__c = year; 
                kpiToUpsert.Customer__c = scoreKey;
                kpiToUpsert.Period__c = period;
                kpiToUpsert.Region__c = records[0].Sales_RegionA__c; 
                kpiToUpsert.Month__c =month;
                kpiToUpsert.Partner_Type__c = records[0].Type;
                kpiToUpsert.KPI_Calculation_Date__c = datetime.now(); 
                if(isInternational && ((records[0].Location_Type__c == 'DDLR' && excludeSapIdList.contains(records[0].SAP_Id__c)) || records[0].Location_Type__c == 'D') ) {
                    kpiToUpsert.isPartOfPRP__c=false;
                }
                else kpiToUpsert.isPartOfPRP__c = true;
                isPartOfPRP = kpiToUpsert.isPartOfPRP__c;
                prpScoremap.put(scoreKey, kpiToUpsert);  
            } 
            if(existingKPIMap.containsKey(scoreKey+'-'+isPartOfPRP)) prpScoremap.get(scoreKey).Id = existingKPIMap.get(scoreKey+'-'+isPartOfPRP);
            if(branchMap.containsKey(scoreKey)) prpScoremap.get(scoreKey).Customer_SAP_Id__c = Decimal.valueOf(branchMap.get(scoreKey).SAP_Id__c);
            List<PRPC_prpCalculationClass.kpiScoreWrapper> prpList = new List<PRPC_prpCalculationClass.kpiScoreWrapper>();
            prpList = prpScoreMapMap.get(scoreKey);
            system.debug('prplist sap ids ' + prpScoreMapMap.get(scoreKey));
            for(PRPC_prpCalculationClass.kpiScoreWrapper prpElement : prpList) {
                system.debug('prpElement.kpiTypeName '+ prpElement.kpiTypeName);
                prpScoremap.get(scoreKey).PRP_Score__c +=prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                switch on prpElement.kpiTypeName {
                    when 'RET' {        
                        prpScoremap.get(scoreKey).Total_Parts_Sold_ReTran__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Total_Parts_Sold_ReTran_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }   
                    when 'TPS' {
                        prpScoremap.get(scoreKey).TPS__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).TPS_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalTPS += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Training' {       
                        prpScoremap.get(scoreKey).Training__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Training_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalTraining += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalTrainingTwoTech += prpElement.isTwoTech;
                    }
                    when 'CSI' {    
                        prpScoremap.get(scoreKey).CSI__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).CSI_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalCSI += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        If(prpElement.value.setScale(1,System.RoundingMode.HALF_UP)>0){
                            CSIRecordCount = CSIRecordCount+1;
                        }
                    }
                    when 'CSI Service' {        
                        prpScoremap.get(scoreKey).CSI_Service__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).CSI_Service_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'CSI Parts' {      
                        prpScoremap.get(scoreKey).CSI_Parts__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).CSI_Parts_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Annual Dealer Experience' {      
                        prpScoremap.get(scoreKey).CSI_Dealer__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).CSI_Dealer_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Turnaround Time I' {      
                        prpScoremap.get(scoreKey).Turnaround_Time_I__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Turnaround_Time_I_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalTatI += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Turnaround Time O' {      
                        prpScoremap.get(scoreKey).Turnaround_Time_O__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Turnaround_Time_O_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalTatO += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Turnaround Time M' {      
                        prpScoremap.get(scoreKey).Turnaround_Time_M__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Turnaround_Time_M_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Parts Ordering' { 
                        prpScoremap.get(scoreKey).Parts_Ordering__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Parts_Ordering_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalPO += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when 'Facility Audit' {     
                       prpScoremap.get(scoreKey).Facility_Audit__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Facility_Audit_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        totalFA += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    /*when 'Service Dealer Development' {     
                        prpScoremap.get(scoreKey).Service_Dealer_Development__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).Service_Dealer_Development_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }*/
                    //ENHC0011584 - ETC calculation
                    when 'Extended Transmission Coverage' {
                        system.debug('Entering to when logic' );
                        prpScoremap.get(scoreKey).ETC__c = prpElement.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                        prpScoremap.get(scoreKey).ETC_Score__c = prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                        system.debug('prpScoremap.get(scoreKey).ETC__c '+ prpScoremap.get(scoreKey).ETC__c );
                        system.debug('prpScoremap.get(scoreKey).ETC_Score__c '+ prpScoremap.get(scoreKey).ETC_Score__c);
                        //totalTPS += prpElement.value.setScale(1,System.RoundingMode.HALF_UP);
                    }
                    when else {       
                    }
                }
                
            }
            
        }
        if(isInternational && records[0].Location_Type__c != 'DDLR') {
            KPI__c kpiToUpsertDist = new KPI__c();
            kpiToUpsertDist.PRP_Score__c = 0.0;
            kpiToUpsertDist.Year__c = year; 
            kpiToUpsertDist.Customer__c = records[0].Id;
            kpiToUpsertDist.Period__c = period;
            kpiToUpsertDist.Region__c = records[0].Sales_RegionA__c; 
            kpiToUpsertDist.Month__c =month;
            kpiToUpsertDist.Partner_Type__c = records[0].Type;
            kpiToUpsertDist.KPI_Calculation_Date__c = datetime.now(); 
            kpiToUpsertDist.isPartOfPRP__c = true;
            kpiToUpsertDist.Customer_SAP_Id__c = Decimal.valueOf(records[0].SAP_Id__c);
            if(prpScoreMapMap.size() != 0) {
                kpiToUpsertDist.TPS_Score__c = totalTPS/prpScoreMapMap.size();
                kpiToUpsertDist.TPS__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'TPS', kpiToUpsertDist.TPS_Score__c>100 ? 100 : kpiToUpsertDist.TPS_Score__c,'RL1');
                kpiToUpsertDist.Training_Score__c =totalTraining/prpScoreMapMap.size();
                System.debug('Check: 255: '+totalTrainingTwoTech +' : '+prpScoreMapMap.size());
                String tempMaxLevel = (totalTrainingTwoTech/prpScoreMapMap.size())*100 < 80 ? 'RL0' : 'RL1';
                kpiToUpsertDist.Training__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'Training', kpiToUpsertDist.Training_Score__c>100 ? 100 : kpiToUpsertDist.Training_Score__c,tempMaxLevel);
                if(CSIRecordCount>0){
                    kpiToUpsertDist.CSI_Score__c = (totalCSI/CSIRecordCount).setScale(1,System.RoundingMode.HALF_UP);
                }
                else if(CSIRecordCount == 0){
                    kpiToUpsertDist.CSI_Score__c = 0;
                }
                //kpiToUpsertDist.CSI_Score__c = totalCSI/prpScoreMapMap.size();
                kpiToUpsertDist.CSI__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'CSI', kpiToUpsertDist.CSI_Score__c>10 ? 10 : kpiToUpsertDist.CSI_Score__c,'RL1');
                kpiToUpsertDist.Turnaround_Time_I_Score__c = totalTatI/prpScoreMapMap.size();
                kpiToUpsertDist.Turnaround_Time_I__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'Turnaround Time I', kpiToUpsertDist.Turnaround_Time_I_Score__c>100 ? 100 : kpiToUpsertDist.Turnaround_Time_I_Score__c,'RL1');
                kpiToUpsertDist.Turnaround_Time_O_Score__c =totalTatO/prpScoreMapMap.size();
                kpiToUpsertDist.Turnaround_Time_O__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'Turnaround Time O', kpiToUpsertDist.Turnaround_Time_O_Score__c>100 ? 100 : kpiToUpsertDist.Turnaround_Time_O_Score__c,'RL1');
                kpiToUpsertDist.Parts_Ordering_Score__c =totalPO/prpScoreMapMap.size();
                kpiToUpsertDist.Parts_Ordering__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'Parts Ordering', kpiToUpsertDist.Parts_Ordering_Score__c>100 ? 100 : kpiToUpsertDist.Parts_Ordering_Score__c,'RL1');
                kpiToUpsertDist.Facility_Audit_Score__c =totalFA/prpScoreMapMap.size();
                kpiToUpsertDist.Facility_Audit__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Distributor', records[0].Sales_RegionA__c, year,'Facility Audit', kpiToUpsertDist.Facility_Audit_Score__c>10 ? 10 : kpiToUpsertDist.Facility_Audit_Score__c,'RL1');
                kpiToUpsertDist.PRP_Score__c =  kpiToUpsertDist.TPS__c +  kpiToUpsertDist.CSI__c + kpiToUpsertDist.Turnaround_Time_I__c + kpiToUpsertDist.Turnaround_Time_O__c + kpiToUpsertDist.Parts_Ordering__c + kpiToUpsertDist.Facility_Audit__c+kpiToUpsertDist.Training__c;
                kpiToUpsertDist.PRP_Score__c = kpiToUpsertDist.PRP_Score__c.setScale(1,System.RoundingMode.HALF_UP);
                if(existingKPIMap.containsKey(records[0].Id +'-'+kpiToUpsertDist.isPartOfPRP__c)) kpiToUpsertDist.Id = existingKPIMap.get(records[0].Id +'-'+kpiToUpsertDist.isPartOfPRP__c);
                UPSERT kpiToUpsertDist;
            }   
        }
        system.debug('prpScoremap.values ' + prpScoremap.values());
        UPSERT prpScoremap.values();
    }   
     
    //finish Method of the batch
    global void finish(Database.BatchableContext bc){
        System.debug('Inside finish method.');
        List<KPI__c> allKPIDirectDealerException = new List<KPI__c>();
        allKPIDirectDealerException = [SELECT Id,Name,Year__c,Customer__c,Customer__r.SAP_Id__c, Customer__r.Sales_RegionA__c, Period__c, Region__c,
                                       CSI_Score__c,Facility_Audit_Score__c,TPS_Score__c,Turnaround_Time_I_Score__c,Turnaround_Time_O_Score__c,Training_Score__c,
                                       Month__c, Partner_Type__c, KPI_Calculation_Date__c, isPartOfPRP__c,
                                      TPS__c,CSI__c,Training__c,Turnaround_Time_I__c,Turnaround_Time_O__c,
                                       Parts_Ordering__c,Facility_Audit__c FROM KPI__c where Customer__r.Sap_Id__c IN :excludeSapIdList AND year__c =:year 
                                      AND Month__c = :month AND Period__c = :period AND Customer__r.Sales_RegionA__c IN :SelectedRegions ];
        System.debug('Check 68: '+[select count() from KPI__c]);
        Map<String, String> existingKPIDDLR = new Map<String, String>();
        Map<String, List<KPI__c>> ddlrKpiMap = new Map<String, List<KPI__c>>();
        Map<String, KPI__c> existingDealerKpiIdMap = new Map<String, KPI__c>();
        for(KPI__c kpiElement : allKPIDirectDealerException) {
            if(directDealerGroupRevMap.containsKey(kpiElement.Customer__r.SAP_Id__c)) {
                if(!ddlrKpiMap.containskey(directDealerGroupRevMap.get(kpiElement.Customer__r.SAP_Id__c))) ddlrKpiMap.put(directDealerGroupRevMap.get(kpiElement.Customer__r.SAP_Id__c), new List<KPI__c>());
                ddlrKpiMap.get(directDealerGroupRevMap.get(kpiElement.Customer__r.SAP_Id__c)).add(kpiElement);
                existingDealerKpiIdMap.put(kpiElement.Customer__r.SAP_Id__c+'-'+kpiElement.isPartOfPRP__c, kpiElement);
            }
            String key  = kpiElement.Customer__c+'-'+kpiElement.isPartOfPRP__c;
            existingKPIDDLR.put(key,kpiElement.Id);
        } 
        List<KPI__c> ddlrKpiToUpsert = new List<KPI__c>();
        for(String ddlrKpiMapKey : ddlrKpiMap.keySet()) {
            Decimal totalCSI = 0.0;
            Decimal totalFA = 0.0;
            Decimal totalTPS = 0.0;
            Decimal totalTatI = 0.0;
            Decimal totalTatO = 0.0;
            Decimal totalTraining = 0.0;
            KPI__c newKpiRec = new KPI__c();
            newKpiRec.PRP_Score__c = 0.0;
            newKpiRec.Year__c = year; 
            newKpiRec.Customer__c = existingDealerKpiIdMap.get(ddlrKpiMapKey+'-'+false).Customer__c;
            newKpiRec.Period__c = period;
            newKpiRec.Region__c = existingDealerKpiIdMap.get(ddlrKpiMapKey+'-'+false).Customer__r.Sales_RegionA__c; 
            newKpiRec.Month__c =month;
            newKpiRec.Partner_Type__c = 'Direct Dealer';
            newKpiRec.KPI_Calculation_Date__c = datetime.now(); 
            newKpiRec.isPartOfPRP__c = true;
            newKpiRec.Customer_SAP_Id__c = Decimal.valueOf(existingDealerKpiIdMap.get(ddlrKpiMapKey+'-'+false).Customer__r.SAP_Id__c);
            if(existingKPIDDLR.containsKey(newKpiRec.Customer__c +'-'+newKpiRec.isPartOfPRP__c)) newKpiRec.Id = existingKPIDDLR.get(newKpiRec.Customer__c +'-'+newKpiRec.isPartOfPRP__c);
            if(ddlrKpiMap.get(ddlrKpiMapKey) != null) {
                for(KPI__c kpiElement : ddlrKpiMap.get(ddlrKpiMapKey)) {
                    totalCSI += kpiElement.CSI_Score__c!=null?kpiElement.CSI_Score__c:0;
                    totalFA += kpiElement.Facility_Audit_Score__c!=null?kpiElement.Facility_Audit_Score__c:0;
                    totalTPS += kpiElement.TPS_Score__c!=null?kpiElement.TPS_Score__c:0;
                    totalTatI += kpiElement.Turnaround_Time_I_Score__c!=null?kpiElement.Turnaround_Time_I_Score__c:0;
                    totalTatO += kpiElement.Turnaround_Time_O_Score__c!=null?kpiElement.Turnaround_Time_O_Score__c:0;
                    totalTraining += kpiElement.Training_Score__c!=null?kpiElement.Training_Score__c:0;  
                }
            }
            Integer directDealerCount = ddlrKpiMap.get(ddlrKpiMapKey).size();
            newKpiRec.TPS_Score__c = totalTPS/directDealerCount;
            newKpiRec.TPS__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Direct Dealer', newKpiRec.Region__c, year,'TPS', newKpiRec.TPS_Score__c>100 ? 100 : newKpiRec.TPS_Score__c,'RL1');
            newKpiRec.Training_Score__c =totalTraining/directDealerCount;
            //CHG44908 - Adding Training points for Parent Direct Dealer based on training score
            newKpiRec.Training__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Direct Dealer', newKpiRec.Region__c, year, 'Training', newKpiRec.Training_Score__c>100 ? 100 : newKpiRec.Training_Score__c,'RL1');
            newKpiRec.CSI_Score__c = totalCSI/directDealerCount;
            newKpiRec.CSI__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Direct Dealer', newKpiRec.Region__c, year,'CSI', newKpiRec.CSI_Score__c>10 ? 10 : newKpiRec.CSI_Score__c,'RL1');
            newKpiRec.Turnaround_Time_I_Score__c = totalTatI/directDealerCount;
            newKpiRec.Turnaround_Time_I__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Direct Dealer', newKpiRec.Region__c, year,'Turnaround Time I', newKpiRec.Turnaround_Time_I_Score__c>100 ? 100 : newKpiRec.Turnaround_Time_I_Score__c,'RL1');
            newKpiRec.Turnaround_Time_O_Score__c =totalTatO/directDealerCount;
            newKpiRec.Turnaround_Time_O__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Direct Dealer', newKpiRec.Region__c, year,'Turnaround Time O', newKpiRec.Turnaround_Time_O_Score__c>100 ? 100 : newKpiRec.Turnaround_Time_O_Score__c,'RL1');
            newKpiRec.Facility_Audit_Score__c =totalFA/directDealerCount;
            newKpiRec.Facility_Audit__c = PRPC_prpCalculationClass.findPrpScoreFromMatrix(kpiMap, 'Direct Dealer', newKpiRec.Region__c, year,'Facility Audit', newKpiRec.Facility_Audit_Score__c>10 ? 10 : newKpiRec.Facility_Audit_Score__c,'RL1');
            newKpiRec.PRP_Score__c =  newKpiRec.TPS__c +  newKpiRec.CSI__c + newKpiRec.Turnaround_Time_I__c + newKpiRec.Turnaround_Time_O__c + newKpiRec.Facility_Audit__c;
            ddlrKpiToUpsert.add(newKpiRec);
        }
        UPSERT ddlrKpiToUpsert;
        List<KPI__c> allKPIList = new List<KPI__c>();
        Map<String, List<Decimal>> allKpiMap = new Map<String, List<Decimal>>();
        Map<String, PRP_Setup__c> existingPRP = new Map<String, PRP_Setup__c>();
        Map<String, PRP_Range_Settings__c> existingPRPRange = new Map<String, PRP_Range_Settings__c>();
        Map<String, Decimal> partnerScore = new Map<String, Decimal>();
        List<PRP_Setup__c> allPRPSetUpList = new List<PRP_Setup__c>();
        List<PRP_Range_Settings__c> allPRPSetUpRangeList = new List<PRP_Range_Settings__c>();
        List<PRPC_prpCalculationClass.prpRangeWrapper> prpRangeSetUpList = new  List<PRPC_prpCalculationClass.prpRangeWrapper>();
        Map<String, String> prpSetupMap = new Map<String, String>();
        
        for(KPI__c kpiElement : [SELECT Id, Name, PRP_Score__c, Region__c, Partner_Type__c, Year__c, Month__c FROM KPI__c WHERE Year__c =:year AND Month__c = :month AND Partner_Type__c != null AND Period__c = :Period AND isPartOfPRP__c = true AND Customer__r.Sales_RegionA__c IN :SelectedRegions]) {
            String key = kpiElement.Region__c + '-'+ kpiElement.Partner_Type__c + '-'+ kpiElement.Year__c + '-' +kpiElement.Month__c;
            if(!allKpiMap.containsKey(key)) allKpiMap.put(key, new List<Decimal>());
            allKpiMap.get(key).add(kpiElement.PRP_Score__c);
        }
        for(PRP_Setup__c prpSetUp : [SELECT Id, Name, Region__c, Partner_Type__c, Year__c, Month__c,Manual_Override__c FROM PRP_Setup__c WHERE Year__c =:String.valueOf(year) AND Month__c = :allMonthMap.get(String.valueOf(month)) AND Region__c IN :SelectedRegions]) {
            String key = prpSetUp.Region__c+'-'+ prpSetUp.Partner_Type__c + '-'+ prpSetUp.Year__c + '-' +month;
            existingPRP.put(key, prpSetUp);
        }
        for(String key : allKpiMap.keySet()) {
            PRP_Setup__c prpsSetUpElement = new PRP_Setup__c(); 
            prpsSetUpElement.Month__c = allMonthMap.get(key.split('-')[3]);
            prpsSetUpElement.Year__c = key.split('-')[2];
            prpsSetUpElement.Partner_Type__c = key.split('-')[1];
            System.debug('Check 178: ' +key.split('-')[1]);
            prpsSetUpElement.Region__c = key.split('-')[0];
            if(existingPRP.containsKey(key)) {
                prpsSetUpElement.Id = existingPRP.get(key).Id;
                if(!existingPRP.get(key).Manual_Override__c) {
                    allPRPSetUpList.add(prpsSetUpElement);
                    prpRangeSetUpList.addAll(PRPC_prpCalculationClass.createPRPSetup(key, allKpiMap.get(key)));
                }    
            }
            else {
                allPRPSetUpList.add(prpsSetUpElement);
                prpRangeSetUpList.addAll(PRPC_prpCalculationClass.createPRPSetup(key, allKpiMap.get(key)));
            }     
        }
        UPSERT allPRPSetUpList;
        for(PRP_Setup__c setUpElement : allPRPSetUpList) {
            String key = setUpElement.Region__c + '-'+ setUpElement.Partner_Type__c + '-'+ setUpElement.Year__c + '-' +month;
            prpSetupMap.put(key, setUpElement.Id);
        }
        for(String key : existingPRP.keySet()) {
            if(existingPRP.get(key).Manual_Override__c) prpSetupMap.put(key, existingPRP.get(key).Id);
        }
        for(PRP_Range_Settings__c kpiRange : [select Id, Name,PRP_Setup__c,Manual_Override__c,Low_Range__c,PRP_Setup__r.Region__c,PRP_Setup__r.Partner_Type__c from PRP_Range_Settings__c where PRP_Setup__c IN :prpSetupMap.values()]) {
            String key = kpiRange.PRP_Setup__c + '-' + kpiRange.Name;
            existingPRPRange.put(key, kpiRange );
        }
        System.debug('Check 204: '+prpRangeSetUpList.size()+' : '+ prpRangeSetUpList);
        for(PRPC_prpCalculationClass.prpRangeWrapper prpSetupWrapperElement :prpRangeSetUpList) {
            String rangeKey =  prpSetupMap.get(prpSetupWrapperElement.key)+'-'+prpSetupWrapperElement.Name;
            PRP_Range_Settings__c newPrpRange = new PRP_Range_Settings__c();
            newPrpRange.Name = prpSetupWrapperElement.Name;
            newPrpRange.High_Range__c = prpSetupWrapperElement.High_Range;
            newPrpRange.Low_Range__c = prpSetupWrapperElement.Low_Range;
            newPrpRange.PRP_Setup__c = prpSetupMap.get(prpSetupWrapperElement.key);
            System.debug('Check 204: '+ prpSetupWrapperElement.key + ' : '+prpSetupMap.get(prpSetupWrapperElement.key));
            if(existingPRPRange.containsKey(rangeKey) && !existingPRPRange.get(rangeKey).Manual_Override__c) newPrpRange.Id = existingPRPRange.get(rangeKey).Id;
            partnerScore.put(prpSetupWrapperElement.key+'-'+prpSetupWrapperElement.Name, prpSetupWrapperElement.Low_Range);
            allPRPSetUpRangeList.add(newPrpRange);
        }
        for(String key : existingPRPRange.keySet()) {
            PRP_Range_Settings__c existingOverRideRange = existingPRPRange.get(key);
            if(existingOverRideRange.Manual_Override__c) {
                String ptrScorekey = existingOverRideRange.PRP_Setup__r.Region__c + '-'+ existingOverRideRange.PRP_Setup__r.Partner_Type__c + '-'+ year + '-' +month;
                partnerScore.put(ptrScorekey+'-'+existingOverRideRange.Name, existingOverRideRange.Low_Range__c);
            }
        }
        System.debug('Check207: '+ allPRPSetUpRangeList);
        if(this.period == 'YTD') upsert allPRPSetUpRangeList;
        List<KPI__c> updatePRPLevel = new List<KPI__c>();
        List<KPI__c> updatePRPLevelONAbranch = new List<KPI__c>();
        updatePRPLevel = [SELECT Id, Name, PRP_Score__c,Customer__c, Customer__r.SAP_Id__c,Customer_SAP_Id1__c, Region__c,PRP_Level__c, Partner_Type__c, Year__c, Month__c,Period__c FROM KPI__c WHERE Year__c =:year AND Month__c = :month AND Partner_Type__c != null AND Period__c=:period AND isPartOfPRP__c = true AND Customer__r.Sales_RegionA__c IN :SelectedRegions];
     // CHG- 42853 by Akanksha [Start]
        updatePRPLevelONAbranch = [SELECT Id, Name, PRP_Score__c,Customer__c, Customer__r.Parent.SAP_ID__c,Customer__r.SAP_Id__c,Customer_SAP_Id1__c, Region__c,PRP_Level__c, Partner_Type__c, Year__c, Month__c,Period__c FROM KPI__c WHERE Year__c =:year AND Month__c = :month AND Partner_Type__c='Distributor' AND Period__c=:period AND isPartOfPRP__c = false AND Customer__r.Sales_RegionA__c IN :SelectedRegions];
        List<PRPCO_Facility_Audit__c> flist = new List<PRPCO_Facility_Audit__c>();
        flist=[select id,Facility_Audit_Status__c,Year__c,Location__c,Location_SAP_Number__c,Distributor__c,Distributor_SAP_Number__c from  PRPCO_Facility_Audit__c where Year__c=:year AND (Location__c!=null) AND Facility_Audit_Status__c!=null  ];
        Map<String,String> fmap = new Map<String,String>();
        Map<String,List<String>> fmap2 = new Map<String,List<String>>();
        for(PRPCO_Facility_Audit__c f:flist){
            fmap.put(f.Location_SAP_Number__c, f.Facility_Audit_Status__c);
        }
        
         Map<String,List<String>> ONAbranchmap = new Map<String,List<String>>();
        for(KPI__c kElement :updatePRPLevelONAbranch){
             if(ONAbranchmap.containsKey(kElement.Customer__r.Parent.SAP_ID__c)){
              ONAbranchmap.get(kElement.Customer__r.Parent.SAP_ID__c).add(kElement.Customer__r.SAP_ID__c);
            }
            else{
                List<String> ONAbranchlist = new List<String>();
                ONAbranchlist.add(kElement.Customer__r.SAP_ID__c);
                ONAbranchmap.put(kElement.Customer__r.Parent.SAP_ID__c,ONAbranchlist);
            }
        }
        // CHG- 42853 by Akanksha [End]
        for(KPI__c kpiElement : updatePRPLevel) {
            String key = kpiElement.Region__c + '-'+ kpiElement.Partner_Type__c + '-'+ kpiElement.Year__c + '-' +kpiElement.Month__c;
            System.debug('Check 410: '+kpiElement.Customer__r.SAP_Id__c+' : '+kpiElement.PRP_Score__c);
            if(partnerScore.containskey(key+'-'+'Gold')) {
                System.debug('Check 410: Inside Gold '+kpiElement.Customer__r.SAP_Id__c+' : ');
                if(kpiElement.PRP_Score__c >= partnerScore.get(key+'-'+'Gold')) {
                    System.debug('Check 410: Inside Gold level '+kpiElement.Customer__r.SAP_Id__c+' : ');
                    kpiElement.PRP_Level__c = 'Gold';
                    //continue;
                    // CHG- 42853 by Akanksha [Start]
                    if(kpiElement.Region__c!='North America' && kpiElement.Month__c==12  && kpiElement.Year__c>=2023 && kpiElement.Period__c=='YTD' && kpiElement.Partner_Type__c=='Direct Dealer' ){
         
                                                    if(fmap.containsKey(kpiElement.Customer_SAP_Id1__c)){
                            if(fmap.get(kpiElement.Customer_SAP_Id1__c)=='Fail'){
                               kpiElement.PRP_Level__c = 'Silver'; 
                            }
                        }
                            else{
                             kpiElement.PRP_Level__c = 'Silver'; 
                        }
                        
                        
                    }
                    if(kpiElement.Region__c!='North America' && kpiElement.Month__c==12 && kpiElement.Year__c>=2023 && kpiElement.Period__c=='YTD' && kpiElement.Partner_Type__c=='Distributor' ){
                       
                        system.debug('ONA branchlist ----'+ONAbranchmap.get(kpiElement.Customer_SAP_Id1__c));
                        for(String s:ONAbranchmap.get(kpiElement.Customer_SAP_Id1__c)){
                            system.debug('S ----'+s +'-----'+ fmap.get(s));
                            if(!fmap.containskey(s) || fmap.get(s)=='Fail'){
                                system.debug('failed branch'+ s +fmap.get(s));
                                 kpiElement.PRP_Level__c = 'Silver'; 
                            }
                        }
                    }
                }
            }
            // CHG- 42853 by Akanksha [End]
            if(partnerScore.containskey(key+'-'+'Silver')) {
                System.debug('Check 410: Inside Silver '+ kpiElement.Customer__r.SAP_Id__c+' : ');
                if(kpiElement.PRP_Score__c >= partnerScore.get(key+'-'+'Silver') && kpiElement.PRP_Score__c < partnerScore.get(key+'-'+'Gold') && kpiElement.PRP_Score__c != 0.0) {
                    System.debug('Check 410: Inside Silver level ' + kpiElement.Customer__r.SAP_Id__c+' : ');
                    kpiElement.PRP_Level__c = 'Silver';
                    //continue;
                }
            }
            if(partnerScore.containskey(key+'-'+'Bronze')) {
                System.debug('Check 410: '+kpiElement.Customer__r.SAP_Id__c+'Inside Bronze : '+partnerScore.get(key+'-'+'Bronze')+' : '+partnerScore.get(key+'-'+'Silver'));
                Boolean testA = kpiElement.PRP_Score__c >= partnerScore.get(key+'-'+'Bronze');
                Boolean testB = kpiElement.PRP_Score__c < partnerScore.get(key+'-'+'Silver');
                System.debug('Check 410: '+kpiElement.Customer__r.SAP_Id__c+'Inside Bronze : ' + testA +' : '+ testB );
                
                if((kpiElement.PRP_Score__c >= partnerScore.get(key+'-'+'Bronze') && kpiElement.PRP_Score__c < partnerScore.get(key+'-'+'Silver')) || kpiElement.PRP_Score__c == 0.0) {
                    System.debug('Check 410: Inside Bronze level '+kpiElement.Customer__r.SAP_Id__c+' : ');
                    kpiElement.PRP_Level__c = 'Bronze';
                    //continue;
                }
            }
        }
        UPDATE updatePRPLevel;
        //check for Date range and execute batch again if required
        if(this.period == 'YTD') {
            PRPC_prpCalculationScheduler newPRPCalculation = new PRPC_prpCalculationScheduler();
            newPRPCalculation.startYear = startYear;
            newPRPCalculation.startMonth = startMonth;
            newPRPCalculation.endYear = endYear;
            newPRPCalculation.endMonth =endMonth;
            newPRPCalculation.year = year;
            newPRPCalculation.month = month;
            newPRPCalculation.kpiMap = kpiMap;
            newPRPCalculation.surveyFormulaMap = surveyFormulaMap;
            newPRPCalculation.period = 'MTH';
            newPRPCalculation.SelectedRegions = SelectedRegions;
            newPRPCalculation.isScheduled = isScheduled;
            //newPRPCalculation.prpKpiTypeMap = this.prpKpiTypeMap;
            Database.executeBatch(newPRPCalculation, 1);
        }
        else if((year == endYear && month < endMonth) || year < endYear) {
            PRPC_prpCalculationScheduler newPRPCalculation = new PRPC_prpCalculationScheduler();
            newPRPCalculation.startYear = startYear;
            newPRPCalculation.startMonth = startMonth;
            newPRPCalculation.endYear = endYear;
            newPRPCalculation.endMonth =endMonth;
            if(year < endYear && month == 12) {
                newPRPCalculation.year = year+1;
                newPRPCalculation.month = 1;
            }
            else {
                newPRPCalculation.year = year;
                newPRPCalculation.month = month+1;
            }
            newPRPCalculation.kpiMap = kpiMap;
            newPRPCalculation.surveyFormulaMap = surveyFormulaMap;
            newPRPCalculation.period = 'YTD';
            newPRPCalculation.SelectedRegions = SelectedRegions;
            newPRPCalculation.isScheduled = isScheduled;
            //newPRPCalculation.prpKpiTypeMap = this.prpKpiTypeMap;
            Database.executeBatch(newPRPCalculation, 1);      
        }
        else {
            PRPC_prpCalculationClass.sendBatchCompleteNotification('KPI: Calculation Completed', isScheduled);
        }
    }
    
    
}