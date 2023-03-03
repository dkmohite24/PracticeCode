Public Class SendEmailToOwner{
    Public void SendEmailOpportunity(list<Opportunity>oldOP , list<Opportunity>newOP){
    list<string>TosendEmail;
        for(Opportunity OpNew: newOP){
            for(Opportunity Opold: OldOP){
               if(OpNew.stageName != Opold.stageName){
               TosendEmail.Add(OpNew.owner.id);
               }
            }
            
         }   
    }
}