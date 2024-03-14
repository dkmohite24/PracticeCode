/* Name: LoggableInterface
   Description : Interface to Support Logging feature for integration and other System Errors. 
   Author : Tavant (TY)
   History :
   VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
   1.0 -       Tavant (TY)    24/11/2020          INITIAL DEVELOPMENT
 */
public interface ATI_LoggableInterface {
    WOD_2.ResponseWrapper processType(String editedResponseJSON);
}