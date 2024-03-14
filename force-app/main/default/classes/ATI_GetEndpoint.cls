/* Name: ATI_GetEndpoint
Description : To Fetch Organization Details
Author : Tavant (TY)
History:
VERSION     AUTHOR               DATE                 DETAIL                UserStory/Req#
1.0 -     Tavant (TY)         Mar 25th 2021       INITIAL DEVELOPMENT
*/

public class ATI_GetEndpoint{
    
    /************************************************************
	A Method for checking whether the Org is SandBox Or Prdouction
	*************************************************************/
    public static Boolean isSandbox(){
        Organization orgDetails = [Select id,isSandBox From Organization LIMIT 1];
        if(orgDetails.isSandBox == true){
            return true;           
        }
        else {
            return false;
        }
    }
    
    
    /**************************************
	A Method for getting the Endpoint Url
	***************************************/
    public static String  getURL(String processName) {
        String connectionType;
        if(isSandbox()){
            connectionType = 'Sandbox';
        } else {
            connectionType = 'Production';
        }
        ATI_Integration_Endpoint__mdt integrationEndpointList = [Select id, ATI_URL__c,ATI_Api_Key__c,ATI_Connection_Type__c FROM ATI_Integration_Endpoint__mdt WHERE MasterLabel = :processName AND ATI_Connection_Type__c = :connectionType AND ATI_isActive__c = true LIMIT 1];
        if(integrationEndpointList != null){
            return integrationEndpointList.ATI_URL__c;
        } else{
            return ''; 
        }
    }
}