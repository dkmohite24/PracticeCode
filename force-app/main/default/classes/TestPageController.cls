public class TestPageController{
       public Account acc{set;get;}
       public boolean editSection {get;set;}
       public TestPageController(){
           
           String accid = Apexpages.currentPage().getParameters().get('id');
           acc = new Account();
           List<account> listAcc = [Select id, name, billingcity, billingstreet, billingstate, billingcountry, billingpostalcode, phone, shippingcity, shippingstate, shippingcountry, shippingstreet from account Where id =: accid ];
           
           if(listacc.size() > 0){
           acc = listAcc[0];        
           }
       }
       
       public pagereference saveAccount(){
           update acc;
           return new Pagereference('/'+acc.id);
       
       }
       public void editAccount() {
      editSection = true;
     
      }

}