public class NotEXID{
public void NotoEXID(){



list<account>obj = new list<account>();
integer i = 0;
obj = [SELECT Exeternal_ID__c FROM Account where Exeternal_ID__c = null ORDER BY name asc];
    system.debug('listofaccount'+obj);
list<account>letestID = new list<account>();
letestID =[SELECT Exeternal_ID__c FROM Account ORDER BY Exeternal_ID__c DEsc NULLS LAST limit 1];
list<account>newlist = new list<account>();

for (account ac: obj){
    ac.Exeternal_ID__c = newlist[0].Exeternal_ID__c+i;
    newlist.add(ac);}
update newlist;
}}