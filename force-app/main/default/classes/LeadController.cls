public with sharing class LeadController {
    
    public Lead c { get; set; }
    
    
    public LeadController(){
        lead c=new Lead();
        system.debug('Lead'+c);     
    }
    public void save() {
        
        insert c;
        
    }
}