public class YearOverYearController {
    Public contact conRec{get;set;}
    public Id ConRecId;
    public List<AggregateResult> YearToYearRec{get;set;}
    public List<string> getLastTwelveMonths{get;set;} 
    public list<string> options{get;set;}
    public map<String,integer>MrnCountRecordMap{get;set;}
    public map<String,integer> PhysicianChargeRecordMap{get;set;}
    public map<String , integer>PhyFinal {get;set;}
    public map<String , integer>mrnFinal {get;set;}
    Public List<String> optionsUp {get;set;}        
    Public List<String> optionsDown {get;set;} 
    public YearOverYearController(ApexPages.StandardController controller) { 
        
        
        MrnCountRecordMap = new map<String,integer>();
        PhysicianChargeRecordMap = new map<String,integer>();
        map<integer,integer> MonthYearRecordMap = new map<integer,integer>();
        map<integer,string> monthsMap = new map<integer,string>{1=> 'Jan', 2=> 'Feb', 3=> 'March', 4=> 'April', 5=> 'May', 6=> 'June', 7=> 'July', 8=> 'Aug', 9=> 'Sep', 10=> 'Oct', 11=> 'Nov', 12=> 'Dec'};
            map<string,integer> monthNoMap = new map<string,integer>{'Jan'=> 1, 'Feb'=> 2, 'March'=> 3, 'April'=> 4, 'May'=> 5, 'June'=> 6, 'July'=> 7, 'Aug'=> 8, 'Sep'=> 9, 'Oct'=> 10, 'Nov'=> 11, 'Dec'=>12 };
                Integer currentMonth = date.today().Month();
        system.debug( 'current month ' +currentMonth);
        
        options = new list<string>();
        
        //add last 24 months
        for(integer i=(currentMonth-23); i<=currentMonth; i++){
            //cheking if i < 1 then this month is of past year
            if(i<1 && i>-12){
                //adding options
                system.debug(monthsMap.get(i+12) + ' ' + string.valueOf(date.today().year() - 1));
                options.add(monthsMap.get(i+12) + ' ' + string.valueOf(date.today().year() - 1));
            }
            else if(i<-11){
                system.debug(monthsMap.get(i+24) + ' ' + string.valueOf(date.today().year() - 2));
                options.add(monthsMap.get(i+24) + ' ' + string.valueOf(date.today().year() - 2));
            }
            else{
                system.debug(monthsMap.get(i) + ' ' + string.valueOf(date.today().year()));
                options.add(monthsMap.get(i) + ' ' + string.valueOf(date.today().year()));
            }
            //system.debug(options);
        }
        optionsUp = new List<String>();        
        optionsDown = new List<String>();        
        for(integer i = 0; i<options.size(); i++){            
            if(i>11){                
                optionsUp.add(options[i]);   
                system.debug('optionsUp'+optionsUp);
            }            
            else{                
                optionsDown.add(options[i]); 
                system.debug('optionsDown'+optionsDown);
            }    
        }
        
        
        
        ConRecId = ApexPages.currentPage().getParameters().get('id');
        YearToYearRec = [SELECT CALENDAR_MONTH(App_Date__c) CalMonth,CALENDAR_YEAR(App_Date__c) Calyear, SUM(MRN_Count__c) MRNCountOfMonth,Sum(Physician_Charge__c) PhysicianChargeOfMonth
                         FROM YEAR_OVER_YEAR__c
                         GROUP BY CALENDAR_MONTH(App_Date__c),CALENDAR_YEAR(App_Date__c) Order by CALENDAR_YEAR(App_Date__c) desc,CALENDAR_MONTH(App_Date__c) desc limit 24];
        system.debug('Year'+YearToYearRec);
        For(AggregateResult YearRecord:YearToYearRec){
            //MrnCountRecordMap.put((integer)monthsMap.get(integer.ValueOf(YearRecord.get('CalMonth')))+(integer)YearRecord.get('Calyear'),(integer)YearRecord.get('MRNCountOfMonth')); 
            // PhysicianChargeRecordMap.put((integer)YearRecord.get('CalMonth')+(integer)YearRecord.get('Calyear'),(integer)YearRecord.get('PhysicianChargeOfMonth')); 
            string MonthNyearString = monthsMap.get((integer)YearRecord.get('CalMonth'))+' '+((integer)YearRecord.get('Calyear'));
            PhysicianChargeRecordMap.put(MonthNyearString,(integer)integer.ValueOf(YearRecord.get('PhysicianChargeOfMonth')));
            MrnCountRecordMap.put(MonthNyearString,(integer)integer.ValueOf(YearRecord.get('MRNCountOfMonth')));
        }
        PhyFinal = new map<String , integer>();
        mrnFinal = new map<String , integer>();
        For(string Opt: OPtions){
            if(PhysicianChargeRecordMap.containsKey(opt)){
                
                PhyFinal.put(opt,PhysicianChargeRecordMap.get(opt));
                mrnFinal.put(opt,MrnCountRecordMap.get(opt));
            }
            else{
                PhyFinal.put(opt,0);
                mrnFinal.put(opt,0);
                system.debug('PhyFinal'+PhyFinal);
            }
            system.debug('optttvalue '+opt +PhysicianChargeRecordMap.get(opt));   
        }
        system.debug('PhyFinal2+++++++++++++'+PhyFinal.get('Aug 2019'));
        
        //system.debug('MrnCountRecordMap'+MrnCountRecordMap);
        system.debug('PhysicianChargeRecordMap'+PhysicianChargeRecordMap);
    }

}