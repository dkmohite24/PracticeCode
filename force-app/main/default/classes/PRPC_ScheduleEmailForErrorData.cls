global class PRPC_ScheduleEmailForErrorData implements Schedulable {
    global void execute(SchedulableContext sc) {
        PRPC_EmailForErrorData.sendEmail();
        PRPC_EmailForErrorData.sendEmailToCustomers();
    }
}