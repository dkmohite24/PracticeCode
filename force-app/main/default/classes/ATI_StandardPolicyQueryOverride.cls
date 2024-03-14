/**
 -------------------------------------------------------------------------------------------------
This is ATI_StandardPolicyQueryOverride class
* --------------------------------------------------------------------------------------------------
* @author         Mukesh Kumar Bhati
* @version        1.0
* @created        03-DEC-2020
* @modified
* --------------------------------------------------------------------------------------------------
*/
global with sharing class ATI_StandardPolicyQueryOverride implements WOD_2.ATQueryOverrideInterface{
     global List<WOD_2__Applicability_Term__c> fetchApplicabilityTerm(String query, List<String> queryFields, String ruleObjectName, String baseObjectFieldName ) {
         System.debug('Inside StandardPolicyQueryOverride -> ' + ruleObjectName);
         query = 'SELECT Name,WOD_2__Policy_Definition__c,WOD_2__Applicability_Term_Type__c,WOD_2__Rule_Object_API_Name__c,WOD_2__Logical_Grouping__c FROM WOD_2__Applicability_Term__c WHERE WOD_2__Policy_Definition__c != null AND WOD_2__Rule_Object_API_Name__c = :ruleObjectName AND WOD_2__isValidExpression__c = true';
         query += ' AND (WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Supplemental Coverage\' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Standard\' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Regulatory\') AND WOD_2__Policy_Definition__r.WOD_2__Active_From__c <= TODAY AND WOD_2__Policy_Definition__r.WOD_2__Active_Until__c >= TODAY';
         System.debug('Inside StandardPolicyQueryOverride -> ' + Database.query(query));
         return Database.query(query);
     }
}