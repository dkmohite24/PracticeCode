trigger DublicateTriggerProduct on Product2 (before insert,before update) {
    If(trigger.isbefore&& trigger.isupdate){
        dublicateTriggerHandlerProduct.dublicatecheck(trigger.new);
    }

}