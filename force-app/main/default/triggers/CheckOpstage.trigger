trigger CheckOpstage on Account (before Update) {
    if(trigger.isbefore && trigger.isupdate){
        
        CheckOpstageHandler Classnew = new CheckOpstageHandler();
          Classnew.BeforeUpdate(Trigger.new);  
    }
    
    
}