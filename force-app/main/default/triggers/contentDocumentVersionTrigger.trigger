trigger contentDocumentVersionTrigger on ContentVersion (after insert) {       
        if(trigger.IsAfter)  
        {
            if(trigger.isInsert)
            {
                contentDocumentVersionHandler.onAfterInsert(Trigger.new);
            }
        }
}