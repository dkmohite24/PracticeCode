public class createAccount{
public void deleteAccontBySysAdmin(list<account> acclist){
        Profile pro=[SELECT Id,Name FROM Profile WHERE id = :userinfo.getProfileId()];
        for(account acc : acclist){
            if(pro.name != 'System Administrator'){
                acc.adderror('You are not authorized to delete this record ');
            }
        }
}
}