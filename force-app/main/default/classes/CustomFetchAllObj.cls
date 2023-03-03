public class CustomFetchAllObj {
    @AuraEnabled
    public static List<String> getObjectName(){
        List<String> objects=new List<String>();
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();  
        for(SObjectType sot:gd){
            objects.add(sot.getDescribe().getName());
            objects.sort();  
        }
        return objects;
       
    }
    @AuraEnabled
    public static ObjDataTableWrapper getObjectsData(string objSelected,integer pageNumber,integer PageSize,boolean next,boolean prev, String FirstId, String LastId, Integer totalRecords){
        string query;
        List<sobject> data1;
        system.debug('pagesize='+PageSize);
       
        If(objSelected.length()>0){
            if(next==True && prev==True){
                query = 'SELECT CreatedBy.Name,CreatedDate,name From ' + objSelected + ' order by id Asc LIMIT :PageSize';
                
                
            }
            else if(next==True && prev==false){
                query = 'select CreatedBy.Name,CreatedDate,name from '+ objSelected +' where Id >:LAstId order by id Asc LIMIT :PageSize';
                
                
            }
            else if(next==false && prev==True){
                query = 'select CreatedBy.Name,CreatedDate,name from '+ objSelected +' where Id <:FirstId order by id Desc LIMIT :PageSize';
                
            }
            
            else if(next==false && prev==false){
                query = 'SELECT CreatedBy.Name,CreatedDate,name From ' + objSelected + ' order by id DESC LIMIT :PageSize';
                
                
            }
            else {
                query = 'SELECT CreatedBy.Name,CreatedDate,name From ' + objSelected + ' order by id Asc LIMIT :PageSize' ;
               
            }
           system.debug(query);
            data1 = Database.query(query);
            integer size1 = data1.size();
            if((next==false && prev==True)||(next==false && prev==false) ){
                List<sobject> reversed = new List<sobject>();
                
                for(Integer i = (size1 - 1); i >= 0; i--){
                    system.debug(size1);
                    system.debug('inside prev'+data1);
                    reversed.add(data1[i]);
                    
                }
                data1 = reversed ;
            }
            else{
                data1 = data1;
            }
            
           FirstId= data1[0].id;
            LastId= data1[(size1-1)].id;
            
            
                       
        }
        ObjDataTableWrapper objDT =  new ObjDataTableWrapper();  
        system.debug(query);
        objDT.PageSize = PageSize;
        system.debug('objDT.pageSize'+objDT.pageSize);
        objDT.PageNumber = pageNumber;
        string queryCount = 'select count() from '+objSelected ;
        objDT.totalRecords = database.countQuery(queryCount);
        system.debug('objDT.totalRecords'+objDT.totalRecords);
        objDT.ObjList1 = data1;
        objDT.FirstId = FirstId;
        objDT.LastId = LastId;
        system.debug(PageNumber);
        system.debug(LastId);
        return objDT;
       
    }
    //Wrapper Class For Contact DataTable  
    public class ObjDataTableWrapper {
        @AuraEnabled
        public Integer PageSize {get;set;}
        @AuraEnabled
        public Integer PageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
       
        @AuraEnabled
        public List<sobject> ObjList1 {get;set;}
        @AuraEnabled
        Public string FirstId{get;set;}
        @AuraEnabled
        Public String LastId{get;set;}
       
    }
   
   
}