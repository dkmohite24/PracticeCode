public class TrainingCreateRecord {
    String lastName;
    String email;
    String company;
    public TrainingCreateRecord(String lastName, String email, String company){
        this.lastName = lastName;
        this.email = email;
        this.company = company;
        
    }
    
    
    public void InsertLeadRecords (){
        List<Lead> LeadList = new List<Lead>();
        for(integer i=0; i<5; i++){
            Lead objLead = new Lead();
            objLead.LastName = lastName+i;
            objLead.Company = company+i;
            objLead.Email = email+i;
            LeadList.add(objLead);
            system.debug('LeadList+++'+LeadList);
            
        }
        insert LeadList;
        
    }
    public void InsertcontactRecord (){
        Contact objCon = new Contact();
        objCon.LastName = lastName;
        objCon.Email = email;
        insert objCon;
        System.debug('Contact++'+objCon);
    }
    public void InsertAccountRecord (){
        Account objAcc = new Account();
        objAcc.Name = lastName;
        objAcc.Email__c = email;
        insert objAcc;
        System.debug('objAcc++'+objAcc);
    } 
    public void UpdateLead (){
		lead Ld = new Lead(Id='00Q2w000007nixaEAA',Email= 'KJNKJAK@jnd.com');
        System.debug(ld);
        update ld;
        
    }
    
    public void deleteLead (){
		lead Ld = new Lead(Id='00Q2w000007nixaEAA');
        System.debug(ld);
        delete ld;
        
    }
    
    
    //create a new method to create account in org. Accept Account name in method's paramter.
    
    
    // Contact
    
    
    //create a method to insert 5 lead records from that method.
    
    
    
}