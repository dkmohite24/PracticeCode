trigger Task10Val on Task10__c (Before insert, Before update) {

    If(Trigger.isBefore && Trigger.isInsert){
         task10valationTRI VALTK = new  task10valationTRI();
         Valtk.Task10ValMeth(Trigger.new);
    }

}