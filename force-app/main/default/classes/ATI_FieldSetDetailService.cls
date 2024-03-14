/* Name: ATI_FieldSetDetailService
Description : This class is used to get fieldset details
Author : TAVANT
History:
Test Class: ATI_CustomRelatedListCompControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public class ATI_FieldSetDetailService {
    /*
        Method Name :   fetchFieldSetDetails
        Params      :   objectName, fieldSetName
    */
    public static List<FieldSetDetailsWrapper> fetchFieldSetDetails(String objectName, String fieldSetName){
        List<FieldSetDetailsWrapper> fieldSetDetailsWrapperlst = new List<FieldSetDetailsWrapper>();
        try{
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Map<String,Schema.SObjectField> fieldsTokenMap = objectType.getDescribe().fields.getMap();
            System.debug('Object Name ' + objectName);
            System.debug('fieldSetName' + fieldSetName);
            System.debug('objectType ' + objectType);
            System.debug('Fieldset ' + objectType.getDescribe().fieldSets.getMap().get(fieldSetName).getFields());
            
            List<Schema.FieldSetMember> fieldSetMemberList =  objectType.getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
            List<String> ignoreFieldList = new List<String>{'CreatedBy','LastModifiedBy'};
                for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                    FieldSetDetailsWrapper fieldSetDetailsWrapperObj = new FieldSetDetailsWrapper();
                    fieldSetDetailsWrapperObj.label = fieldSetMemberObj.getLabel();
                    fieldSetDetailsWrapperObj.fieldpath = fieldSetMemberObj.getFieldPath();
                    fieldSetDetailsWrapperObj.type = String.valueof(fieldSetMemberObj.getType());
                    String helpText = '';
                    if(fieldSetDetailsWrapperObj.fieldpath.contains('.') && ignoreFieldList.contains(fieldSetDetailsWrapperObj.fieldpath.split('\\.')[0])) {
                        helpText = '';
                    }else if(fieldSetDetailsWrapperObj.fieldpath.contains('.')) {
                        // String refObjectName = fieldSetDetailsWrapperObj.fieldpath.split('\\.')[0].replace('__r','__c');
                        // String refObjectFieldName = fieldSetDetailsWrapperObj.fieldpath.split('\\.')[1];
                        // helpText = Schema.getGlobalDescribe().get(refObjectName).getDescribe().fields.getMap().get(refObjectFieldName).getDescribe().getInlineHelpText();
                        System.debug(helpText);
                    }else {
                        helpText = (fieldsTokenMap.get(fieldSetDetailsWrapperObj.fieldpath)).getDescribe().getInlineHelpText();
                    }
                    fieldSetDetailsWrapperObj.inlineHelpText = helpText != null ? helpText : '';
                    System.debug('IT '+fieldSetDetailsWrapperObj.inlineHelpText);
                    /*if(fieldSetDetailsWrapperObj.type==String.valueof(Schema.DisplayType.Reference)) {
                        List<Schema.sObjectType> parentReferenceList = (fieldsTokenMap.get(fieldSetDetailsWrapperObj.fieldpath)).getDescribe().getReferenceTo();
                        List<string> parentReferenceListNames = new List<string>();
                        for(Schema.sObjectType parentreference : parentReferenceList) {
                            parentReferenceListNames.add(parentReferenceList.get(0).getDescribe().getName());
                        }
                        fieldSetDetailsWrapperObj.parentReferenceList = parentReferenceListNames;
                    }*/
                    fieldSetDetailsWrapperObj.dbrequired = fieldSetMemberObj.getDBRequired();
                    fieldSetDetailsWrapperObj.required = fieldSetMemberObj.getRequired();
                    fieldSetDetailsWrapperlst.add(fieldSetDetailsWrapperObj);
                }
            System.debug(' fieldSetDetailsWrapperlst BC'+fieldSetDetailsWrapperlst);
        } Catch(Exception e){
            System.debug(' Error Message in fetchFieldSetDetails ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return fieldSetDetailsWrapperlst;
    }
    
    public class FieldSetDetailsWrapper {
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string fieldpath;
        @AuraEnabled
        public string type;
        @AuraEnabled
        public boolean dbrequired;
        @AuraEnabled
        public boolean required;
        @AuraEnabled
        public List<string> parentReferenceList;
        @AuraEnabled
        public String inlineHelpText;
    }
    
}