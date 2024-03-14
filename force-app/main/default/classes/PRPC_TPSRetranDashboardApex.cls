public class PRPC_TPSRetranDashboardApex {
    @AuraEnabled
    public static wrapperClass getDistributors(String regionType,string PartnerType){
        //String DistributorName='Test';
         Set<Id> IdOfAccounts = new Set<Id>();
        List<Account> account = new List<Account>();
        list<Account>DistributorName = new list<Account>();
        list<string>DistributorId = new list<string>();
        string partType;
        //String DistributorId='TestId';
        User currentuser=new User();
        currentuser=[Select Id,ContactId,ProfileId from User where Id=:userinfo.getuserId()];
        If([Select Name from profile where id=:currentuser.profileId].Name=='PRP Partner'){
            Contact conDetails=[Select AccountId,Account.Type,Account.AccountSAPField__c,Account.Sales_RegionA__c from Contact where Id=:currentuser.ContactId];
            partType = string.valueof(conDetails.Account.Type);
            List<AccountContactRelation> accRel = new List<AccountContactRelation>([SELECT id,AccountId, ContactId FROM AccountContactRelation where contactId= :currentuser.ContactId]);
            for(AccountContactRelation ac : accRel){
                IdOfAccounts.add(ac.AccountId);
            }
            account = [SELECT ID,Sales_RegionA__c,AccountSAPField__c,Type,name,SAP_ID__c FROM Account WHERE ID IN: IdOfAccounts];
            if(account.size() > 0){
                for(Account acc:account){
                    DistributorName.add(acc);
                    DistributorId.add(acc.Id);
                }
            }
            //DistributorName=conDetails.Account.AccountSAPField__c;
            //DistributorId=String.valueOf(conDetails.AccountId);
        }
        List<String> Years=new List<String>();
        Set<String> regionSet=new Set<String>();
        If(regionType=='North America'){
            regionSet.add('North America');
        }
        else{
            regionSet.add('Latin America');
            regionSet.add('EMEA');
            regionSet.add('Asia pacific');
            
        }
        Integer CurrentYear = Date.Today().Year();
        for(Integer i= CurrentYear; i>=CurrentYear-20; i--){
            Years.add(String.valueof(i));
        }
        List<Account> distLists=New List<Account>([Select id,AccountSAPField__c from Account where Type=:PartnerType and Sales_RegionA__c=:regionSet ORDER BY AccountSAPField__c]);
        System.debug('Years'+Years);
        System.debug('Distributor'+distLists);
        return new wrapperClass(Years,distLists,DistributorName,DistributorId,partType);       
    }
    @AuraEnabled
    public Static responseWrapper returnDashboardDetails(Integer YearSelected,String SelectedDist,String TPSTypes, String regionType,string partnerType){
        Set<String> regionSet=new Set<String>();
        System.debug('Year'+regionType);
        System.debug('SelectedDist:'+SelectedDist);
        System.debug('TPSTypes:'+TPSTypes);
        System.debug('regionType:'+regionType);
        System.debug('partnerType:'+partnerType);
        Integer storeMonth;
        // CHG-42909 by Akanksha [Start]
        If(!Test.isRunningTest())
        {
            if(Date.today().month() == 1){
                storeMonth = 12; 
                YearSelected=YearSelected -1;
            }
            else
            {
                storeMonth = Date.today().month() -1;
            }
        }
        else
        {
            storeMonth = 12;
        }
        // CHG-42909 by Akanksha [End]
       /* Integer storeMonth = Date.today().month() -1;
         system.debug('STOREMONTH:'+storeMonth);
        if(storeMonth == 12){
            YearSelected = YearSelected -1;
        }*/
        
        String DistAVg='0.00';
        String RegAvg='0.00';
        String NatAvg='0.00';
        string TpsTypeForRange;
        if(TPSTypes == 'TPS' ){
            TpsTypeForRange = 'TPS';
        }
        if(TPSTypes == 'RET'){
           TpsTypeForRange = 'Total Parts Sold ReTran'; 
        }
        AggregateResult[] groupedResults;
        Account accList=[Select Sales_RegionA__c,Service_Start_Date__c from Account where  id=:SelectedDist];
        regionType = accList.Sales_RegionA__c;
        Date serviceDateDist = accList.Service_Start_Date__c;
        
        Integer yearCount1 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,1,YearSelected);
        System.debug('yearCount1'+yearCount1);
        Integer yearCount2 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,2,YearSelected);
        Integer yearCount3 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,3,YearSelected);
        Integer yearCount4 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,4,YearSelected);
        Integer yearCount5 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,5,YearSelected);
        Integer yearCount6 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,6,YearSelected);
        Integer yearCount7 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,7,YearSelected);
        Integer yearCount8 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,8,YearSelected);
        Integer yearCount9 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,9,YearSelected);
        Integer yearCount10 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,10,YearSelected);
        Integer yearCount11 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,11,YearSelected);
        Integer yearCount12 = PRPC_TPSRetranDashboardApex.returnYearCount(serviceDateDist,12,YearSelected);
        
        If(regionType=='North America'){
            regionSet.add('North America');
        }
        else{
            regionSet.add('Latin America');
            regionSet.add('EMEA');
            regionSet.add('Asia pacific');
            
        }
        try {
            if(regionType=='North America'){
            if(TPSTypes=='TPS'){
                groupedResults= [Select AVG(TPS__c) from KPI__c where Customer__r.ParentId=:SelectedDist and year__c =:YearSelected and Period__C = 'YTD' and month__C =: storeMonth];
            }else{
                groupedResults= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Customer__r.ParentId=:SelectedDist and year__c =:YearSelected and Period__C = 'YTD' and month__C =: storeMonth];
            }
            }else{
                 if(TPSTypes=='TPS'){
                groupedResults= [Select AVG(TPS__c) from KPI__c where Customer__c=:SelectedDist and year__c =:YearSelected and Period__C = 'YTD' and month__C =: storeMonth];
            }else{
                groupedResults= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Customer__c=:SelectedDist and year__c =:YearSelected and Period__C = 'YTD' and month__C =: storeMonth];
            }
            }
            System.debug('Average'+groupedResults);
            for (AggregateResult ar : groupedResults)  {
                System.debug('Campaign ID' + ar.get('expr0'));
                DistAVg=String.valueof(ar.get('expr0'));
            }
        }
        catch (Exception e) {
            // Handle this exception here
        }
       /* try {
            
            groupedResults= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Region__c='North America'];
            System.debug('Average'+groupedResults);
            for (AggregateResult ar : groupedResults)  {
                System.debug('Campaign ID' + ar.get('expr0'));
                NatAvg=String.valueof(ar.get('expr0'));
            }
        }
        catch (Exception e) {
            // Handle this exception here
        }*/
        try {
            if(TPSTypes=='TPS'){
                groupedResults= [Select AVG(TPS__c) from KPI__c where Region__c=:regionType and year__c =:YearSelected and month__C =: storeMonth];
            }else{
                groupedResults= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Region__c=:regionType and year__c =:YearSelected and month__C =: storeMonth];
            }
            //AggregateResult[] groupedResults= [Select AVG(Total_Parts_Sold_ReTran__c) from KPI__c where Region__c!=NUll];
            System.debug('Average'+groupedResults);
            for (AggregateResult ar : groupedResults)  {
                System.debug('Campaign ID' + ar.get('expr0'));
                RegAvg=String.valueof(ar.get('expr0'));
            }
        }
        catch (Exception e) {
            // Handle this exception here
        } 
        //string distributorYTDPoints;
        Double kpiInst = [SELECT Month__c FROM KPI__c ORDER BY createdDate DESC Limit 1].Month__c;
        
        //System.debug('distributorYTDPoints'+distributorYTDPoints);
        List<KPI_Range_Settings__c> rangedetails=New List<KPI_Range_Settings__c>();
        String kpiId;
        try {
            kpiId=[Select id,createddate from KPI_Setup__c where Region__c=:regionSet AND Partner_Type__c='Distributor' AND Year__c=:String.valueof(YearSelected) and KPI_Type__c=:TpsTypeForRange order by createddate DESC  limit 1].Id;
            
               //kpiId=[Select id,createddate from KPI_Setup__c where Region__c=:regionSet AND Partner_Type__c='Distributor' AND Year__c=:String.valueof(YearSelected-1) and KPI_Type__c=:TpsTypeForRange order by createddate DESC  limit 1].Id;
            
            rangedetails=[Select Id,Name,High_Range_Value__c,Low_Range_Value__c,Points__c from KPI_Range_Settings__c where KPI_Setup__c=:kpiId];
        }
        catch (Exception e) {
            system.debug('enter 158: '+e.getMessage());
            if(!Test.isRunningTest()){
            kpiId=[Select id,createddate from KPI_Setup__c where Region__c=:regionSet AND Partner_Type__c='Distributor' AND Year__c=:String.valueof(YearSelected-1) and KPI_Type__c=:TpsTypeForRange order by createddate DESC  limit 1].Id;
            
            rangedetails=[Select Id,Name,High_Range_Value__c,Low_Range_Value__c,Points__c from KPI_Range_Settings__c where KPI_Setup__c=:kpiId];
            // Handle this exception here
              }
        }
        
        System.debug('KPi Settings'+rangedetails);
        System.debug('KPi Setup Id'+kpiId);
        System.debug('Dist'+SelectedDist);
        list<TPSDetails> responseData=New list<TPSDetails>();
        Set<Integer> yearSet=New Set<Integer>();
        yearSet.add(YearSelected);
        yearSet.add(YearSelected-1);
        yearSet.add(YearSelected-2);
        yearSet.add(YearSelected-3);
        Integer prevYear = YearSelected - 1;
        Integer prevYear1 = YearSelected - 2;
        Integer prevYear2 = YearSelected - 3;
        /*Decimal amountJan = 0.0;
        Decimal amountFeb = 0.0;
        Decimal amountMar = 0.0;
        Decimal amountApr = 0.0;
        Decimal amountMay = 0.0;
        Decimal amountJun = 0.0;
        Decimal amountJul = 0.0;
        Decimal amountAug = 0.0;
        Decimal amountSep = 0.0;
        Decimal amountOct = 0.0;
        Decimal amountNov = 0.0;
        Decimal amountDec = 0.0;
        
         Decimal amount2Jan = 0.0;
        Decimal amount2Feb = 0.0;
        Decimal amount2Mar = 0.0;
        Decimal amount2Apr = 0.0;
        Decimal amount2May = 0.0;
        Decimal amount2Jun = 0.0;
        Decimal amount2Jul = 0.0;
        Decimal amount2Aug = 0.0;
        Decimal amount2Sep = 0.0;
        Decimal amount2Oct = 0.0;
        Decimal amount2Nov = 0.0;
        Decimal amount2Dec = 0.0;
        
        Decimal amount3Jan = 0.0;
        Decimal amount3Feb = 0.0;
        Decimal amount3Mar = 0.0;
        Decimal amount3Apr = 0.0;
        Decimal amount3May = 0.0;
        Decimal amount3Jun = 0.0;
        Decimal amount3Jul = 0.0;
        Decimal amount3Aug = 0.0;
        Decimal amount3Sep = 0.0;
        Decimal amount3Oct = 0.0;
        Decimal amount3Nov = 0.0;
        Decimal amount3Dec = 0.0;*/
        
        TPSDetails wrapperInstance1=new TPSDetails();
        wrapperInstance1.Duration='Current Year';
        wrapperInstance1.format='currency';
        wrapperInstance1.Jan=0;
        wrapperInstance1.Feb=0;
        wrapperInstance1.Mar=0;
        wrapperInstance1.Apr=0;
        wrapperInstance1.May=0;
        wrapperInstance1.Jun=0;
        wrapperInstance1.Jul=0;
        wrapperInstance1.Aug=0;
        wrapperInstance1.Sep=0;
        wrapperInstance1.Oct=0;
        wrapperInstance1.Nov=0;
        wrapperInstance1.Dec=0;
        TPSDetails wrapperInstance2=new TPSDetails();
        wrapperInstance2.Duration='Average';
        wrapperInstance2.format='currency';
        wrapperInstance2.Jan=0;
        wrapperInstance2.Feb=0;
        wrapperInstance2.Mar=0;
        wrapperInstance2.Apr=0;
        wrapperInstance2.May=0;
        wrapperInstance2.Jun=0;
        wrapperInstance2.Jul=0;
        wrapperInstance2.Aug=0;
        wrapperInstance2.Sep=0;
        wrapperInstance2.Oct=0;
        wrapperInstance2.Nov=0;
        wrapperInstance2.Dec=0;
        
        TPSDetails wrapperInstance3=new TPSDetails();
        wrapperInstance3.Duration='Variance';
        wrapperInstance3.format='currency';
        wrapperInstance3.Jan=0;
        wrapperInstance3.Feb=0;
        wrapperInstance3.Mar=0;
        wrapperInstance3.Apr=0;
        wrapperInstance3.May=0;
        wrapperInstance3.Jun=0;
        wrapperInstance3.Jul=0;
        wrapperInstance3.Aug=0;
        wrapperInstance3.Sep=0;
        wrapperInstance3.Oct=0;
        wrapperInstance3.Nov=0;
        wrapperInstance3.Dec=0;
        TPSDetails wrapperInstance4=new TPSDetails();
        wrapperInstance4.Duration='% Change';
        wrapperInstance4.format='percent';
        wrapperInstance4.Jan=0;
        wrapperInstance4.Feb=0;
        wrapperInstance4.Mar=0;
        wrapperInstance4.Apr=0;
        wrapperInstance4.May=0;
        wrapperInstance4.Jun=0;
        wrapperInstance4.Jul=0;
        wrapperInstance4.Aug=0;
        wrapperInstance4.Sep=0;
        wrapperInstance4.Oct=0;
        wrapperInstance4.Nov=0;
        wrapperInstance4.Dec=0;
        System.debug('Years'+yearSet);
        System.debug('Sold Types'+TPSTypes);
        System.debug('Distributor'+SelectedDist);
        List<TPS_Data__c> TpsRecords = new list<TPS_Data__c>();
        if(partnerType == 'Distributor'){
           TpsRecords=new List<TPS_Data__c>([Select Id,Invoice_Amount__c,Month__c,Year__c from TPS_Data__c where Year__c=:yearSet AND Parts_Sold_Type__c=:TPSTypes AND Customer__r.parentId=:SelectedDist AND Customer__r.Type !='Service Dealer' and (customer__r.PRP_Participation__c = true or customer__r.Include_Sales__c = true) order by Year__C]);
            
        }else{
           TpsRecords=new List<TPS_Data__c>([Select Id,Invoice_Amount__c,Month__c,Year__c from TPS_Data__c where Year__c=:yearSet AND Parts_Sold_Type__c=:TPSTypes AND Customer__c=:SelectedDist AND Customer__r.Type !='Service Dealer' and (customer__r.PRP_Participation__c = true or customer__r.Include_Sales__c = true) order by Year__C]);
            
        }
        System.debug('TPS Data'+TpsRecords);
        for(TPS_Data__c tpsData: TpsRecords){
            System.debug('TPS'+tpsData);
            System.debug('tpsrecordsize'+TpsRecords.size());
            Decimal InvoiceAmount;
            
            Decimal totalAmountPrevYr1 = 0.0;
            Decimal totalAmountPrevYr2 = 0.0;
            if(tpsData.Invoice_Amount__c==null)
                InvoiceAmount=0;
            else
                InvoiceAmount=tpsData.Invoice_Amount__c;
            
            if(tpsData.Year__c==YearSelected){
                System.debug('test'+tpsData.Invoice_Amount__c);
                
                if(tpsData.Month__c==1){
                    wrapperInstance1.Jan=(InvoiceAmount+wrapperInstance1.Jan).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==2){
                    wrapperInstance1.Feb=(InvoiceAmount+wrapperInstance1.Feb).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==3){
                    wrapperInstance1.Mar=(InvoiceAmount+wrapperInstance1.Mar).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==4){
                    wrapperInstance1.Apr=(InvoiceAmount+wrapperInstance1.Apr).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==5){
                    wrapperInstance1.May=(InvoiceAmount+wrapperInstance1.May).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==6){
                    wrapperInstance1.Jun=(InvoiceAmount+wrapperInstance1.Jun).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==7){
                    wrapperInstance1.Jul=(InvoiceAmount+wrapperInstance1.Jul).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==8){
                    wrapperInstance1.Aug=(InvoiceAmount+wrapperInstance1.Aug).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==9){
                    wrapperInstance1.Sep=(InvoiceAmount+wrapperInstance1.Sep).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==10){
                    wrapperInstance1.Oct=(InvoiceAmount+wrapperInstance1.Oct).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==11){
                    wrapperInstance1.Nov=(InvoiceAmount+wrapperInstance1.Nov).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==12){
                    wrapperInstance1.Dec=(InvoiceAmount+wrapperInstance1.Dec).setScale(0, RoundingMode.HALF_UP);
                } 
            }
            
            
            else{
                
                if(tpsData.Month__c==1){
                    /*if(tpsData.Year__c == prevYear){
                        amountJan = amountJan+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Jan = amount2Jan+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Jan = amount3Jan+ InvoiceAmount;
                    }*/
                    /*if(tpsData.Year__c != prevYear2){
                        wrapperInstance2.Jan=((InvoiceAmount+wrapperInstance2.Jan).setScale(0, RoundingMode.HALF_UP));
                    }else{
                        if(InvoiceAmount != 0){
                            amountJan=((InvoiceAmount+amountJan).setScale(0, RoundingMode.HALF_UP));
                        }
                    }*/
                    wrapperInstance2.Jan=(InvoiceAmount+wrapperInstance2.Jan).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==2){
                    /*if(tpsData.Year__c == prevYear){
                        amountFeb = amountFeb+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Feb = amount2Feb+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Feb = amount3Feb+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Feb=(InvoiceAmount+wrapperInstance2.Feb).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==3){
                    /*if(tpsData.Year__c == prevYear){
                        amountMar = amountMar+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Mar = amount2Mar+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Mar = amount3Mar+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Mar=(InvoiceAmount+wrapperInstance2.Mar).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==4){
                    /*if(tpsData.Year__c == prevYear){
                        amountApr = amountApr+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Apr = amount2Apr+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Apr = amount3Apr+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Apr=(InvoiceAmount+ wrapperInstance2.Apr).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==5){
                    /*if(tpsData.Year__c == prevYear){
                        amountMay = amountMay+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2May = amount2May+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3May = amount3May+ InvoiceAmount;
                    }*/
                    wrapperInstance2.May=(InvoiceAmount+wrapperInstance2.May).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==6){
                    /*if(tpsData.Year__c == prevYear){
                        amountJun = amountJun+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Jun = amount2Jun+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Jun = amount3Jun+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Jun=(InvoiceAmount+wrapperInstance2.Jun).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==7){
                    /*if(tpsData.Year__c == prevYear){
                        amountJul = amountJul+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Jul = amount2Jul+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Jul = amount3Jul+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Jul=(InvoiceAmount+wrapperInstance2.Jul).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==8){
                    /*if(tpsData.Year__c == prevYear){
                        amountAug = amountAug+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Aug = amount2Aug+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Aug = amount3Aug+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Aug=(InvoiceAmount+wrapperInstance2.Aug).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==9){
                    /*if(tpsData.Year__c == prevYear){
                        amountSep = amountSep+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Sep = amount2Sep+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Sep = amount3Sep+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Sep=(InvoiceAmount+wrapperInstance2.Sep).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==10){
                    /*if(tpsData.Year__c == prevYear){
                        amountOct = amountOct+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Oct = amount2Oct+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Oct = amount3Oct+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Oct=(InvoiceAmount+wrapperInstance2.Oct).setScale(0, RoundingMode.HALF_UP);
                }
                else if(tpsData.Month__c==11){
                    /*if(tpsData.Year__c == prevYear){
                        amountNov = amountNov+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Nov = amount2Nov+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Nov = amount3Nov+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Nov=(InvoiceAmount+wrapperInstance2.Nov).setScale(0, RoundingMode.HALF_UP);
                }  
                else if(tpsData.Month__c==12){
                    /*if(tpsData.Year__c == prevYear){
                        amountDec = amountDec+InvoiceAmount;
                        
                    }if(tpsData.Year__c == prevYear1){
                        amount2Dec = amount2Dec+InvoiceAmount;
                    }if(tpsData.Year__c == prevYear2){
                        amount3Dec = amount3Dec+ InvoiceAmount;
                    }*/
                    wrapperInstance2.Dec=(InvoiceAmount+wrapperInstance2.Dec).setScale(0, RoundingMode.HALF_UP);
                }               
                
            }
        }
        System.debug('Mon2'+wrapperInstance2.Jan);
        //jan
        /*if(amount2Jan != 0){
            if(amount3Jan == 0) {
                wrapperInstance2.Jan = ((amountJan + amount2Jan)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Jan =  ((amountJan + amount2Jan + amount3Jan)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Jan == 0) {
                wrapperInstance2.Jan = amountJan.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Jan = ((amountJan + amount3Jan)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        //Feb
        if(amount2Feb != 0){
            if(amount3Feb == 0) {
                wrapperInstance2.Feb = ((amountFeb + amount2Feb)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Feb =  ((amountFeb + amount2Feb + amount3Feb)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Feb == 0) {
                wrapperInstance2.Feb = amountFeb.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Feb = ((amountFeb + amount3Feb)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Mar
        if(amount2Mar != 0){
            if(amount3Mar == 0) {
                wrapperInstance2.Mar= ((amountMar + amount2Mar)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Mar =  ((amountMar + amount2Mar + amount3Mar)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Mar == 0) {
                wrapperInstance2.Mar = amountMar.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Mar = ((amountMar + amount3Mar)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Apr
        if(amount2Apr != 0){
            if(amount3Apr == 0) {
                wrapperInstance2.Apr= ((amountApr + amount2Apr)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Apr =  ((amountApr + amount2Apr + amount3Apr)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Apr == 0) {
                wrapperInstance2.Apr = amountApr.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Apr = ((amountApr + amount3Apr)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //May
        if(amount2May != 0){
            if(amount3May == 0) {
                wrapperInstance2.May= ((amountMay + amount2May)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.May =  ((amountMay + amount2May + amount3May)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3May == 0) {
                wrapperInstance2.May = amountMay.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.May = ((amountMay + amount3May)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Jun
        if(amount2Jun != 0){
            if(amount3Jun == 0) {
                wrapperInstance2.Jun= ((amountJun + amount2Jun)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Jun =  ((amountJun + amount2Jun + amount3Jun)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Jun == 0) {
                wrapperInstance2.Jun = amountJun.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Jun = ((amountJun + amount3Jun)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Jul
        if(amount2Jul != 0){
            if(amount3Jul == 0) {
                wrapperInstance2.Jul= ((amountJul + amount2Jul)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Jul =  ((amountJul + amount2Jul + amount3Jul)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Jul == 0) {
                wrapperInstance2.Jul = amountJul.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Jul = ((amountJul + amount3Jul)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Aug
        if(amount2Aug != 0){
            if(amount3Aug == 0) {
                wrapperInstance2.Aug= ((amountAug + amount2Aug)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Aug =  ((amountAug + amount2Aug + amount3Aug)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Aug == 0) {
                wrapperInstance2.Aug = amountAug.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Aug = ((amountAug + amount3Aug)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Sep
        if(amount2Sep != 0){
            if(amount3Sep == 0) {
                wrapperInstance2.Sep= ((amountSep + amount2Sep)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Sep =  ((amountSep + amount2Sep + amount3Sep)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Sep == 0) {
                wrapperInstance2.Sep = amountSep.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Sep = ((amountSep + amount3Sep)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Oct
        if(amount2Oct != 0){
            if(amount3Oct == 0) {
                wrapperInstance2.Oct= ((amountOct + amount2Oct)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Oct =  ((amountOct + amount2Oct + amount3Oct)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Oct == 0) {
                wrapperInstance2.Oct = amountOct.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Oct = ((amountOct + amount3Oct)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Nov
        if(amount2Nov != 0){
            if(amount3Nov == 0) {
                wrapperInstance2.Nov= ((amountNov + amount2Nov)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Nov =  ((amountNov + amount2Nov + amount3Nov)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Nov == 0) {
                wrapperInstance2.Nov = amountNov.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Nov = ((amountNov + amount3Nov)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }
        
        //Dec
        if(amount2Dec != 0){
            if(amount3Dec == 0) {
                wrapperInstance2.Dec= ((amountDec + amount2Dec)/2).setScale(0, RoundingMode.HALF_UP);
            }
            else {
                wrapperInstance2.Dec =  ((amountDec + amount2Dec + amount3Dec)/3).setScale(0, RoundingMode.HALF_UP);
            }
        }else{
            if(amount3Dec == 0) {
                wrapperInstance2.Dec = amountDec.setScale(0, RoundingMode.HALF_UP);
            }else{
                wrapperInstance2.Dec = ((amountDec + amount3Dec)/2).setScale(0, RoundingMode.HALF_UP);
            }
        }*/
        
        /*if(amountJan == 0 ){
            wrapperInstance2.Jan = (wrapperInstance2.Jan/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Jan = ((wrapperInstance2.Jan+amountJan)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountFeb == 0 ){
            wrapperInstance2.Feb = (wrapperInstance2.Feb/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Feb = ((wrapperInstance2.Feb+amountFeb)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountMar == 0 ){
            wrapperInstance2.Mar= (wrapperInstance2.Mar/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Mar = ((wrapperInstance2.Mar+amountMar)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountApr == 0 ){
            wrapperInstance2.Apr = (wrapperInstance2.Apr/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Apr = ((wrapperInstance2.Apr+amountApr)/3).setScale(0, RoundingMode.HALF_UP);
        }
        
        if(amountMay == 0 ){
            wrapperInstance2.May = (wrapperInstance2.May/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.May = ((wrapperInstance2.May+amountMay)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountJun == 0 ){
            wrapperInstance2.Jun = (wrapperInstance2.Jun/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Jun = ((wrapperInstance2.Jun+amountJun)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountJul == 0 ){
            wrapperInstance2.Jul = (wrapperInstance2.Jul/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Jul = ((wrapperInstance2.Jul+amountJul)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountAug == 0 ){
            wrapperInstance2.Aug = (wrapperInstance2.Aug/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Aug = ((wrapperInstance2.Aug+amountAug)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountSep == 0 ){
            wrapperInstance2.Sep = (wrapperInstance2.Sep/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Sep = ((wrapperInstance2.Sep+amountSep)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountOct == 0 ){
            wrapperInstance2.Oct = (wrapperInstance2.Oct/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Oct = ((wrapperInstance2.Oct+amountOct)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountNov == 0 ){
            wrapperInstance2.Nov = (wrapperInstance2.Nov/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Nov = ((wrapperInstance2.Nov+amountNov)/3).setScale(0, RoundingMode.HALF_UP);
        }
        if(amountDec == 0 ){
            wrapperInstance2.Dec = (wrapperInstance2.Dec/2).setScale(0, RoundingMode.HALF_UP);
        }else{
            wrapperInstance2.Dec = ((wrapperInstance2.Dec+amountDec)/3).setScale(0, RoundingMode.HALF_UP);
        }*/
            
        if(storeMonth>=1){    
            wrapperInstance1.Jan=wrapperInstance1.Jan;
            }
        else{
            wrapperInstance1.Jan=0;
        }
        if(storeMonth>=2){    
            wrapperInstance1.Feb=wrapperInstance1.Jan+wrapperInstance1.Feb;
            }
        else{
            wrapperInstance1.Feb=0;
        }
        if(storeMonth>=3){    
            wrapperInstance1.Mar=wrapperInstance1.Feb+wrapperInstance1.Mar;
            }
        else{
            wrapperInstance1.Mar=0;
        }
        if(storeMonth>=4){    
            wrapperInstance1.Apr=wrapperInstance1.Mar+wrapperInstance1.Apr;
            
            }
        else{
            wrapperInstance1.Apr=0;
        }
         if(storeMonth>=5){    
            wrapperInstance1.May=wrapperInstance1.Apr+wrapperInstance1.May;
            
            }
        else{
            wrapperInstance1.May=0;
        }
         if(storeMonth>=6){    
            wrapperInstance1.Jun=wrapperInstance1.May+wrapperInstance1.Jun;
            
            }
        else{
            wrapperInstance1.Jun=0;
        }
         if(storeMonth>=7){    
            wrapperInstance1.Jul=wrapperInstance1.Jun+wrapperInstance1.Jul;
            
            }
        else{
            wrapperInstance1.Jul=0;
        }
         if(storeMonth>=8){    
            wrapperInstance1.Aug=wrapperInstance1.Jul+wrapperInstance1.Aug;        
            
            }
        else{
            wrapperInstance1.Aug=0;
        }
        if(storeMonth>=9){    
            wrapperInstance1.Sep=wrapperInstance1.Aug+wrapperInstance1.Sep;
            
            }
        else{
            wrapperInstance1.Sep=0;
        }
        if(storeMonth>=10){    
            wrapperInstance1.Oct=wrapperInstance1.Sep+wrapperInstance1.Oct;
            
            }
        else{
            wrapperInstance1.Oct=0;
        }
        if(storeMonth>=11){    
            wrapperInstance1.Nov=wrapperInstance1.Oct+wrapperInstance1.Nov;
            
            }
        else{
            wrapperInstance1.Nov=0;
        }
        if(storeMonth>=12){    
            wrapperInstance1.Dec=wrapperInstance1.Nov+wrapperInstance1.Dec;
                        
            }
        else{
            wrapperInstance1.Dec=0;
        }
            
        
        
            wrapperInstance2.Jan=wrapperInstance2.Jan;
            wrapperInstance2.Feb=wrapperInstance2.Jan+wrapperInstance2.Feb;
            wrapperInstance2.Mar=wrapperInstance2.Feb+wrapperInstance2.Mar;
            wrapperInstance2.Apr=wrapperInstance2.Mar+wrapperInstance2.Apr;
            wrapperInstance2.May=wrapperInstance2.Apr+wrapperInstance2.May;
            wrapperInstance2.Jun=wrapperInstance2.May+wrapperInstance2.Jun;
            wrapperInstance2.Jul=wrapperInstance2.Jun+wrapperInstance2.Jul;
            wrapperInstance2.Aug=wrapperInstance2.Jul+wrapperInstance2.Aug;        
            wrapperInstance2.Sep=wrapperInstance2.Aug+wrapperInstance2.Sep;
            wrapperInstance2.Oct=wrapperInstance2.Sep+wrapperInstance2.Oct;
            wrapperInstance2.Nov=wrapperInstance2.Oct+wrapperInstance2.Nov;
            wrapperInstance2.Dec=wrapperInstance2.Nov+wrapperInstance2.Dec;

        
        wrapperInstance2.Jan = (wrapperInstance2.Jan/yearCount1).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Feb = (wrapperInstance2.Feb/yearCount2).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Mar = (wrapperInstance2.Mar/yearCount3).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Apr = (wrapperInstance2.Apr/yearCount4).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.May = (wrapperInstance2.May/yearCount5).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Jun = (wrapperInstance2.Jun/yearCount6).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Jul = (wrapperInstance2.Jul/yearCount7).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Aug = (wrapperInstance2.Aug/yearCount8).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Sep = (wrapperInstance2.Sep/yearCount9).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Oct = (wrapperInstance2.Oct/yearCount10).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Nov = (wrapperInstance2.Nov/yearCount11).setScale(0, RoundingMode.HALF_UP);
        wrapperInstance2.Dec = (wrapperInstance2.Dec/yearCount12).setScale(0, RoundingMode.HALF_UP);
        
        System.debug('Mon'+wrapperInstance1);
        
        if(wrapperInstance1.Dec!=0){
            wrapperInstance3.Dec=wrapperInstance1.Dec-wrapperInstance2.Dec;
            if(wrapperInstance2.Dec==0){
                wrapperInstance2.Dec=1;
                wrapperInstance4.Dec=((wrapperInstance3.Dec/wrapperInstance2.Dec)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Dec=0;
            }
            else{
                wrapperInstance4.Dec=((wrapperInstance3.Dec/wrapperInstance2.Dec)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Nov!=0){
            wrapperInstance3.Nov=wrapperInstance1.Nov-wrapperInstance2.Nov;
            if(wrapperInstance2.Nov==0){
                wrapperInstance2.Nov=1;
                wrapperInstance4.Nov=((wrapperInstance3.Nov/wrapperInstance2.Nov)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Nov=0;
            }
            else{
                wrapperInstance4.Nov=((wrapperInstance3.Nov/wrapperInstance2.Nov)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Oct!=0){
            wrapperInstance3.Oct=wrapperInstance1.Oct-wrapperInstance2.Oct;
            if(wrapperInstance2.Oct==0){
                wrapperInstance2.Oct=1;
                wrapperInstance4.Oct=((wrapperInstance3.Oct/wrapperInstance2.Oct)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Oct=0;
            }
            else{
                wrapperInstance4.Oct=((wrapperInstance3.Oct/wrapperInstance2.Oct)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Sep!=0){
            wrapperInstance3.Sep=wrapperInstance1.Sep-wrapperInstance2.Sep;
            if(wrapperInstance2.Sep==0){
                wrapperInstance2.Sep=1;
                wrapperInstance4.Sep=((wrapperInstance3.Sep/wrapperInstance2.Sep)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Sep=0;
            }
            else{
                wrapperInstance4.Sep=((wrapperInstance3.Sep/wrapperInstance2.Sep)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Aug!=0){
            wrapperInstance3.Aug=wrapperInstance1.Aug-wrapperInstance2.Aug;
            if(wrapperInstance2.Aug==0){
                wrapperInstance2.Aug=1;
                wrapperInstance4.Aug=((wrapperInstance3.Aug/wrapperInstance2.Aug)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Aug=0;
            }
            else{
                wrapperInstance4.Aug=((wrapperInstance3.Aug/wrapperInstance2.Aug)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Jul!=0){
            wrapperInstance3.Jul=wrapperInstance1.Jul-wrapperInstance2.Jul;
            if(wrapperInstance2.Jul==0){
                wrapperInstance2.Jul=1;
                wrapperInstance4.Jul=((wrapperInstance3.Jul/wrapperInstance2.Jul)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Jul=0;
            }
            else{
                wrapperInstance4.Jul=((wrapperInstance3.Jul/wrapperInstance2.Jul)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Jun!=0){
            wrapperInstance3.Jun=wrapperInstance1.Jun-wrapperInstance2.Jun;
            if(wrapperInstance2.Jun==0){
                wrapperInstance2.Jun=1;
                wrapperInstance4.Jun=((wrapperInstance3.Jun/wrapperInstance2.Jun)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Jun=0;
            }
            else{
                wrapperInstance4.Jun=((wrapperInstance3.Jun/wrapperInstance2.Jun)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.May!=0){
            wrapperInstance3.May=wrapperInstance1.May-wrapperInstance2.May;
            if(wrapperInstance2.May==0){
                wrapperInstance2.May=1;
                wrapperInstance4.May=((wrapperInstance3.May/wrapperInstance2.May)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.May=0;
            }
            else{
                wrapperInstance4.May=((wrapperInstance3.May/wrapperInstance2.May)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Apr!=0){
            wrapperInstance3.Apr=wrapperInstance1.Apr-wrapperInstance2.Apr;
            if(wrapperInstance2.Apr==0){
                wrapperInstance2.Apr=1;
                wrapperInstance4.Apr=((wrapperInstance3.Apr/wrapperInstance2.Apr)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Apr=0;
            }
            else{
                wrapperInstance4.Apr=((wrapperInstance3.Apr/wrapperInstance2.Apr)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Mar!=0){
            wrapperInstance3.Mar=wrapperInstance1.Mar-wrapperInstance2.Mar;
            if(wrapperInstance2.Mar==0){
                wrapperInstance2.Mar=1;
                wrapperInstance4.Mar=((wrapperInstance3.Mar/wrapperInstance2.Mar)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Mar=0;
            }
            else{
                wrapperInstance4.Mar=((wrapperInstance3.Mar/wrapperInstance2.Mar)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Feb!=0){
            
            wrapperInstance3.Feb=wrapperInstance1.Feb-wrapperInstance2.Feb;
            if(wrapperInstance2.Feb==0){
                wrapperInstance2.Feb=1;
                wrapperInstance4.Feb=((wrapperInstance3.Feb/wrapperInstance2.Feb)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Feb=0;
            }
            else{
                wrapperInstance4.Feb=((wrapperInstance3.Feb/wrapperInstance2.Feb)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        if(wrapperInstance1.Jan!=0){
            wrapperInstance3.Jan=wrapperInstance1.Jan-wrapperInstance2.Jan;
            if(wrapperInstance2.Jan==0){
                wrapperInstance2.Jan=1;
                wrapperInstance4.Jan=((wrapperInstance3.Jan/wrapperInstance2.Jan)).setScale(4,System.RoundingMode.HALF_UP);
                wrapperInstance2.Jan=0;
            }
            else{
                wrapperInstance4.Jan=((wrapperInstance3.Jan/wrapperInstance2.Jan)).setScale(4,System.RoundingMode.HALF_UP);
            }
        }
        
        responseData.add(wrapperInstance1);
        responseData.add(wrapperInstance2);
        responseData.add(wrapperInstance3);
        responseData.add(wrapperInstance4);
        System.debug('MoN900'+wrapperInstance3.Dec);
        responseWrapper wrapperInst=new responseWrapper();
        if(TPSTypes=='TPS' && regionType !='North America'){
            
            List<Direct_Dealer_Group__mdt> dealerlist = [select Parent_Dealer__c from Direct_Dealer_Group__mdt ];
            String SAP = ([Select id,SAP_ID__c from Account where id=:SelectedDist].SAP_ID__c);
            Integer count = 0;
            for( Direct_Dealer_Group__mdt meta : dealerlist){
                system.debug('DIST :'+SAP);
                system.debug(' PARENT DEALER:'+meta.Parent_Dealer__c);
                if(SAP==meta.Parent_Dealer__c){
                    count++;
                }
            }
            system.debug('Count:'+count);
            Boolean exceptionDLR;
            if(count==0){
                exceptionDLR= false;
            }
            else{
                exceptionDLR= true;
            }
        try{
            system.debug('exceptionDLR'+exceptionDLR );
            if(exceptionDLR==false){
           system.debug('INSIDE IF');
           wrapperInst.distributorYTDPoints = string.valueof([select TPS__c from KPI__c where Customer__c=:SelectedDist and year__c =:YearSelected and Period__C = 'YTD' and Month__c=:kpiInst and Region__c=:regionType].TPS__c);
                 }
         else
            {
                system.debug('INSIDE ELSE');
            wrapperInst.distributorYTDPoints = string.valueof([select TPS__c from KPI__c where Customer__c=:SelectedDist and year__c =:YearSelected and Period__C = 'YTD' and Month__c=:kpiInst and Region__c=:regionType and isPartOfPRP__c=false].TPS__c);
                
            }
        
        }
            
        catch(Exception e){
            //wrapperInst.distributorYTDPoints = string.valueof([select TPS_Score__c from KPI__c where Customer__c=:SelectedDist and year__c =:YearSelected-1 and Period__C = 'YTD' and Month__c=:kpiInst and Region__c=:regionType].TPS_Score__c);
        }
        }
        wrapperInst.TPSDetails=responseData;
        wrapperInst.KPIranges=rangedetails;
        System.debug('Mon4'+wrapperInst);
        System.debug('dis'+DistAvg);
        System.debug('wrapperInst.distributorYTDPoints'+wrapperInst.distributorYTDPoints);
        System.debug('wrapperInst.DistributorAvg'+wrapperInst.DistributorAvg);
        
        if(wrapperInst.distributorYTDPoints == null){
            wrapperInst.distributorYTDPoints='0.0';
        }
        If(DistAvg!=null){
            wrapperInst.DistributorAvg=DistAvg;
        }
        else{
            wrapperInst.DistributorAvg='0.0'; 
        }
        /*If(NatAvg!=null){
            wrapperInst.NationalAvg=NatAvg.substring(0,NatAvg.indexOf('.')+2);
        }
        else{
            wrapperInst.NationalAvg='0.0'; 
        }*/
        If(RegAvg!=null){
            wrapperInst.RegionAvg=RegAvg;
        }
        else{
            wrapperInst.RegionAvg='0.0'; 
        }
        System.debug('Average'+wrapperInst.DistributorAvg);
        System.debug('response Data'+responseData);
        return wrapperInst;
    }
    public class wrapperClass{
        @AuraEnabled public List<String> YearList{get;set;}
        @AuraEnabled public List<Account> DistList{get;set;}
        @AuraEnabled public list<Account>DistName{get;set;}
        @AuraEnabled public list<String>DistId{get;set;}
        @AuraEnabled public String partnerType{get;set;}
        public wrapperClass(List<String> YearLists,List<Account> DistLists,list<Account>DistName, list<String> DistId,string partnerType){
            this.YearList=YearLists;
            this.DistList=DistLists; 
            this.DistName=DistName;
            this.DistId=DistId; 
            this.partnerType = partnerType;
        }
    }
    public class TPSDetails{
        @AuraEnabled public String Duration{get;set;}
        @AuraEnabled public String format{get;set;}
        @AuraEnabled public Decimal Jan{get;set;}
        @AuraEnabled public Decimal Feb{get;set;}
        @AuraEnabled public Decimal Mar{get;set;}
        @AuraEnabled public Decimal Apr{get;set;}
        @AuraEnabled public Decimal May{get;set;}
        @AuraEnabled public Decimal Jun{get;set;}
        @AuraEnabled public Decimal Jul{get;set;}
        @AuraEnabled public Decimal Aug{get;set;}
        @AuraEnabled public Decimal Sep{get;set;}
        @AuraEnabled public Decimal Oct{get;set;}
        @AuraEnabled public Decimal Nov{get;set;}
        @AuraEnabled public Decimal Dec{get;set;}
        
    }
    public class responseWrapper{
        @AuraEnabled public List<TPSDetails> TPSDetails{get;set;}
        @AuraEnabled public List<KPI_Range_Settings__c> KPIranges{get;set;}
        @AuraEnabled public String DistributorAvg{get;set;}
        @AuraEnabled public String NationalAvg{get;set;}
        @AuraEnabled public String RegionAvg{get;set;}
        @AuraEnabled public String distributorYTDPoints{get;set;}
    }
    /*
    public static void fakeMethod(){
    Integer i = 0;
        
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
    */
    public static integer returnYearCount(Date serviceStartDate, integer monthValue, Integer selectYear){
        integer yearCount;
        integer prevYear = selectYear - 1;
        integer prevYear1 = selectYear - 2;
        integer prevYear2 = selectYear - 3;
        if(serviceStartDate == null) {
            yearCount = 3;
        }
        else if(serviceStartDate.year()<prevYear2) {
            yearCount = 3;
        }
        else if(serviceStartDate.year() == prevYear2) {
            if(serviceStartDate.month() <= monthValue ) {
                yearCount = 3;
            }
            else {
                yearCount = 2;
            }
        }
        else if(serviceStartDate.year()<prevYear1) {
            yearCount = 2;
        }
        else if(serviceStartDate.year() == prevYear1) {
            if(serviceStartDate.month() <= monthValue ) {
                yearCount = 2;
            }
            else {
                yearCount = 1;
            }
        }
        else if(serviceStartDate.year()<prevYear) {
            yearCount = 1;
        }
        else if(serviceStartDate.year() == prevYear) {
            if(serviceStartDate.month() <= monthValue ) {
                yearCount = 1;
            }
            else {
                yearCount = 0;
            }
        }
        return yearCount;
        
    }
    
}