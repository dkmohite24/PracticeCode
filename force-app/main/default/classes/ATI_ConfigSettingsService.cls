/* Name: ATI_ConfigSettingsService
Description : This class is used to get configuration setting
Author : TAVANT
History:
Test Class: ATI_CustomRelatedListCompControllerTest
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public with sharing class ATI_ConfigSettingsService {
    /*
        Method Name :   getClassOverrideSettingMetaData
        Params      :   logicname
    */
    public static WOD_2__Class_Override_Setting__mdt getClassOverrideSettingMetaData(String logicName) {
        WOD_2__Class_Override_Setting__mdt customSettingData = null;
        WOD_2__Class_Override_Setting__mdt[] comArray = [SELECT MasterLabel, QualifiedApiName,WOD_2__ClassName__c,WOD_2__LogicName__c FROM WOD_2__Class_Override_Setting__mdt Where WOD_2__LogicName__c=:logicName];
        if(comArray.size() != 0 && comArray[0].WOD_2__ClassName__c != null)
        {
            customSettingData = comArray[0];
        }
        return customSettingData;
    }   
    
    /*
        Method Name :   getRelatedListSettingMetaData
        Params      :   metadataRecordAPIName
    */
     public static List<ATI_RelatedListConfiguration__mdt> getRelatedListSettingMetaData(String metadataRecordAPIName) {
        List<ATI_RelatedListConfiguration__mdt> configurationSettingMetaData = null;
        try{
            metadataRecordAPIName =  metadataRecordAPIName;
            // Access check cannot be performed since it is a Custom Metadata
            ATI_RelatedListConfiguration__mdt[] configrationArray = [SELECT DeveloperName,ATI_FieldsetName__c,ATI_Limit__c,ATI_Orderby__c,ATI_Class_Override_Setting__r.WOD_2__ClassName__c,ATI_ObjectName__c,ATI_Reference_Field__c,ATI_Related_List_Heading__c,ATI_ButtonComponentName__c,(Select HyperLinkFieldPath__c,RedirectUrl__c from HyperLinkConfigurations__r) 
                                                                    FROM ATI_RelatedListConfiguration__mdt WHERE QualifiedApiName =: metadataRecordAPIName];
            if(configrationArray.size() > 0) {
                configurationSettingMetaData = configrationArray;
            }
        }catch(Exception e) {
            system.debug('Exception in Error in getConfigurationSettingMetaData' + ' Error Message - ' + e.getMessage() + ' Line # ' + e.getLineNumber());
        }
        return configurationSettingMetaData; 
    }
}