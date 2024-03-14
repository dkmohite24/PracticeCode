/* Name: ATI_WRDetailPageUrlLocatorOverride
Description : This class is used for warranty reg detail page override 
Author : Manoj Paul(MP)
History:
Test Class :    ATI_WRDetailPageUrlLocatorOverrideTest
VERSION     AUTHOR                 DATE                            DETAIL                                    UserStory/Req#
1.0 -     Tavant(MP)             04/12/2020                  INITIAL DEVELOPMENT                              
*/
public with sharing class ATI_WRDetailPageUrlLocatorOverride implements ATI_DetailPageUrlLocatorInterface {
    /*
        Method Name :   getURL
        Params      :   recordId
    */
    @AuraEnabled
    public static String getURL(String recordId) {
        String redirectURL = '';
        Boolean hasAccess = false;
    
        // check record read access is there for the dealer or not
        List<UserRecordAccess>  accessRecords = [SELECT HasReadAccess,RecordId FROM UserRecordAccess WHERE RecordId =:  recordId AND UserId =:UserInfo.getuserId()];
        if(!accessRecords.isEmpty()) {
            hasAccess = accessRecords[0].HasReadAccess;
        }
        return ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'WarrantyRegistrationDetailPage');
    }
}