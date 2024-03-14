public class TriggerHandlerForMailAwaare {
    Public static void AddCustomerCode(list<AWAARE_4WARD_Basic__c> AwaareBasicList){
        for(AWAARE_4WARD_Basic__c awrbasic:AwaareBasicList){
            String customercode;
            String u= awrbasic.Username__c;
            String firstnine = u.left(9);
            String sixth = firstnine.left(6).right(1);
            
            if(sixth=='9'){
                system.debug('inside if');
                customercode = firstnine.left(5) + '9' + firstnine.right(4) ;
            }
            else{
                system.debug('inside else');
                customercode = firstnine.left(5) + '0' + firstnine.right(4) ;   
            }
            awrbasic.Customer_Code__c=customercode;
        }
        
        
    }
    @future
    public static void userreactivation(String uname,String role,String jobtitle ){
        List<AWAARE_Role__mdt> metalist = [Select id,AWAARE_role__c,Profile__c from AWAARE_Role__mdt];
        Map<String,String> metamap = new  Map<String,String>();
        for(AWAARE_Role__mdt m:metalist ){
            metamap.put(m.AWAARE_role__c, m.Profile__c);
        }
        
        List<User> inactiveuserlist= [SELECT Id,ProfileId,Username,Name,Profile.Name,Email,IsActive,Title FROM User WHERE Username=:uname LIMIT 1];
        inactiveuserlist[0].ProfileId=metamap.get(role);
        inactiveuserlist[0].IsActive=true;
        if(jobtitle!=null && jobtitle!=''){
            inactiveuserlist[0].Title=jobtitle;
        }
        inactiveuserlist[0].Username=inactiveuserlist[0].Username.remove('.inactive');
        update inactiveuserlist[0];
        System.resetpassword( inactiveuserlist[0].id ,True);
        
        List<UserPackageLicense> upllist = [select userid from UserPackageLicense where userid=: inactiveuserlist[0].id LIMIT 1];
        
        if(upllist.size()==0){
            PackageLicense p =[select Id from PackageLicense where NamespacePrefix='WOD_2'];
            UserPackageLicense upl = new UserPackageLicense();
            upl.UserId=inactiveuserlist[0].id;
            system.debug(p);
            upl.PackageLicenseId=p.id;
            insert upl; 
        }
        //adding Permission set for external user at the time of Re-activation
        
        List<PermissionSet> permissionLst = [select id, Name, Label from PermissionSet where Label =: 'TWOD_Upgrade_v1.88' limit 1];
        List<PermissionSetAssignment> permissionAssignList = [select Assignee.id from PermissionSetAssignment where PermissionSet.label='TWOD_Upgrade_v1.88' and Assignee.id =: inactiveuserlist[0].id];
        if(permissionLst.size()>0 && permissionAssignList.Size()==0){
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.PermissionSetId = permissionLst[0].Id;
            psa.AssigneeId = inactiveuserlist[0].id;
            Insert psa;
        }
    }
    
    
    public static void awaare4wardrecordcreation( AWAARE_4WARD_Basic__c awrbasic){
        AWAARE_4WARD__c awr = new AWAARE_4WARD__c();
        awr.FirstName__c=awrbasic.FirstName__c;
        awr.Address__c=awrbasic.Address__c;
        awr.City__c=awrbasic.City__c;
        awr.Country_Picklist__c=awrbasic.Country_Picklist__c;
        awr.Company__c=awrbasic.Company__c;
        awr.Customer_Code__c=awrbasic.Customer_Code__c;
        awr.Email__c=awrbasic.Email__c;
        awr.LastName__c=awrbasic.LastName__c;
        awr.Locale__c=awrbasic.Locale__c;
        awr.Phone__c=awrbasic.Phone__c;
        awr.Role_Picklist__c=awrbasic.Role_Picklist__c;
        awr.State_Province__c=awrbasic.State_Province__c;
        awr.Zip__c=awrbasic.Zip__c;
        awr.Username__c= awrbasic.Username__c;
        awr.Job_Title__c=awrbasic.Job_Title__c;
        insert awr;
        
    }
    
    public static void awaare4wardupdation(String username, String Role,String jobtitle ){
        system.debug('username---'+username+'  Role-----'+Role);
        List<AWAARE_4WARD__c> awaarelist = [select Role_Picklist__c,Job_Title__c,Username__c,Community_User__c from AWAARE_4WARD__c where Username__c=:username  LIMIT 1 ];
        awaarelist[0].Job_Title__c=jobtitle;
        awaarelist[0].Role_Picklist__c=role;
        update awaarelist[0];
    }
}