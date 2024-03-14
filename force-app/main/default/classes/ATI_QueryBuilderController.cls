/* Name: ATI_QueryBuilderController
Description : This class is used to build the query
Author : TAVANT
History:
Test Class: ATI_QueryBuilderControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_QueryBuilderController {
     
    /**
    description: Method is used to build where condition for soql using filter logic and filter criteria.
    Receives filterLogic(EX: 1 AND 2 AND 3 AND 4) and filterCriteria : List<FilterCriteriaWrapper> object
    Here Id of the FilterCriteriaWrapper object is the number in filterLogic
    ..Yet to write description
    return : Returns where condition formed
    **/
    public static String buildWhereCondition(String filterLogic,String filterCriteria) {
        String whereCondition = '';
        List<FilterCriteriaWrapper> filterCriteriaWrapperList  = (List<FilterCriteriaWrapper>)JSON.deserialize(filterCriteria,List<FilterCriteriaWrapper>.class);
        List<String> filterLogicCharactersList = new List<String>();
        //Taking one by one character of filter logic (Filter logic EX: (1 AND 2) OR 3 ) to filterLogicCharactersList
        for(Integer i = 0; i < filterLogic.length(); i++) {
            filterLogicCharactersList.add(filterLogic.substring(i,i+1));
        }
        
        for(FilterCriteriaWrapper filterCriteriaWrapperObject : filterCriteriaWrapperList) {
            String subCondition = ATI_QueryBuilderController.getSubCondition(filterCriteriaWrapperObject);
            //Replacing filter logic number with actual logic
            for(Integer j = 0; j < filterLogicCharactersList.size(); j++) {
                if(filterLogicCharactersList[j] == filterCriteriaWrapperObject.id) {
                    filterLogicCharactersList[j] = subCondition;
                }
            }
        }
        
        //Preparing Where condition
        for(String filterLogicCharacterString : filterLogicCharactersList) {
            whereCondition += filterLogicCharacterString;
        }
        return whereCondition;
    }
    
    /*
        Method Name :   getWhereCondition
        Params      :   filterLogic , filterCriteria
    */
    @AuraEnabled
    public static WOD_2.ResponseWrapper getWhereCondition(String filterLogic,String filterCriteria) {
        System.debug('Inside getWhereCondition' + 'filterLogic >>' +  filterLogic + 'filterCriteria>>'+ filterCriteria );
        String whereConditionString = ATI_QueryBuilderController.buildWhereCondition(filterLogic, filterCriteria);
        if(whereConditionString != null) {
            return new WOD_2.ResponseWrapper(JSON.serialize(whereConditionString),true,'');
        }else {
            return new WOD_2.ResponseWrapper('{}',false,'');
        }
    }  

    /**
    description: Method is used to build where condition for soql using filter logic and filter criteria.
    Receives filterCriteriaWrapperObject and compare value and for sub condition Ex 1  =>  Name LIKE '%Test%'
    return : Returns sub condition formed
    **/
    private static String getSubCondition(FilterCriteriaWrapper filterCriteriaWrapperObject) {
        String subCondition = '';
        if(filterCriteriaWrapperObject.fieldType == 'DATE' || filterCriteriaWrapperObject.fieldType == 'BOOLEAN') {
            subCondition = filterCriteriaWrapperObject.field + ' ' + filterCriteriaWrapperObject.operator + ' ' + filterCriteriaWrapperObject.values[0] + ' ';
        }else if(filterCriteriaWrapperObject.fieldType == 'PICKLIST' && filterCriteriaWrapperObject.values[0] != null && filterCriteriaWrapperObject.values[0] != '') {
            String pickListValues = '';
            for(String picklistValue:filterCriteriaWrapperObject.values) {
                pickListValues += '\''+String.escapeSingleQuotes(picklistValue)+'\',';
            }
            pickListValues = pickListValues.removeEnd(',');
            if(filterCriteriaWrapperObject.operator == '=') {
                subCondition = filterCriteriaWrapperObject.field + ' IN ('+pickListValues+')';
            }else if(filterCriteriaWrapperObject.operator == '!=') {
                subCondition = filterCriteriaWrapperObject.field + ' NOT IN ('+pickListValues+')';
            }
        }else if(filterCriteriaWrapperObject.operator == 'contains') {
            subCondition = filterCriteriaWrapperObject.field + ' LIKE \'%'+ String.escapeSingleQuotes(filterCriteriaWrapperObject.values[0]) + '%\'';
        }else if(filterCriteriaWrapperObject.operator == 'starts with') {
            subCondition = filterCriteriaWrapperObject.field + ' LIKE \''+ String.escapeSingleQuotes(filterCriteriaWrapperObject.values[0]) + '%\'';
        }else if(filterCriteriaWrapperObject.operator == 'ends with') {
            subCondition = filterCriteriaWrapperObject.field + ' LIKE \'%'+ String.escapeSingleQuotes(filterCriteriaWrapperObject.values[0]) + '\'';
        }else {
            subCondition = filterCriteriaWrapperObject.field + ' ' + filterCriteriaWrapperObject.operator + ' \'' + String.escapeSingleQuotes(filterCriteriaWrapperObject.values[0]) + '\'';
        }
        return subCondition;
    }
    
    @TestVisible
    private static WOD_2__Class_Override_Setting__mdt getCustomMetaData(String logicName) {
        // Access check cannot be performed since it is a Custom Metadata
        WOD_2__Class_Override_Setting__mdt customSettingData = null;
        WOD_2__Class_Override_Setting__mdt[] comArray = [SELECT MasterLabel, QualifiedApiName,WOD_2__ClassName__c,WOD_2__LogicName__c FROM WOD_2__Class_Override_Setting__mdt Where WOD_2__LogicName__c=:logicName];
        
        if(comArray.size() != 0 && comArray[0].WOD_2__ClassName__c != null)
        {
            customSettingData = comArray[0];
        }
        return customSettingData;
    }

    public class FilterCriteriaWrapper {
        public String id;                 // Id is the filterLogic Number
        public String field;
        public String operator;
        public String fieldType;
        public List<String> values;
    }
    
    public class InventoryWrapper {
        public List<sObject> data;
        public Integer recordCount;
        public InventoryWrapper(List<sObject> data,Integer recordCount) {
            this.data = data;
            this.recordCount = recordCount;
        }
    }
}