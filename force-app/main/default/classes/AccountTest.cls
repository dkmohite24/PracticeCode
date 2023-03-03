/*
       Name            :    AccountTest
       Author          :    Anavclouds (Dhananjay mohite)
       Date            :    6th April 2021
       Description     :  For (Editepage Assignment)  This class will be binded with vf page test_page. This will be used to create a page for accounts, which can be edited and the autopopulated records can be saved.
            <apex:pageBlockSection>
                <chatter:feedWithFollowers entityId="0012w00000Wvm9nAAB"/>
            </apex:pageBlockSection>

*/

public class AccountTest
{
    public Account acc{set;get;}
    public boolean editSection {get;set;}
    public AccountTest(){
        
        String accid = Apexpages.currentPage().getParameters().get('id');
        acc = new Account();
        List<account> listAcc = [Select id, name,BillingLatitude,AnnualRevenue,Site,CreatedById,CreatedBy.name,CreatedDate,Email__c,Fax,Industry,OwnerId, billingcity, billingstreet, billingstate, billingcountry, billingpostalcode, phone, shippingcity, shippingstate, shippingcountry, shippingstreet from account Where id =: accid ];
        
        if(listacc.size() > 0){
            acc = listAcc[0];        
        }
    }
    
    public pagereference saveAccount(){
        update acc;
        return new Pagereference('/'+acc.id);
        
    }
    
    public PageReference EdittheSection()
    {
        editSection = true;
        return null;
    }
}