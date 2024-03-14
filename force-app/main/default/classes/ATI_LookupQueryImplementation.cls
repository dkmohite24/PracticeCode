global class ATI_LookupQueryImplementation implements WOD_2.LookupQueryDataInterface {
    global String fetchRecords(WOD_2.QueryBuilderWrapper queryBuilderWrapper) {
        System.debug('queryBuilderWrapper---->'+queryBuilderWrapper);
        String queryStr = '';
        Map<String, Object> extraParamsMap = new Map<String, Object>();
        if(queryBuilderWrapper.extraParams != NULL){
        	extraParamsMap = (Map<String, Object>)JSON.deserializeUntyped(queryBuilderWrapper.extraParams);
        }
        switch on queryBuilderWrapper.lookUpConfigurationName {
            when 'WOD_2__Claim_Services_JobCodeLookUp' {
                queryStr = 'SELECT '+String.join(queryBuilderWrapper.fieldsToQuery,',')+' FROM ' + queryBuilderWrapper.fromObject + ' WHERE ';
                if(extraParamsMap.get('WOD_2__Warranty_Product__c') != NULL){
                    List<WOD_2__Warranty_Product__c> wpList = [SELECT Id,WOD_2__Parent_Product__c FROM WOD_2__Warranty_Product__c 
                                                               WHERE Id=:(Id)extraParamsMap.get('WOD_2__Warranty_Product__c')];
                    queryStr +='WOD_2__Group__c IN (SELECT WOD_2__Group__c FROM WOD_2__Group_Member__c WHERE WOD_2__Warranty_Product__c=\''+wpList[0].WOD_2__Parent_Product__c+'\') AND ';
                }
                queryStr +=' WOD_2__Code__r.RecordType.Name=\'Job Code\' AND WOD_2__Status__c=true AND WOD_2__Code__r.name LIKE \''+queryBuilderWrapper.userEnteredValue+'%\'';
                queryStr +=' AND WOD_2__Code__r.ATI_IsActive__c=true';
                
                queryBuilderWrapper.orderByLogic = String.isBlank(queryBuilderWrapper.orderByLogic) ? ' ASC ' : queryBuilderWrapper.orderByLogic;
                
                if(String.isNotBlank(queryBuilderWrapper.orderByField)) {
                    queryStr += ' ORDER BY '+queryBuilderWrapper.orderByField+' '+queryBuilderWrapper.orderByLogic;
                    
                }
                queryBuilderWrapper.recordLimit = queryBuilderWrapper.recordLimit == null || queryBuilderWrapper.recordLimit > 100 ? 10 : queryBuilderWrapper.recordLimit;
                queryStr += ' LIMIT '+queryBuilderWrapper.recordLimit;
            }
            //Added By Dishari For 27379
            when 'ATI_DiagnosticCodes_Lookup' {
                System.debug(queryBuilderWrapper);
                JSONParser parser = JSON.createParser(queryBuilderWrapper.conditions);
                Conditions conditions = NULL;
                while (parser.nextToken() != null) {
                    System.debug('1');
                    // Start at the array of invoices.
                    if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                        System.debug('2');
                        while (parser.nextToken() != null) {
                            // Advance to the start object marker to
                            //  find next invoice statement object.
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                System.debug('3');
                                // Read entire invoice object, including its array of line items.
                                conditions = (Conditions)parser.readValueAs(Conditions.class);
                                System.debug('fieldName'+conditions.fieldName);
                            }
                        }
                    }
                }
                List<String> comparisonFields = (List<String>)queryBuilderWrapper.comparisonFields;
                System.debug(comparisonFields);
                queryStr = 'SELECT '+String.join(queryBuilderWrapper.fieldsToQuery,',')+' FROM ' + queryBuilderWrapper.fromObject + ' WHERE ';
                if(extraParamsMap.containsKey('modelId')){
                    List<WOD_2__Warranty_Product__c> wpList = [SELECT Id,WOD_2__Parent_Product__c,WOD_2__Parent_Product__r.WOD_2__Parent_Product__c FROM WOD_2__Warranty_Product__c 
                                                               WHERE  Id=:(Id)extraParamsMap.get('modelId')];
                    
                    queryStr += 'Id IN (SELECT ATI_Warranty_Code__c FROM ATI_Diagnostic_Codes_Mapper__c WHERE ATI_Warranty_Product__c=\''+wpList[0].WOD_2__Parent_Product__r.WOD_2__Parent_Product__c+'\') AND ';                    
                }
                if(!comparisonFields.isEmpty()){
                    queryStr += comparisonFields[0]+' LIKE \''+queryBuilderWrapper.userEnteredValue+'%\' AND ';
                } 
                queryStr += conditions.fieldName+' = \''+conditions.value+'\'';
                queryBuilderWrapper.orderByLogic = String.isBlank(queryBuilderWrapper.orderByLogic) ? ' ASC ' : queryBuilderWrapper.orderByLogic;
                
                if(String.isNotBlank(queryBuilderWrapper.orderByField)) {
                    queryStr += ' ORDER BY '+queryBuilderWrapper.orderByField+' '+queryBuilderWrapper.orderByLogic;
                    
                }
                queryBuilderWrapper.recordLimit = queryBuilderWrapper.recordLimit == null || queryBuilderWrapper.recordLimit > 100 ? 10 : queryBuilderWrapper.recordLimit;
                queryStr += ' LIMIT '+queryBuilderWrapper.recordLimit;
            }
            when 'WOD_2__SHP_Carrier_Lookup_Configuration' {
                List<Conditions> conditions = null;
                if(String.isNotBlank(queryBuilderWrapper.conditions)){
                	conditions = (List<Conditions>) JSON.deserialize(queryBuilderWrapper.conditions, List<Conditions>.class);    
                }
            	queryStr = 'select Id,Name from WOD_2__Carrier__c where WOD_2__Business_Units__c INCLUDES  (\'ATI\') ';
                if(conditions != null && !conditions.isEmpty() && conditions[0].fieldName == 'Id'){
                    queryStr += ' AND Id = \'' + conditions[0].value + '\'';
                } else {
                    queryStr += ' AND Name LIKE \''+queryBuilderWrapper.userEnteredValue+'%\'';
                }
                List<User> usersList = [select id, Name, UserType, ContactId, AccountId, Account.BillingCountry from User where id = :UserInfo.getUserId()];
                if(!usersList.isEmpty() && usersList[0].AccountId != null && usersList[0].Account.BillingCountry != 'US'){
                	queryStr += ' AND Name not in (\'UPS\')';    
                }
                if(String.isNotBlank(queryBuilderWrapper.orderByField)) {
                    String orderByLogic = String.isBlank(queryBuilderWrapper.orderByLogic) ? ' ASC ' : queryBuilderWrapper.orderByLogic;
                    queryStr += ' ORDER BY '+queryBuilderWrapper.orderByField+' '+ orderByLogic;
                }
           }
        }
        System.debug('@@queryStr------> '+queryStr);
        return JSON.serialize(Database.query(queryStr));
    }
    
    public class Conditions{
        public String fieldName;
        public String value;
        public String operator;
        public String searchType;
        public String valueType;  
        
    }
}