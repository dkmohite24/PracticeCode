public with sharing class CustomPaginationVFController {

    //default page size
    private static final Integer PAGE_SIZE = 10;
    
    
    //pagination information
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    
    

    /*
    *   set controller
    */
    public List<CCWRow> tRecords{get;set;}
    
    
    
    /*
    *   constructor
    */
    public CustomPaginationVFController ()
    {
        //init variable
        this.tRecords = new List<CCWRow>();
        
        //set initial page
        this.page = 1;
        
        //load records
        getContacts();
                
    }
    
    
    /*
    *   advance to next page
    */
    public void doNext(){
        
        if(getHasNext()){
            this.page++;
            getContacts();
        }

    }
    
    
    /*
    *   advance to previous page
    */
    public void doPrevious(){
        
        if(getHasPrevious()){
            this.page--;
            getContacts();
        }
                
    }
    
    /*
    *   returns whether the previous page exists
    */
    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
    *   returns whether the next page exists
    */
    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }
    
    
    
    /*
    *   return current page of records
    */
    public void getContacts(){
        
        //calculate range of records for capture
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        
        //clear container for records displayed
        this.tRecords.clear();
                
        
        //cycle through
        for(Contact c : [SELECT Id, FirstName, LastName, Title, Phone, MobilePhone, Email, 
                            MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity 
                            FROM Contact 
                            ORDER BY LastName ASC 
                            LIMIT 50000]){
        
            //capture records within the target range
            if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   
           
                this.tRecords.add( new CCWRow(c, false) );
            }
            
            //count the total number of records
            this.totalRecords++;
        
        }
        
        
        //calculate total pages
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
        //adjust start index e.g. 1, 11, 21, 31
        this.startIdx++;
        
        
        //adjust end index
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }
     
        
        //display resource usage
        System.Debug(LoggingLevel.WARN,'****** LIMIT query rows: '+Limits.getQueryRows()+' / '+Limits.getLimitQueryRows());
        System.Debug(LoggingLevel.WARN,'****** LIMIT heap size: '+Limits.getHeapSize()+' / '+Limits.getLimitHeapSize());
        System.Debug(LoggingLevel.WARN,'****** LIMIT cpu time: '+Limits.getCpuTime()+' / '+Limits.getLimitCpuTime());
       // System.Debug(LoggingLevel.WARN,'****** LIMIT script statements: '+Limits.getScriptStatements()+' / '+Limits.getLimitScriptStatements());
        
    }
        
    
    /*
    *   helper class that represents a row
    */
    public with sharing class CCWRow{
        
        public Contact tContact{get;set;}
        public Boolean IsSelected{get;set;}
        
        public CCWRow(Contact c, Boolean s){
            this.tContact=c;
            this.IsSelected=s;
        }
        
    } 

}