Public class Task8deleteaProfile{
    public void DeleteOnlyAdmin(List<Account>NewAc){
        Profile pro=[SELECT Id,Name FROM Profile WHERE id = :userinfo.getProfileId()];
        for(account Ac: NewAc){
            if(pro.name != 'System Administrator'){
            
                Ac.Adderror('Admin can delete account');
                }
            
            }
        }
}