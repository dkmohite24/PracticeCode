/**
** Created By : Asish Nayak
**/
global class PRPC_SendNotificationSchedule implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    	PRPC_EmailForDefaulters.sentEmail(); 
    	PRPC_SendNotificationToDistributor.sentEmail();
        PRPC_SendNotificationForCustomerData.sentEmail();

    }
}