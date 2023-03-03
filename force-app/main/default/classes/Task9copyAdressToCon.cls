public class Task9copyAdressToCon{
    public void ACtoConAddress(list<account>NewAc){
    system.debug('Trigger.new'+NewAc);
    list<contact> UpdatedCon = new list<contact>();
    List<contact> SoqlCon = [SELECT id,OtherCity,OtherCountry,OtherGeocodeAccuracy,OtherPhone,OtherPostalCode,OtherState,
                                OtherStreet FROM Contact Where AccountId In:NewAc];
    system.debug('SoqlCon::::'+SoqlCon);                       
    For(account ACC: NewAc){
        if(Acc.Send_Address_to_contact__c == True){
            for(contact con: Soqlcon){
                //con.OtherAddress = Acc.BillingAddress;
                Con.OtherCity = ACC.shippingCity;
                Con.OtherCountry = Acc.ShippingCountry;
                Con.OtherPostalCode =Acc.ShippingPostalCode;
                Con.OtherState =Acc.ShippingState;
                Con.OtherStreet = Acc.ShippingStreet;
                UpdatedCon.add(con);
                }
                system.debug('UpdatedCon::::'+UpdatedCon);
            }
        }
        update UpdatedCon;
    }
}