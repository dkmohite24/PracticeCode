public without sharing class ATI_WithoutSharingService {
    
    public static void  lockRecords(List<id> recordId){
        Approval.lock(recordId);
    }
    public static void unLockRecords(List<id> recordId){
        Approval.unlock(recordId);
    }

}