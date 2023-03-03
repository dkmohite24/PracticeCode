Public class IncrementInExternalId{
    public void IncrementInExternalIdmeth(list<account>IncrementInExternalId){
    
    
    List<account> AcList=[SELECT Exeternal_ID__c FROM Account ORDER BY Exeternal_ID__c  DESC NULLS Last limit 1];
    
for(account c : IncrementInExternalId){

c.Exeternal_ID__c = AcList[0].Exeternal_ID__c+1;

}

}
    
    }