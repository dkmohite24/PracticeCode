/**************************************************************************************
// Name          : ATI_QueueableUtil 
// Date          : March 25 , 2021 
// Description   : This utility checks to see if you're in a Queueable context. If so,
// 				 : your job will be added to a queue to be executed, and if you're not, 
// 				 : you'll be queued normally, found it on 
// 				 : https://salesforce.stackexchange.com/questions/188774/chaining-queueables-clarification-practical-usage
// 				 : in order to test the chained Queueable Apex.
//               :
// Author        : Brian Fear - @brianmfear - https://sfdcfox.blogspot.com/
// Revisions     : 
//               : 
***************************************************************************************/
public class ATI_QueueableUtil implements Queueable {
    Queueable[] payload;
    static ATI_QueueableUtil self;
    ATI_QueueableUtil(Queueable item) {
        payload = new Queueable[] { item };
    }
    public static Id enqueueJob(Queueable item) {
        if(!System.isQueueable()) {
            return System.enqueueJob(new ATI_QueueableUtil(item));
        } else {
            self.payload.add(item);
            return null;
        }
    }
    public void execute(QueueableContext context) {
        self = this;
        payload.remove(0).execute(context);
        if(!payload.isEmpty()) {
            System.enqueueJob(this);
        }
    }
}