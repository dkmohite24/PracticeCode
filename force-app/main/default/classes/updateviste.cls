public Class updateviste{
public void updateVisitemeth(){

List<Visit__c>Vupdate = new list<Visit__c>();
Vupdate = [SELECT Name,Visit_Date__c,Account__c,Type_of_Visit__c FROM Visit__c order by name asc];

/*List<Visit__c>newlist = new list<Visit__c>();

for(Visit__c NewName:Vupdate)
{
integer X = 001;
x++;
NewName.name = ''+x;
NewName.Type_of_Visit__c = 'Call';
NewName.Visit_Date__c = System.now();

newlist.add(NewName);

}
update newlist;*/
delete Vupdate;
}


}