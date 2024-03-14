/* Name: ATI_ClaimDetailPageUrlLocatorController
Description : This class is used to redirect to claim detail page
Author : TAVANT
Test Class : ATI_ClaimDetailPageUrlLocatorTest
History:
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public without sharing class ATI_ClaimDetailPageUrlLocatorController implements ATI_DetailPageUrlLocatorInterface {
    /*
        Method Name :   getURL
        Parameters  :   recordId -> record Id whose detail page needs to be opened.
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
        
        List<String> fieldsForClaim = new List<String> {'RecordType.DeveloperName'};
        String sObjName = 'WOD_2__Claim__c';
        ATI_Utils.NoAccessObjectFieldWrapper noAccessObjectFieldWrapperObject = ATI_Utils.fetchReadAccess(sObjName,fieldsForClaim);
        WOD_2__Claim__c claim = new WOD_2__Claim__c();
        if(noAccessObjectFieldWrapperObject.noAccessObjectList.size() == 0 && noAccessObjectFieldWrapperObject.noAccessFieldList.size() == 0)
        {
            claim = [SELECT RecordType.DeveloperName FROM WOD_2__Claim__c WHERE Id =: recordId];
        }
        if(hasAccess) {
            /*if(claim.RecordType.DeveloperName == 'Machine') { 
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ClaimDetailPage');
            }else if(claim.RecordType.DeveloperName == 'Part') {
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ClaimDetailPagePart'); 
            }else if(claim.RecordType.DeveloperName == 'Campaign') {
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ClaimDetailPageCampaign'); 
            }else if(claim.RecordType.DeveloperName == 'Claim_Template') {
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ClaimDetailPageCampaign'); 
            }*/
            return 'claim record is shared';
        }else{
            if(claim.RecordType.DeveloperName == 'Machine') {  
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ATI_ClaimDetailPageMachineWithoutAccess');
            }else if(claim.RecordType.DeveloperName == 'Part') { 
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ATI_ClaimDetailPagePartWithoutAccess');
            }else if(claim.RecordType.DeveloperName == 'Campaign') { 
                redirectURL = ATI_DetailPageUrlLocatorController.getURLFromMetadata(recordId, 'ATI_ClaimDetailPageCampaignWithoutAccess');
            }
        }
        return redirectURL;
    }
}