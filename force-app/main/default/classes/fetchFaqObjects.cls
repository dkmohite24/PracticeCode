public with sharing class fetchFaqObjects {

    @AuraEnabled(cacheable=true)
    public static List<FAQ__c> getCustomObjectData(String searchQuery, String searchPick) {
        String query = 'SELECT Id, Name, Answer__c, Question__c, Language__c FROM FAQ__c';
        system.debug('get the language data' + query);
        
        if (!String.isBlank(searchQuery) || !String.isBlank(searchPick)) {
            query += ' WHERE';
            
            if (!String.isBlank(searchQuery)) {
                query += ' Name LIKE \'%' + String.escapeSingleQuotes(searchQuery) + '%\'';
            }
            
            if (!String.isBlank(searchPick)) {
                if (!String.isBlank(searchQuery)) {
                    query += ' AND';
                }
                query += ' Language__c LIKE \'%' + String.escapeSingleQuotes(searchPick) + '%\'';
            }
        }
    
        return Database.query(query);    
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues() {
        List<Schema.PicklistEntry> entries = FAQ__c.Language__c.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            values.add(valueMap);
        }
        return values;
    }
}