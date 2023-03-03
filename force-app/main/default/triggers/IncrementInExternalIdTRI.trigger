trigger IncrementInExternalIdTRI on Account (before insert,before update) {


    if(trigger.isBefore && trigger.isinsert){
        
      IncrementInExternalId a = new IncrementInExternalId();
      a.IncrementInExternalIdmeth(trigger.new);
    
    }
    }