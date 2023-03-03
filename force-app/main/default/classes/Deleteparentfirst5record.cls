public class Deleteparentfirst5record{
    public static void Deleteparentfirst5recordmeth(){
    
    list<Parent__c>listfirst5 = new list<parent__c>();
    listfirst5=[SELECT Address__c,Email_Address__c,Id,name,Mobile_number__c 
                FROM Parent__c Where Name like'k%' order by createddate ASC limit 5];
                system.debug('Listoffirst5record'+listfirst5);
                
                delete listfirst5;
                }}