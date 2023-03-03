/*
        Name          :    paginationforcontactscontroller
        Author        :    Anavclouds (Dhananjay mohite)
        Date          :    10th April 21
        Description   :    This class is created to set up pagination for contacts object.
        
        */
        
        public class paginationforcontactscontroller{
            public Integer startIdx{get;set;}
            public Integer totalPages{get;set;}
            public Integer endIdx{get;set;}
            public Integer page{get;set;}
            public list<contact> contactList {get;set;}
            Public Integer Pagesize{get;set;}
            public List<SelectOption> options{get;set;}
            
            public list<contact> finallist{get;set;}
            
            public paginationforcontactscontroller()
            {
                finallist= New list<contact>();
                pagesize = 10;
                page = 1;
                String Soql = 'select name, department, fax, title, phone from contact  order by id Asc';
                System.debug('page+++++'+page);
                
                System.debug('pagesize+++++'+pagesize);
                getContacts();
                
            }
            Public void IsFirstPage()
            {
                If(getHasfirstPage())
                {
                    page = 1;
                    getContacts();
                }
                
            }
            Public void IsLastPage()
            {
                If(getHasLastPage())
                {
                    page = totalPages;
                    getContacts();
                }
                
            }
            public void isprevious()
            { 
                if(getHasPrevious())
                {
                    page--;
                    getContacts();
                }
                
                
            }

            public void isnext()
            { 
                if(getHasNext())
                {
                    page++;
                    Getcontacts();
                }
            }
            public boolean getHasfirstPage(){
                if(page>1){
                    return true; 
                }
                else
                {
                    return false;
                }     
                
            }
            public boolean getHasLastPage(){
                if(page<totalPages)
                {
                    return true; 
                }
                else
                {
                    return false;
                }     
                
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
                startIdx = (page - 1)*pageSize;
                System.debug('startIdx+++++'+startIdx);
                System.debug('page+++++'+page);
                endIdx = page*PAgeSize;
                System.debug('endIdx+++++'+endIdx);
                System.debug('pagesize+++++'+pagesize);
                Integer TotalRecords = 0;
                System.debug('TotalRecords+++++'+TotalRecords);
                finallist = new list<contact>();
                contactlist = [select name, department, fax, title, phone from contact  order by id Asc];
                
                for(Contact Con: contactlist)
                { 
                    if(totalRecords>=startIdx && totalRecords<endIdx)
                    {
                        finallist.Add(con);
                        
                    }
                    TotalRecords++;
                }
                System.debug('TotalRecords+++++'+TotalRecords);
                System.debug('finallist++++++'+finallist);
                System.debug('Contactlist+++++'+contactlist);
                totalPages = TotalRecords/pageSize;
                System.debug('totalPages+++++'+totalPages);
                return finallist;
                
            }
            
            public void Box(){
                page =page;
                System.debug('page+++++'+page);
                
                getContacts();
                System.debug('page+++++'+page);
            }
            public pageReference refresh()
            {	System.debug('Contactlist+++++'+contactlist);
             System.debug('finallist++++++'+finallist);
             getContacts();
             return null;
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