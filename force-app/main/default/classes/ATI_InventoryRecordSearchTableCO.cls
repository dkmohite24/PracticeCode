/* Name: ATI_InventoryRecordSearchTableCO
Description : Override class for Inventory search to decide detail page
Author : TAVANT
History:
Test Class: ATI_InventoryRecordSearchTableCOTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public without sharing class ATI_InventoryRecordSearchTableCO implements ATI_TableComponentInterface,WOD_2.LookupQueryDataInterface {
    /*
        Method Name :   queryRecords
        Params      :   WOD_2.QueryBuilderWrapper querybuilderObject
    */
    public String queryRecords(WOD_2.QueryBuilderWrapper querybuilderObject) { 
        System.debug('InventoryRecordSearchTableClassOverride');
        if(querybuilderObject.fromObject == 'WOD_2__Inventory__c') {
            System.debug('-- whereClause'+querybuilderObject.whereClause);
            String stockInventoryWhereClause = '(RecordType.DeveloperName = \'OEM_Stock\' OR RecordType.DeveloperName = \'Dealer_Stock\' OR RecordType.DeveloperName = \'Stock\')';
            // if(BaseController.isPartnerUser().data == 'true') {
            //      stockInventoryWhereClause = 'RecordType.DeveloperName = \'Warrantable\'';
            // }
            String retailInventoryWhereClause = 'RecordType.DeveloperName = \'Retail\'';
            if(String.isNotBlank(querybuilderObject.whereClause)) {
                stockInventoryWhereClause += ' AND '+querybuilderObject.whereClause;
                retailInventoryWhereClause += ' AND '+querybuilderObject.whereClause;
            }
            WOD_2.QueryBuilderWrapper stockInvQueryBuilderWrapperObject = querybuilderObject;
            stockInvQueryBuilderWrapperObject.whereClause = stockInventoryWhereClause;
            WOD_2.QueryBuilderWrapper retailInvQueryBuilderWrapperObject = new WOD_2.QueryBuilderWrapper();
            retailInvQueryBuilderWrapperObject.fieldsToQuery = querybuilderObject.fieldsToQuery;
            retailInvQueryBuilderWrapperObject.fromObject = querybuilderObject.fromObject;
            retailInvQueryBuilderWrapperObject.whereClause = retailInventoryWhereClause;
            retailInvQueryBuilderWrapperObject.recordLimit = querybuilderObject.recordLimit;
            retailInvQueryBuilderWrapperObject.orderBy = querybuilderObject.orderBy;
            List<WOD_2__Inventory__c> stockInventoryList = this.getStockInventories(stockInvQueryBuilderWrapperObject);
            List<WOD_2__Inventory__c> retailInventoryList = this.getRetailInventories(retailInvQueryBuilderWrapperObject);
            stockInventoryList.addAll(retailInventoryList);
            //if(querybuilderObject.recordLimit == 1 && stockInventoryList.size() > 0 ) {
            //	return JSON.serialize(new List<WOD_2__Inventory__c>{stockInventoryList.get(0)});
            //} else {
            return JSON.serialize(stockInventoryList);
            //} 
        } else {
            return '';
        }
    }
    
    /*
        Method Name :   queryInventoryRecords
        Params      :   WOD_2.QueryBuilderWrapper querybuilderObject
    */
    public String queryInventoryRecords(WOD_2.QueryBuilderWrapper querybuilderObject) {
        System.debug('InventoryRecordSearchTableClassOverride');
        if(querybuilderObject.fromObject == 'WOD_2__Inventory__c') {
            System.debug('-- whereClause'+querybuilderObject.whereClause);
            String stockInventoryWhereClause = '(RecordType.DeveloperName = \'OEM_Stock\' OR RecordType.DeveloperName = \'Dealer_Stock\' OR RecordType.DeveloperName = \'Stock\')';
            // if(BaseController.isPartnerUser().data == 'true') {
            //      stockInventoryWhereClause = 'RecordType.DeveloperName = \'Warrantable\'';
            // }
            String retailInventoryWhereClause = 'RecordType.DeveloperName = \'Retail\'';
            String otherWhereClause = querybuilderObject.whereClause.split('AND').get(0) + ' AND '+querybuilderObject.whereClause.split('AND').get(1);
            System.debug('otherWhereClause'+otherWhereClause);
            String servicingDealerId = querybuilderObject.whereClause.split('AND').get(2).split('=').get(1);
            System.debug('accountid'+servicingDealerId);
            //Based on servicing dealer selection, we are gettting all child accounts of servicing dealer and getting the stock inventories belongs to him
            String accountIdsWhereClause = '';
            if(servicingDealerId != '' && servicingDealerId != null && servicingDealerId.length() > 10) {
                List<Id> accountIds = ATI_InventoryRecordSearchTableCO.getAllParentChildAccountIds(servicingDealerId);
                for(Id accId :accountIds) {
                    accountIdsWhereClause += '\''+String.escapeSingleQuotes(accId)+'\',';
                }
                accountIdsWhereClause = accountIdsWhereClause.removeEnd(',');
                accountIdsWhereClause = 'AND WOD_2__Account__c IN ('+accountIdsWhereClause+')';
                System.debug('accountIdsWhereClause -- '+accountIdsWhereClause);
            }
            
            if(String.isNotBlank(querybuilderObject.whereClause)) {
                stockInventoryWhereClause += ' AND '+otherWhereClause;
                retailInventoryWhereClause += ' AND '+otherWhereClause;
            }
            stockInventoryWhereClause = stockInventoryWhereClause + accountIdsWhereClause;
            WOD_2.QueryBuilderWrapper stockInvQueryBuilderWrapperObject = querybuilderObject;
            stockInvQueryBuilderWrapperObject.whereClause = stockInventoryWhereClause;
            WOD_2.QueryBuilderWrapper retailInvQueryBuilderWrapperObject = new WOD_2.QueryBuilderWrapper();
            retailInvQueryBuilderWrapperObject.fieldsToQuery = querybuilderObject.fieldsToQuery;
            retailInvQueryBuilderWrapperObject.fromObject = querybuilderObject.fromObject;
            retailInvQueryBuilderWrapperObject.whereClause = retailInventoryWhereClause;
            retailInvQueryBuilderWrapperObject.recordLimit = querybuilderObject.recordLimit;
            retailInvQueryBuilderWrapperObject.orderBy = querybuilderObject.orderBy;
            List<WOD_2__Inventory__c> stockInventoryList = new List<WOD_2__Inventory__c>();
            if(accountIdsWhereClause != '') {
                stockInventoryList = this.getStockInventories(stockInvQueryBuilderWrapperObject);
            }
            List<WOD_2__Inventory__c> retailInventoryList = this.getRetailInventories(retailInvQueryBuilderWrapperObject);
            stockInventoryList.addAll(retailInventoryList);
            if(querybuilderObject.recordLimit == 1 && stockInventoryList.size() > 0 ) {
                return JSON.serialize(new List<WOD_2__Inventory__c>{stockInventoryList.get(0)});
            } else {
                return JSON.serialize(stockInventoryList);
            }
        }else {
            return '';
        }
    }
    
    /*
        Method Name :   getAllParentChildAccountIds
        Params      :   accountId
    */
    //Pass accountId with single quoate  EX : 'a99u898990998'
    public static List<Id> getAllParentChildAccountIds(String accountId) {
        String query = 'Select Id from Account where ParentId ='+accountId + ' OR Id = '+accountId;
        
        List<Account> accountsList = Database.query(query);
        
        if(accountsList != null && accountsList.size() > 0 ) {
            return new List<Id>(new Map<Id,Account>(accountsList).keySet());
        }else {
            return new List<Id>();
        }
    }
    
    /*
        Method Name :   getStockInventories
        Params      :   WOD_2.QueryBuilderWrapper querybuilderObject
    */
    private List<WOD_2__Inventory__c> getStockInventories(WOD_2.QueryBuilderWrapper querybuilderObject) {
        String query = ATI_Utils.buildQuery(querybuilderObject);
        System.debug('getStockInventories query--'+query);
        //List<WOD_2__Inventory__c> stockInventoryList = Database.query(query);
        List<WOD_2__Inventory__c> stockInventoryList = ATI_QueryRunWithoutSharing.runQuery(query);
        System.debug('stockInventoryList'+stockInventoryList);
        return stockInventoryList;
    }
    
    /*
        Method Name :   getRetailInventories
        Params      :   WOD_2.QueryBuilderWrapper querybuilderObject
    */
    private List<WOD_2__Inventory__c> getRetailInventories(WOD_2.QueryBuilderWrapper querybuilderObject) {
        String query = ATI_Utils.buildQuery(querybuilderObject);
        System.debug('getRetailInventories query--'+query);
        // List<WOD_2__Inventory__c> retailInventoryList = Database.query(query);
        List<WOD_2__Inventory__c> retailInventoryList = ATI_QueryRunWithoutSharing.runQuery(query);
        return retailInventoryList;
    }
    
    /*
        Method Name :   fetchRecords
        Params      :   WOD_2.QueryBuilderWrapper querybuilderObject
    */
    public String fetchRecords(WOD_2.QueryBuilderWrapper queryBuilderWrapper) {
        return queryInventoryRecords(queryBuilderWrapper);
    }
}