public class PaginationWithCustomCNTRL {
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public integer pageSize{get;set;}
    
    private list<contact>CurrentItrationRecord{get;set;}
    public PaginationWithCustomCNTRL(){
      list<contact> AllRetriveContactRecords =  new list<contact>();
        AllRetriveContactRecords =[select id, FirstName,lastName,title,email from contact order by Id Asc];
    }
    public list<contact> AllRetriveContactRecords(){
        page = 1;
        pageSize = 10;
        Return [select id, FirstName,lastName,title,email from contact order by Id Asc];
    }
    public void doNext(){
        
        if(getHasNext()){
            page++;
            Getcontacts();
        }
        
    }
    public void doPrevious(){
        
        if(getHasPrevious()){
            page--;
            getContacts();
        }
        
    }
    public Boolean getHasNext(){
        if(page<totalPages){
            return true;
        }
        else{
            return false;
        }
    }
    public Boolean getHasPrevious(){
        if(page>1){
            return true;
        }
        else{
            return false;
        }
    }
    
    
    public void Getcontacts(){
        
        startIdx = (page - 1)*pageSize;
        endIdx = page*PAgeSize;
        Integer TotalRecords = 0;
        list<Contact> RetrivedContact = AllRetriveContactRecords();
        for(Contact Con: RetrivedContact){
            If(totalRecords<=startIdx && totalRecords>endIdx){
                CurrentItrationRecord.Add(Con);
            }
            TotalRecords++;
        }
        totalPages = TotalRecords/pageSize;
    } 
    
}