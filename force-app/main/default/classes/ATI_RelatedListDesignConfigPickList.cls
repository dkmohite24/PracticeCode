/* Name: ATI_RelatedListDesignConfigPickList
Description : Override class to select related list in community page
Author : TAVANT
History:
Test Class: ATI_RelatedListDesignConfigPLTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_RelatedListDesignConfigPickList extends VisualEditor.DynamicPickList {
/*
    Method Name :   getDefaultValue
    Description :   method to get default value
*/
public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('SELECT', 'SELECT');
    return defaultValue;
}

/*
    Method Name :   getValues
    Description :   method to get all related lists in metadata
*/
public override VisualEditor.DynamicPickListRows getValues() {
    List<ATI_RelatedListConfiguration__mdt> configurationSettingMetaData =  this.getRelatedListSettingMetaData();
    VisualEditor.DynamicPickListRows dynamicPicklistRows = new VisualEditor.DynamicPickListRows();
    if(configurationSettingMetaData != null && configurationSettingMetaData.size() > 0 ) {
        for(ATI_RelatedListConfiguration__mdt rlmetadataObject : configurationSettingMetaData) {
            VisualEditor.DataRow dataRowObject = new VisualEditor.DataRow(rlmetadataObject.DeveloperName,rlmetadataObject.DeveloperName);
            dynamicPicklistRows.addRow(dataRowObject);
        }
    }
    return dynamicPicklistRows;
}

/*
    Method Name :   getRelatedListSettingMetaData
    Description :   method to get all related lists in metadata
*/
private List<ATI_RelatedListConfiguration__mdt> getRelatedListSettingMetaData() {
    List<ATI_RelatedListConfiguration__mdt> configurationSettingMetaData = null;
    try{
        ATI_RelatedListConfiguration__mdt[] configrationArray = [SELECT DeveloperName FROM ATI_RelatedListConfiguration__mdt];
        if(configrationArray.size() > 0) {
            configurationSettingMetaData = configrationArray;
        }
    }catch(Exception e) {
        system.debug('Exception in Error in getConfigurationSettingMetaData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
    }
    return configurationSettingMetaData; 
}
}