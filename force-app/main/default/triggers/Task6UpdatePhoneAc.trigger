trigger Task6UpdatePhoneAc on Contact (After update,After insert) {
   
    if(trigger.isAfter && trigger.isupdate){
    
        Task6AccountPhoneTri NewConTri = new Task6AccountPhoneTri();
        NewconTri.AccountPhoneContact(trigger.new,trigger.old,Trigger.newMap,Trigger.oldMap);
        }
}