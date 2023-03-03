global class BatchUpdateAccount implements Database.Batchable<Sobject>, database.stateful {

	 Integer magicNum = 0;
     string K = 'kyllie';
     String VAr = '%'+ k +'%';
	global Database.QueryLocator start(Database.BatchableContext bc){	
		return Database.getQueryLocator('select id , name from account Where name like: Var');
	}
	
	global void execute(Database.BatchableContext bc, List<Account> scope){
		System.debug('In the execute method');
        list <Account> ListAcc = new list<Account>();
        For(Account Acc: Scope){
            Acc.name = 'miss '+Acc.name;
            ListAcc.Add(acc);
       }
       Update ListAcc;
       for(Integer i = 0; i <Scope.size(); i++){
        	magicNum++; 
       }
	}

	global void finish(Database.BatchableContext bc){
		System.debug('In the finish method');
		System.debug('magicNum ' + magicNum);
	}
}