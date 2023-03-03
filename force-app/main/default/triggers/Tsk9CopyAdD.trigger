trigger Tsk9CopyAdD on Account (After insert,After update) {

    if(trigger.isAfter && trigger.isInsert){
    
    Task9copyAdressToCon copyAc = new Task9copyAdressToCon();
    copyAc.ACtoConAddress(trigger.new);
    
    }
    
    if(trigger.isAfter && trigger.isupdate){
    
    Task9copyAdressToCon copyAc = new Task9copyAdressToCon();
    copyAc.ACtoConAddress(trigger.new);
    
    }

}