/* Name: ATI_ExtendedPolicyQueryOverride
Description : ATI_ExtendedPolicyQueryOverride - Policy override which provides only Extended Policies
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      30-DEC-2020          INITIAL DEVELOPMENT
*/

global with sharing class ATI_ExtendedPolicyQueryOverride implements WOD_2.ATQueryOverrideInterface{
     public static List<Id> policyDefList = null;
     global List<WOD_2__Applicability_Term__c> fetchApplicabilityTerm(String query, List<String> queryFields, String ruleObjectName, String baseObjectFieldName ) {
         System.debug('Inside ATI_ExtendedPolicyQueryOverride -> ' + ruleObjectName);
         query = 'SELECT Name,WOD_2__Policy_Definition__c,WOD_2__Applicability_Term_Type__c,WOD_2__Rule_Object_API_Name__c,WOD_2__Logical_Grouping__c FROM WOD_2__Applicability_Term__c WHERE WOD_2__Policy_Definition__c != null AND WOD_2__Rule_Object_API_Name__c = :ruleObjectName AND WOD_2__isValidExpression__c = true';
         query += ' AND WOD_2__Policy_Definition__r.WOD_2__Type__c = \'Extended\' AND WOD_2__Policy_Definition__r.WOD_2__Active_From__c <= TODAY AND WOD_2__Policy_Definition__r.WOD_2__Active_Until__c >= TODAY AND WOD_2__Policy_Definition__r.WOD_2__Status__c=\'Active\'';
         if(policyDefList != null && !policyDefList.isEmpty()){
             query+= ' AND WOD_2__Policy_Definition__c in :policyDefList';
         }
         System.debug('Inside ATI_ExtendedPolicyQueryOverride -> ' + query);
         return Database.query(query);
     }
}