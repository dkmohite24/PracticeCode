/* Name: ATI_TWODPermissionCacheTest
Description : ATI_TWODPermissionCacheTest - test class for ATI_TWODPermissionCache
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      17-MAR-2021          INITIAL DEVELOPMENT
*/
@isTest			
public class ATI_TWODPermissionCacheTest {

    @isTest
    static void testAddDataToCache(){
        ATI_TWODPermissionCache myCache = new ATI_TWODPermissionCache();
        Test.startTest();
        String key = 'cacheKey';
        String cacheValue = 'cachedValue';
        myCache.saveToCache(key, cacheValue, 1000);
        String valFetchedFromCache = (String) myCache.getCacheValue(key);
        Test.stopTest();
        System.assertEquals(cacheValue, valFetchedFromCache, 'Cache value is not same as the stored value');
    }
    
@isTest
    static void testAddDataToCacheForKeySizeGt50(){
        ATI_TWODPermissionCache myCache = new ATI_TWODPermissionCache();
        Test.startTest();
        String key = 'cacheKey123cacheKey123cacheKey123cacheKey123cacheKey123cacheKey123cacheKey123cacheKey123cacheKey123';
        String cacheValue = 'cachedValue';
        myCache.saveToCache(key, cacheValue, 1000);
        String valFetchedFromCache = (String) myCache.getCacheValue(key);
        Test.stopTest();
        System.assertEquals(cacheValue, valFetchedFromCache, 'Cache value is not same as the stored value');
    }    
}