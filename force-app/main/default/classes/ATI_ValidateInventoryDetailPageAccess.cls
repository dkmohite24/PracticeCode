public class ATI_ValidateInventoryDetailPageAccess implements ATI_ValidateDetailPageInterface{
    public Boolean validateDetailPage(String recordId) {
        Boolean result = false;
        String fromObject = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String[] fieldsToQuery = new List<String>{'Name'};
        String whereClause = 'Id = \''+recordId + '\'';
        ATI_InventoryRecordSearchTableCO invSearchObject = new ATI_InventoryRecordSearchTableCO();  
        WOD_2.QueryBuilderWrapper queryBuilderWrapper = new WOD_2.QueryBuilderWrapper();
        queryBuilderWrapper.fieldsToQuery = fieldsToQuery;
        queryBuilderWrapper.fromObject = fromObject;
        queryBuilderWrapper.whereClause = whereClause; 
        queryBuilderWrapper.recordLimit = 1;  
        queryBuilderWrapper.orderBy = '';
        System.debug(queryBuilderWrapper);
        String invListString = invSearchObject.queryRecords(queryBuilderWrapper);
        List<WOD_2__Inventory__c> invList = (List<WOD_2__Inventory__c>) JSOn.deserialize(invListString,List<WOD_2__Inventory__c>.class);
        System.debug(invList);
        if(invList != null && invList.size() == 1) {
            result = true;
        }
         return result;
    }
}