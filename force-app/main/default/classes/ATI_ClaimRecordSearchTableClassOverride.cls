/*Name: ClaimRecordSearchTableClassOverride
Description: this call is used in community, claim custom search
Author: Tavant ()
History:
VERSION      AUTHOR         DATE                   DETAIL 			UserStory/Req #
1.0 -       Tavant ()    9/26/2019          INITIAL DEVELOPMENT
*/
public with sharing class ATI_ClaimRecordSearchTableClassOverride implements ATI_TableComponentInterface {
    
    /**
If where condition come from query builder, we are splitting it and taking status and preparing withstare withoutshare status lists
EX : WOD_2__Claim_Status__c IN ('Draft','Paid');
Here Draft status should run in withshare mode and Paid should run in without share mode

If No where condition then it pick from picklist values and compare against config and prepare list
**/
    public String queryRecords(WOD_2.QueryBuilderWrapper querybuilderObject) {
        List<sObject> allClaims = new List<sObject>();
        String oldWhereClause = querybuilderObject.whereClause;
        List<String> withShareStatusList = new List<String>();
        List<String> withoutShareStatusList = new List<String>();
       // WOD_2__Configuration_Setting__mdt configsetting = ATI_ConfigSettingsService.getConfigurationSettingMetaData('Claim_AdvancedSearch_StatusValues');
       // String[] statusValuesFromConfig = configsetting.WOD_2__Configuration_Value__c.split(',');
        
        SObjectType objectType = Schema.getGlobalDescribe().get('WOD_2__Claim__c');
        Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
        List<Schema.PicklistEntry> pickListvalues = fieldsTokenMap.get('WOD_2__Claim_Status__c').getDescribe().getPickListValues();
        List<String> allstatusValues = new List<String>();
        for (Schema.PicklistEntry value: pickListvalues) {//&& statusValuesFromConfig.contains(value.getValue()
            if(value.isActive()) {
                withoutShareStatusList.add(value.getValue());
            } else {
                withShareStatusList.add(value.getValue());
            }
        }
        List<sObject> dealerClaims = ATI_ClaimRecordSearchTableClassOverride.getDealerHierarchyClaims(querybuilderObject,oldWhereClause,withShareStatusList);
        List<sObject> othersClaims = ATI_ClaimRecordSearchTableClassOverride.getOthersClaims(querybuilderObject,oldWhereClause,withoutShareStatusList);
        //System.debug('othersClaims '+othersClaims);
        if(dealerClaims != null && dealerClaims.size() > 0) {
            allClaims.addAll(dealerClaims);
        }
        if(othersClaims != null && othersClaims.size() > 0) {
            allClaims.addAll(othersClaims);
        }
        System.debug('Claim '+allClaims);
        return JSON.serialize(allClaims);
    }
    
    /**
We are fetching
Draft
Additional Information Required
Pending Approval
**/
    private static List<sObject> getDealerHierarchyClaims(WOD_2.QueryBuilderWrapper querybuilderObject,String oldWhereClause,List<String> idList) {
        if(oldWhereClause != '') {
            querybuilderObject.whereClause = oldWhereClause + ' AND WOD_2__Claim_Status__c IN :idList AND recordtype.developerName != \'Claim_Template\'';
        }else {
            querybuilderObject.whereClause = ' WOD_2__Claim_Status__c IN :idList AND recordtype.developerName != \'Claim_Template\'';
        }
        String query = ATI_Utils.buildQueryWithoutAccessCheck(querybuilderObject);
        System.debug('getDealerHierarchyClaims query '+query);
        return Database.query(query);
    }
    
    
    
    /**
We are fetching other than
Draft
Additional Information Required
Pending Approval
**/
    private static List<sObject> getOthersClaims(WOD_2.QueryBuilderWrapper querybuilderObject,String oldWhereClause,List<String> idList) {
        if(oldWhereClause != '') {
            querybuilderObject.whereClause = oldWhereClause + ' AND WOD_2__Claim_Status__c IN :idList AND WOD_2__Inventory__r.recordtype.developerName = \'Retail\' AND recordtype.developerName != \'Claim_Template\' AND recordtype.developerName != \'Part\'';
        }else {
            querybuilderObject.whereClause = ' WOD_2__Claim_Status__c IN :idList AND WOD_2__Inventory__r.recordtype.developerName = \'Retail\' AND recordtype.developerName != \'Claim_Template\' AND recordtype.developerName != \'Part\'';
        }
        String otherQuery = ATI_Utils.buildQueryWithoutAccessCheck(querybuilderObject);
        System.debug('getOthersClaims query '+otherQuery);
        List<sObject> otherRecordtypeClaims = ATI_QueryRunWithoutSharing.runQueryWithIdsStringList(otherQuery,idList);
        
        if(oldWhereClause != '') {
            querybuilderObject.whereClause = oldWhereClause + ' AND WOD_2__Claim_Status__c IN :idList AND recordtype.developerName = \'Part\'';
        }else {
            querybuilderObject.whereClause = ' WOD_2__Claim_Status__c IN :idList AND recordtype.developerName = \'Part\'';
        }
        String partQuery = ATI_Utils.buildQueryWithoutAccessCheck(querybuilderObject);
        System.debug('getOthersClaims partQuery '+partQuery);
        List<sObject> partRecordtypeClaims = ATI_QueryRunWithoutSharing.runQueryWithIdsStringList(partQuery,idList);
        
        if(partRecordtypeClaims != null && partRecordtypeClaims.size() > 0) {
            otherRecordtypeClaims.addAll(partRecordtypeClaims);
        }
        
        if(oldWhereClause != '') {
            String allClaims = 'Select Id,WOD_2__Inventory__c from WOD_2__Claim__c Where '+oldWhereClause+ ' AND recordtype.developerName != \'Claim_Template\' AND recordtype.developerName != \'Part\'';
            List<WOD_2__Claim__c> claimList  = Database.query(allClaims);
            List<String> invIdsStringList = new List<String>();
            for(WOD_2__Claim__c climObj : claimList) {
                invIdsStringList.add('\''+climObj.WOD_2__Inventory__c+'\'');
            }
            if(invIdsStringList != null && invIdsStringList.size() >  0) {
                String invQuery = 'Select Id from WOD_2__Inventory__c where recordtype.developerName = \'Stock\' AND Id IN ('+String.join(invIdsStringList,',')+')';
                System.debug('@@@ '+invQuery);
                Map<Id,WOD_2__Inventory__c> inventoryMap = new Map<Id,WOD_2__Inventory__c>((List<WOD_2__Inventory__c>)ATI_QueryRunWithoutSharing.runQuery(invQuery));
                Set<Id> inventoryIds = inventoryMap.keyset();
                if(inventoryIds != null && inventoryIds.size() > 0 ) {
                    List<String> idsStringList = new List<String>();
                    for(Id invId : inventoryIds) {
                        idsStringList.add('\''+invId + '\'');
                    }
                    querybuilderObject.whereClause = oldWhereClause + ' AND WOD_2__Claim_Status__c IN :idList AND WOD_2__Inventory__c IN ('+String.join(idsStringList,',')+')';
                    
                    System.debug('--q- '+querybuilderObject.whereClause);
                    String queryUpdatedClaim = ATI_Utils.buildQueryWithoutAccessCheck(querybuilderObject);
                    List<sObject> claimListnew = Database.query(queryUpdatedClaim);
                    otherRecordtypeClaims.addAll(claimListnew);
                }
            }
        }
        return otherRecordtypeClaims;
    }
}