public class UserProfileController {
    
    @AuraEnabled 
    public static List<User> getUserProfiles(){
        return [Select Id,Address ,BannerPhotoUrl,CompanyName,Department,Email,FirstName , LastName ,FullPhotoUrl from User];
    } 

}