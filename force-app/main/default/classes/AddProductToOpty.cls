Public class AddProductToOpty{
    Public void AddlineItom(list<Opportunity>OPTY){

            OpportunityLineItem[] lines = new OpportunityLineItem[0];
            PricebookEntry entry = [SELECT Id, Product2.Name, UnitPrice FROM PriceBookEntry 
                                    WHERE Product2.Name like 'Cipla%'  AND Pricebook2.id = '01s2w00000EfZ9iAAF'
                                    ORDER BY Product2.Name desc LIMIT 1];
            for(Opportunity record: OPTY) {
                lines.add(new OpportunityLineItem(PricebookEntryId=entry.Id,OpportunityId = record.Id, 
                            UnitPrice=entry.UnitPrice, Quantity=1));
            }//for end
            if (lines.size() > 0){
                insert lines;
                }//if end
    }//Meth end
}//class end