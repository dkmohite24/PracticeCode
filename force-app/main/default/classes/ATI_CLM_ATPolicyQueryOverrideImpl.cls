/* Name: ATI_CLM_ATPolicyQueryOverrideImpl
Description : ATI_CLM_ATPolicyQueryOverrideImpl - Policy override class for claim, need this to fetch the Goodwill policy for pre-auth claims
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      19-FEB-2021          INITIAL DEVELOPMENT
*/

global inherited sharing class ATI_CLM_ATPolicyQueryOverrideImpl  implements WOD_2.ATQueryOverrideInterface {
    
    public static String businessUnitId; 
    public static String claimType;
    public static Boolean preDelivery = false;
    public static Id inventoryId;
    //ALSN-127 defaulted it to false
    public static Boolean isPreAuthClaim = false;
    public static String buId;
    //ALSN-141 added months..
    public static Double months;
    public List<WOD_2__Applicability_Term__c> fetchApplicabilityTerm(String query, List<String> queryFields, String ruleObjectName, String baseObjectFieldName ) 
    {
        Set<Id> policyIdsSet = WOD_2.CLM_UnmanagedUtility.policyIdsSet;
        //ALSN-127 add isPreAuthClaim check
        //Pre-delivery policy to be applied on the claim only if it is not a pre-auth claim
        if(preDelivery == true && inventoryId != NULL && isPreAuthClaim == false){
            List<WOD_2__Warranty_Coverages__c> preDelCoverageLst = [SELECT Id,WOD_2__Policy_Definition__c FROM WOD_2__Warranty_Coverages__c
                                                                    WHERE WOD_2__Warranty_Registration__r.WOD_2__Inventory__c=:inventoryId
                                                                    AND WOD_2__Warranty_Registration__r.ATI_Pre_Delivery__c = true
                                                                    AND WOD_2__Warranty_Registration__r.WOD_2__Status__c = 'Registered'
                                                                    ORDER BY LastModifiedDate DESC LIMIT 1];
            if(!preDelCoverageLst.isEmpty()){
                query += ' AND WOD_2__Policy_Definition__c = \''+preDelCoverageLst[0].WOD_2__Policy_Definition__c+'\' AND WOD_2__Policy_Definition__r.WOD_2__Business_Units__c INCLUDES (\'' + String.escapeSingleQuotes(getBUName()) + '\')';
            }
        }else if(WOD_2.CLM_UnmanagedUtility.type == 'Retail') {
            query += ' AND WOD_2__Policy_Definition__c IN :policyIdsSet AND WOD_2__Policy_Definition__r.WOD_2__Business_Units__c INCLUDES (\'' + String.escapeSingleQuotes(getBUName()) + '\')';
        }else if(WOD_2.CLM_UnmanagedUtility.type == 'Part') {
            System.debug('months'+months); // ALSN - 141 added monthscovered >= months in query.. //
            query += ' AND WOD_2__Policy_Definition__r.WOD_2__Sub_Type__c=\'Part\' AND WOD_2__Policy_Definition__r.WOD_2__Status__c = \'Active\' AND WOD_2__Policy_Definition__r.WOD_2__Months_Covered__c>=: months AND WOD_2__Policy_Definition__r.WOD_2__Business_Units__c INCLUDES (\'' + String.escapeSingleQuotes(getBUName()) + '\')';
        }else if(WOD_2.CLM_UnmanagedUtility.type == 'Goodwill'){
            query += ' AND WOD_2__Policy_Definition__r.WOD_2__Type__c=\'Goodwill\' AND WOD_2__Policy_Definition__r.WOD_2__Status__c = \'Active\' AND WOD_2__Policy_Definition__r.WOD_2__Business_Units__c INCLUDES (\'' + String.escapeSingleQuotes(getBUName()) + '\')';
        }
        System.debug('AT Query - ' +query);
        ATI_Utils.NoAccessObjectFieldWrapper applicabilityTermAccessList = ATI_Utils.fetchReadAccess('WOD_2__Applicability_Term__c',queryFields);
        if(applicabilityTermAccessList.noAccessObjectList.size() != 0 || applicabilityTermAccessList.noAccessFieldList.size() != 0 ) {
            throw new TWoDException(System.Label.ATI_Log_Insufficient_access + ' Object: WOD_2__Applicability_Term__c, Fields: '+String.join(applicabilityTermAccessList.noAccessFieldList, ','));
        }
        return Database.query(query);
    }
    @TestVisible
    private String getBUName(){
        // defaulting it to ATI, if nothing is passed then ATI will be used
        if(String.isNotBlank(businessUnitId)){
            List<WOD_2__Business_Category_Configuration__c> buList = [SELECT Id, Name FROM WOD_2__Business_Category_Configuration__c WHERE Id = :businessUnitId];    
            if(!buList.isEmpty()){
                return buList[0].Name;
            }
        }
        return 'ATI';
    }
}