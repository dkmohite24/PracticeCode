public class CalenderClass {
    @AuraEnabled
    public static list<Survey_Assignment__c> getAllEvents(){
        list<Survey_Assignment__c> eventlist =[SELECT name, Assign_To__c,CreatedDate,Date__c,End__c,Start__c FROM Survey_Assignment__c where createdById=:Userinfo.getUserId()] ;
        system.debug(eventlist);
        return eventlist;
        
    }
    
    
    @AuraEnabled
    public static void updateEvent(string eventid,string eventdate){
        system.debug(eventid);
        system.debug(eventdate);
        string eventdatelist = eventdate.replace('T',' ');
        
        system.debug(eventdatelist);
        Survey_Assignment__c e= new Survey_Assignment__c(id = eventid);
        e.Start__c = DateTime.valueof(eventdatelist);
        e.End__c = DateTime.valueof(eventdatelist);   
        update e;
        
    }
}