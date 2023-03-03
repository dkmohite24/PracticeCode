Global class BatchAdressKIm implements database.BAtchable<sobject>,Database.stateful {
    string Var = 'KIm%';
    Global Database.QueryLocator Start(Database.BatchableContext Bc){
        Return database.getQuerylocator('SELECT CreatedById,Email__c,Id,Jigsaw,Name,Owner.name,Phone FROM Account where Name like :var ');
                                           
    } 
    Global void execute(Database.batchableContext bc, list<Account>Scope ){
        List<account> ListUpdated = New List<account>();
        For(Account Acc:Scope){
            Acc.name = 'Miss '+Acc.name+' kadarshian';
            /*If (Acc.Email__c == null){
                Acc.Email__c = Acc.name+'@gmail.com';
            }*/
            ListUpdated.Add(acc);
        }
        Update ListUpdated;
        System.debug('ListUpdated***'+ListUpdated);
    }
    Global Void Finish(Database.Batchablecontext Bc){
        
        AsyncApexJob A = [SELECT CompletedDate,CreatedBy.name, CreatedBy.Email,CreatedDate,Id,JobItemsProcessed,JobType,MethodName,NumberOfErrors,Status,TotalJobItems FROM AsyncApexJob  Where Id = :bc.getChildJobId()];
         //List<Messaging.SingleEmailMessage> Emails=new List<Messaging.SingleEmailMessage>();
        Messaging.singleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{a.CreatedBy.Email};
        Mail.settoAddresses(toAddress);
        
        Mail.SetSubject('Apex Job Status '+ A.status);
        Mail.setplainTextBody('The total number of apex job Proccessed'+A.JobItemsProcessed+'with Number of Failuer: '+A.NumberOfErrors +'Total number Itom'+A.TotalJobItems+ 'Method NAme'+A.MethodName);
        //EmailS.Add(Mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    

}