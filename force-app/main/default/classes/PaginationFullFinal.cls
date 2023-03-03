public class PaginationFullFinal {
    public integer PageSize{set;get;}
    public integer page{get;set;}
    public list<contact> contactList {get;set;}
    public Integer totalPages{get;set;}
    public List<SelectOption> options{get;set;}
    public list<contact> finallist{get;set;}
    string FinalSoql{get;set;}
    string FirstId{get;set;}
    String LastId{get;set;}
    integer TotalRecords{get;set;}
    
    
    public PaginationFullFinal()
    {
        finallist= New list<contact>();
        page = 1;
        pagesize = 10;
        System.debug('Page'+page);
        FinalSoql = 'select name, department, fax, title, phone from contact  order by id Asc';
        getContacts();
    }
    public void IsNext()
    {
        Finalsoql = 'select name, department, fax, title, phone from contact where Id >:LAstId order by id Asc';
        page++;
        System.debug('Page'+page);
        getContacts();
    }
    public void IsPrevious()
    {
        
        Finalsoql = 'select name, department, fax, title, phone from contact where Id <:FirstId order by id desc';
        page--;
        FinalSoql= FinalSoql + ' limit :pagesize';
        System.debug(FinalSoql);
        finallist= New list<contact>();
        finallist = database.query(FinalSoql);
        list<Contact> reversedCon = New list<contact>();
        for(integer i=finallist.size()-1;i>=0;i--){
            reversedCon.Add(finallist[i]);
        }
        finallist = reversedCon;
        system.debug(finallist);
        integer size1 = finallist.size();
        FirstId = finallist[0].id;
        LastId = finallist[size1-1].id;
        
        TotalRecords = [SELECT count() FROM Contact];
        totalPages = TotalRecords/pageSize;
        System.debug('Page'+page);
        
    }
    public void IslastPage()
    {
        
        FinalSoql = 'select name, department, fax, title, phone from contact  order by id Desc';
        page = totalPages;
        getContacts();
        System.debug('Page'+page);
        System.debug('FnalSoql lAst'+FinalSoql);
        
        
        
    }
    public void IsFirstPage()
    { 
        
        
        FinalSoql = 'select name, department, fax, title, phone from contact  order by id Asc';
        page = 1;
        System.debug('Page'+page);
        getContacts();
        
    }
    public Boolean getHasPrevious()
    {
        if(page>1)
        {
            return true;
        }
        else{
            return false;
        }
    }
    
    public boolean getHasNext()
    {
        if(page<totalPages)
            return true;
        else
            return false;
    }
    
    Public List<contact> getContacts()
    {
        
        System.debug('Page'+page);
        
        FinalSoql= FinalSoql + ' limit :pagesize';
        System.debug(FinalSoql);
        finallist= New list<contact>();
        finallist = database.query(FinalSoql);
        system.debug(finallist);
        integer size1 = finallist.size();
        FirstId = finallist[0].id;
        LastId = finallist[size1-1].id;
        
        TotalRecords = [SELECT count() FROM Contact];
        totalPages = TotalRecords/pageSize;
        
        return finallist;
    }
    public pageReference refresh()
    {	
        System.debug('Contactlist+++++'+totalPages);
        System.debug('finallist++++++'+finallist);
        getContacts();
        return null;
    }
    public void pickPAgeSize(){
        page =1;
        System.debug('page+++++'+page);
        FinalSoql = 'select name, department, fax, title, phone from contact  order by id Asc';
        getContacts();
        System.debug('page+++++'+page);
    }
    public List<SelectOption> getItems()
    {	
        options = new List<SelectOption>();
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('20','20'));
        options.add(new SelectOption('30','30'));
        options.add(new SelectOption('40','40'));
        return options;
        
    }
}