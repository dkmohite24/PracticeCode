public class MultipleInsertAc{
        public static void multipleInsertAcMeth(){
        
        list<Account> listAc = new list<Account>();
        for(integer i=0; i<=100; i++)            
        {
                Account a = new account ();

                    a.name = 'kyllie'+i;
                    a.phone = '144444'+i;
                    a.Active__c = 'Yes';
                    //A.Fax = '555542';
                    a.Industry = 'Communications';
                    a.SLAExpirationDate__c = system.today();
                    //A.DunsNumber = '1455';
                    
                    //A.city ='kota'+i;
                    ListAc.add(a);
                    
                    
                    
                    
         }
        system.debug('listofAccount'+listAc); 
        Insert listAc;
        
        }

}