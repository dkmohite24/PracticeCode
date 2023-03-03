public class SampleController1 {
    public lead member {get;set;}
    
    public SampleController1() {
        member = new Lead();
        system.debug('lead33'+member);
    }
    
    public void sav(){
        insert member;
        
        system.debug('lead33'+member);
        member = new Lead();
    }
}