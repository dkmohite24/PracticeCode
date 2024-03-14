/**
 -------------------------------------------------------------------------------------------------
This is ATI_BulkWRPolicyQueryOverride class
* --------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        08-JAN-2021
* @modified
* --------------------------------------------------------------------------------------------------
*/
global with sharing class ATI_PreDeliveryPolicyOverride implements WOD_2.ATQueryOverrideInterface{
    global List<WOD_2__Applicability_Term__c> fetchApplicabilityTerm(String query, List<String> queryFields, String ruleObjectName, String baseObjectFieldName ) {
        System.debug('Inside ATI_BulkWRPolicyQueryOverride -> ' + ruleObjectName); 
        query = 'SELECT Name,WOD_2__Policy_Definition__c,WOD_2__Applicability_Term_Type__c,WOD_2__Rule_Object_API_Name__c,WOD_2__Logical_Grouping__c FROM WOD_2__Applicability_Term__c WHERE WOD_2__Policy_Definition__c != null AND WOD_2__Rule_Object_API_Name__c = :ruleObjectName AND WOD_2__isValidExpression__c = true';
        query += ' AND WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Standard\' AND WOD_2__Policy_Definition__r.WOD_2__Sub_Type__c = \'01\'';
        System.debug('Inside ATI_BulkWRPolicyQueryOverride -> ' + query);
		return Database.query(query);
	 }
}