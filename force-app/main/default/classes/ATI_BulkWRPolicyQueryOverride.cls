/**
 -------------------------------------------------------------------------------------------------
This is ATI_BulkWRPolicyQueryOverride class
* --------------------------------------------------------------------------------------------------
* @author         (TY)
* @version        1.0
* @created        05-JAN-2021
* @modified
* --------------------------------------------------------------------------------------------------
*/
global with sharing class ATI_BulkWRPolicyQueryOverride implements WOD_2.ATQueryOverrideInterface{
	public static List<Id> policyDefList = null;
    global List<WOD_2__Applicability_Term__c> fetchApplicabilityTerm(String query, List<String> queryFields, String ruleObjectName, String baseObjectFieldName ) {
        //System.debug('Inside ATI_BulkWRPolicyQueryOverride -> ' + ruleObjectName); 
        query = 'SELECT Name,WOD_2__Policy_Definition__c,WOD_2__Applicability_Term_Type__c,WOD_2__Rule_Object_API_Name__c,WOD_2__Logical_Grouping__c FROM WOD_2__Applicability_Term__c WHERE WOD_2__Policy_Definition__c != null AND WOD_2__Rule_Object_API_Name__c = :ruleObjectName AND WOD_2__isValidExpression__c = true';
         if(policyDefList != null && !policyDefList.isEmpty()){
             query += ' AND ((WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Extended\' AND WOD_2__Policy_Definition__c in :policyDefList) OR WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Standard\' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Supplemental Coverage\' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Regulatory\')';
             query+= ' AND WOD_2__Policy_Definition__r.WOD_2__Active_From__c <= TODAY AND WOD_2__Policy_Definition__r.WOD_2__Active_Until__c >= TODAY';
         }else{
             query+= ' AND (WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Regulatory\' OR  WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Standard\' OR WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Supplemental Coverage\') AND WOD_2__Policy_Definition__r.WOD_2__Active_From__c <= TODAY AND WOD_2__Policy_Definition__r.WOD_2__Active_Until__c >= TODAY';
         }
         System.debug('Inside ATI_BulkWRPolicyQueryOverride -> ' + query);
		 return Database.query(query);
	 }
}