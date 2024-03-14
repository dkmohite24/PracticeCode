/* Name: ATI_ClaimStarusUpdateToReject_Scheduled
Description : ATI_ClaimStarusUpdateToReject_Scheduled for ATI.
Author : Tavant (MB)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (MB)     21-JAN-2021        INITIAL DEVELOPMENT							
*/
global class ATI_ClaimStarusUpdateToClosed_Scheduled Implements Schedulable{
	 global void execute(SchedulableContext sc){
            ATI_UpdateClaimStatusToClosedBatch updateStatus = new ATI_UpdateClaimStatusToClosedBatch();
			Database.executeBatch(updateStatus,100);
     }
}