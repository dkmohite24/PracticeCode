public class noToEXID{
public void noToEXIDMeth(){


list<account>obj = new list<account>();
obj = [SELECT Exeternal_ID__c FROM Account where Exeternal_ID__c = null ORDER BY name asc];
    system.debug('listofaccount'+obj);
list<account>newlist = new list<account>();
for (account ac: obj){
    ac.Exeternal_ID__c = 'mm-0'+1;
newlist.add(ac);
}
update newlist;






}
}