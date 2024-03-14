/*Name: ATI_REST_BatchClaimSubmittalResponse
Description : This class is used for mapping the BatchClaimSubmittal JSON response 
Author : Tavant(TY)
History:
VERSION     AUTHOR             DATE             	DETAIL                 UserStory/Req#
1.0 -     Tavant(TY)       	08/02/2021     	  INITIAL DEVELOPMENT                              
*/
global class ATI_REST_BatchClaimSubmittalResponse{
    global String status;
    global String message;
    global String interfaceName;
    global List<ResponseData> data;
    global class ResponseData{
        global String name;
        global String transactionId;
        global String message;
        global String identifier;
    }
    global ATI_REST_BatchClaimSubmittalResponse(){
        
    }
}