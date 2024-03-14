/* Name: ATI_ClaimUpdateToCancelled_Scheduled
Description : ATI_ClaimUpdateToCancelled_Scheduled for ATI.
Author : Tavant (DB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (DB)     16-FEB-2021        INITIAL DEVELOPMENT                          
*/
global class ATI_ClaimUpdateToCancelled_Scheduled Implements Schedulable{
 global void execute(SchedulableContext sc){
            ATI_UpdateClaimStatusToCancelledBatch updateStatus = new ATI_UpdateClaimStatusToCancelledBatch();
            Database.executeBatch(updateStatus,1);
     }
}