public class AmmountAndNoOppTRI{
    public void OpptoAc(list<Opportunity> Opnew){
    
        list<id> TriList = new  list<id>();
        for (opportunity OP:Opnew){
            TriList.add(OP.AccountId);
             system.debug('Trigger.new value list TriList:'+TriList);
        }
    list<Account>  Execution = new list<account>();
    list<Opportunity> ListOP  = [select id,name,AccountId,amount from Opportunity where AccountId in:TriList];
    list<Account> ListOPAc  = [select id ,(select id from Opportunities)from account where id in:TriList];
    system.debug('Soql List ListOP::::::'+ListOP);
    system.debug('Soql List ListOPAc ::::::'+ListOPAc);
    
    decimal sum = 0;
    
    for(account AcOp: ListOPAc){
            for(Opportunity opps:ListOP){
            
            Sum = sum + (opps.amount!= null?opps.amount:0);
                
        
            }
            system.debug('Sum Of amount::: :'+Sum);
        Integer CountOP = ListOP.size();
        AcOp.Description ='AMOUNT :::'+Sum;
        
               // AcOp.First_Name__c = 'ff';
                //AcOp.Last_Name__c = 'hh';
                AcOp.count__c = CountOP;
                system.debug('updated list AcOp.count__c :'+AcOp.count__c);
        
        
        Execution.Add(AcOp);
        }
        system.debug('updated list of Account :'+Execution);
        update Execution;
 
        
    
    }
    
    Public void OpptoAcAfterDelete(list<Opportunity> Opnew){
    list<id> TriList = new  list<id>();
        for (opportunity OP:Opnew){
            TriList.add(OP.AccountId);
             system.debug('Trigger.new value list TriList:'+TriList);
        }
    list<Account>  Execution = new list<account>();
    list<Opportunity> ListOP  = [select id,name,AccountId,amount from Opportunity where AccountId in:TriList];
    list<Account> ListOPAc  = [select id ,(select id from Opportunities)from account where id in:TriList];
    system.debug('Soql List :'+ListOP);
    
    decimal sum = 0;
    
    for(account AcOp: ListOPAc){
            for(Opportunity opps:ListOP){
            
            Sum = sum + (opps.amount!= null?opps.amount:0);
                
        
            }
            system.debug('Sum Of amount::: :'+Sum);
            AcOp.Description ='AMOUNT :::'+Sum;
        Integer CountOP = ListOP.size();
        
                //AcOp.First_Name__c = 'ff';
                //AcOp.Last_Name__c = 'hh';
                AcOp.count__c = CountOP;
                system.debug('updated list AcOp.count__c :'+AcOp.count__c);
        
        
        Execution.Add(AcOp);
        }
        system.debug('updated list of Account :'+Execution);
        update Execution;
 
        
    
    
    
    }  
}