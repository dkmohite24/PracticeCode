public with sharing class inlinecontroller {
    Public contact conRec{get;set;}
    public Id ConRecId;
    public List<AggregateResult> YearToYearRec{get;set;}
    public List<string> getLastTwelveMonths{get;set;} 
    public list<string> optionsDown{get;set;}
    public list<string> optionsUp{get;set;}
    public List<integer> MrnCountUp{get;set;}
    public List<integer> PhysicianChargeup{get;set;}
    public List<integer> MrnCountDown{get;set;}
    public List<integer> PhysicianChargeDown{get;set;}
    public Integer MRNTotalup{get;set;}
    public Integer MRNTotalDown{get;set;}
    public integer PhysicianChargeupTotal{get;set;}
    public integer PhysicianChargeDownTotal{get;set;}
    public List<Integer> physicianChargeMinus {get;set;}
    public List<Integer> mrnCountMinus {get;set;}
    // public map<String,integer> PhysicianChargeRecordMap{get;set;}
    public inlinecontroller(ApexPages.StandardController controller) { 
        
        
        List<integer>MrnCount = new List<integer>();
        List<integer> PhysicianCharge = new List<integer>();
        MrnCountup = new List<integer>();
        PhysicianChargeup = new List<integer>();
        MrnCountDown = new List<integer>();
        PhysicianChargeDown = new List<integer>();
        map<String,integer> MrnCountRecordMap = new map<String,integer>();
        OptionsDown = new list<string>();
        OptionsUp = new list<string>();
        physicianChargeMinus = new List<Integer>();
        mrnCountMinus= new List<Integer>();
        list<string>OptionsDown1 = new list<string>();
        list<string>OptionsUp1 = new list<string>();
        DateTime d = datetime.now();        
        String monthName= d.format('MMM');      
        Integer yearName = d.year(); 
        
        for(Integer i = 0; i<24; i++) 
        {            
            string s1=string.valueof(yearName).right(2);
            DateTime dDate = d.addmonths(-i);          
            monthname = dDate.format('MMM');   
            if(monthname == 'jan'){            
                yearName = yearName - 1;       
            }           
            If(i<=11){
                OptionsUp1.add(monthName +' '+ s1);
                system.debug('OptionsDown+++++'+OptionsDown);
            }
            else{
                OptionsDown1.add(monthName +' '+ s1);
                system.debug('Optionsup++++++'+OptionsUp);
            }
        }
        for(Integer i = OptionsDown1.size() - 1; i >= 0; i--){
            OptionsDown.add(OptionsDown1[i]);
            OptionsUp.add(OptionsUp1[i]);
            system.debug('OptionsDown'+Optionsup);
            system.debug('OptionsDown'+OptionsDown);
        }
        /*
// PhysicianChargeRecordMap = new map<String,integer>();
//  map<integer,integer> MonthYearRecordMap = new map<integer,integer>();
map<integer,string> monthsMap = new map<integer,string>{1=> 'Jan', 2=> 'Feb', 3=> 'March', 4=> 'April', 5=> 'May', 6=> 'June', 7=> 'July', 8=> 'Aug', 9=> 'Sep', 10=> 'Oct', 11=> 'Nov', 12=> 'Dec'};
map<string,integer> monthNoMap = new map<string,integer>{'Jan'=> 1, 'Feb'=> 2, 'March'=> 3, 'April'=> 4, 'May'=> 5, 'June'=> 6, 'July'=> 7, 'Aug'=> 8, 'Sep'=> 9, 'Oct'=> 10, 'Nov'=> 11, 'Dec'=>12 };
Integer currentMonth = date.today().Month();
system.debug( 'current month ' +currentMonth);

options = new list<string>();
list<string>Last12Months = new list<string>();
//add last 24 months
for(integer i=(currentMonth-24); i<=currentMonth; i++){
//cheking if i < 1 then this month is of past year
if(i<1 && i>-12){
//adding options
system.debug(monthsMap.get(i+12) + ' ' + string.valueOf(date.today().year() - 1));
Last12Months.add(monthsMap.get(i+12) + ' ' + string.valueOf(date.today().year() - 1));
}
else if(i<-11){
system.debug(monthsMap.get(i+24) + ' ' + string.valueOf(date.today().year() - 2));
options.add(monthsMap.get(i+24) + ' ' + string.valueOf(date.today().year() - 2));
}
else{
system.debug(monthsMap.get(i) + ' ' + string.valueOf(date.today().year()));
options.add(monthsMap.get(i) + ' ' + string.valueOf(date.today().year()));
}
system.debug(Last12Months);
}

system.debug('last month***'+options);
string MonthNyear = options[0];
String delimiter = ' ';
String LastMonth = MonthNyear.substringBefore(delimiter); // 'this'
integer LastYearInt = Integer.valueOf(MonthNyear.substringAfter(delimiter));
system.debug('LastMonth**'+LastMonth);
system.debug('LastYear**'+LastYearInt);
integer LastmonthInt = monthNoMap.get(LastMonth);
system.debug('ls'+LastmonthInt);*/
        ConRecId = ApexPages.currentPage().getParameters().get('id');
        YearToYearRec = [SELECT CALENDAR_MONTH(App_Date__c) CalMonth,CALENDAR_YEAR(App_Date__c) Calyear, SUM(MRN_Count__c) MRNCountOfMonth,Sum(Physician_Charge__c) PhysicianChargeOfMonth
                         FROM YEAR_OVER_YEAR__c
                         GROUP BY CALENDAR_MONTH(App_Date__c),CALENDAR_YEAR(App_Date__c) Order by CALENDAR_YEAR(App_Date__c) desc,CALENDAR_MONTH(App_Date__c) desc limit 24];
        system.debug('Year'+YearToYearRec.size());
        For(AggregateResult YearRecord:YearToYearRec){
            // MrnCountRecordMap.put((String)String.ValueOf(YearRecord.get('CalMonth'))+(integer)integer.ValueOf(YearRecord.get('Calyear')),(integer)integer.ValueOf(YearRecord.get('MRNCountOfMonth'))); 
            // +(integer)integer.ValueOf(YearRecord.get('Calyear'))            
            //   PhysicianChargeRecordMap.put((String)monthsMap.get(String.ValueOf(YearRecord.get('CalMonth'))),(integer)integer.ValueOf(YearRecord.get('PhysicianChargeOfMonth')));          
            //	System.debug('PhysicianChargeRecordMap'+PhysicianChargeRecordMap);
            //  string MonthNyearString = monthsMap.get((integer)YearRecord.get('CalMonth'))+((integer)YearRecord.get('Calyear'));
            //  PhysicianChargeRecordMap.put(MonthNyearString,(integer)integer.ValueOf(YearRecord.get('PhysicianChargeOfMonth')));
            //system.debug('PhysicianChargeRecordMap'+PhysicianChargeRecordMap);
            // system.debug('MonthNyearString'+MonthNyearString);
            
            mrnCount.add((integer)integer.ValueOf(YearRecord.get('MRNCountOfMonth')));
            PhysicianCharge.add((integer)integer.ValueOf(YearRecord.get('PhysicianChargeOfMonth')));
            
        } 
        PhysicianChargeupTotal = 0;
        MRNTotalUp= 0;
        PhysicianChargeDownTotal = 0;
        MRNTotalDown= 0;
        for(Integer i = mrnCount.size() - 1; i >= 0; i--){
            if(i<12){
                
                mrnCountUp.add(mrnCount[i]);
                PhysicianChargeUp.add(PhysicianCharge[i]);
                system.debug('OptionsDown'+PhysicianChargeUp);
                MRNTotalUp = MRNTotalUp+mrnCount[i];
                PhysicianChargeupTotal = PhysicianChargeupTotal + PhysicianCharge[i];
                
            }
            
            Else{
                mrnCountDown.add(mrnCount[i]);
                PhysicianChargeDown.add(PhysicianCharge[i]);
                system.debug('OptionsDown'+PhysicianChargeDown);
                MRNTotalDown = MRNTotalDown+mrnCount[i];
                PhysicianChargeDownTotal = PhysicianChargeDownTotal + PhysicianCharge[i];
                
            }
        }
        for(integer i = 0; i<12;i++)
        {
            physicianChargeMinus.add(physicianChargeUp[i] - physicianChargeDown[i]);
            mrnCountMinus.Add(mrnCountUp[i] - mrnCountDown[i]);
        }
        system.debug('physicianChargeMinus'+physicianChargeMinus);
        system.debug('mrnCountMinus'+mrnCountMinus);
    }
}