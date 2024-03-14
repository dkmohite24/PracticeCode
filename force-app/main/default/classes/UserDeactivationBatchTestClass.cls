@IsTest(seeAllData=true)
public class UserDeactivationBatchTestClass {
    
    @IsTest
    public static void UserDeactivation(){
   /* List<Profiles_for_Auto_Deactivation__mdt> metalist = [Select Profile_Name__c from Profiles_for_Auto_Deactivation__mdt];
    		Set<String> metaset= new Set<String>();
    for(Profiles_for_Auto_Deactivation__mdt p:metalist){
        			metaset.add(p.Profile_Name__c);
    		}*/
       // For Dev
   // List<User> Userlist = [Select id,LastLoginDate,Profile.Name,IsActive from User where id ='0053h000006igVAAAY' LIMIT 1] ;
        //for prod
    List<User> Userlist = [Select id,LastLoginDate,Profile.Name,IsActive,Username,LastModifiedDate from User where id ='0053h000003jI9sAAE' LIMIT 1] ;    
      // List<User> Userlist = [Select id,LastLoginDate,Profile.Name,IsActive,Username from User where id ='0053h000003u7hlAAA' LIMIT 1] ;      
        test.startTest();
       
        UserDeactivationBatch myBatchObject = new UserDeactivationBatch();
        Database.executeBatch(myBatchObject);
      
        test.stopTest();
        
        
    } 
    
    @IsTest
    public static void UserDeactivation2(){
        
        test.starttest();
        UserDeactivationBatch myClass1 = new UserDeactivationBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched 1', chron , myClass1);
         test.stopTest();
    }
    
}