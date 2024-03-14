/*
	Class Name	:	ATI_RejectClaimsOnOverDueShipmentSchdl
	Description	:	Scheduler class for ATI_RejectClaimsOnOverDueShipment Batch apex
*/
global class ATI_RejectClaimsOnOverDueShipmentSchdl Implements System.Schedulable {
	global void execute(SchedulableContext sc){
            ATI_RejectClaimsOnOverDueShipment batchJobObj = new ATI_RejectClaimsOnOverDueShipment();
			Database.executeBatch(batchJobObj,1);
     }
}