/* Name: ATI_REST_UnitHistoryUpdateSchedulable
Description : ATI_REST_UnitHistoryUpdateSchedulable - schedules ATI_REST_UnitHistoryUpdateBatch class for sending claim and Inventory details
History:
VERSION     AUTHOR               DATE                  DETAIL             UserStory/Req#
1.0 -     Tavant(TY)          Mar 26th 2021      INITIAL DEVELOPMENT
*/
global class ATI_REST_UnitHistoryUpdateSchedulable implements Schedulable{
    //Job runs everyday at midnight
    public static String cron_exp = '0 0 0 1/1 * ? *';
    global void execute(SchedulableContext sc) {
        ID batchJobId = Database.executeBatch(new ATI_REST_UnitHistoryUpdateBatch(),Integer.valueOf(Label.ATI_UnitHistoryUpdate_Batch_Count));
    }
}