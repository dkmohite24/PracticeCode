@isTest
public class CreateNewOpportunity_Test {
public static testmethod void oppTest(){
    Account acct=new Account();
        acct.name='a';
        acct.industry='Electronics';   
        insert acct;
        Opportunity op = new Opportunity();
          op.Name = acct.Name;
          op.AccountId = acct.Id;
          op.Amount = 100;
          op.StageName = 'Proposal';
          op.CloseDate = System.today() + 30;
          insert op;
      }
 }