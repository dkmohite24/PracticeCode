/* Name: ATI_ClaimStarusUpdateToReject_Scheduled
Description : ATI_ClaimStarusUpdateToReject_Scheduled for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     21-JAN-2021        INITIAL DEVELOPMENT							
*/
global class ATI_ClaimStarusUpdateToReject_Scheduled Implements Schedulable{
	 global void execute(SchedulableContext sc){
            ATI_UpdateClaimStatusToRejectBatch updateStatus = new ATI_UpdateClaimStatusToRejectBatch();
			Database.executeBatch(updateStatus,1);
     }
}