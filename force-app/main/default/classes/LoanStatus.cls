Public Class LoanStatus{
    public void LoanStatusMeth(list<case>TgNew){
    List<Loan_Applicant__c> Newlist = new List<Loan_Applicant__c>();
    list<Loan_Application__c> NewlistAp = new list<Loan_Application__c>();
    list<Id> ApplicantId = New List<Id>();
    list<id> ApplicationId = New list<id>();
    for(case TGId : TgNew){
      ApplicantId.add(TGID.Applicant_Name__c);
        
    }
    system.debug('id'+ApplicantId);
    list<Case>TGCase = [select id ,Applicant_Name__c, recordtype.name ,recordtypeid,status from case where Applicant_Name__c In:ApplicantId];
    List<Loan_Applicant__c> SoqlApplicant = [select id, name,Current_Address_Case_Status__c,Office_Address_Case_Status__c,
                       Parmenent_Address_case_Status__c,loan_Application__c from Loan_Applicant__c where id IN:ApplicantId];
    
    system.debug('soql'+SoqlApplicant);
    for(Loan_Applicant__c LA : SoqlApplicant){
           ApplicationId.add(LA.Loan_Application__c);
           system.debug('ApplicationId'+ApplicationId);
       for(case Cg:TGCase){
       system.debug('cg.Applicant_Name__c'+cg.Applicant_Name__c);
       system.debug('Cg.recordtype.name'+Cg.recordtype.name);
       system.debug('Cg.Status'+Cg.Status);

       system.debug('LA.Current_Address_Case_Status__ce'+LA.Current_Address_Case_Status__c);

       system.debug('Cg.recordtype.name'+Cg.recordtype.name);
       
          if(cg.Applicant_Name__c == LA.Id ){
           system.debug('cg.Applicant_Name__c'+cg.Applicant_Name__c);
           system.debug('LA.Id'+LA.Id);          
               if(Cg.recordtype.name =='current Address of Aplicant'){
                   LA.Current_Address_Case_Status__c = Cg.Status;
                   system.debug('LA.Current_Address_Case_Status__c'+LA.Current_Address_Case_Status__c);

               }
               else if(Cg.recordtype.name == 'Office Address of Aplicant'){
                   LA.Current_Address_Case_Status__c = Cg.Status;
                   system.debug('LA.Current_Address_Case_Status__c'+LA.Current_Address_Case_Status__c);
               }
               else if(Cg.recordtype.name == 'Permanent Address of Applicant'){
                   LA.Parmenent_Address_case_Status__c = Cg.Status;
                   system.debug('LA.Parmenent_Address_case_Status__c'+LA.Parmenent_Address_case_Status__c);
               }
               Newlist.add(LA);
          }
          
       } 
   }
   
   update Newlist;
     List<Loan_Application__c> SoqlApplication = [select id, name,Current_Address_Case_Status__c,Office_Address_Case_Status__c,
                         Parmenent_Address_case_Status__c from Loan_Application__c where ID IN:ApplicationId];
                         
      for(Loan_Application__c APP : SoqlApplication){
         
               for(case Cgg:TGCase){
                
                       if(Cgg.recordtype.name =='current Address of Aplicant'){
                           APP.Current_Address_Case_Status__c = Cgg.Status;
                       }
                       else if(Cgg.recordtype.name == 'Office Address of Aplicant'){
                           APP.Current_Address_Case_Status__c = Cgg.Status;
                       }
                       else if(Cgg.recordtype.name == 'Permanent Address of Applicant'){
                           APP.Parmenent_Address_case_Status__c = Cgg.Status;
                       }
                       NewlistAp.add(app);
                  
               } 
               
            
        } 
        
        update NewlistAp;                       
    
      }

}