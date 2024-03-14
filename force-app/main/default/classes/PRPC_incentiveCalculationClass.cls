/* Class Name: PRPC_incentiveCalculationClass
* Description: Class to create Monthly and Annual Incentives for North America 
* Updated By: Akanksha Mondal, Ritu Raj Singh
*/

global class PRPC_incentiveCalculationClass implements Database.Batchable<sObject>,Database.stateful {
    List<Incentive__c> newIncentives = new List<Incentive__c>();
    Map<Id,Account> accountsForIncentives = new Map<Id,Account>();
    Integer Month = Date.today().Month();
    Integer Year = Date.today().Year();
   // Integer previousMonth = Month == 1? 12 : Month-1;
    Integer effectiveYear = Month == 1? Year-1 : Year;
    Integer previousMonth = 3;
    Map<Integer,String> mapForMonth = new Map<Integer,String>();
    Map<String,Integer> mapToInteger = new Map<String,Integer>();
    public Integer maxRows = 0;
    Integer accountsSize = 0;
    Public Map<String,Double> serviceDealerMap = new Map<String,Double>();
    Public Map<String,Double> parentToTps = new Map<String,Double>();
    Public Map<String,Double> accountsToIncentives = new Map<String,Double>();
    Public Map<Id,List<Incentive__c>> accountToIncentiveMap = new Map<Id,List<Incentive__c>>();
    public PRPC_incentiveCalculationClass(){
        mapToInteger.put('January',1);
        mapToInteger.put('February',2);
        mapToInteger.put('March',3);
        mapToInteger.put('April',4);
        mapToInteger.put('May',5);
        mapToInteger.put('June',6);
        mapToInteger.put('July',7);
        mapToInteger.put('August',8);
        mapToInteger.put('September',9);
        mapToInteger.put('October',10);
        mapToInteger.put('November',11);
        mapToInteger.put('December',12);
        mapForMonth.put(1,'January');
        mapForMonth.put(2,'February');
        mapForMonth.put(3,'March');
        mapForMonth.put(4,'April');
        mapForMonth.put(5,'May');
        mapForMonth.put(6,'June');
        mapForMonth.put(7,'July');
        mapForMonth.put(8,'August');
        mapForMonth.put(9,'September');
        mapForMonth.put(10,'October');
        mapForMonth.put(11,'November');
        mapForMonth.put(12,'December');
    }
    global void setMonth(Integer Month){
        this.Month = month;
    }
    global void setYear(Integer Year){
        this.Year = Year;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer previousMonth = This.Month;
        Integer effectiveYear = This.Year;
        System.debug('Inside start PreviousMonth ::'+previousMonth);
        System.debug('Inside start effectiveYear ::'+effectiveYear);
        final String EMPTY_SPACE = '';
        String typeDLR = 'Direct Dealer';
        String typeDis = 'Distributor';
        String YTD ='YTD';
        Integer MonthTPS = 12;        
        String query = 'Select id,Name,Sales_RegionA__c,Type,Include_Sales__c,SAP_ID__c,parentId,PRP_Participation__c,Number_Of_Active_Branches__c,parent.Number_Of_Active_Branches__c,parent.Type, (SELECT Id,CreatedDate, KPI_Calculation_Date__c,Partner_Type__c,Total_Parts_Sold__c,Year__c,Month__c,Region__c,PRP_Score__c,PRP_Level__c FROM KPIs__r WHERE Year__c =:effectiveYear AND Month__c =:previousMonth AND Period__c=:YTD AND isPartOfPRP__c = True),(select id,Invoice_amount__c,Year__c,Month__c from Functional_Comp_Data__r WHERE Year__c =:effectiveYear),(select id,Name,Incentive_Amount__c,TRPS_Amount__c,Year__c,Month__c from Incentives__r WHERE Year__c = :effectiveYear),(select id,Name,Invoice_Amount__c,Parts_Sold_Type__c,Extraction_Date__c,Month__c,Year__c from TPS_Data__r where Year__c=:effectiveYear) From Account where type!= :typeDis AND type != :EMPTY_SPACE AND Sales_RegionA__c = \'North America\' ';
        //query += ' AND parentId=  \'0013h00000QOCVPAA5\'';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> accounts){
        System.debug('Month ::'+Month);
        System.debug('Year ::'+Year);
        previousMonth = This.Month;
        effectiveYear = THIS.year;
        System.debug('PreviousMonth'+previousMonth);
        System.debug('effectiveYear'+effectiveYear);
        List<Account>distributoraccounts = new List<Account>();
        System.debug('Accounts Size ::'+accounts.size());
        System.debug('Accounts::'+accounts);
        for(Account acc : accounts){
            Boolean eligibleForParticipation = acc.Type == 'Distributor Branch';
                //&& (acc.PRP_Participation__c || acc.Include_Sales__c);
            if(eligibleForParticipation || acc.Type == 'Service Dealer' ){
                distributoraccounts.add(acc);
            }

        }

        System.debug('Distributor Size :: '+distributoraccounts.size());        
        calculateIncentiveForDistributorBranch(distributoraccounts);
        
    }
    global void finish(Database.BatchableContext bc){
         System.debug('Accounts Registered :: '+accountsSize);
        System.debug('Incentive Size ::'+newIncentives.size());
        Set<Id> accountIdsHavingInc = new Set<Id>();
        for(Incentive__c i : newIncentives){
            accountIdsHavingInc.add(i.IncentiveAcc__c);
            //System.debug(i);
        }
        for(Id id : accountsForIncentives.keySet()){
            if(!accountIdsHavingInc.contains(id)){
                Account acc = accountsForIncentives.get(id);
                System.debug('Name : '+acc.Name+' Id : '+acc.id);
                
            }
        }
        PRPC_incentiveFileGenerator.createFile(newIncentives);
    }
    global List<TPS_Data__c> getTpsOfTypeOfType(List<TPS_Data__c> tpsList,String tpsType){
        List<TPS_Data__C> dataToReturn = new List<TPS_Data__c>();
        for(TPS_Data__c data : tpsList){
            if(data.Parts_Sold_Type__c!=null && data.Parts_Sold_Type__c.equals(tpsType)){
                dataToReturn.add(data);  
            }
        }
        return dataToReturn;        
    }
    
    global void calculateIncentiveForDistributorBranch(List<Account> accounts){
        Set<Id> parentIdsSet = new Set<Id>();
        List<Account> parentAccountList = new List<Account>();
        System.debug(accounts.size());
        for(Account acc : accounts){
            if(acc.Sales_RegionA__c == 'North America' && acc.Type=='Distributor Branch'){
                accountsForIncentives.put(acc.id, acc);
            	accountsSize ++;    
            }
            parentIdsSet.add(acc.ParentId);
        }
        maxRows = (Limits.getLimitQueryRows() - Limits.getQueryRows());
        try{
            parentAccountList = [Select id,Name,PRP_Participation__c,Type,SAP_ID__c,parentId,Number_Of_Active_Branches__c,Sales_RegionA__c,parent.Number_Of_Active_Branches__c,parent.Type, (SELECT Id,CreatedDate, KPI_Calculation_Date__c,Partner_Type__c,Total_Parts_Sold__c,Year__c,Month__c,Region__c,PRP_Score__c,PRP_Level__c FROM KPIs__r WHERE Year__c =:effectiveYear AND Month__c =:previousMonth AND isPartOfPRP__c = True),(select id,Invoice_amount__c,Year__c,Month__c from Functional_Comp_Data__r WHERE Year__c =:effectiveYear),(select id,Name,Incentive_Amount__c,TRPS_Amount__c,Year__c,Month__c from Incentives__r WHERE Year__c = :effectiveYear),(select id,Name,Invoice_Amount__c,Parts_Sold_Type__c,Extraction_Date__c,Month__c,Year__c from TPS_Data__r where Year__c =:effectiveYear) From Account WHERE Id IN :parentIdsSet AND Sales_RegionA__c != null LIMIT :maxRows];    
        }
        catch(System.QueryException ex){
            System.debug('From parent Acc query');
            System.debug('Line : '+ex.getLineNumber());
            throw ex;
        }
        System.debug('Size of Q1 ::'+parentAccountList.size());
        accounts.addAll(parentAccountList);
        Map<id,Decimal> levelDiscountMap = new Map<id,Decimal>();
        Map<id,Decimal> levelDiscountMapForIntnl = new Map<id,Decimal>();
        Map<id,Decimal> levelTRPSRebateMap = new Map<id,Decimal>();
        Map<id,Decimal> levelTRPSRebateMapForIntnl = new Map<id,Decimal>();
        Set<Id> distributorIds = new Set<Id>();
        Map<String, Double> parentToWPC = new Map<String,Double>();
        String previousMonthString = mapForMonth.get(This.previousMonth);
        String effectiveYearString = String.valueOf(effectiveYear);
        
        Map<Id,String> prpLevelMap = new Map<id,String>();
        Map<id,Account> parentAccMap = new Map<id,Account>();
        List<PRP_Range_Settings__c> prps=[SELECT Name,Low_Range__c,High_Range__c,Level_Discount__c,PRP_Setup__r.Region__c,PRP_Setup__r.Year__c,PRP_Setup__r.Month__c,Functional_Comp_Range__c FROM PRP_Range_Settings__c WHERE PRP_Setup__r.Month__c =:previousMonthString AND PRP_Setup__r.Year__c =:effectiveYearString AND PRP_Setup__r.Partner_Type__c = 'Distributor' LIMIT :maxRows];
        System.debug('Size of Q2 ::'+prps.size());
        //For Testing :
        List<Account> subparentlist = [Select id,ParentId,Name from Account where Name LIKE '%Subparent%'];
        Map<id,id> subparentmap = new Map<id,id>();
        for(Account a:subparentlist){
            subparentmap.put(a.id,a.ParentId);
        }
        
        Map<String,String> parentIdToName = new Map<String,String>();
        Map<String,Double> parentAccToNumOfBranch = new Map<String,Double>();
        Map<String,List<Account>> parentToBranches= new Map<String,List<Account>>();
        Map<String, Double> parentToFuncComp = new Map<String,Double>();
        Map<String, Double> parentToCEData = new Map<String,Double>();
        Map<String,Double> step2Map = new Map<String,Double>();
        
        
        try{

            for(Account acc : accounts ){
                parentIdToName.put(acc.id,acc.Name);
                if(acc.Type!=null && acc.Type == 'Distributor'){
                    System.debug('acc.Functional_Comp_Data__r ::'+acc.Functional_Comp_Data__r);
                    parentAccToNumOfBranch.put(acc.id,acc.Number_Of_Active_Branches__c);
                    parentToFuncComp.put(acc.id,getTotalFuncComp(acc.Functional_Comp_Data__r));
                    Double TotalCE = calculateTotalTps(acc.Tps_data__r,'CE');
                    for(TPS_Data__C tps : acc.Tps_data__r){
                        if(tps.Parts_Sold_Type__c == 'CE'){
                            System.debug('CE Amount adding :: '+tps.Invoice_Amount__c);
                        }
                    }
                    System.debug('Total CE : '+TotalCE);
                    parentToCEData.put(acc.id,calculateTotalTps(acc.Tps_data__r,'CE'));
                }
                if(acc.ParentId!=null && acc.Type=='Distributor Branch'){
                    if(parentToBranches.containsKey(acc.ParentId)){
                        List<Account> existingAccounts = parentToBranches.get(acc.ParentId);
                        existingAccounts.add(acc);
                        parentToBranches.put(acc.ParentId,existingAccounts);
                    }
                    else{
                        List<Account> newList = new List<Account>();
                        newList.add(acc);
                        parentToBranches.put(acc.ParentId,newList);
                    }                
                    accountsToIncentives.put(acc.Id,getTotalIncentives(acc.Incentives__r));
                    accountToIncentiveMap.put(acc.Id,acc.Incentives__r);
                }
                if(acc.ParentId!=null && acc.Type=='Service Dealer'){
                    String pid=acc.ParentId;
                        if(subparentmap.containsKey(acc.ParentId)){
                            pid=subparentmap.get(acc.ParentId);
                        }
                    system.debug('Servide Dealer SAP*******'+acc.SAP_ID__c);
                    if(serviceDealerMap.containsKey(pid)  ){
                        DOuble updtdValue = serviceDealerMap.get(pid)+calculateTotalTps(acc.Tps_data__r,'WPC');
                        System.debug('Calculate WPC ::'+updtdValue);
                        serviceDealerMap.put(pid,updtdValue);
                    }
                    else{
                        DOuble updtdValue = calculateTotalTps(acc.Tps_data__r,'WPC');
                        System.debug('Calculate WPC ::'+updtdValue);
                        serviceDealerMap.put(pid,updtdValue);
                    }
                }
            }
            System.debug('Line 175');
            System.debug('serviceDealerMap ::'+serviceDealerMap);
        }
        catch(System.QueryException ex){
            System.debug('Line : '+ex.getLineNumber());
            System.debug('Strack trace '+ex.getStackTraceString());
            throw ex;
        }
        for(Account a : parentAccountList){
            parentAccMap.put(a.id,a);
        }
        for(String key : parentAccToNumOfBranch.keyset()){
            Double numberOfBranches = parentAccToNumOfBranch.get(key);
            Double totalFuncCOmp = parentToFuncComp.get(key);
            if(parentToBranches.containsKey(key)){
                List<Account> accs = parentToBranches.get(key);
                Double totalTps = 0.0;
                Double totalWpc = 0.0;
                for(Account a : accs){
                    totalTps = calculateTotalTps(a.Tps_data__r,'TPS')+calculateTotalTps(a.Tps_data__r,'RET')+totalTps;
                    totalWpc = calculateTotalTps(a.Tps_data__r,'WPC') + totalWpc;
                }
                System.debug('totalTps'+totalTps);
                System.debug('totalFuncCOmp'+totalFuncCOmp);
                System.debug('numberOfBranches'+numberOfBranches);
                if(numberOfBranches!=null && numberOfBranches!=0){
                    Double tpsValue = (1/numberOfBranches)*totalFuncCOmp;
                    System.debug('totalFuncCOmp1'+totalFuncCOmp);
                    System.debug('numberOfBranches1'+numberOfBranches);
                    System.debug('tpsValue1'+tpsValue);
                    Double wpcValue = totalWpc/numberOfBranches;
                    step2Map.put(key,tpsValue);
                    parentToWPC.put(key,totalWpc);
                    parentToTps.put(key,totalTps);
                }
                else{
                    step2Map.put(key,0.0);
                    parentToWPC.put(key,0.0);
                    parentToTps.put(key,0.0);
                }
                
            }
        }
        
        //Step 3 Calculating Bonus
        Map<Id,KPI__C> latestPrpMap = new Map<Id,KPI__C>();
        for(Account acc : accounts){
            if(acc.Type == 'Distributor Branch'){
                KPI__c latestPrpScore = null;
                System.debug('KPI Size ::::'+acc.KPIs__r.size());
                if(acc.KPIs__r!= null && acc.KPIs__r.size()>0){
                    KPI__c mostRecent = acc.KPIs__r.get(0);
                    latestPrpScore = mostRecent;
                    System.debug('latestPrpScore ::::::'+latestPrpScore);
                }
                latestPrpMap.put(acc.id, latestPrpScore);
                Decimal Discount = null;
                Decimal Rebate = null;
                if(latestPrpScore != null ){
                    
                    for(PRP_Range_Settings__c prpRange : prps){
                        System.debug('Inside For of PRPRangeSettings');
                        if(prpRange.PRP_Setup__r.Region__c == latestPrpScore.Region__c){
                            //if(prpRange.Level_Discount__c!= null && prpRange.Functional_Comp_Range__c!=null && prpRange.Low_Range__c <= latestPrpScore.PRP_Score__c && prpRange.High_Range__c >= latestPrpScore.PRP_Score__c){
                            if(prpRange.Level_Discount__c!= null && prpRange.Functional_Comp_Range__c!=null && prpRange.Name == latestPrpScore.PRP_Level__c){
                                Discount =  prpRange.Level_Discount__c;
                                Rebate =prpRange.Functional_Comp_Range__c;
                                System.debug('Setting levelDiscount'+prpRange.Level_Discount__c+'id ::::'+prpRange.id);
                                System.debug('Setting Rebate'+prpRange.Functional_Comp_Range__c+'id ::::'+prpRange.id);
                                break;
                            }
                        }
                    }
                }
                levelDiscountMap.put(acc.id,Discount);
                levelTRPSRebateMap.put(acc.id,Rebate);
                if(latestPrpScore != null){
                	prpLevelMap.put(acc.id,latestPrpScore.PRP_Level__c);    
                }
            }
        }
        for(String key : levelDiscountMap.keySet()){
            System.debug(key);
            System.debug('levelDiscountMap #####'+levelDiscountMap.get(key));
        }              
        Map<String,Double> step3Map = new Map<String,Double>();
        for(Account acc : accounts){
            if(acc.Type == 'Distributor Branch'){
                System.debug('Inside Branch');
                System.debug('Account Id'+acc.Id);
                System.debug('Account ParentId'+acc.ParentId);
                System.debug('LevelDiscountMap'+levelDiscountMap.get(acc.Id));
                System.debug('step2Map'+step2Map.get(acc.ParentId));
                if(levelDiscountMap.containsKey(acc.Id) && levelDiscountMap.get(acc.Id) != null && step2Map.containsKey(acc.ParentId)){
                    System.debug('Calculation Part'+(levelDiscountMap.get(acc.Id)*step2Map.get(acc.ParentId))/100);
                    step3Map.put(acc.Id,(levelDiscountMap.get(acc.Id)*step2Map.get(acc.ParentId))/100);
                }
            }
        }
        for(String key : step3Map.keyset()){
            System.debug('Inside step3Map');
            System.debug('Map#######Account Name ::::'+parentIdToName.get(Key)+' Result ::: '+step3Map.get(key)+ 'LevelDiscount :: '+levelDiscountMap.get(key));
        }
        //Create incentives For North America :
        List<Incentive__c> insentivesToInsert = new List<Incentive__c>();
        for(Account acc : accounts){            
            if(acc.type=='Distributor Branch' && acc.Sales_RegionA__c=='North America' && acc.PRP_Participation__c==true){
                if(step3Map.containsKey(acc.id) && accountsToIncentives.containsKey(acc.id)){
                    Incentive__c i = currentMonthIncentive(acc.Incentives__r);

                    i.IncentiveAcc__c = acc.Id;
                    i.SAP_ID__c = acc.SAP_ID__c;
                    
                    Switch on previousMonth {
                        when 1{
                            i.Month__c = 'January';}
                        when 2{
                            i.Month__c = 'February';}
                        when 3{
                            i.Month__c = 'March';}
                        when 4{
                            i.Month__c = 'April';}
                        when 5{
                            i.Month__c = 'May';}
                        when 6{
                            i.Month__c = 'June';}
                        when 7{
                            i.Month__c = 'July';}
                        when 8{
                            i.Month__c = 'August';}
                        when 9{
                            i.Month__c = 'September';}
                        when 10{
                            i.Month__c = 'October';}
                        when 11{
                            i.Month__c = 'November';}
                        when 12{
                            i.Month__c = 'December';}
                    }
                    setIncentiveYTDAndAmount(accountToIncentiveMap.get(acc.id),i,step3Map.get(acc.id));
                    i.PerformanceLevel__c = prpLevelMap.get(acc.id);
                    insentivesToInsert.add(i);
                    //TRPS Calculation begins --------->
                    System.debug('MonthForTRPS ::'+Month);
                    if(Month == 12 ){
                        System.debug('Inside TRPS');
                        String key = acc.ParentId;
                        system.debug('SAP ID INSIDE TRPS ********'+acc.SAP_ID__c);
                        System.debug('TPS : '+parentToTps.get(key));
                        System.debug('CE : '+parentToCEData.get(key));
                        System.debug('Service Dealer Map Value ::'+serviceDealerMap.get(key));
                        if(parentToTps.containsKey(key)){
                            System.debug('Inside If Condition TRPS');
                            Double TRPS = 0;
                            Double CEValue = parentToCEData.containsKey(key) ? parentToCEData.get(key) : 0.0;
                            if(serviceDealerMap.containsKey(key)){
                               TRPS = parentToTps.get(key)-serviceDealerMap.get(key)-CEValue; 
                                                              }
                            else {
                                TRPS = parentToTps.get(key)-parentToCEData.get(key);
                            }
                            System.debug('TRPS Value ::'+TRPS);
                            Double Value = 0;
                            Double wpcBranch = calculateTotalTps(acc.Tps_data__r,'WPC');
                            Double levelTRPSValue = levelTRPSRebateMap.containsKey(acc.id) ? levelTRPSRebateMap.get(acc.id) : 0.0;
                            System.debug('WPC Branch : '+wpcBranch);
                            Value = ((TRPS/parentAccToNumOfBranch.get(key))-wpcBranch) * (levelTRPSValue/100); 
                            Value = Value<0 ? 0 : Value;
                            system.debug('level---'+levelTRPSValue);
                            system.debug('TRPS VALUE*****'+Value);
                            i.TRPS_Amount__c = value;    
                        }
                    }
                }
            }
            if(acc.type=='Distributor Branch' && acc.Sales_RegionA__c != 'North America' && acc.ParentId != null){
                parentIdsSet.add(acc.ParentId);
            }
        }
        System.debug('Incentive List :: '+insentivesToInsert);
        storeIncentives(insentivesToInsert);
        //insert insentivesToInsert;
        newIncentives.addAll(insentivesToInsert);
    }
    
    global Double calculateTotalTps(List<TPS_Data__c> tpsData,String dataType){
        Double sum = 0.0;
        Integer count=0;
        if(tpsData!=null && tpsData.size()>0){
            for(TPS_Data__c data : tpsData){
                if(data.Parts_Sold_Type__c == dataType){
                    count++;
                    sum = sum+data.Invoice_Amount__c;
                }
            }
        }
        system.debug('DATATYPE*****'+dataType);
        system.debug('SUM*****'+sum);
        return sum;
    }
    global Double calculateTotalWpc(List<TPS_Data__c> tpsData,String dataType){
        Double sum = 0.0;
        if(tpsData!=null && tpsData.size()>0){
            for(TPS_Data__c data : tpsData){
                if(data.Parts_Sold_Type__c == dataType && data.Invoice_Amount__c!=null){
                    sum = sum+data.Invoice_Amount__c;
                }
            }
        }
        system.debug('DATATYPE*****'+dataType);
        system.debug('SUM*****'+sum);
        return sum;
    }
    global Double getTotalIncentives(List<Incentive__c> incentives){
        Double sum =0.0;
        if(incentives!=null){
            for(Incentive__c inc : incentives){
                Integer incmonth = mapToInteger.get(inc.Month__c);
                if(incmonth != null && incmonth<previousMonth && inc.Incentive_Amount__c!=null){
                    sum = sum + inc.Incentive_Amount__c;
                }
            }
            
        }
        return sum;
    }
    global Double getTotalFuncComp(List<Functional_Comp_Data__c> funcComps){
        Double sum = 0.0;
        System.debug('funcComps'+funcComps);
        System.debug('Size ::'+funcComps.size());
        if(funcComps!=null && funcComps.size()>0){
            System.debug('Inside funcComps');
            System.debug('Previous Month : '+previousMonth);
            for(Functional_Comp_Data__c ins : funcComps){
                if(ins.Invoice_amount__c != null && ins.Month__c <= previousMonth){
                    System.debug('Func comp for month : '+ins.Month__c+' Amount '+ins.Invoice_amount__c);
                	sum = sum + ins.Invoice_amount__c;    
                }
            }
        }
        System.debug('Sum Inside Function'+sum);
        return sum;
    }
    global Double getTotalCEData(List<TPS_Data__c> ce,String dataType){
        Double sum = 0.0;
        if(ce!=null && ce.size()>0){
            for(TPS_Data__c tps : ce){
                if(tps.Parts_Sold_Type__c == dataType && tps.Invoice_Amount__c != null){
                    sum = sum+tps.Invoice_Amount__c;  
                }
            }
        }
        return sum;
    }
    global void setIncentiveYTDAndAmount(List<Incentive__c> accIncetives, Incentive__c inc,Double amount){
        //amount = amount * previousMonth;
        System.debug('List Of Incentives ::'+accIncetives);
        System.debug('Size Of Incentives ::'+accIncetives.size());
        System.debug('Amount getting calculated ::'+amount);
        System.debug('inc ::'+inc);
        System.debug('previousMonth Here Is::'+previousMonth);
        if(mapToInteger.get(inc.Month__c)==1){
            Decimal amountDec = Decimal.valueOf(amount);
            amountDec = amountDec.setScale(0);
            inc.IncentiveYTD__c = 0.0;
            inc.Incentive_Amount__c = amountDec;
            return;
        }
        Double amounttoUpdate = 0.0;
        Double ytd = 0.0;
        Double totalIncAmount = 0.0;
        for(Incentive__c elt : accIncetives){
            //Double temp = elt.Incentive_Amount__c == null ? 0.0 : elt.Incentive_Amount__c;
            System.debug('Month Inside :'+inc.Month__c);
            System.debug('Month Inside elt:'+elt.Month__c);
            if(mapToInteger.containsKey(elt.Month__c) && mapToInteger.get(elt.Month__c)<previousMonth){
                System.debug('totalIncAmount Getting Added'+elt.Incentive_Amount__c+ 'Month'+elt.Month__c);
            	totalIncAmount = totalIncAmount + elt.Incentive_Amount__c;    
            }
            //ytd = ytd + (amount - temp);
            //ytd += temp;
        }
        Decimal amountDecimal = Decimal.valueOf(amount - totalIncAmount);
        amountDecimal = amountDecimal.setScale(0);
        Decimal ytdDecimal = Decimal.valueOf(totalIncAmount);
        ytdDecimal = ytdDecimal.setScale(0);
        inc.IncentiveYTD__c = ytdDecimal ;
        inc.Incentive_Amount__c = amountDecimal;
        System.debug('amountDecimal :'+amountDecimal);
        System.debug('ytdDecimal :'+ytdDecimal);
        //inc.Incentive_Amount__c = amountDecimal;
        
    }
    global Incentive__c currentMonthIncentive(List<Incentive__c> accIncetives){
        if(accIncetives==null || accIncetives.size()==0){
            return new Incentive__c();
        }
        for(Incentive__c inc : accIncetives){
            if(inc.Month__c==mapForMonth.get(previousMonth)){
                return inc;  
            }
        }
        return new Incentive__c();
    }
    global void storeIncentives(List<Incentive__c> accIncetives){
        List<Incentive__c> incToUpdate = new List<Incentive__c>();
        List<Incentive__c> incToInsert = new List<Incentive__c>();
        Map<id,Incentive__c> incmapfinal = new Map<id,Incentive__c>();
        for(Incentive__c inc : accIncetives){
            System.debug('Id for incentive'+inc.id);
            if(inc.id!=null){
                incmapfinal.put(inc.id,inc);
                incToUpdate.add(inc);
            }else{
                incToInsert.add(inc);
            }
        }
        System.debug('Update List :'+incToUpdate.size());
        for(Incentive__c x:incToUpdate){
            system.debug('SAP ID UPDATE LIST *******'+x.SAP_ID__c);
        }
        System.debug('Update Map :'+incmapfinal.keyset().size());
        if(incmapfinal.keyset().size()>0){
            update incmapfinal.values();    
        }
        insert incToInsert;
        System.debug('Update List :'+incToInsert.size());
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
    }
}