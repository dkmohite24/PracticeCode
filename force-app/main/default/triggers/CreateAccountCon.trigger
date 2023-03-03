trigger CreateAccountCon on Account (After insert,After Update) {

    If(trigger.isAfter && trigger.isInsert)
    {
        InsertAccountContactTRI a = new InsertAccountContactTRI();
        a.InsertAccountContactTRIMeth(trigger.new);
    }
}