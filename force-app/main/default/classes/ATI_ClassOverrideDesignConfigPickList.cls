/* Name: ATI_ClassOverrideDesignConfigPickList
Description : This class is used in community builder to select class override setting metadata record
Author : TAVANT
History:
Test Class: ATI_ClassOverrideDesignConfigPLTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_ClassOverrideDesignConfigPickList extends VisualEditor.DynamicPickList {
    public override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('SELECT', 'SELECT');
        return defaultValue;
    }
    public override VisualEditor.DynamicPickListRows getValues() {
        List<WOD_2__Class_Override_Setting__mdt> configurationSettingMetaData =  this.getRelatedListSettingMetaData();
        VisualEditor.DynamicPickListRows dynamicPicklistRows = new VisualEditor.DynamicPickListRows();
        if(configurationSettingMetaData != null && configurationSettingMetaData.size() > 0 ) {
            for(WOD_2__Class_Override_Setting__mdt rlmetadataObject : configurationSettingMetaData) {
                VisualEditor.DataRow dataRowObject = new VisualEditor.DataRow(rlmetadataObject.DeveloperName,rlmetadataObject.DeveloperName);
                dynamicPicklistRows.addRow(dataRowObject);
            }
        }
        return dynamicPicklistRows;
    }
    
    private List<WOD_2__Class_Override_Setting__mdt> getRelatedListSettingMetaData() {
        List<WOD_2__Class_Override_Setting__mdt> configurationSettingMetaData = null;
        try{
            WOD_2__Class_Override_Setting__mdt[] configrationArray = [SELECT DeveloperName FROM WOD_2__Class_Override_Setting__mdt];
            if(configrationArray.size() > 0) {
                configurationSettingMetaData = configrationArray;
            }
        }catch(Exception e) {
            system.debug('Exception in Error in getConfigurationSettingMetaData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return configurationSettingMetaData;
    }
}