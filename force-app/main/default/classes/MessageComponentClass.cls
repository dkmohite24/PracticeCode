/* Class Name: MessageComponentClass
* Description: This class is used by two different lightning components to display knowledge articles.
* Created by: Akanksha Mondal
* Created Date :6/15/2022
*/
global class MessageComponentClass {    
    @AuraEnabled
    public static Wrapper getcategory()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Knowledge__kav.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        Set<id> knowledgeidset = new Set<id>();
        Set<string> cdlset = new Set<string>();
        List<Knowledge__kav> knowledgearticlelist=[ Select id,Title,Summary,PublishStatus,Category__c,LastPublishedDate,PublishDateFormula__c,Article_Validity_Date__c from Knowledge__kav where PublishStatus='Online' ORDER BY LastPublishedDate DESC]; 
        for(Knowledge__kav k:knowledgearticlelist){
            knowledgeidset.add(k.id);
        }
        List<ContentDocumentLink> cdlist =[Select Id, LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN:knowledgeidset];
        for(ContentDocumentLink cdl : cdlist ){
            cdlset.add(String.valueof(cdl.LinkedEntityId)+'+'+String.valueof(cdl.ContentDocumentId));
        }
        
        system.debug('categorylist------'+pickListValuesList);
        system.debug('knowlist------'+knowledgearticlelist);
        system.debug('cdlset------'+cdlset);
        Wrapper w = new Wrapper();
        w.cdlset = cdlset;
        w.knowlist= knowledgearticlelist; 
        w.categorylist=pickListValuesList;
        return w;
    }   
    @AuraEnabled
    public static Wrapper GetData(String category,Date startdate,Date enddate,String title)        
    {  
        
        Set<String> cset = new Set<String>();
        Date sdate;
        Date edate;
        String ch;
        if(category==null || category=='Select Category') { 
            Schema.DescribeFieldResult fieldResult = Knowledge__kav.Category__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                cset.add(pickListVal.getLabel());
            }  
        }
        else{
            cset.add(category);
        }
        if(startdate==null){
            Date t = date.today();
            ch='<=';
            sdate= Date.newInstance(t.year(), t.month(), t.day());
        }
        else{
            ch='=';
            sdate = Date.newInstance(startdate.year(),startdate.month(),startdate.day());
        }
        if(enddate==null){
            edate= Date.newInstance(2100, 12, 31);
        }
        else{
            edate = Date.newInstance(enddate.year(),enddate.month(),enddate.day());
        }
        
        system.debug('startdate----'+sdate);
        system.debug('enddate----'+edate);
        system.debug('cset----'+cset);
        system.debug('title----'+title);
        Set<id> knowledgeset = new Set<id>();
        Set<string> cdlset = new Set<string>();
        List<Knowledge__kav> knowlist = new List<Knowledge__kav>();
        String query = 'Select id,Title,Summary,PublishStatus,Category__c,LastPublishedDate,PublishDateFormula__c,Article_Validity_Date__c from Knowledge__kav where Article_Validity_Date__c<=:edate AND PublishStatus=\'Online\' AND Category__c IN:cset AND PublishDateFormula__c';
        query= query + ch + ':sdate ORDER BY LastPublishedDate DESC';
        List<Knowledge__kav> klist = Database.query(query);
        for(Knowledge__kav k:klist){
            if(title==null || title==''|| title=='undefined'){
                system.debug('INSIDE If TITLE');
                knowlist.add(k);
            }
            else{
                if(k.Title.containsIgnoreCase(title)){
                    knowledgeset.add(k.id);
                    knowlist.add(k);  
                }
                
            }
            
        }
        if(knowledgeset.size()>0){
            List<ContentDocumentLink> cdlist =[Select Id, LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN:knowledgeset];
            for(ContentDocumentLink cdl : cdlist ){
                cdlset.add(String.valueof(cdl.LinkedEntityId)+'+'+String.valueof(cdl.ContentDocumentId));
            }
        }
        
        
        system.debug('knowlist------'+knowlist);
        system.debug('cdlset------'+cdlset);
        Wrapper w = new Wrapper();
        w.cdlset = cdlset;
        w.knowlist= knowlist; 
        return w;
    }
    @AuraEnabled
    public static Wrapper GetAnnouncement(){
        List<Knowledge__kav> knowledgelist=[ Select Title,Summary,PublishStatus,Category__c,LastPublishedDate,PublishDateFormula__c,Article_Validity_Date__c from Knowledge__kav where PublishStatus='Online' AND Is_Announcement__c=true ORDER BY LastPublishedDate DESC  ]; 
        Set<id> knowledgeset = new Set<id>();
        Set<string> cdlset = new Set<string>();
        for(Knowledge__kav k:knowledgelist){
            knowledgeset.add(k.id);
        }
        List<ContentDocumentLink> cdlist =[Select Id, LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN:knowledgeset];
        for(ContentDocumentLink cdl : cdlist ){
            cdlset.add(String.valueof(cdl.LinkedEntityId)+'+'+String.valueof(cdl.ContentDocumentId));
        }
        
        
        
        system.debug('knowlist------'+knowledgelist);
        system.debug('cdlset------'+cdlset);
        Wrapper w = new Wrapper();
        w.cdlset = cdlset;
        w.knowlist= knowledgelist; 
        return w;
        
    }    
    @AuraEnabled
    public static Wrapper HomePageArticles(){
        List<Knowledge__kav> knowledgelist=[ Select Title,Summary,PublishStatus,Category__c,LastPublishedDate,PublishDateFormula__c,Article_Validity_Date__c from Knowledge__kav where PublishStatus='Online' ORDER BY LastPublishedDate DESC  ]; 
        Set<id> knowledgeidset = new Set<id>();
        Set<string> cdlset = new Set<string>();
        for(Knowledge__kav k:knowledgelist){
            knowledgeidset.add(k.id);
        }
        List<ContentDocumentLink> cdlist =[Select Id, LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN:knowledgeidset];
        for(ContentDocumentLink cdl : cdlist ){
            cdlset.add(String.valueof(cdl.LinkedEntityId)+'+'+String.valueof(cdl.ContentDocumentId));
        }
        List<RecentlyViewed> recentviewlist =[SELECT Id, Name FROM RecentlyViewed WHERE LastViewedDate !=null ORDER BY LastViewedDate DESC Limit 10];
        system.debug('knowlist------'+knowledgelist);
        system.debug('cdlset------'+cdlset);
        Wrapper wr = new Wrapper();
        wr.cdlset = cdlset;
        wr.knowlist= knowledgelist; 
        wr.recentviewLst= recentviewlist;
        return wr;
        
    }
    public class Wrapper{
        @AuraEnabled  public List<String> categorylist{get;set;}
        @AuraEnabled public List<Knowledge__kav> knowlist {get;set;}
        @AuraEnabled public List<RecentlyViewed> recentviewLst {get;set;}
        @AuraEnabled public Set<string> cdlset {get;set;}
    }
    
}