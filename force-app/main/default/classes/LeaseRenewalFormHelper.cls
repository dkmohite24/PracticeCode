public class LeaseRenewalFormHelper {
    public Boolean renewLease {get;set;}
    public Boolean agreeToRaise {get;set;}
    public Boolean showRaisingRent  {get;set;}
    public boolean xyz{get;set;}
    public boolean bool{get;set;}
    public Void leaseRenewal(){ 
        system.debug(renewLease);
        showRaisingRent = false; 
        if (renewLease == true){ 
            showRaisingRent = true;
        }
        //return showRaisingRent;
    
    
    }
}