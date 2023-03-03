trigger AdminDelete on Account (Before delete) {
    if(trigger.isbefore && trigger.isdelete){
        Task8deleteaProfile Acc = new Task8deleteaProfile();
        Acc.DeleteOnlyAdmin(trigger.new);
        }
}