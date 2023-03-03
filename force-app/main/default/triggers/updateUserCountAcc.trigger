trigger updateUserCountAcc on Account (before insert, before delete) {
    set<id> userSet = new set<id>();
    list<user> userList = new list<user>();
    for(account acc : trigger.new){
        
        userSet.add(acc.OwnerId);
        system.debug('userSet'+userSet);
    }
    for(AggregateResult us: [SELECT OWNERID ownId, COUNT(Id) cot From Account GROUP BY OwnerId HAVING OWNERID IN:userSet ]){
        system.debug('AggQuery'+us);
        user userAc = new user();
        userAc.id = (string)us.get('ownId');
        userAc.count__c = (double) us.get('cot');
        userList.add(userAc);
        system.debug('userID'+us.get('ownId') );
        system.debug('userList'+userList);
    }
    update userList;
}