/* Name: ATI_WarrantyCoverageCheck
Description : This class is used to check warranty coverage.
Author : Tavant(Mukesh)
History:
VERSION     AUTHOR                 DATE                            DETAIL                                    UserStory/Req#
1.0 -     Tavant(Mukesh)             12/16/2020                  INITIAL DEVELOPMENT                              
*/

public class ATI_WarrantyCoverageCheck {
    
    /*
     * Method  : WarrantyCoverageCheck
     * 
     * Added By Mukesh 
     * 
     * Description :  Accepting inv id and returning coverage list and machine info
     * 
     */
    @AuraEnabled(cacheable=true)
    public static WOD_2.ResponseWrapper WarrantyCoverageCheck(String invSN, Date rodate, Integer unitUsage){
        WOD_2.ResponseWrapper rw = new WOD_2.ResponseWrapper();
        WarrantyCoverageCheckWrapper wccw = new WarrantyCoverageCheckWrapper();
        WarrantyCoverageCheckWrapper.InventoryData invData = new WarrantyCoverageCheckWrapper.InventoryData();
        List<WarrantyCoverageCheckWrapper.CoverageData> cdataList = new List<WarrantyCoverageCheckWrapper.CoverageData>();
        List<WarrantyCoverageCheckWrapper.CampaignData> cmpDataList = new List<WarrantyCoverageCheckWrapper.CampaignData>();
        String objectName = 'WOD_2__Inventory__c';
        List<String> fieldSetMemberList =  readFieldSet('ATI_WarrantyPolicyCheckFS','WOD_2__Inventory__c');
        String wrSubQuery = '(SELECT id, Name,WOD_2__Status__c FROM WOD_2__Warranty_Registration__r WHERE WOD_2__Status__c = \''+'Registered'+'\')';
        String campaignSubQuery = '(SELECT id, Name,twodcms__Service_Campaign__r.Name,twodcms__Service_Campaign__r.twodcms__Status__c,twodcms__Service_Campaign__r.twodcms__Start_Date__c,twodcms__Service_Campaign__r.twodcms__End_Date__c FROM twodcms__Campaign_Members__r WHERE twodcms__Service_Campaign__r.twodcms__Status__c = \'Active\')';
        
        try{
            ATI_Utils.NoAccessObjectFieldWrapper sObjReadAccessCheck = new ATI_Utils.NoAccessObjectFieldWrapper();
            if(invSN !=''){
                sObjReadAccessCheck = ATI_Utils.fetchReadAccess(objectName,fieldSetMemberList);
            }
            else{
                return new WOD_2.ResponseWrapper('[]',false,Label.ATI_PolicyEmptySerialError);
            }
            if(rodate ==null){
                
            }
            if(unitUsage ==null){
                
            }
            
            if(sObjReadAccessCheck.noAccessObjectList.size() == 0 && sObjReadAccessCheck.noAccessFieldList.size() == 0 && invSN !=''){
                String query = 'SELECT Id,'+String.join(fieldSetMemberList,',')+',WOD_2__Type__c,'+wrSubQuery+','+campaignSubQuery +' FROM ' + objectName + ' WHERE WOD_2__Serial_Number__c=\'' + invSN + '\'';//+' AND WOD_2__Type__c = '+'\'' +'Retail' +'\'';
                List<WOD_2__Inventory__c> invList = Database.query(query);
                if(!invList.isEmpty()){
                    if(invList[0].WOD_2__Type__c =='Retail'){
                      wccw = prepareData(invList[0], rodate, unitUsage);  
                    }
                    else{
                         return new WOD_2.ResponseWrapper('[]',false,Label.ATI_PolicySerialStockError);
                    }
                    
                }
                else{
                    return new WOD_2.ResponseWrapper('[]',false,Label.ATI_PolicyInvalidSerialError);
                }
                return new WOD_2.ResponseWrapper(JSON.serialize(wccw),true,'');
            }
            else{
                return new WOD_2.ResponseWrapper('[]',false,'Insufficient Read Access '+sObjReadAccessCheck);
            }
         
        }catch(Exception e) {
            System.debug('Exception while fetching records>>> '+e.getMessage());
            return new WOD_2.ResponseWrapper('[]',false,Label.ATI_PolicyExceptionError);
        }
        //return rw;
    }
    /*
     * Method  : prepareData
     * 
     * Added By Mukesh 
     * 
     * Description :  Accepting Inv record with it's child WR and Campaign member, 
     * returning WarrantyCoverageCheckWrapper
     * 
     */
    Public static WarrantyCoverageCheckWrapper prepareData(WOD_2__Inventory__c inv,Date rodate, Integer unitUsage){
        Set<id> wrIdSet = new Set<id>();
        Map<id,Integer> policyIdToMaxUsageMap = new Map<id,Integer>();
        WarrantyCoverageCheckWrapper wccw = new WarrantyCoverageCheckWrapper();
        WarrantyCoverageCheckWrapper.InventoryData invData = new WarrantyCoverageCheckWrapper.InventoryData();
        List<WarrantyCoverageCheckWrapper.CoverageData> cdataList = new List<WarrantyCoverageCheckWrapper.CoverageData>();
        List<WarrantyCoverageCheckWrapper.CampaignData> cmpDataList = new List<WarrantyCoverageCheckWrapper.CampaignData>();
        
        invData.invId = inv.id;
        invData.name = inv.WOD_2__Serial_Number__c;
        invData.model = inv.WOD_2__Item__r.WOD_2__Product_Name__c;
        invData.account = inv.WOD_2__Account__r.SAP_Id__c;
        invData.unitsUsage = String.valueOf(inv.WOD_2__Units_Usage__c);
        invData.unitOfMeasure = inv.WOD_2__Item__r.WOD_2__Units_Of_Measure__c;
        JSON.deserialize(JSON.serialize(inv), WarrantyCoverageCheckWrapper.inv.class);
        wccw.invData = invData;
        wccw.inv = (WOD_2__Inventory__c)JSON.deserialize(JSON.serialize(inv), WOD_2__Inventory__c.class);
        if(inv.twodcms__Campaign_Members__r.size()>0){
            for(twodcms__Campaign_Members__c cmpMem :  inv.twodcms__Campaign_Members__r){
                    WarrantyCoverageCheckWrapper.CampaignData cmpData = new WarrantyCoverageCheckWrapper.CampaignData();
                    cmpData.cmpName = cmpMem.twodcms__Service_Campaign__r.Name;
               
                    cmpData.cmpStartDate = cmpMem.twodcms__Service_Campaign__r.twodcms__Start_Date__c;
                    cmpData.cmpEndDate = cmpMem.twodcms__Service_Campaign__r.twodcms__End_Date__c;
                
                if(cmpMem.twodcms__Service_Campaign__r.twodcms__Status__c == 'Active' && cmpData.cmpStartDate <= System.today() && cmpData.cmpEndDate >= System.today()){
                    cmpData.isActive = true;
                } 
                cmpDataList.add(cmpData);
            }
        }
        if(inv.WOD_2__Warranty_Registration__r.size()>0){
            for(WOD_2__Warranty_Registration__c wr : inv.WOD_2__Warranty_Registration__r){
                wrIdSet.add(wr.id);
            }
            List<WOD_2__Warranty_Coverages__c> wcList = [SELECT id,WOD_2__Policy_Definition__r.Name, WOD_2__Warranty_Start_Date__c, WOD_2__Warranty_End_Date__c,WOD_2__Policy_Definition__r.WOD_2__Description__c,WOD_2__Policy_Definition__r.WOD_2__Type__c,WOD_2__Policy_Definition__c,WOD_2__Policy_Definition__r.WOD_2__Priority__c  FROM WOD_2__Warranty_Coverages__c  WHERE WOD_2__Is_Active__c = true AND WOD_2__Warranty_Registration__c IN :wrIdSet
                                                         ORDER BY WOD_2__Policy_Definition__r.WOD_2__Priority__c ASC];
            
            for(WOD_2__Warranty_Coverages__c wc:wcList){
                policyIdToMaxUsageMap.put(wc.WOD_2__Policy_Definition__c,0);
            }
            for(WOD_2__Policy_Definition__c pd: [SELECT id, (SELECT id, WOD_2__Maximum_Unit__c FROM WOD_2__Policy_Definition_Inventory_Usages__r WHERE WOD_2__Usage_Reading_Type__c ='Machine') FROM WOD_2__Policy_Definition__c WHERE id IN : policyIdToMaxUsageMap.keyset()]){
                if(pd.WOD_2__Policy_Definition_Inventory_Usages__r.size()>0 && policyIdToMaxUsageMap.containskey(pd.id)&& pd.WOD_2__Policy_Definition_Inventory_Usages__r[0].WOD_2__Maximum_Unit__c!=null){
                    policyIdToMaxUsageMap.put(pd.id,(Integer)pd.WOD_2__Policy_Definition_Inventory_Usages__r[0].WOD_2__Maximum_Unit__c);
                }
            }
            
            for(WOD_2__Warranty_Coverages__c wc: wcList){
                WarrantyCoverageCheckWrapper.CoverageData wcd = new WarrantyCoverageCheckWrapper.CoverageData();
                wcd.policyName = wc.WOD_2__Policy_Definition__r.Name;
                wcd.policyType = wc.WOD_2__Policy_Definition__r.WOD_2__Type__c;
                
                //date d123 = wc.WOD_2__Warranty_Start_Date__c;
                //String dt = DateTime.newInstance(d123.year(),d123.month(),d123.day()).format('MM/dd/YYYY');
               // wcd.warrantyStartDate = Date.valueOf(dt);
                
                wcd.warrantyStartDate = wc.WOD_2__Warranty_Start_Date__c;
                wcd.warrantyEndDate = wc.WOD_2__Warranty_End_Date__c;
                wcd.priority = wc.WOD_2__Policy_Definition__r.WOD_2__Priority__c;
                if(policyIdToMaxUsageMap.containskey(wc.WOD_2__Policy_Definition__c) && policyIdToMaxUsageMap.get(wc.WOD_2__Policy_Definition__c)!=0){
                   wcd.maxUnitUsage = policyIdToMaxUsageMap.get(wc.WOD_2__Policy_Definition__c);
                }
                if(policyIdToMaxUsageMap.containskey(wc.WOD_2__Policy_Definition__c) && policyIdToMaxUsageMap.get(wc.WOD_2__Policy_Definition__c)!=0 && policyIdToMaxUsageMap.get(wc.WOD_2__Policy_Definition__c)>= unitUsage && wcd.warrantyStartDate<=rodate && wcd.warrantyEndDate>=rodate){
                    wcd.activeOnCurrantDate = true;
                }
                else if(policyIdToMaxUsageMap.containskey(wc.WOD_2__Policy_Definition__c) && policyIdToMaxUsageMap.get(wc.WOD_2__Policy_Definition__c)==0 && wcd.warrantyStartDate<=rodate && wcd.warrantyEndDate >=rodate ){
                    wcd.activeOnCurrantDate = true; 
                }
                wcd.description = wc.WOD_2__Policy_Definition__r.WOD_2__Description__c;
                cdataList.add(wcd);
            }
            
        }
        if(!cdataList.isEmpty()){
            wccw.cvrgData =cdataList; 
        }
        if(!cmpDataList.isEmpty()){
            wccw.cmpData = cmpDataList;
        }
         return wccw;   
    }
    
    /*
     * Method  : readFieldSet
     * 
     * Added By Mukesh 
     * 
     * Description :  Accepting field set name and Object Name, 
     * returning Inventory with WR and Member service campaign
     * 
     */
    
    public static List<String> readFieldSet(String fieldSetName, String ObjectName){
        List<String> fieldApiNameList = new List<String>();
        //String fieldApiNames = '';
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()){
            system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            fieldApiNameList.add(fieldSetMemberObj.getFieldPath());
    	}
        fieldApiNameList.add('WOD_2__Account__r.SAP_Id__c');
        fieldApiNameList.add('WOD_2__Units_Usage__c');
        fieldApiNameList.add('WOD_2__Item__r.WOD_2__Units_Of_Measure__c');
        return fieldApiNameList; 
	} 
}