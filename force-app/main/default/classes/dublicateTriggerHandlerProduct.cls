public class dublicateTriggerHandlerProduct {
    public static void dublicatecheck(list<Product2>prlist){
        list<product2> upadteCheckList = new list<product2>();
        
        for(product2 pr: prlist){
            upadteCheckList = [select id,name from product2 where name= :pr.Name];
            if(upadteCheckList.size() > 0){
                pr.name =  pr.name+'ilead2020';
            }
            
        }
    }
    
}