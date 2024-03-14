/* Name: ATI_TWODPermissionCache
Description : ATI_TWODPermissionCache - Platform cache implementation for Field and permission cache for TWoD
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      17-MAR-2021          INITIAL DEVELOPMENT
*/
global with sharing class ATI_TWODPermissionCache implements WOD_2.BaseControllerCacheInterface {
	
    public Object getCacheValue(String key) {
        Cache.OrgPartition orgPart = Cache.Org.getPartition(Label.ATI_TWOD_Permission_Cache_With_NS);
        return orgPart.get(getCacheKey(key));
    }

    public void saveToCache(String key, Object cachedValue,Integer ttl) {
        System.debug('getCpuTime -> ' + Limits.getCpuTime());
        Cache.OrgPartition orgPart = Cache.Org.getPartition(Label.ATI_TWOD_Permission_Cache_With_NS);
		orgPart.put(getCacheKey(key), cachedValue, ttl);
    }

    private String getCacheKey(String key){
        if(key.length() > 50){
            return getHashKey(key);
        }
        return key;
    }
    
    public static String getHashKey(String key){
        Blob targetBlob = Blob.valueOf(key);
        Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
        return EncodingUtil.convertToHex(hashBlob);
    }
    
}