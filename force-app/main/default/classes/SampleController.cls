public class SampleController {
    public Lead member {get;set;}
    
    public SampleController() {
        member = new Lead();
        System.debug('Lead'+member);
    }
    
    public void sav(){
        insert member;
        member = new Lead();
    }
}