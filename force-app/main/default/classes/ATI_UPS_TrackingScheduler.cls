/*
	Class Name	:	ATI_UPS_TrackingScheduler
	Description	:	Scheduler class for ATI_UPS_TrackingBatch , which runs at 8AM,12PM,4PM,8PM.... at every 4 hrs 
	Developed On:	1st June 2021
	Author		: 	TAVNT (RSG)
*/
global class ATI_UPS_TrackingScheduler implements Schedulable {
	global static String sched = '0 0 0,4,8,12,16,20 ? * *'; 

    global static String scheduleUPSTrackingBatch() {
        String sched = '0 0 0,4,8,12,16,20 ? * *'; 
        ATI_UPS_TrackingScheduler SC = new ATI_UPS_TrackingScheduler(); 
        return System.schedule('Shipment Tracking -UPS :'+ System.currentTimeMillis(), sched, SC);  
    }

    global void execute(SchedulableContext sc) {
        ATI_UPS_TrackingBatch upsTrackingBatch = new ATI_UPS_TrackingBatch();
        Database.executeBatch(upsTrackingBatch,1);           
    }
}