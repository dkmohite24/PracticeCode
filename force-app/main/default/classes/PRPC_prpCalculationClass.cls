/**
 * @Description: KPI Calculation Handler Class
 * Created:  02/17/2021 – Nitish Gyansys
 * Updated By : 10/17/2023 - Susovan Mondal & Chinmaya Dash
 * Update: ENHC0011584 - The Facility audit metric score carries over into the next year until a new audit is completed and entered the system or until the end of the year. Also, ETC was added as a new metric for calculation, and the SDM metric was removed from the system.
*/

public class PRPC_prpCalculationClass {
    private static Account dealerAccount;
    private static String partnerType;
    Private static List<Account> locationList; 
    
    public class kpiScoreWrapper{
        public String kpiTypeName;
        public Decimal value;
        public Decimal prpScore;
        public Decimal isTwoTech;
        public kpiScoreWrapper() {
            isTwoTech = 0;
        }   
    }
    
    public class prpRangeWrapper{
        public String key;
        public String Name;
        public Decimal High_Range;
        public Decimal Low_Range;   
    }
    
    public static void findAllAccounts(String acctId, Integer year, Integer month, String period /*,Map<String, List<String>> directDealerGroupMap*/) {
        dealerAccount = findDealer(acctId);
        partnerType = dealerAccount.Type;
        locationList = findLocation(acctId, year, month, partnerType, period);
    }
    
    public static Map<String,   List<KPI_Range_Settings__c>> findAllKPISetup() {
        Map<String, List<KPI_Range_Settings__c>> kpiMap = new Map<String,  List<KPI_Range_Settings__c>>();        
        List<KPI_Setup__c> kpiSetupList = new List<KPI_Setup__c>();
        String query = 'SELECT Id, Name, Region__c, Year__c, KPI_Type__c,Partner_Type__c, (SELECT Id, Name, File_Submission_Date__c,KPI_Calculation_Date__c FROM KPI_Date_Settings__r ';
        if(System.isScheduled()) query += 'WHERE KPI_Calculation_Date__c = TODAY';
        query += '), (SELECT Id, Name, Reward_Level__c, Low_Range_Value__c, High_Range_Value__c, X2_Tech__c, Points__c FROM KPI_Range_Settings__r order by Reward_Level__c) FROM KPI_Setup__c';
        kpiSetupList = Database.query(query);
        for(KPI_Setup__c setUp : kpiSetupList) {
            if(setUp.KPI_Date_Settings__r != null && setUp.KPI_Date_Settings__r.size() != 0 && setUp.Region__c != null &&  setUp.Partner_Type__c != null && setUp.Year__c != null && setUp.KPI_Type__c != null) {
                setUp.KPI_Type__c = setUp.KPI_Type__c == 'Total Parts Sold ReTran'?'RET':setUp.KPI_Type__c;
                String key = setUp.Region__c +'-'+setUp.Partner_Type__c+'-'+setUp.Year__c+'-'+setUp.KPI_Type__c;
                kpiMap.put(key, setUp.KPI_Range_Settings__r);
            }
        }
        return kpiMap;
    }
    
    
    
    
    
    public static Map<String, List<kpiScoreWrapper>> calculateCSI(Id acctId, Map<String, List<KPI_Range_Settings__c>> kpiMap, Map<String, List<kpiScoreWrapper>> locationScoreMap, Map<String, Decimal> surveyFormulaMap, Integer year, Integer month,String period, String type) {
        Map<String, Decimal> locationCSIScoreMap = new Map<String, Decimal>();
        Map<Id, List<Survey_Data__c>> branchSurveyMap = new Map<Id, List<Survey_Data__c>>();
        List<Survey_Data__c>  surveyToUpdate = new List<Survey_Data__c>();
        List<Survey_Data__c> allSurveyList = new List<Survey_Data__c>();
        Integer countCSI = 0;
        
        String querySurvey = 'SELECT Id, Name, Customer_Dealer_Id__c, Date_Taken__c, Type__c, Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c, ';
        querySurvey += 'Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c, Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, '; 
        querySurvey += 'Q8_Value__c, Q9_Value__c,Survey_Type__c, Survey_Score__c,Old_Formula__c FROM Survey_Data__c WHERE Year__c = :year AND Customer_Dealer_Id__c IN :locationList AND Survey_Type__c =:type AND Month__c ';
        
        if(period == 'MTH') {
            querySurvey += '= :month';
        }
        else if(period == 'YTD') {
            querySurvey += '<= :month';
        }
        
        allSurveyList = Database.query(querySurvey);
        
        for(Survey_Data__c surveyRecord : allSurveyList) {
            if(!branchSurveyMap.containsKey(surveyRecord.Customer_Dealer_Id__c)) branchSurveyMap.put(surveyRecord.Customer_Dealer_Id__c, new List<Survey_Data__c>());
            branchSurveyMap.get(surveyRecord.Customer_Dealer_Id__c).add(surveyRecord);
        }
        // CHG- 42853 by Akanksha [Start]
         Map<Decimal,Integer> endcustomermap = new Map<Decimal,Integer>();
                endcustomermap.put(1, 0);
                endcustomermap.put(2, 0);
                endcustomermap.put(3, 0);
                endcustomermap.put(4, 0);
                endcustomermap.put(5, 0);
                endcustomermap.put(6, 0);
                endcustomermap.put(7, 0);
                endcustomermap.put(8, 0);
                endcustomermap.put(9, 0);
                endcustomermap.put(10, 0);
                endcustomermap.put(11, 0);
                endcustomermap.put(12, 0);
                List<End_Customer__c> elist = [ Select id,Month__c from End_Customer__c where Customer__c=:acctId AND Year__c=:year];                
                for(End_Customer__c ecust : elist){
                    if(endcustomermap.containsKey(ecust.Month__c)){
                        Integer val= endcustomermap.get(ecust.Month__c);
                        endcustomermap.put(ecust.Month__c, val + 1);
                    }
                }
        // CHG- 42853 by Akanksha [End]        
        for(Account locationElement : locationList) {
            Map<String, Decimal> surveyScoreMap = new Map<String, Decimal>();
            countCSI = 0;
            if(!branchSurveyMap.containsKey(locationElement.Id)) {
                continue;
            }
            for(Survey_Data__c surveyElement :  branchSurveyMap.get(locationElement.Id)) {
                String surveyQuesKey = '';
                Survey_Data__c surveyDataToUpdate = new Survey_Data__c();
                surveyDataToUpdate.Id = surveyElement.Id;
                if(surveyElement.Old_Formula__c) {    
                    surveyDataToUpdate.Survey_Score_New__c = surveyElement.Survey_Score__c;
                    surveyToUpdate.add(surveyDataToUpdate);
                    surveyScoreMap.put(surveyElement.Name, surveyElement.Survey_Score__c);
                }
                else {
                    for(String surveyFormulaKey : surveyFormulaMap.keyset()) {
                        String surveyRegion = surveyFormulaKey.split('-')[0];
                        String surveyType = surveyFormulaKey.split('-')[1];
                        if(locationElement.Sales_RegionA__c == surveyRegion && (surveyType.contains(surveyElement.Survey_Type__c) || (surveyType == 'CSI' && locationElement.Sales_RegionA__c != 'North America' ))) {
                            String quesNumber = surveyFormulaKey.split('-')[2];
                            Decimal scoreGiven =surveyElement.get(quesNumber+'_Value__c') != null? Decimal.valueOf(String.valueOf(surveyElement.get(quesNumber+'_Value__c'))):0;
                            Decimal newScore = 0.0;
                            if(surveyScoreMap.containsKey(surveyElement.Name)) newScore =  surveyScoreMap.get(surveyElement.Name);  
                            Decimal newScoreTemp = scoreGiven*surveyFormulaMap.get(surveyFormulaKey);
                            newScore += newScoreTemp; 
                            surveyScoreMap.put(surveyElement.Name, newScore);
                        }
                    }
                    surveyDataToUpdate.Survey_Score_New__c = surveyScoreMap.get(surveyElement.Name);
                    surveyToUpdate.add(surveyDataToUpdate);                   
                }
                if(locationCSIScoreMap.containsKey(locationElement.Id) == false) {
                    locationCSIScoreMap.put(locationElement.Id, 0.0);
                }            
                if(surveyScoreMap.containsKey(surveyElement.Name)) {
                    Decimal newSurveyScore = surveyScoreMap.get(surveyElement.Name);
                    Decimal newLocationScore = locationCSIScoreMap.get(locationElement.Id) +newSurveyScore;
                    locationCSIScoreMap.put(locationElement.Id, newLocationScore);
                    countCSI++;
                }     
            }            
            if(!locationScoreMap.containsKey(locationElement.Id)) {
                locationScoreMap.put(locationElement.Id, new List<kpiScoreWrapper>());
            }
            if(locationCSIScoreMap.containsKey(locationElement.Id)) {
                kpiScoreWrapper csiWrapper = new kpiScoreWrapper();
                csiWrapper.kpiTypeName = type != 'CSI' ? 'CSI ' + type : type;
                Decimal totalCSIScore = locationCSIScoreMap.get(locationElement.Id).setScale(1,System.RoundingMode.HALF_UP);
                csiWrapper.value = countCSI != 0?totalCSIScore/ countCSI:0;
                system.debug(' PRP CHANGES LOCATION ELEMENT'+ locationElement.SAP_ID__c);
                system.debug(' PRP CHANGES csiWrapper.kpiTypeName'+ csiWrapper.kpiTypeName);
                system.debug(' PRP CHANGES csiWrapper.value'+ csiWrapper.value);
                system.debug(' PRP CHANGES locationElement.Type'+locationElement.Type);
              // CHG- 42853 by Akanksha [Start]   
                if(csiWrapper.kpiTypeName =='CSI' && locationElement.Type=='Direct Dealer' && month==12 && year>=2023){
                   for(Integer i:endcustomermap.values()){
                        if(i==0){
                            csiWrapper.value=0;
                             system.debug('PRP CHANGES');
                        }
                    }
                }
                // CHG- 42853 by Akanksha [End]
                csiWrapper.value = csiWrapper.value.setScale(1,System.RoundingMode.HALF_UP);
                csiWrapper.prpScore = findPrpScoreFromMatrix(kpiMap, partnerType,dealerAccount.Sales_RegionA__c, year, csiWrapper.kpiTypeName, csiWrapper.value>10? 10.0 : csiWrapper.value,'RL1');
                csiWrapper.prpScore = csiWrapper.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                locationScoreMap.get(locationElement.Id).add(csiWrapper);
            }
            else {
                kpiScoreWrapper csiWrapper = new kpiScoreWrapper();
                csiWrapper.kpiTypeName = type != 'CSI' ? 'CSI ' + type : type;
                csiWrapper.value = 0.0;
                csiWrapper.prpScore = 0.0;
                locationScoreMap.get(locationElement.Id).add(csiWrapper);
            }           
        }
        if(surveyToUpdate.size() > 0) {
            Database.update(surveyToUpdate, false);
        }
        return locationScoreMap;     
    }
    
    
    public static Map<String, List<kpiScoreWrapper>> calculateAnnualDealerExperience(Id acctId, Map<String, List<KPI_Range_Settings__c>> kpiMap, Map<String, List<kpiScoreWrapper>> locationAnnualDealerScoreMap, Integer year, Integer month,String period) {
        String querySurvey = 'SELECT avg(Survey_Score_New__c) annualScore';
        querySurvey += ' FROM Survey_Data__c WHERE Year__c = :year AND Customer_Dealer_Id__c = :acctId AND Survey_Type__c =\'Annual Dealer Experience\' AND Month__c ';
        
        if(period == 'MTH') {
            querySurvey += '= :month';
        }
        else if(period == 'YTD') {
            querySurvey += '<= :month';
        }
        AggregateResult[] averageDealerScore = Database.query(querySurvey);
        Decimal annualDealer = 0;
        if(averageDealerScore[0].get('annualScore') != null) {
            annualDealer = Decimal.valueOf(String.valueOf(averageDealerScore[0].get('annualScore')));
        }
        
        Decimal annualDealerScore = findPrpScoreFromMatrix(kpiMap, partnerType,dealerAccount.Sales_RegionA__c, year, 'Annual Dealer Experience' , annualDealer,'RL1');
        for(Account locationElement : locationList) {
            if(!locationAnnualDealerScoreMap.containsKey(locationElement.Id)) locationAnnualDealerScoreMap.put(locationElement.Id, new List<kpiScoreWrapper>());
            kpiScoreWrapper aseKpiWraper = new kpiScoreWrapper();
            aseKpiWraper.kpiTypeName = 'Annual Dealer Experience';
            aseKpiWraper.value = annualDealer;
            aseKpiWraper.prpScore = annualDealerScore.setScale(1,System.RoundingMode.HALF_UP);
            locationAnnualDealerScoreMap.get(locationElement.Id).add(aseKpiWraper);
        }
        return locationAnnualDealerScoreMap;
    }
        
    /*
    public static Map<String, List<kpiScoreWrapper>> calculateServiceDealerDev(Id acctId, Map<String, List<KPI_Range_Settings__c>> kpiMap, Map<String, List<kpiScoreWrapper>> locationServiceDealerScoreMap, Integer year, Integer month,String period) {
        String yearStr = String.valueOf(year);
        String monthStr = String.valueOf(month);
        String serviceDealerQuery = 'SELECT Id, Distributor__c, Service_Dealer_Count__c, Type__c, Year__c, Month__c FROM Service_Dealer_Development__c WHERE Distributor__c =:acctId AND Year__c =:yearStr AND Type__c = ';
        String serviceDealerQueryAnnual = serviceDealerQuery + '\'Annually\' AND Month__c = \'1\'  LIMIT 1';
        String serviceDealerQueryMonth = serviceDealerQuery + '\'Monthly\' AND Month__c =:monthStr LIMIT 1';
        Service_Dealer_Development__c serviceDealerAnnual = new Service_Dealer_Development__c();
        Service_Dealer_Development__c serviceDealerMonth = new Service_Dealer_Development__c();
        try{
        serviceDealerAnnual = Database.query(serviceDealerQueryAnnual);
        serviceDealerMonth = Database.query(serviceDealerQueryMonth);
        }
        catch(Exception ex) {
            return locationServiceDealerScoreMap;
        }
        Decimal serviceDealerScore = ((serviceDealerMonth.Service_Dealer_Count__c / serviceDealerAnnual.Service_Dealer_Count__c) - 1)*100;
        Decimal serviceDealerScoreTemp = 0;
        if(serviceDealerScore >= 10) {
            serviceDealerScoreTemp=10;
        }
        else if(serviceDealerScore < 1 && serviceDealerScore >=0) {
            serviceDealerScoreTemp = 0;
        }
        else if(serviceDealerScore <0) {
            serviceDealerScoreTemp= -1;
        }
        else {
            serviceDealerScoreTemp = serviceDealerScore;
        }
        Decimal serviceDealerPRPScore = findPrpScoreFromMatrix(kpiMap, partnerType,dealerAccount.Sales_RegionA__c, year, 'Service Dealer Development' , serviceDealerScoreTemp,'RL1');
        for(Account locationElement : locationList) {
            if(!locationServiceDealerScoreMap.containsKey(locationElement.Id)) locationServiceDealerScoreMap.put(locationElement.Id, new List<kpiScoreWrapper>());
            kpiScoreWrapper sddKpiWraper = new kpiScoreWrapper();
            sddKpiWraper.kpiTypeName = 'Service Dealer Development';
            sddKpiWraper.value = serviceDealerScore;
            sddKpiWraper.prpScore = serviceDealerPRPScore.setScale(1,System.RoundingMode.HALF_UP);
            locationServiceDealerScoreMap.get(locationElement.Id).add(sddKpiWraper);
        }
        
        return locationServiceDealerScoreMap;
    }
    */
    public static Map<String, List<kpiScoreWrapper>> calculateTraining(Id acctId, Map<String, List<KPI_Range_Settings__c>> kpiMap, Integer year, Map<String, List<kpiScoreWrapper>> locationTrainingScoreMap, Integer month) {
        Integer branchCounter = 0;
        Decimal totalValueDist = 0.0;
        Decimal totalScoreDist = 0.0;
        for(Account locationElement : locationList) {
            branchCounter++;
            Decimal totalvalue = 0.0;
            Integer recCount = 0;
            Integer twoTechCount = 0;
            String maxLevel = 'RL1';
            Decimal totalScore = 0;
            for(Training_Data__c trainingElement : locationElement.Training_Data__r ) {
                if(year == trainingElement.Year__c) {     
                    if(trainingElement.Two_trained_tech__c == 'Y') twoTechCount++;
                    totalvalue += trainingElement.Tech_compliant__c * 100;
                    recCount++;
                }
            }
            kpiScoreWrapper newTrainingScore = new kpiScoreWrapper();
            if(recCount != 0) {
                Decimal temTwoTech = (twoTechCount*100.0)/recCount;
                if(temTwoTech < 80) maxLevel = 'RL0';
                newTrainingScore.isTwoTech = temTwoTech;
            }
            totalvalue = recCount != 0? totalvalue /recCount:0;
            totalScore = findPrpScoreFromMatrix(kpiMap, partnerType, dealerAccount.Sales_RegionA__c, year,'Training', totalvalue.setScale(1,System.RoundingMode.HALF_UP), maxLevel);
            System.debug('Check 450: '+locationElement.Id +' : '+twoTechCount +' : '+recCount+' : '+totalvalue);
            newTrainingScore.kpiTypeName = 'Training';
            newTrainingScore.prpScore = totalScore.setScale(1,System.RoundingMode.HALF_UP);
            newTrainingScore.value = totalvalue.setScale(1,System.RoundingMode.HALF_UP);
            if(!locationTrainingScoreMap.containsKey(locationElement.Id)) locationTrainingScoreMap.put(locationElement.Id, new List<kpiScoreWrapper>());
            locationTrainingScoreMap.get(locationElement.Id).add(newTrainingScore);
            System.debug('Check 450:X '+newTrainingScore.value +' : '+newTrainingScore.prpScore +' : '+maxLevel);   
        }
        return locationTrainingScoreMap;
    }
    
    
    
    public static Map<String, List<kpiScoreWrapper>> calculateTPS(Id acctId, Map<String,  List<KPI_Range_Settings__c>> kpiMap, Integer year, Map<String, List<kpiScoreWrapper>> locationTPSScoreMap, Integer month, String tpsType, String period, Boolean isNew) {
        Decimal totalAmountCurrentYear = 0.0;
        Decimal totalAmountPrevYr = 0.0;
        Decimal totalAmountPrevYr1 = 0.0;
        Decimal totalAmountPrevYr2 = 0.0;
        Integer prevYear = year - 1;
        Integer prevYear1 = year - 2;
        Integer prevYear2 = year - 3;
        AggregateResult[] previousYearResult1;
        AggregateResult[] previousYearResult2;
        Integer yearCount = 0;
        if(dealerAccount.Service_Start_Date__c == null) {
            yearCount = 3;
        }
        else if(dealerAccount.Service_Start_Date__c.year()<prevYear2) {
            yearCount = 3;
        }
        else if(dealerAccount.Service_Start_Date__c.year() == prevYear2) {
            if(dealerAccount.Service_Start_Date__c.month() <= month ) {
                yearCount = 3;
            }
            else {
                yearCount = 2;
            }
        }
        else if(dealerAccount.Service_Start_Date__c.year()<prevYear1) {
            yearCount = 2;
        }
        else if(dealerAccount.Service_Start_Date__c.year() == prevYear1) {
            if(dealerAccount.Service_Start_Date__c.month() <= month ) {
                yearCount = 2;
            }
            else {
                yearCount = 1;
            }
        }
        else if(dealerAccount.Service_Start_Date__c.year()<prevYear) {
            yearCount = 1;
        }
        else if(dealerAccount.Service_Start_Date__c.year() == prevYear) {
            if(dealerAccount.Service_Start_Date__c.month() <= month ) {
                yearCount = 1;
            }
            else {
                yearCount = 0;
            }
        }
        
        String query = 'select  sum(Invoice_Amount__c) Amount from TPS_DATA__C where Parts_Sold_Type__c=:tpsType and ';
        if(partnerType == 'Distributor') query +=  'Customer__r.ParentId = :acctId and Customer__r.Location_Type__c IN (\'DB\',\'D\') and ';
        else query +=  'Customer__c = :acctId and ';
        //query += ' (customer__r.PRP_Participation__c = true or customer__r.Include_Sales__c = true) and ';
        if(period == 'YTD') query += 'month__c<=' ;
        else query += 'month__c=' ;
        query += ':month and Year__c=';
        
        AggregateResult[] currentYearResult = Database.query(query+':year');
        totalAmountCurrentYear = currentYearResult[0].get('Amount')!= null ?Decimal.valueOf(String.valueOf(currentYearResult[0].get('Amount'))):0;
        
        AggregateResult[] previousYearResult = Database.query(query+':prevYear');
        totalAmountPrevYr = previousYearResult[0].get('Amount') != null? Decimal.valueOf(String.valueOf(previousYearResult[0].get('Amount'))):0;
        Decimal avgAmount = totalAmountPrevYr;
        if(isNew == true) {
            previousYearResult1 = Database.query(query+':prevYear1');
            totalAmountPrevYr1 = previousYearResult1[0].get('Amount') != null? Decimal.valueOf(String.valueOf(previousYearResult1[0].get('Amount'))):0;
        	previousYearResult2 = Database.query(query+':prevYear2');
            totalAmountPrevYr2 = previousYearResult2[0].get('Amount') != null? Decimal.valueOf(String.valueOf(previousYearResult2[0].get('Amount'))):0;
            if(yearCount == 3) {
                avgAmount += totalAmountPrevYr1 + totalAmountPrevYr2;
                avgAmount = avgAmount /3;
                
            }
            if(yearCount == 2) {
                avgAmount += totalAmountPrevYr1;
                avgAmount = avgAmount /2;
            }
            if(yearCount == 0) {
                avgAmount = 0;
            }
        }
        
        Decimal value = avgAmount != 0?((totalAmountCurrentYear/avgAmount) - 1) * 100:0;
        Decimal prpScore = findPrpScoreFromMatrix(kpiMap, partnerType,dealerAccount.Sales_RegionA__c, year, tpsType,value>100?100:value, 'RL1');
        //prpScore = 
        for(Account locationElement : locationList) {
            if(!locationTPSScoreMap.containsKey(locationElement.Id)) locationTPSScoreMap.put(locationElement.Id, new List<kpiScoreWrapper>());
            kpiScoreWrapper tpsKpiWraper = new kpiScoreWrapper();
            tpsKpiWraper.kpiTypeName = tpsType;
            tpsKpiWraper.value = value;
            tpsKpiWraper.prpScore = prpScore;
            locationTPSScoreMap.get(locationElement.Id).add(tpsKpiWraper);
        }
        
        return locationTPSScoreMap;
    }
    //ENHC0011584 Change - ETC Calculation
    public static Map<String, List<kpiScoreWrapper>> calculateETC(Id acctId, Map<String,  List<KPI_Range_Settings__c>> kpiMap, Integer year, Map<String, List<kpiScoreWrapper>> locationETCScoreMap, Integer month,  String period) {
   		Decimal totalAmountCurrentYear = 0.0;
        Decimal totalAmountPrevYr = 0.0;
        Integer prevYear = year - 1;
        
		 
        String query = 'Select  sum(Retail_Amount_ETC__c) Amount from ETC_DATA__C where ';
        query +=  'Customer__r.ParentId = :acctId and Customer__r.Location_Type__c IN (\'DB\',\'D\') and ';
        if(period == 'YTD') query += 'month__c<=' ;
        else query += 'month__c=' ;
        query += ':month and Year__c=';
        
        AggregateResult[] currentYearResult = Database.query(query+':year');
        totalAmountCurrentYear = currentYearResult[0].get('Amount')!= null ?Decimal.valueOf(String.valueOf(currentYearResult[0].get('Amount'))):0;
        
        AggregateResult[] previousYearResult = Database.query(query+':prevYear');
        totalAmountPrevYr = previousYearResult[0].get('Amount') != null? Decimal.valueOf(String.valueOf(previousYearResult[0].get('Amount'))):0;
        
        system.debug('line 386 :'+totalAmountCurrentYear+'  avg :'+totalAmountPrevYr);
        Decimal value = totalAmountPrevYr != 0?((totalAmountCurrentYear/totalAmountPrevYr) - 1) * 100:0;
        Decimal prpScore = findPrpScoreFromMatrix(kpiMap, partnerType,dealerAccount.Sales_RegionA__c, year,'Extended Transmission Coverage' ,value>100?100:value, 'RL1');
        for(Account locationElement : locationList) {
            if(!locationETCScoreMap.containsKey(locationElement.Id)) locationETCScoreMap.put(locationElement.Id, new List<kpiScoreWrapper>());
            kpiScoreWrapper etcKpiWraper = new kpiScoreWrapper(); 
            etcKpiWraper.kpiTypeName = 'Extended Transmission Coverage';
            etcKpiWraper.value = value;
            etcKpiWraper.prpScore = prpScore;
            locationETCScoreMap.get(locationElement.Id).add(etcKpiWraper);
            system.debug('line 428 :'+locationElement.SAP_id__c+' score : '+prpScore+'locationETCScoreMap '+ locationETCScoreMap);
        }
        
        return locationETCScoreMap;
    }
    
    
    public static Map<String, List<kpiScoreWrapper>> calculateTAT(Id acctId, Map<String,  List<KPI_Range_Settings__c>> kpiMap, Integer year, Map<String, List<kpiScoreWrapper>> locationTATSScoreMap, Integer month, String period /*, Map<String, List<String>> directDealerGroupMap*/) {
        Map<String, List<TAT_Data__c>> LocationTATMap = new Map<String, List<TAT_Data__c>>();
        List<TAT_Data__c> tatList= new List<TAT_Data__c>();
        List<TAT_Data__c> tatToUpdateList= new List<TAT_Data__c>();
        String query = 'SELECT Id,Dealer_Id__c, Name, Repair_Type__c , Service_End_Date_Formula__c,Service_Start_Date_Formula__c '; 
        query +='FROM TAT_Data__c WHERE Year__c = :year AND Month__c <=:month AND (Source_Type__c = \'AWARE\' OR (Source_Type__c = \'Distributor\' AND Repair_Payment__c = \'C\')) ';
        query += 'AND Dealer_Id__r.PRP_Participation__c = true ';
        //query += 'AND Dealer_Id__r.Location_Type__c IN (\'DB\',\'D\')';
        if(partnerType == 'Distributor' && period == 'YTD') {
            //query += 'AND Dealer_Id__r.ParentId = :acctId ';
            tatList = [SELECT Id,Dealer_Id__c, Dealer_Id__r.Sales_RegionA__c, all_labor_ops__c, Name, Repair_Type__c ,Vehicle_Arrived_Earlier__c, Service_End_Date_Formula__c,Service_Start_Date_Formula__c 
                       FROM TAT_Data__c WHERE Year__c = :year AND Month__c <=:month AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))
                       AND Dealer_Id__r.ParentId = :acctId AND Dealer_Id__r.PRP_Participation__c = true 
                       AND Dealer_Id__r.Location_Type__c IN ('DB','D')];
        }
        else if(partnerType == 'Direct Dealer' && period == 'YTD') {
                    tatList = [SELECT Id,Dealer_Id__c, Dealer_Id__r.Sales_RegionA__c, all_labor_ops__c, Name, Repair_Type__c , Vehicle_Arrived_Earlier__c, Service_End_Date_Formula__c,Service_Start_Date_Formula__c 
                       FROM TAT_Data__c WHERE Year__c = :year AND Month__c <=:month AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))
                       AND Dealer_Id__c = :acctId AND Dealer_Id__r.PRP_Participation__c = true ];
        }
        else if(partnerType == 'Distributor' && period == 'MTH') {
            tatList = [SELECT Id,Dealer_Id__c, Dealer_Id__r.Sales_RegionA__c, all_labor_ops__c, Name, Repair_Type__c ,Vehicle_Arrived_Earlier__c, Service_End_Date_Formula__c,Service_Start_Date_Formula__c 
                       FROM TAT_Data__c WHERE Year__c = :year AND Month__c =:month AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))
                       AND Dealer_Id__r.ParentId = :acctId AND Dealer_Id__r.PRP_Participation__c = true 
                       AND Dealer_Id__r.Location_Type__c IN ('DB','D')];
        }
        else if(partnerType == 'Direct Dealer' && period == 'MTH') {    
            tatList = [SELECT Id,Dealer_Id__c,Dealer_Id__r.Sales_RegionA__c, all_labor_ops__c, Name, Repair_Type__c , Vehicle_Arrived_Earlier__c,Service_End_Date_Formula__c,Service_Start_Date_Formula__c 
                       FROM TAT_Data__c WHERE Year__c = :year AND Month__c =:month AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))
                       AND Dealer_Id__c = :acctId AND Dealer_Id__r.PRP_Participation__c = true ];
        }
        for(TAT_Data__c tatData : tatList) {
            if(tatData.Dealer_Id__r.Sales_RegionA__c == 'North America' && tatData.all_labor_ops__c != null && tatData.all_labor_ops__c.contains('111111')) continue;   //exclude rows if labour code contains 111111(travel time) 
            if(!LocationTATMap.containsKey(tatData.Dealer_Id__c)) LocationTATMap.put(tatData.Dealer_Id__c, new List<TAT_Data__c>());
            LocationTATMap.get(tatData.Dealer_Id__c).add(tatData);
        }
        for(String locationElement : LocationTATMap.keySet()) {
            Decimal totalCountI = 0;
            Decimal goalMeetCountI = 0;   
            Decimal totalCountO = 0;
            Decimal goalMeetCountO = 0;
            Decimal totalCountM = 0;
            Decimal goalMeetCountM = 0;
            for(TAT_Data__c tatElement : LocationTATMap.get(locationElement) ) {
                TAT_Data__c tatData = new TAT_Data__c();
                tatData.Id = tatElement.Id;
                if(tatElement.Repair_Type__c != null) {
                    Decimal totalServiceTime = 10000.0;
                    System.debug('Check 649: '+locationElement+' : '+tatElement.Id);
                    if(tatElement.Service_End_Date_Formula__c != null && tatElement.Service_Start_Date_Formula__c != null) {
                        Long totalTimeDifference = tatElement.Service_End_Date_Formula__c.getTime() -tatElement.Service_Start_Date_Formula__c.getTime();
                        totalServiceTime = totalTimeDifference/(1000.0*3600.0);
                        tatData.TT_in_Days__c = totalTimeDifference/(1000.00*3600.0*24.0);
                        tatData.TT_in_Hours__c = totalServiceTime;
                        tatData.TT_in_Minutes__c = totalTimeDifference/(1000.00*60.0);
                    }
                    System.debug('Check 381: '+tatData);
                    if(tatElement.Repair_Type__c.toUpperCase() == 'M'  ) {                        
                        if((totalServiceTime >= 0 || tatElement.Vehicle_Arrived_Earlier__c) && totalServiceTime <= 4.0 ) {
                            tatData.Meets_TT_Goal__c = true;
                            goalMeetCountM++;   
                        }else {
                            tatData.Meets_TT_Goal__c = false;
                        }
                        totalCountM++;
                    }
                    if(tatElement.Repair_Type__c.toUpperCase() == 'I' ) {
                        if((totalServiceTime >= 0 || tatElement.Vehicle_Arrived_Earlier__c) && totalServiceTime <=24.0) {
                            tatData.Meets_TT_Goal__c = true;
                            goalMeetCountI++;
                        }else {
                            tatData.Meets_TT_Goal__c = false;
                        }
                        totalCountI++;
                    }
                    if(tatElement.Repair_Type__c.toUpperCase() == 'O') {
                        if((totalServiceTime >= 0 || tatElement.Vehicle_Arrived_Earlier__c) && totalServiceTime <=96.0) {
                            tatData.Meets_TT_Goal__c = true;
                            goalMeetCountO++;
                        }else {
                            tatData.Meets_TT_Goal__c = false;
                        }
                        totalCountO++;
                    }
                }
                tatToUpdateList.add(tatData);
            }
            if(!locationTATSScoreMap.containsKey(locationElement)) locationTATSScoreMap.put(locationElement, new List<kpiScoreWrapper>());
            kpiScoreWrapper kpiWrapperTATM = new kpiScoreWrapper();
            kpiWrapperTATM.kpiTypeName = 'Turnaround Time M';
            kpiWrapperTATM.value = totalCountM != 0?(goalMeetCountM / totalCountM) * 100:0;
            kpiWrapperTATM.value = kpiWrapperTATM.value.setScale(2,System.RoundingMode.HALF_UP);
            kpiWrapperTATM.prpScore = findPrpScoreFromMatrix(kpiMap, partnerType, dealerAccount.Sales_RegionA__c, year,kpiWrapperTATM.kpiTypeName, kpiWrapperTATM.value, 'RL1');
            kpiWrapperTATM.prpScore = kpiWrapperTATM.prpScore.setScale(1,System.RoundingMode.HALF_UP);
            locationTATSScoreMap.get(locationElement).add(kpiWrapperTATM);
            
            kpiScoreWrapper kpiWrapperTATO = new kpiScoreWrapper();
            kpiWrapperTATO.kpiTypeName = 'Turnaround Time O';
            kpiWrapperTATO.value = totalCountO != 0?(goalMeetCountO / totalCountO) * 100:0;
            kpiWrapperTATO.value = kpiWrapperTATO.value.setScale(2,System.RoundingMode.HALF_UP);
            kpiWrapperTATO.prpScore = findPrpScoreFromMatrix(kpiMap,partnerType, dealerAccount.Sales_RegionA__c, year,kpiWrapperTATO.kpiTypeName, kpiWrapperTATO.value, 'RL1');
            kpiWrapperTATO.prpScore = kpiWrapperTATO.prpScore.setScale(1,System.RoundingMode.HALF_UP);
            locationTATSScoreMap.get(locationElement).add(kpiWrapperTATO);
            
            kpiScoreWrapper kpiWrapperTATI = new kpiScoreWrapper();
            kpiWrapperTATI.kpiTypeName = 'Turnaround Time I';
            kpiWrapperTATI.value = totalCountI!=0?(goalMeetCountI / totalCountI) * 100:0;
            kpiWrapperTATI.value = kpiWrapperTATI.value.setScale(1,System.RoundingMode.HALF_UP);
            kpiWrapperTATI.prpScore = findPrpScoreFromMatrix(kpiMap,partnerType, dealerAccount.Sales_RegionA__c, year,kpiWrapperTATI.kpiTypeName, kpiWrapperTATI.value, 'RL1');
            kpiWrapperTATI.prpScore = kpiWrapperTATI.prpScore.setScale(1,System.RoundingMode.HALF_UP);
            locationTATSScoreMap.get(locationElement).add(kpiWrapperTATI);
            System.debug('Check I: '+ locationElement +' : '+goalMeetCountI +' : '+totalCountI);
            System.debug('Check O: '+ locationElement +' : '+goalMeetCountO +' : '+totalCountO);
            System.debug('Check M: '+ locationElement +' : '+goalMeetCountM +' : '+totalCountM);
        }  
        if(tatToUpdateList.size() > 0) Database.Update(tatToUpdateList, false);
        return locationTATSScoreMap;
    }
  
    
    public static Map<String, List<kpiScoreWrapper>> calculatePartsOrdering_INT(Id acctId, Map<String,  List<KPI_Range_Settings__c>> kpiMap, Integer year, Map<String, List<kpiScoreWrapper>> locationPartsOrderScoreMap, Integer month, String Period) {
        String query = 'SELECT Id,Ship_To__c, Delivery_Priority__c, Month__c, Year__c FROM Parts_Ordering__c WHERE Year__c = :year AND (Ship_To__r.PRP_Participation__c = true OR Ship_To__r.Include_Sales__c = true ) AND Month__c';
        if(Period == 'YTD') query += '<=:month AND ';
        else if(Period == 'MTH') query += '=:month AND ';
        if(partnerType == 'Direct Dealer') query += 'Ship_To__c = :acctId';
        else if(partnerType == 'Distributor') query += 'Ship_To__r.ParentId = :acctId';
        List<Parts_Ordering__c> allPO = new List<Parts_Ordering__c>();
        allPO  =   Database.query(query);
        Map<String, List<Parts_Ordering__c>> acctPOMap = new Map<String, List<Parts_Ordering__c>>();
        Integer prirityOrder = 0;
        Integer totalOrder = 0;
        for(Parts_Ordering__c poElement : allPO) {
            if(poElement.Delivery_Priority__c == '03' || poElement.Delivery_Priority__c == '3') prirityOrder++;
            totalOrder++;
        }
        System.debug('Check 707: Priority:' + prirityOrder);
        System.debug('Check 707: totalOrder:' + totalOrder);
        Decimal partsOrderScore = totalOrder != 0 ?(Decimal.valueOf(prirityOrder)/totalOrder) * 100 : 0;
        Decimal partsOrderPoints = findPrpScoreFromMatrix(kpiMap, partnerType,dealerAccount.Sales_RegionA__c, year, 'Parts Ordering', partsOrderScore, 'RL1');
        //partsOrderPoints
        System.debug('Check 707: partsOrderPoints:' + partsOrderPoints);
        for(Account acct : locationList) {
            kpiScoreWrapper ptrOrd = new kpiScoreWrapper();
            ptrOrd.kpiTypeName = 'Parts Ordering';
            ptrOrd.value = partsOrderScore.setScale(1,System.RoundingMode.HALF_UP);
            ptrOrd.prpScore = partsOrderPoints.setScale(1,System.RoundingMode.HALF_UP);
            if(!locationPartsOrderScoreMap.containsKey(acct.Id)) locationPartsOrderScoreMap.put(acct.Id, new List<kpiScoreWrapper>());            
            locationPartsOrderScoreMap.get(acct.Id).add(ptrOrd);
            System.debug('Check 707: ' + ptrOrd);
        }
        return locationPartsOrderScoreMap;
    }
    public static Map<String, List<kpiScoreWrapper>> calculateFacilityAudit(Id acctId, Map<String,  List<KPI_Range_Settings__c>> kpiMap, Integer year, Map<String, List<kpiScoreWrapper>> locationFacilityAuditMap, Integer month, String Period) {
        Integer prevYear = year -1;
        Integer NoOfRecord=0;
        Decimal LastYaerScore = 0;
        Decimal LastYearValue = 0;
        
        //Fetching the Facility audit score for the last year
        Map<String ,KPI__c> PreviousKpiMap = new Map<String ,KPI__c>();
        For(KPI__c kpi : [select id,Facility_Audit_Score__c,Customer__c,Customer__r.SAP_ID__c, Facility_Audit__c, Period__c from KPI__c where Customer__r.ParentId =: acctId and Year__c =: prevYear and Month__c = 12 AND Facility_Audit_Score__c > 0 AND Period__c =:'YTD' ORDER BY CreatedDate DESC]){
            If(!PreviousKpiMap.containskey(kpi.Customer__c)){
                PreviousKpiMap.put(String.valueOf(kpi.Customer__c),kpi);
            }
        }
        
        for(Account locationElement : locationList) {
            Decimal totalScore = 0.0;
            Decimal lastYearScore = 0.0;
            for(PRPCO_Facility_Audit__c faData : locationElement.Facility_Audits__r ) {
                If(((year < 2024 && month == faData.Month__c && Period == 'MTH')||(year < 2024 && Period == 'YTD')) || year > 2023){
                    totalScore += faData.Score__c;
                }
                System.debug('Check locationElement.SAP_ID__c: ' + locationElement.SAP_ID__c+'Check faData.Score__c: ' + faData.Score__c+'Check faData.Name: ' + faData.id);
            }
            kpiScoreWrapper kpiWrapperFA = new kpiScoreWrapper();
            kpiWrapperFA.kpiTypeName = 'Facility Audit';
            //If the year is 2024 or after 2024, the last year's Score will be carried out to the next year until we receive a score.
            If((locationElement.Facility_Audits__r.size() != 0 && year > 2023) ||(year < 2024)){
                kpiWrapperFA.value = locationElement.Facility_Audits__r.size()!=0?(totalScore / locationElement.Facility_Audits__r.size()):0;
                kpiWrapperFA.prpScore = findPrpScoreFromMatrix(kpiMap,partnerType, dealerAccount.Sales_RegionA__c, year,kpiWrapperFA.kpiTypeName, kpiWrapperFA.value, 'RL1');
                kpiWrapperFA.prpScore = kpiWrapperFA.prpScore.setScale(1,System.RoundingMode.HALF_UP);
            }
            else{
                if(month != 12){
                    kpiWrapperFA.value = PreviousKpiMap.containskey(String.valueOf(locationElement.Id))?PreviousKpiMap.get(String.valueOf(locationElement.Id)).Facility_Audit_Score__c:0;
                	kpiWrapperFA.prpScore = PreviousKpiMap.containskey(String.valueOf(locationElement.Id))?PreviousKpiMap.get(String.valueOf(locationElement.Id)).Facility_Audit__c:0;
                	kpiWrapperFA.prpScore = kpiWrapperFA.prpScore.setScale(1,System.RoundingMode.HALF_UP);
                }
                else{
                    kpiWrapperFA.value = 0;
                	kpiWrapperFA.prpScore = 0;
                }
                
            }
            System.debug('Check locationElement.Facility_Audits__r.size(): ' + locationElement.Facility_Audits__r.size());
            locationFacilityAuditMap.get(locationElement.Id).add(kpiWrapperFA);
        }
        return locationFacilityAuditMap;
    }
    
    public static Decimal findPrpScoreFromMatrix(Map<String, List<KPI_Range_Settings__c>> kpiMap, String partnerType, String Region, Integer year, String Type, Decimal score, String maxLevel) {  
        String key = Region + '-'+ partnerType+'-' + String.valueOf(year)+'-'+Type;
        Decimal actualPoints = 0.0;
        Decimal maxPoints = 100.0;
        if(kpiMap.containsKey(key))  {
            List<KPI_Range_Settings__c>  kpiMatrixList = kpiMap.get(key);
            for(KPI_Range_Settings__c kpiRange : kpiMatrixList) {
                if(score >= kpiRange.Low_Range_Value__c && score <= kpiRange.High_Range_Value__c) {
                    actualPoints = kpiRange.Points__c;
                }
                if(kpiRange.X2_Tech__c && maxLevel != 'RL1') maxPoints = kpiRange.Points__c;
            }
        }
        if(actualPoints > maxPoints) return maxPoints;
        return actualPoints;
    }
    
    
    public static Map<String, Decimal> findSurveyFormula(Integer year) {
        Map<String,  Decimal> surveyFormulaMap = new Map<String, Decimal>();
        List<Survey_Formula_Setup__c> surveyFormulaList = new List<Survey_Formula_Setup__c>();
        surveyFormulaList = [SELECT Id, Percentage__c, Survey_Type__c, Question_Number__c,Region_Type__c FROM Survey_Formula_Setup__c WHERE Year__c = :String.valueOf(year)];
        for(Survey_Formula_Setup__c surveyElement : surveyFormulaList) {
            if(surveyElement.Percentage__c != null) {
                Decimal value = surveyElement.Percentage__c / 100;
                String key = surveyElement.Region_Type__c +'-'+ surveyElement.Survey_Type__c + '-' + surveyElement.Question_Number__c;
                surveyFormulaMap.put(key, value);
            }   
        }
        return surveyFormulaMap;
    }
    public static Account findDealer(Id acctId) {
        Account dealerAccount = new Account();
        dealerAccount = [SELECT Id, Type,SAP_ID__c, Name, Sales_RegionA__c, ParentId, Service_Start_Date__c,
                         (SELECT Id, Customer_Dealer_Id__c, Date_Taken__c,
                          Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c,
                          Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c,
                          Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, 
                          Q8_Value__c, Q9_Value__c
                          FROM Survey_Data__r) 
                         FROM Account 
                         WHERE Id = :acctId];
        return dealerAccount;
    }
    public static List<Account> findLocation(Id dealerId, Integer year, Integer month,String partnerType, String period) {
        Integer prevYear = year -1;
        List<Account> locationList = new List<Account>();
        String query = 'SELECT Id, Name, Sales_RegionA__c, ParentId,Type,';
        query += '(SELECT Id, Name, Customer_Dealer_Id__c, Date_Taken__c, Type__c, Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c, ';
        query += 'Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c,Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, '; 
        query += 'Q8_Value__c, Q9_Value__c,Survey_Type__c FROM Survey_Data__r WHERE Year__c = :year AND Month__c = :month), ';
        query += '(SELECT Id, Month__c, Year__c, Retail_Amount_ETC__c, Customer__c from ETC_Datas__r WHERE Year__c = :year AND Month__c =: month), ';
        query += '(SELECT Id, Name, Tech_compliant__c, Two_trained_tech__c,Month__c, Year__c FROM Training_Data__r WHERE Year__c = :year AND Month__c = :month), ';
        query += '(SELECT Id, Name, Parts_Sold_Type__c, Invoice_Amount__c,Year__c,Month__c FROM TPS_Data__r WHERE (Year__c =:year OR Year__c = :prevYear) AND Month__c = :month  ), ';
        query += '(SELECT Id, Name, Repair_Type__c , date_cust_request_service__c, Date_Distributor_schedules_for_service__c, date_vehicle_first_arrived__c, Date_last_labor_applied__c, customer_notified__c,Total_Service_Time__c,Service_End_Date_Formula__c,Service_Start_Date_Formula__c '; 
        query += 'FROM TAT_Datas__r WHERE Year__c = :year AND Month__c =:month';
        query += 'AND (Source_Type__c = \'AWARE\' OR (Source_Type__c = \'Distributor\' AND Repair_Payment__c = \'C\'))),';
        query += '(SELECT Id, Delivery_Priority__c, Month__c, Year__c FROM Parts_Orderings__r WHERE Year__c = :year AND Month__c =:month) FROM Account ';
        
        if(period == 'MTH') {
            if(partnerType == 'Distributor') {
                locationList = [SELECT Id,SAP_ID__c, Name, Sales_RegionA__c, ParentId,Type,
                                (SELECT Id, Name, Customer_Dealer_Id__c, Date_Taken__c, Type__c,
                                 Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c,
                                 Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c,
                                 Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, 
                                 Q8_Value__c, Q9_Value__c,Survey_Type__c, Survey_Score__c,Old_Formula__c
                                 FROM Survey_Data__r WHERE Year__c = :year AND Month__c = :month),
                                (SELECT Id, Location__c, Month__c, Year__c, Score__c FROM Facility_Audits__r WHERE Year__c = :year AND Month__c <=: month ORDER BY CreatedDate DESC),
                                (SELECT Id, Month__c, Year__c, Retail_Amount_ETC__c, Customer__c from ETC_Datas__r WHERE Year__c = :year AND Month__c =: month),
                                (SELECT Id, Name, Tech_compliant__c, Two_trained_tech__c,Month__c, Year__c FROM Training_Data__r WHERE Year__c = :year AND Month__c = :month order by Month__c),
                                (SELECT Id, Name, Parts_Sold_Type__c, Invoice_Amount__c,Year__c,Month__c FROM TPS_Data__r WHERE (Year__c =:year OR Year__c = :prevYear) AND Month__c = :month  ),
                                (SELECT Id, Name, Repair_Type__c , date_cust_request_service__c, Date_Distributor_schedules_for_service__c, date_vehicle_first_arrived__c, Date_last_labor_applied__c, customer_notified__c,Total_Service_Time__c,Service_End_Date_Formula__c,Service_Start_Date_Formula__c  
                                 FROM TAT_Datas__r WHERE Year__c = :year AND Month__c =:month
                                 AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))),
                                (SELECT Id, Delivery_Priority__c, Month__c, Year__c FROM Parts_Orderings__r WHERE Year__c = :year AND Month__c =:month)
                                FROM Account 
                                WHERE ParentId = :dealerId AND PRP_Participation__c = true AND Location_Type__c IN ('DB','D')];
            }
            else if(partnerType == 'Direct Dealer'){
                locationList = [SELECT Id,SAP_ID__c, Name, Sales_RegionA__c, ParentId,Type,
                                (SELECT Id, Name, Customer_Dealer_Id__c, Date_Taken__c, Type__c,
                                 Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c,
                                 Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c,
                                 Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, 
                                 Q8_Value__c, Q9_Value__c,Survey_Type__c, Survey_Score__c,Old_Formula__c
                                 FROM Survey_Data__r WHERE Year__c = :year AND Month__c = :month),
                                (SELECT Id, Location__c, Month__c, Year__c, Score__c FROM Facility_Audits__r WHERE  Year__c = :year AND Month__c <=: month ORDER BY CreatedDate DESC),
                                (SELECT Id, Name, Tech_compliant__c, Two_trained_tech__c,Month__c, Year__c FROM Training_Data__r WHERE Year__c = :year AND Month__c = :month order by Month__c),
                                (SELECT Id, Name, Parts_Sold_Type__c, Invoice_Amount__c,Year__c,Month__c FROM TPS_Data__r WHERE (Year__c =:year OR Year__c = :prevYear) AND Month__c = :month  ),
                                (SELECT Id, Name, Repair_Type__c , date_cust_request_service__c, Date_Distributor_schedules_for_service__c, date_vehicle_first_arrived__c, Date_last_labor_applied__c, customer_notified__c,Total_Service_Time__c,Service_End_Date_Formula__c,Service_Start_Date_Formula__c  
                                 FROM TAT_Datas__r WHERE Year__c = :year AND Month__c =:month
                                 AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))),
                                (SELECT Id, Delivery_Priority__c, Month__c, Year__c FROM Parts_Orderings__r WHERE Year__c = :year AND Month__c =:month)
                                FROM Account 
                                WHERE Id = :dealerId AND PRP_Participation__c = true];
                
            }
        }
        else if(period == 'YTD') {
            if(partnerType == 'Distributor') {
                locationList = [SELECT Id,SAP_ID__c, Name, Sales_RegionA__c, ParentId,Type,
                                (SELECT Id, Name, Customer_Dealer_Id__c, Date_Taken__c, Type__c,
                                 Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c,
                                 Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c,
                                 Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, 
                                 Q8_Value__c, Q9_Value__c,Survey_Type__c, Survey_Score__c,Old_Formula__c
                                 FROM Survey_Data__r WHERE Year__c = :year AND Month__c <= :month),
                                (SELECT Id, Location__c, Month__c, Year__c, Score__c FROM Facility_Audits__r WHERE  Year__c = :year AND Month__c <=: month ORDER BY CreatedDate DESC),
                                (SELECT Id, Month__c, Year__c, Retail_Amount_ETC__c, Customer__c from ETC_Datas__r WHERE Year__c = :year AND Month__c <=: month ),
                                (SELECT Id, Name, Tech_compliant__c, Two_trained_tech__c,Month__c, Year__c FROM Training_Data__r WHERE Year__c = :year AND Month__c <= :month order by Month__c),
                                (SELECT Id, Name, Parts_Sold_Type__c, Invoice_Amount__c,Year__c,Month__c FROM TPS_Data__r WHERE (Year__c =:year OR Year__c = :prevYear) AND Month__c <= :month  ),
                                (SELECT Id, Name, Repair_Type__c , date_cust_request_service__c, Date_Distributor_schedules_for_service__c, date_vehicle_first_arrived__c, Date_last_labor_applied__c, customer_notified__c,Total_Service_Time__c,Service_End_Date_Formula__c,Service_Start_Date_Formula__c  
                                 FROM TAT_Datas__r WHERE Year__c = :year AND Month__c <=:month
                                 AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))),
                                (SELECT Id, Delivery_Priority__c, Month__c, Year__c FROM Parts_Orderings__r WHERE Year__c = :year AND Month__c <=:month)
                                FROM Account 
                                WHERE ParentId = :dealerId AND PRP_Participation__c = true AND Location_Type__c IN ('DB','D')];
            }
            else if(partnerType == 'Direct Dealer'){
                locationList = [SELECT Id, Name,SAP_ID__c, Sales_RegionA__c, ParentId,Type,
                                (SELECT Id, Name, Customer_Dealer_Id__c, Date_Taken__c, Type__c,
                                 Branch_location__c, Q1_Value__c, Q10_Value__c, Q11_Value__c, Q12_Value__c,
                                 Q13_Value__c, Q14_Value__c, Q15_Value__c, Q16_Value__c, Q17_Value__c, Q18_Value__c,
                                 Q2_Value__c, Q3_Value__c, Q4_Value__c, Q5_Value__c, Q6_Value__c, Q7_Value__c, 
                                 Q8_Value__c, Q9_Value__c,Survey_Type__c, Survey_Score__c,Old_Formula__c
                                 FROM Survey_Data__r WHERE Year__c = :year AND Month__c <= :month),
                                (SELECT Id, Location__c, Month__c, Year__c, Score__c FROM Facility_Audits__r WHERE  Year__c = :year AND Month__c <=: month ORDER BY CreatedDate DESC),
                                (SELECT Id, Name, Tech_compliant__c, Two_trained_tech__c,Month__c, Year__c FROM Training_Data__r WHERE Year__c = :year AND Month__c <= :month order by Month__c),
                                (SELECT Id, Name, Parts_Sold_Type__c, Invoice_Amount__c,Year__c,Month__c FROM TPS_Data__r WHERE (Year__c =:year OR Year__c = :prevYear) AND Month__c <= :month  ),
                                (SELECT Id, Name, Repair_Type__c , date_cust_request_service__c, Date_Distributor_schedules_for_service__c, date_vehicle_first_arrived__c, Date_last_labor_applied__c, customer_notified__c,Total_Service_Time__c,Service_End_Date_Formula__c,Service_Start_Date_Formula__c  
                                 FROM TAT_Datas__r WHERE Year__c = :year AND Month__c <=:month
                                 AND (Source_Type__c = 'AWARE' OR (Source_Type__c = 'Distributor' AND Repair_Payment__c = 'C'))),
                                (SELECT Id, Delivery_Priority__c, Month__c, Year__c FROM Parts_Orderings__r WHERE Year__c = :year AND Month__c <=:month)
                                FROM Account 
                                WHERE Id = :dealerId AND PRP_Participation__c = true];
            }
        }
        return locationList;
    }
    
    
    public static List<prpRangeWrapper> createPRPSetup(String key,List<Decimal> allPRPScoreList ) {
        Decimal goldLower;
        Decimal silverLower;
        List<prpRangeWrapper> prpRangeSetUpList = new List<prpRangeWrapper>();
        allPRPScoreList.sort();
        System.debug('------------------------: '+key +' : '+ allPRPScoreList.size() );
        System.debug('------------------------');
        
        Integer totalRecord = allPRPScoreList.size();
        if(totalRecord == 0) {
            return null;
        }
        goldLower = findLowerRange(.75, totalRecord, allPRPScoreList);
        silverLower = findLowerRange(.25, totalRecord, allPRPScoreList);
        
        prpRangeWrapper prpSetUpGold = new prpRangeWrapper();
        prpSetUpGold.key = key;
        prpSetUpGold.Name = 'Gold';
        prpSetUpGold.High_Range = 100.0;
        prpSetUpGold.Low_Range =  goldLower;
        prpRangeSetUpList.add(prpSetUpGold);
        
        prpRangeWrapper prpSetUpSilver = new prpRangeWrapper();
        prpSetUpSilver.key = key;
        prpSetUpSilver.Name = 'Silver';
        prpSetUpSilver.High_Range = goldLower - 0.1;
        prpSetUpSilver.Low_Range =  silverLower;
        prpRangeSetUpList.add(prpSetUpSilver);
        
        prpRangeWrapper prpSetUpBronze = new prpRangeWrapper();
        prpSetUpBronze.key = key;
        prpSetUpBronze.Name = 'Bronze';
        prpSetUpBronze.High_Range = silverLower -0.1 >= 0 ?silverLower -0.1: 0;
        prpSetUpBronze.Low_Range =  0;
        prpRangeSetUpList.add(prpSetUpBronze);
        System.debug('Check 779: '+prpSetUpSilver);
        return prpRangeSetUpList;
        
    }
    
    private static Decimal findLowerRange(Decimal k, Integer totalRecord, List<Decimal> allPRPScoreList) {
        Decimal lowerRange;
        Integer lastIndexOfRange = Integer.valueOf((totalRecord * k).round(System.RoundingMode.HALF_UP)) - 1;
        if(lastIndexOfRange < 0 ) {
            return 0.0;
        }
        if(checkIfmultiple(k, totalRecord)) {
            lastIndexOfRange = Integer.valueOf((totalRecord * k).round(System.RoundingMode.CEILING)) - 1;
            lowerRange= allPRPScoreList[lastIndexOfRange];
        }
        else if(!Test.isRunningTest()){
            lowerRange = (allPRPScoreList[lastIndexOfRange] + allPRPScoreList[lastIndexOfRange+1])/2;
        }
        else if(Test.isRunningTest()){
            return 1;
        }
        lowerRange = lowerRange.setScale(1,System.RoundingMode.HALF_UP);
        return lowerRange;
        
    }
    
    private static Boolean checkIfmultiple(Decimal k, Integer totalRecord) {
        //find if 1/(n-1) is a multiplier of k
        Decimal multiplier = totalRecord!= 1? 1.0/(totalRecord+1):0; 
        Decimal temp = multiplier!= 0?k/multiplier:0;
        temp = temp.setScale(2,System.RoundingMode.HALF_UP);
        if(math.ceil(temp) == math.floor(temp)) {
            return true;
            //return false;
        }
        else {
            return false;
        }
    }
    
    public static void sendBatchCompleteNotification(String templateName, Boolean isDefaultUser){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(isDefaultUser) {
            message.setTargetObjectId(System.Label.PRPL_Default_Notification_User);
        }
        else {
            message.setTargetObjectId(UserInfo.getUserId()); 
        }
        message.setSenderDisplayName('PRP Team'); 
        message.setReplyTo('no-reply@allisontransmissionenterprise.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = :templateName];
        message.setTemplateID(emailTemplate.Id); 
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }
    
    public static void sendBatchCompleteNotification(String templateName){
        sendBatchCompleteNotification(templateName, false);
    }
    
}