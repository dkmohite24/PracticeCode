global class GetOrgBaseUrl {
    @InvocableMethod(Label= 'Get Sandbox Url')
    global static List<results>getBaseUrl(List<sobject>sourceRecords)
    {
        List<results>orgUrl= new List<results>();
        for(sObject obj:sourceRecords){
            results r= new results();
            r.baseUrl= URL.getSalesforceBaseUrl().toExternalForm();
            orgUrl.add(r);
        }
      return orgUrl;
    }
    
    
    global class results{
        
        @InvocableVariable
        global String baseUrl;
    }
}