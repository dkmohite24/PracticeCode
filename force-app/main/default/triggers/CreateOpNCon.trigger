trigger CreateOpNCon on Account (After insert) {
    
    if (Trigger.isafter && Trigger.isinsert){
        CreateOppNcontact ASA = new CreateOppNcontact();
        ASA.CreateOppNcontact(Trigger.new);
        
    }
    
}