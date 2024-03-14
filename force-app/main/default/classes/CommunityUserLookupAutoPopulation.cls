/*
 * Developer Name: Akanksha Mondal, Ritu Raj Singh
 * Date: 2021-10-01
 * Updated: For all community users created with username having 'allison4ward.com' a Userpackagelicense record is created
 * For internal users created with certain profiles a Userpackagelicense record is created and and Permission Set is assigned.
 * 
 * 
*/

public class CommunityUserLookupAutoPopulation {
    public static void CommunityAutopopulation(list<User> us){
                for(User newus : us){
                    String u= newus.Username;
                    List<String> Splitlist = u.split('\\@');
           List<AWAARE_4WARD__c> awaarelist = new List<AWAARE_4WARD__c> ();

       awaarelist=[Select Id,Username__c,FirstName__c,LastName__c,Email__c,Customer_Code__c,Role_Picklist__c,Company__c,Locale__c from AWAARE_4WARD__c WHERE Username__c=: Splitlist[0] LIMIT 1   ];
                   Splitlist.clear(); 
                    if(awaarelist.size()!=0){
                    for(AWAARE_4WARD__c awr:awaarelist){
                        awr.Community_User__c=newus.id;
                        update awr;
                    }
                    }
        
        
        
                }
    }
    
    @future
   public static void userpackagelicense(String us){

        User ur = [Select Username,Profile.Name from User where Username=:us];
       
           if((us).contains('@allison4ward.com')){
                system.debug('INSIDE 1ST Loop'+us);
               
                PackageLicense p =[select Id from PackageLicense where NamespacePrefix='WOD_2'];
                UserPackageLicense upl = new UserPackageLicense();
                upl.UserId=ur.id;
               // upl.PackageLicenseId='0503h000000PHm7AAG';
               system.debug(p);
               upl.PackageLicenseId=p.id;
                insert upl;
                
           
        }
       
       else{ 
        	
           
           list<X4WARD_Access__mdt> metadata = new list<X4WARD_Access__mdt>();
          metadata = [select id,Profile__c,Permission_Set__c from X4WARD_Access__mdt ];

       
           for(X4WARD_Access__mdt meta : metadata){
       			
               if(meta.Profile__c==ur.Profile.Name){
                   system.debug('INSIDE IF');
      			// if(ur.Profile.Name=='Standard Platform User' || ur.Profile.Name=='Standard User' || ur.Profile.Name=='System Administrator' || ur.Profile.Name=='PRP Admin' || ur.Profile.Name=='ATI Warranty Admin' || ur.Profile.Name=='ATI Warranty Claim Processor' || ur.Profile.Name=='ATI Part Receiver' || ur.Profile.Name=='ATI Part Inspector' || ur.Profile.Name=='ATI Field Service Manager' || ur.Profile.Name=='ATI Division Service Manager'|| ur.Profile.Name=='Read Only' || ur.Profile.Name=='ATI Warranty Approver' || ur.Profile.Name=='ATI_TWOD_Read'|| ur.Profile.Name=='ATI IT Warranty Admin'|| ur.Profile.Name=='ATI Warranty Claim Processor'){
        		 	PackageLicense p =[select Id from PackageLicense where NamespacePrefix='WOD_2'];
                	UserPackageLicense upl = new UserPackageLicense();
               		upl.UserId=ur.id;
                	system.debug(p);
           			upl.PackageLicenseId=p.id;
                	insert upl;  
           
                   if(meta.Permission_Set__c==true){
           			PermissionSet ps =[select id, Name from PermissionSet where Name ='ATI_Warranty_Admin_Permission'LIMIT 1 ] ;
           			PermissionSetAssignment psa = new PermissionSetAssignment();
           			psa.PermissionSetId = ps.Id;
           			psa.AssigneeId = ur.id;
           			insert psa; 
                   }
      			}
              }   
           
         }   
              
                
   }

    public static void removeUserPackageLicense(List<Id> deactivateduserList){
        PackageLicense p =[select Id from PackageLicense where NamespacePrefix='WOD_2'];
        List<UserPackageLicense> userpackagelicenseList = [select UserId from UserPackageLicense where UserId IN:deactivateduserList AND PackageLicenseId=:p.Id ];
        
        if(userpackagelicenseList.size()>0)
        {   system.debug('userpackagelicenseList:'+userpackagelicenseList.size());
            delete userpackagelicenseList;
        }
        
    }

}