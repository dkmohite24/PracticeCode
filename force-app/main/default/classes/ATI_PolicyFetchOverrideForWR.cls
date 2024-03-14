global without sharing class ATI_PolicyFetchOverrideForWR implements WOD_2.ATQueryOverrideInterface{
    
    public List<WOD_2__Applicability_Term__c> fetchApplicabilityTerm(String query, List<String> queryFields, String ruleObjectName, String baseObjectFieldName ) {
        query += ' AND WOD_2__Policy_Definition__r.WOD_2__Status__c=\'Active\'';
        System.debug('ATI_PolicyFetchOverrideForWR -> ' + query);
        return Database.query(query);
    }
}