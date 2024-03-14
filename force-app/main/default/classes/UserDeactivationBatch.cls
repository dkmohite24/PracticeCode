public class UserDeactivationBatch implements Database.Batchable<sObject>,Schedulable {
public list<Sobject> start(Database.BatchableContext BC){
			List<Profiles_for_Auto_Deactivation__mdt> metalist = [Select Profile_Name__c from Profiles_for_Auto_Deactivation__mdt];
    		Set<String> metaset= new Set<String>();
    		for(Profiles_for_Auto_Deactivation__mdt p:metalist){
        			metaset.add(p.Profile_Name__c);
    		}
             String query2;
    if(!test.isRunningTest()){
        	query2='Select id,LastLoginDate,username,Profile.Name,IsActive,LastModifiedDate from User where IsActive=true AND Profile.Name IN:metaset' ;
			//query2 += ' AND Id!=  \'0053h000005NNyJAAW\'';
        	//query2 +=' AND Id= \'0053h000006PagfAAC\'';
        
    }
    else{
        //For PRP Dev
        // query2 = 'Select id,LastLoginDate,Profile.Name,username,IsActive,LastModifiedDate from User where id =\'0053h000006igVAAAY\'';
        //For PRP UaT/Prod  
      query2 = 'Select id,LastLoginDate,Profile.Name,username,IsActive,LastModifiedDate from User where id =\'0053h000003jI9sAAE\'';
      
        }
    		list<Sobject> returnQuery2 = Database.query(query2);
    
          	system.debug('RETURN QUERY****'+returnQuery2);
            
            system.debug('RETURN QUERY****'+returnQuery2.size());
          return returnQuery2;
		  }
   
		public void execute(SchedulableContext sc){
         	UserDeactivationBatch u =new UserDeactivationBatch();
        	Database.executebatch(u);
      		}
     	public void execute(Database.BatchableContext bc,  List<User> returnQuery2 ){
            List<UserPackageLicense> upllist =[select UserId from UserPackageLicense];
        Map<String,UserPackageLicense> uplmap =new Map<String,UserPackageLicense>();
            for(UserPackageLicense upl:upllist){
                uplmap.put(upl.UserId,upl);
            }
         List<UserPackageLicense> upltodelete =new  List<UserPackageLicense>();
		List<User> usertoupdate = new List<User>();
            for(User u:returnQuery2){
                if(u.LastLoginDate!=null){
                Date d= u.LastLoginDate.date();
                Date b= date.today();
                Integer num = d.daysBetween(b);
                if(num>90){
                    
                    u.IsActive=false;
                    u.username= u.username+'.inactive';
                    usertoupdate.add(u);
                    if(uplmap.containsKey(u.id)){
                        upltodelete.add(uplmap.get(u.id));
                    	}
                }
            } 
                else{
                     Date d= u.LastModifiedDate.date();
                Date b= date.today();
                Integer num = d.daysBetween(b);
                if(num>90){
                    
                    u.IsActive=false;
                    u.username= u.username+'.inactive';
                    usertoupdate.add(u);
                    if(uplmap.containsKey(u.id)){
                        upltodelete.add(uplmap.get(u.id));
                    	}
                }
                    
                }
                
            }
            system.debug('usertoupdate----'+usertoupdate.size()+'   upltodelete----'+upltodelete.size());
            system.debug('usertoupdate----'+usertoupdate+'   upltodelete----'+upltodelete);
            if(usertoupdate.size()>0) update usertoupdate; 
            if(upltodelete.size()>0) delete upltodelete;
    	}
    
    	public void finish(Database.BatchableContext bc){
      	}
}