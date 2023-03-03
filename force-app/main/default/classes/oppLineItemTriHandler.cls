public class oppLineItemTriHandler {
    public void oppInsertProdectAfterInsert(list<opportunity>triNEW){
        
        list<opportunityLineItem> olilist= new list<OpportunityLineItem>();
    List<PriceBookEntry> priceBookList = [SELECT Id, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2Id = '01t2w000009Vx7UAAS' AND PriceBook2.isStandard=true LIMIT 1];
    for(opportunity op:triNEW){
        OpportunityLineItem oli= New OpportunityLineItem();
        oli.OpportunityId = op.ID;
        oli.PricebookEntryId = priceBookList[0].Id;
        olilist.add(oli);
    }
    if(olilist!=null&&olilist.size()>0)
        insert olilist;
    } 

}