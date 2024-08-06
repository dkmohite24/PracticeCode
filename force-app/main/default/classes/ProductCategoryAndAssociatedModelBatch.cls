public class ProductCategoryAndAssociatedModelBatch implements Database.Batchable<sObject>, Database.Stateful{
    Boolean productTriggerStatus = false;
    List<String> category_errors_list = new List<String>();
    List<String> associated_product_errors_list = new List<String>();
    Set<String> setProductNames = new Set<String>();
    static final String OBSOLETEPARENT_NAME = 'Obsolete Parts';
    static Id parentObsoleteId;/* ADDED BY DHAVAL 02/13/2024 CM-2293*/
    static Id availableObsuluteCatID;// Aaded by Dhannjay mohite CM 2391
    Map<id,Integer> availableObsoluteCatCapacity = new Map<id,Integer>();
    Map<id,integer> categoryCapacityMap = new Map<id,integer>();
    Map<id,ProductCategory> obsuluteCategoryMap = new Map<id,ProductCategory>();
    public ProductCategoryAndAssociatedModelBatch(){
        updateTriggerStatus();
    }
    public ProductCategoryAndAssociatedModelBatch(Set<String> setProducts){
        this.setProductNames = setProducts;
        updateTriggerStatus();
    }
    public static void startManual(Set<String> setProducts){
        ProductCategoryAndAssociatedModelBatch objProd = new ProductCategoryAndAssociatedModelBatch(setProducts);
        Id JobId = Database.executeBatch(objProd, 10);
    }
    public static void startManual(){
        ProductCategoryAndAssociatedModelBatch objProd = new ProductCategoryAndAssociatedModelBatch();
        Id JobId = Database.executeBatch(objProd, 10);
    }
    private void updateTriggerStatus(){
        List<Trigger_Setting__c> triggerSettingList = [Select Id, isActive__c From Trigger_Setting__c WHERE name = 'Product'];
        if(triggerSettingList.isEmpty()){
            Trigger_Setting__c triggerSetting = new Trigger_Setting__c();
            triggerSetting.name = 'Product';
            triggerSetting.isActive__c = false;
            insert triggerSetting;
            productTriggerStatus = true;
        }
        else{
            productTriggerStatus = triggerSettingList[0].isActive__c;
            if(productTriggerStatus == true){
                triggerSettingList[0].isActive__c = false;
                update triggerSettingList[0];
            }
        }
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(!this.setProductNames.isEmpty()){
            return Database.getQueryLocator([
                SELECT 
                    Id, Category_And_Associated_Products__c, RepairPart__c, Stocking_Type__c, SetCategoriesAndAssociatedProduct__c,
                    (Select Id, ProductId, ProductCategoryId, ProductCategory.PDS_Categories__c From ProductCategoryProducts ),
                    (Select Id, Parent_Product__c, Product_Associated__c, Product_Associated__r.name From Associated_Products_Parent__r)
                FROM 
                    Product2
                WHERE 
                    Name IN:this.setProductNames
            ]);

        }
        else{
            return Database.getQueryLocator([
                SELECT 
                    Id, Category_And_Associated_Products__c, RepairPart__c, Stocking_Type__c, SetCategoriesAndAssociatedProduct__c,
                    (Select Id, ProductId, ProductCategoryId, ProductCategory.PDS_Categories__c From ProductCategoryProducts ),
                    (Select Id, Parent_Product__c, Product_Associated__c, Product_Associated__r.name From Associated_Products_Parent__r)
                FROM 
                    Product2
                WHERE 
                    SetCategoriesAndAssociatedProduct__c = true
            ]);

        }
    }
    /* ADDED BY DHAVAL 02/13/2024 CM-2293*/
    void setParentObsolete(){
        /* if(String.isEmpty(parentObsoleteId)){
        List<ProductCategory> productCategoryList = [SELECT id FROM ProductCategory WHERE Name =: OBSOLETEPARENT_NAME LIMIT 1];
        if(!productCategoryList.isEmpty()){
        parentObsoleteId = productCategoryList[0].Id;
        }
        }*/
        // Aaded by Dhannjay mohite CM 2391 END
        obsuluteCategoryMap = new Map<id,ProductCategory>([SELECT id,name ,CatalogId,ParentCategoryId,Sr_Number__c,Product_Count__c FROM ProductCategory WHERE Name like :OBSOLETEPARENT_NAME+'%' ]);
        system.debug('obsuluteCategoryMap.Values()'+obsuluteCategoryMap.Values());
        if(!obsuluteCategoryMap.isEmpty()){
            integer minCapacity = ((Integer.valueOf(System.Label.maxProdCategory))+1);
            for(ProductCategory prodCt: obsuluteCategoryMap.Values()){
                Integer availableCapacity = Integer.valueOf(System.Label.maxProdCategory) - Integer.valueOf(prodCt.Product_Count__c);
                
                    categoryCapacityMap.put(prodCt.Id, availableCapacity);
                    
                    // Track the category with the minimum available capacity
                    if (availableCapacity < minCapacity &&  availableCapacity > 0 ) {
                        minCapacity = availableCapacity;
                        availableObsuluteCatID = prodCt.Id;
                    }
                
                
            }
            
        }  
    }
    public void execute(Database.BatchableContext BC, List<Product2> scope){
        system.debug('#### scope in execute: ' + scope);
        List<object> objProductCategories = new List<object>();
        
        List<ProductCategoryProduct> productCategories_to_delete = new List<ProductCategoryProduct>();
        List<Associated_Product__c> associated_products_to_delete = new List<Associated_Product__c>();

        Map<String, List<cls_categoryWrapper>> mapCategoryWrapperAll = new Map<String, List<cls_categoryWrapper>>();
        Map<String, List<cls_categoryWrapper>> mapRepairAndObsoleteCategoryWrapperAll = new Map<String, List<cls_categoryWrapper>>();
        Map<Id, List<cls_associatedProdWrapper>> mapAssociatedProducts = new Map<Id, List<cls_associatedProdWrapper>>();

        if(!scope.isEmpty()){
            /* ADDED BY DHAVAL 02/13/2024 CM-2293 [START]*/
            setParentObsolete();
            /* ADDED BY DHAVAL 02/13/2024 CM-2293 [END]*/
            for(Product2 prod: scope){
                prod.SetCategoriesAndAssociatedProduct__c = false;
                /* ADDED BY DHAVAL 02/13/2024 CM-2293 [START]*/
                String categoryOrAssociatedProds = prod.Category_And_Associated_Products__c;
                if(String.isEmpty(categoryOrAssociatedProds)){
                    if((prod.RepairPart__c == true) || (!String.isEmpty(prod.Stocking_Type__c) && prod.Stocking_Type__c.trim() == '60')){
                        categoryOrAssociatedProds = '{"lstCategory":[]}';
                    }
                }
                /* ADDED BY DHAVAL 02/13/2024 CM-2293 [END]*/
                /* UPDATED BY DHAVAL 02/13/2024 CM-2293 [START]*/
                /*
                if(!String.isEmpty(prod.Category_And_Associated_Products__c)){
                    objProductCategories.add(JSON.deserialize(prod.Category_And_Associated_Products__c, ProductDataService.productCategoryWrapper.class));
                    object obj = JSON.deserialize(prod.Category_And_Associated_Products__c, ProductDataService.productCategoryWrapper.class);
                */
                if(!String.isEmpty(categoryOrAssociatedProds)){
                    objProductCategories.add(JSON.deserialize(categoryOrAssociatedProds, ProductDataService.productCategoryWrapper.class));
                    object obj = JSON.deserialize(categoryOrAssociatedProds, ProductDataService.productCategoryWrapper.class);
                    /* UPDATED BY DHAVAL 02/13/2024 CM-2293 [END]*/
                    ProductDataService.productCategoryWrapper categoryWrapper = (ProductDataService.productCategoryWrapper) obj;
                    categoryWrapper.productId = prod.Id;

                    Map<String, cls_categoryWrapper> mapCategoryWrapper = new Map<String, cls_categoryWrapper>();
                    Map<String, cls_categoryWrapper> mapRepairAndObsoleteCategoryWrapper = new Map<String, cls_categoryWrapper>();
                    Map<String, Map<String, cls_categoryWrapper>> resultMap = prepareCategoryMap(prod.productCategoryProducts, prod, categoryWrapper);
                    if(!resultMap.isEmpty()){
                        mapCategoryWrapper = resultMap.get('TRADECATEGORY');
                        mapRepairAndObsoleteCategoryWrapper = resultMap.get('REPAIRPARTANDOBSOLETE');
                        //Collecting all categories together
                        for(cls_categoryWrapper cls: mapCategoryWrapper.values()){
                            if(mapCategoryWrapperAll.containsKey(cls.objCategory.productId)){
                                mapCategoryWrapperAll.get(cls.objCategory.productId).add(cls);
                            }
                            else{
                                mapCategoryWrapperAll.put(cls.objCategory.productId, new List<cls_categoryWrapper> {cls});
                            }
                        }
                        for(cls_categoryWrapper cls: mapRepairAndObsoleteCategoryWrapper.values()){
                            if(mapRepairAndObsoleteCategoryWrapperAll.containsKey(cls.objCategory.productId)){
                                mapRepairAndObsoleteCategoryWrapperAll.get(cls.objCategory.productId).add(cls);
                            }
                            else{
                                mapRepairAndObsoleteCategoryWrapperAll.put(cls.objCategory.productId, new List<cls_categoryWrapper> {cls});
                            }
                        }
                    }
                    Map<Id, List<cls_associatedProdWrapper>> resultAssociatedMap = prepareAssociatedProducts(prod, categoryWrapper);
                    if(!resultAssociatedMap.isEmpty()){
                        mapAssociatedProducts.putAll(resultAssociatedMap);
                    }
                }
            }
            ///Processing Records
            Map<String, Object> processAssociatedProduct_result = processAssociatedProduct(mapAssociatedProducts);
            Map<String, Object> processCategories_result = processCategories(mapCategoryWrapperAll, mapRepairAndObsoleteCategoryWrapperAll);
            Set<Id> delete_id_set = new Set<Id>();
            List<sObject> insert_list = new List<sObject>();

            delete_id_set.addAll((Set<Id>) processAssociatedProduct_result.get('ASSOCIATED_PRODUCT_TO_DELETE'));
            delete_id_set.addAll((Set<Id>) processCategories_result.get('CATEGORIES_TO_DELETE'));

            insert_list.addAll((List<sObject>) processAssociatedProduct_result.get('ASSOCIATED_PRODUCT_TO_INSERT'));
            insert_list.addAll((List<sObject>) processCategories_result.get('CATEGORIES_TO_INSERT'));

            List<Id> delete_id_list = new List<Id>();
            delete_id_list.addAll(delete_id_set);

            if(!delete_id_list.isEmpty()){
                Database.DeleteResult[] deleteResult = Database.Delete(delete_id_list, false);
                for (Database.DeleteResult sr : deleteResult) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully deleted: ' + sr.getId());
                    }
                    else {       
                        String error_desc = '';      
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('ProductCategoryProduct: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ProductCategoryProduct fields that affected this error: ' + err.getFields());
                            error_desc += '\nSTATUS CODE: ' + err.getStatusCode();
                            error_desc += '\nERROR MESSAGE: ' + err.getMessage();
                            error_desc += '\nFIELDS: ' + err.getFields(); 
                            error_desc += '\n\n';
                        }
                        category_errors_list.add(error_desc);
                    }
                }
            }

            if(!insert_list.isEmpty()){
                //insert productCategoryProductList;
                Database.SaveResult[] saveResultList = Database.insert(insert_list, false);
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted ProductCategoryProduct: ' + sr.getId());
                    }
                    else {       
                        String error_desc = '';      
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('ProductCategoryProduct: The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('ProductCategoryProduct fields that affected this error: ' + err.getFields());
                            error_desc += '\nSTATUS CODE: ' + err.getStatusCode();
                            error_desc += '\nERROR MESSAGE: ' + err.getMessage();
                            error_desc += '\nFIELDS: ' + err.getFields(); 
                            error_desc += '\n\n';
                        }
                        category_errors_list.add(error_desc);
                    }
                }
            }
            Database.Update(scope, false);
        }
    }
    
    Map<String, Object> processAssociatedProduct(Map<Id, List<cls_associatedProdWrapper>> mapAssociatedProducts){
        Set<Id> delete_id_set = new Set<Id>();
        List<sObject> insert_list = new List<sObject>();
        Set<String> model_set = new Set<String>();
        Map<String, Object> returnMap = new Map<String, Object>();
        if(!mapAssociatedProducts.isEmpty()){
            for(Id prodId : mapAssociatedProducts.keySet()){
                for(cls_associatedProdWrapper ap: mapAssociatedProducts.get(prodId)){
                    if(!ap.survive && !ap.isNew && ap.objAccociatedProduct.Id != null){
                        delete_id_set.add(ap.objAccociatedProduct.Id);
                    }
                    if(ap.isNew){
                        model_set.add(ap.modelName);
                    }
                }
            }
            Map<String, Id> mapAccociatedProdctId = new Map<String, Id>();
            if(!model_set.isEmpty()){
                List<Product2> associatedProductList = [
                                    SELECT
                                        id,ProductCode,Name
                                    FROM
                                        Product2
                                    WHERE
                                        ProductCode IN: model_set
                                ];
                for(Product2 accProd: associatedProductList){
                    mapAccociatedProdctId.put(accProd.ProductCode, accProd.Id);
                }
            }
            if(!mapAccociatedProdctId.isEmpty()){
                for(Id prodId : mapAssociatedProducts.keySet()){
                    for(cls_associatedProdWrapper ap: mapAssociatedProducts.get(prodId)){
                        if(ap.isNew && mapAccociatedProdctId.containsKey(ap.modelName.trim())){
                            ap.objAccociatedProduct.Product_associated__c = mapAccociatedProdctId.get(ap.modelName.trim());
                            insert_list.add((sObject) ap.objAccociatedProduct);
                        }
                    }
                }
            }
        }
        returnMap.put('ASSOCIATED_PRODUCT_TO_DELETE', delete_id_set);
        returnMap.put('ASSOCIATED_PRODUCT_TO_INSERT', insert_list);

        return returnMap;
    }
    Map<String, Object> processCategories(Map<String, List<cls_categoryWrapper>> mapCategoryWrapper, Map<String, List<cls_categoryWrapper>> mapRepairAndObsoleteCategoryWrapper){
        Set<Id> delete_id_set = new Set<Id>();
        List<sObject> insert_list = new List<sObject>();
        Set<String> pds_category_set = new Set<String>();
        Map<String, Object> returnMap = new Map<String, Object>();
        if(!mapRepairAndObsoleteCategoryWrapper.isEmpty()){
            for(String prodId: mapRepairAndObsoleteCategoryWrapper.keySet()){
                for(cls_categoryWrapper cw: mapRepairAndObsoleteCategoryWrapper.get(prodId)){
                    if(!cw.survive && !cw.isNew && cw.objCategory.Id != null){
                        delete_id_set.add(cw.objCategory.Id);
                    }
                    if(cw.isNew){
                        insert_list.add((sObject) cw.objCategory);
                    }
                }
            }
        }
        if(!mapCategoryWrapper.isEmpty()){
            for(String prodId: mapCategoryWrapper.keySet()){
                for(cls_categoryWrapper cw: mapCategoryWrapper.get(prodId)){
                    if(!cw.survive && !cw.isNew && cw.objCategory.Id != null){
                        delete_id_set.add(cw.objCategory.Id);
                    }
                    if(cw.isNew && !String.isEmpty(cw.pds_Category)){
                        pds_category_set.add(cw.pds_Category.trim());
                    }
                }
            }
            system.debug('### pds_category_set: ' + pds_category_set);
            Map<String, Id> mapPdsCategoryToID = new Map<String, Id>();
            if(!pds_category_set.isEmpty()){
                List<ProductCategory> productCategoryList = [
                        SELECT 
                            Id, PDS_Categories__c
                        FROM 
                            ProductCategory
                        WHERE 
                            PDS_Categories__c IN: pds_category_set
                ];
                for(ProductCategory cat: productCategoryList){
                    mapPdsCategoryToID.put(cat.PDS_Categories__c, cat.Id);
                }
            }
            for(String prodId: mapCategoryWrapper.keySet()){
                for(cls_categoryWrapper cw: mapCategoryWrapper.get(prodId)){
                    if(cw.isNew && !String.isEmpty(cw.pds_Category)){
                        cw.objCategory.ProductCategoryId = mapPdsCategoryToID.get(cw.pds_Category.trim());
                        insert_list.add((sObject) cw.objCategory);
                    }
                }
            }
        }
        returnMap.put('CATEGORIES_TO_DELETE', delete_id_set);
        returnMap.put('CATEGORIES_TO_INSERT', insert_list);

        return returnMap;
    }
    Map<Id, List<cls_associatedProdWrapper>> prepareAssociatedProducts(Product2 product, ProductDataService.productCategoryWrapper categoryWrapper){
        Map<String, cls_associatedProdWrapper> mapIdToAssociatedProduct = new Map<String, cls_associatedProdWrapper>();
        if(product != null && !product.Associated_Products_Parent__r.isEmpty()){
            for(Associated_Product__c ap: product.Associated_Products_Parent__r){
                cls_associatedProdWrapper apw = new cls_associatedProdWrapper();
                apw.objAccociatedProduct = ap;
                apw.modelName = ap.Product_Associated__r.name;
                apw.survive = false;
                apw.isNew = false;
                mapIdToAssociatedProduct.put(ap.Product_Associated__r.name.trim().toUpperCase(), apw);
            }
        }
        if(categoryWrapper.setproductModel != null && !categoryWrapper.setproductModel.isEmpty()){
            for(String model: categoryWrapper.setproductModel){
                if(mapIdToAssociatedProduct.containsKey(model.trim().toUpperCase())){
                    mapIdToAssociatedProduct.get(model.trim().toUpperCase()).survive = true;
                }
                else{
                    cls_associatedProdWrapper apw = new cls_associatedProdWrapper();
                    apw.objAccociatedProduct = new Associated_Product__c();
                    apw.objAccociatedProduct.Parent_Product__c = product.Id;
                    apw.objAccociatedProduct.Relationship_Type__c = 'Handle';
                    apw.objAccociatedProduct.Name = model.trim();
                    apw.modelName = model.trim();
                    apw.isNew = true;

                    mapIdToAssociatedProduct.put(model.trim().toUpperCase(), apw);
                }
            }
        }
        if(!mapIdToAssociatedProduct.isEmpty()){
            Map<Id, List<cls_associatedProdWrapper>> returnMap = new Map<Id, List<cls_associatedProdWrapper>>();
            returnMap.put(product.Id, mapIdToAssociatedProduct.values());
            return returnMap;
        }
        else{
            return new Map<Id, List<cls_associatedProdWrapper>>();
        }
    }

    private Map<String, Map<String, cls_categoryWrapper>> prepareCategoryMap(List<ProductCategoryProduct> product_category_list, Product2 prod, ProductDataService.productCategoryWrapper categoryWrapper){
        Map<String, Map<String, cls_categoryWrapper>> returnMap = new Map<String, Map<String, cls_categoryWrapper>>();
        Map<String, cls_categoryWrapper> mapCategoryWrapper = new Map<String, cls_categoryWrapper>();
        Map<String, cls_categoryWrapper> mapRepairAndObsoleteCategoryWrapper = new Map<String, cls_categoryWrapper>();
        system.debug('### parentObsoleteId:' + parentObsoleteId);
        if(!product_category_list.isEmpty()){
            for(ProductCategoryProduct pcp: product_category_list){
                /* UPDATED BY DHAVAL 02/13/2024 CM-2293 [START]*/
                //if(pcp.ProductCategoryId == System.Label.ProductObsoletePartCategory || pcp.ProductCategoryId == System.Label.ProductRepairPartsCategory){
                if(pcp.ProductCategoryId == System.Label.ProductRepairPartsCategory){
                /* UPDATED BY DHAVAL 02/13/2024 CM-2293 [END]*/
                    cls_categoryWrapper cw = new cls_categoryWrapper();
                    cw.objCategory = pcp;
                    cw.survive = false;
                    cw.isNew = false;
                    if(!mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + '' + pcp.ProductCategoryId)){
                        mapRepairAndObsoleteCategoryWrapper.put(prod.Id + '' + pcp.ProductCategoryId, cw);
                    }
                }
                /* ADDED BY DHAVAL 02/13/2024 CM-2293 [START]*/
               // else if(pcp.ProductCategoryId == System.Label.ProductObsoletePartCategory || (!String.isEmpty(parentObsoleteId) && pcp.ProductCategoryId == parentObsoleteId)){
                else if(obsuluteCategoryMap.containsKey(pcp.ProductCategoryId)){ //Dhannjay mohite Cm 2391

                    cls_categoryWrapper cw = new cls_categoryWrapper();
                    cw.objCategory = pcp;
                    cw.survive = false;
                    cw.isNew = false;
                    if(!mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + '' + pcp.ProductCategoryId)){
                        system.debug('### current obsoleteId:' + pcp.ProductCategoryId);
                        mapRepairAndObsoleteCategoryWrapper.put(prod.Id + '' + pcp.ProductCategoryId, cw);
                    }
                }
                /* ADDED BY DHAVAL 02/13/2024 CM-2293 [END]*/
                else if(!String.isEmpty(pcp.ProductCategory.PDS_Categories__c)){
                    cls_categoryWrapper cw = new cls_categoryWrapper();
                    cw.objCategory = pcp;
                    cw.pds_Category = pcp.ProductCategory.PDS_Categories__c.trim();
                    cw.survive = false;
                    cw.isNew = false;
                    if(!mapCategoryWrapper.containsKey(pcp.ProductCategory.PDS_Categories__c.trim())){
                        mapCategoryWrapper.put(pcp.ProductCategory.PDS_Categories__c.trim().toUpperCase(), cw);
                    }
                }
            }
        }
        system.debug('### categoryWrapper.lstCategory: ' + categoryWrapper.lstCategory);
        if(!categoryWrapper.lstCategory.isEmpty()){
            for(String cat: categoryWrapper.lstCategory){
                cat = cat.trim();
                system.debug('### Current Category: ' + cat);
                if((cat.startsWithIgnoreCase('Trade Portal') || cat.startsWithIgnoreCase('Trade Portal_')) && (!String.isEmpty(prod.Stocking_Type__c) && prod.Stocking_Type__c.trim() != '60')){
                    if(mapCategoryWrapper.containsKey(cat.trim().toUpperCase())){
                        mapCategoryWrapper.get(cat.trim().toUpperCase()).survive = true;
                    }
                    else{
                        cls_categoryWrapper cw = new cls_categoryWrapper();
                        cw.objCategory = new ProductCategoryProduct(
                            productId = prod.Id
                        );
                        cw.pds_Category = cat.trim();
                        cw.isNew = true;
                        mapCategoryWrapper.put(cat.trim().toUpperCase(), cw);
                    }
                }
            }
        }

        
        if(prod.RepairPart__c == true){
            if(!mapRepairAndObsoleteCategoryWrapper.isEmpty() && mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + System.Label.ProductRepairPartsCategory)){
                mapRepairAndObsoleteCategoryWrapper.get(prod.Id + '' + System.Label.ProductRepairPartsCategory).survive = true;
            }
            else{
                cls_categoryWrapper cw = new cls_categoryWrapper();
                cw.objCategory = new ProductCategoryProduct(
                    productId=prod.Id,
                    productCategoryId = System.Label.ProductRepairPartsCategory
                );
                cw.isNew = true;
                mapRepairAndObsoleteCategoryWrapper.put(prod.Id + '' + System.Label.ProductRepairPartsCategory, cw);
            }
        }
        if(!String.isEmpty(prod.Stocking_Type__c) && prod.Stocking_Type__c.trim() == '60'){
            /* UPDATED BY DHAVAL 02/13/2024 CM-2293 [START]*/
            //if(!mapRepairAndObsoleteCategoryWrapper.isEmpty() && mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + System.Label.ProductObsoletePartCategory)){
                //mapRepairAndObsoleteCategoryWrapper.get(prod.Id + '' + System.Label.ProductObsoletePartCategory).survive = true;

            if( !product_category_list.isEmpty()){

                system.debug('### product_category_list: ' + product_category_list);
                Boolean flagCheck = false;
                for(ProductCategoryProduct pcp: product_category_list){
                    if(!mapRepairAndObsoleteCategoryWrapper.isEmpty() && mapRepairAndObsoleteCategoryWrapper.containsKey(String.valueOf(prod.Id) + String.valueOf(pcp.ProductCategoryId)) && obsuluteCategoryMap.containsKey(pcp.ProductCategoryId)){
                        system.debug('### setting new obsolete parts id');
                        flagCheck = true;
                        mapRepairAndObsoleteCategoryWrapper.get(prod.Id + '' + pcp.ProductCategoryId).survive = true;
                        
                    }
                }
                if(!flagCheck){
                    system.debug('availableObsuluteCatID'+availableObsuluteCatID);
                     if (categoryCapacityMap.get(availableObsuluteCatID) == 0) {
                            // Find category with minimum capacity
                             availableObsuluteCatID = findCategoryWithCapacity(categoryCapacityMap); 
                         system.debug('availableObsuluteCatID'+availableObsuluteCatID);
                        }
                    system.debug(categoryCapacityMap);
                    categoryCapacityMap.put(availableObsuluteCatID, (categoryCapacityMap.get(availableObsuluteCatID) - 1));
                    system.debug(categoryCapacityMap);
                    cls_categoryWrapper cw = new cls_categoryWrapper();
                    cw.objCategory = new ProductCategoryProduct(
                    productId=prod.Id,
                    productCategoryId = availableObsuluteCatID
                );
                cw.isNew = true;
                mapRepairAndObsoleteCategoryWrapper.put(prod.Id + '' + availableObsuluteCatID, cw);

                }
            }
           /* if(!mapRepairAndObsoleteCategoryWrapper.isEmpty() && 
            (mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + System.Label.ProductObsoletePartCategory) || (!String.isEmpty(parentObsoleteId) && mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + String.valueOf(parentObsoleteId)) ))){
                if(mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + System.Label.ProductObsoletePartCategory)){
                    system.debug('### setting new obsolete parts id');
                    mapRepairAndObsoleteCategoryWrapper.get(prod.Id + '' + System.Label.ProductObsoletePartCategory).survive = true;
                }
                if(!String.isEmpty(parentObsoleteId) && mapRepairAndObsoleteCategoryWrapper.containsKey(prod.Id + String.valueOf(parentObsoleteId)) ){
                    system.debug('### setting old obsolete parts id');
                    mapRepairAndObsoleteCategoryWrapper.get(prod.Id + '' + String.valueOf(parentObsoleteId)).survive = true;
                }
             UPDATED BY DHAVAL 02/13/2024 CM-2293 [END]
            }
            else{
                categoryCapacityMap.put(availableObsuluteCatID, (categoryCapacityMap.get(availableObsuluteCatID) - 1));
                cls_categoryWrapper cw = new cls_categoryWrapper();
                cw.objCategory = new ProductCategoryProduct(
                    productId=prod.Id,
                    productCategoryId = availableObsuluteCatID
                );
                cw.isNew = true;
                mapRepairAndObsoleteCategoryWrapper.put(prod.Id + '' + availableObsuluteCatID, cw);
            }*/
        }
        system.debug('### final mapRepairAndObsoleteCategoryWrapper:' + mapRepairAndObsoleteCategoryWrapper);
        returnMap.put('TRADECATEGORY', mapCategoryWrapper);
        returnMap.put('REPAIRPARTANDOBSOLETE', mapRepairAndObsoleteCategoryWrapper);
        return returnMap;
    }
    private Id findCategoryWithCapacity(Map<Id, Integer> categoryCapacityMap) {
        Id minCapacityCategoryId = null;
        decimal maxSrCategory = 0 ;
        Integer minCapacity = ((Integer.valueOf(System.Label.maxProdCategory))+1);
        system.debug(categoryCapacityMap);
        for (Id categoryId : categoryCapacityMap.keySet()) {
            Integer availableCapacity = categoryCapacityMap.get(categoryId);
            
            if (availableCapacity > 0 && availableCapacity < minCapacity) {
                minCapacity = availableCapacity;
                minCapacityCategoryId = categoryId;
            }
            if(maxSrCategory == 0 || obsuluteCategoryMap.get(categoryId).Sr_Number__c> maxSrCategory){
                maxSrCategory = obsuluteCategoryMap.get(categoryId).Sr_Number__c;
            }
            system.debug(maxSrCategory	);
            
        }
        If(string.isEmpty(minCapacityCategoryId)){
            system.debug(maxSrCategory	);
            maxSrCategory++;
            string ProductObsoletePartCategory= '0ZGEc0000000yyjOAA';
            system.debug(maxSrCategory	);
            ProductCategory newObsoleteCt = new ProductCategory(name=obsuluteCategoryMap.get(ProductObsoletePartCategory).name+' ' + maxSrCategory,Sr_Number__c=maxSrCategory,
                                                                CatalogId=obsuluteCategoryMap.get(ProductObsoletePartCategory).CatalogId,
                                                                ParentCategoryId = obsuluteCategoryMap.get(ProductObsoletePartCategory).id);
            insert newObsoleteCt;
            system.debug('newObsoleteCt'+newObsoleteCt);
            minCapacityCategoryId = newObsoleteCt.id;
            obsuluteCategoryMap.put(minCapacityCategoryId,newObsoleteCt);
            categoryCapacityMap.put(minCapacityCategoryId,integer.valueof(System.Label.maxProdCategory));
        }
        return minCapacityCategoryId;
    }

    class cls_categoryWrapper{
        public productCategoryProduct objCategory {get;set;}
        public String pds_Category{get;set;}
        public boolean survive{get;set;}
        public boolean isNew{get;set;}
        public cls_categoryWrapper(){
            this.objCategory = new productCategoryProduct();
            this.survive = false;
            this.isNew = false;
        }
    }

    class cls_associatedProdWrapper{
        public Associated_Product__c objAccociatedProduct{get;set;}
        public String modelName{get;set;}
        public boolean survive{get;set;}
        public boolean isNew{get;set;}
        public cls_associatedProdWrapper(){
            this.objAccociatedProduct = new Associated_Product__c();
            this.objAccociatedProduct.Relationship_Type__c = 'Handle';
            this.survive = false;
            this.isNew = false;
        }
    }
    /*
    public void execute_old(Database.BatchableContext BC, List<Product2> scope){
        system.debug('#### scope in execute: ' + scope);
        List<object> objProductCategories = new List<object>();
        Set<Id> setAllProductIds = new Set<Id>();
        List<ProductCategoryProduct> productCategoryProductList = new List<ProductCategoryProduct>();
        List<ProductDataService.productCategoryWrapper> lstCategoryWrapper = new List<ProductDataService.productCategoryWrapper>();
        if(!scope.isEmpty()){
            for(Product2 prod: scope){
                setAllProductIds.add(prod.Id);
                if(!String.isEmpty(prod.Category_And_Associated_Products__c)){
                    objProductCategories.add(JSON.deserialize(prod.Category_And_Associated_Products__c, ProductDataService.productCategoryWrapper.class));
                    object obj = JSON.deserialize(prod.Category_And_Associated_Products__c, ProductDataService.productCategoryWrapper.class);
                    ProductDataService.productCategoryWrapper categoryWrapper = (ProductDataService.productCategoryWrapper) obj;
                    categoryWrapper.productId = prod.Id;
                    lstCategoryWrapper.add(categoryWrapper);
                }
            }
        }
        Set<String> setCategoryName = new Set<String>();
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setParentProductIds = new Set<Id>();
        Set<Id> setAssociatedProductIds = new Set<Id>();
        Set<String> setAssociatedModel = new Set<String>();
        Map<String, Set<Id>> mapCategoryToProductId = new Map<String, Set<Id>>();
        Map<String,Set<Id>> mapModelToProductId = new Map<String,Set<Id>>();


        //Remove Old Entries
        if(!setAllProductIds.isEmpty()){
            List<ProductCategoryProduct> pcpToDeleteList = [SELECT 
                                                        Id
                                                    FROM 
                                                        ProductCategoryProduct
                                                    WHERE
                                                        ProductId in: setAllProductIds];
            if(!pcpToDeleteList.isEmpty()){
                Delete pcpToDeleteList;
            }
            List<Associated_Product__c> existingAssociatedProducts = [
                Select
                    Id,Parent_Product__c,Product_Associated__c
                FROM
                    Associated_Product__c
                WHERE
                    Parent_Product__c In:setAllProductIds  
            ];
            //Remove old associated products
            if(!existingAssociatedProducts.isEmpty()){
                Delete existingAssociatedProducts;
            }
        }

            
        //Adding Repair/Obsolete Parts Categories
        for(Product2 prod: scope){
            if(prod.RepairPart__c == true){
                ProductCategoryProduct pcp = new ProductCategoryProduct();
                pcp.ProductCategoryId = System.Label.ProductRepairPartsCategory;
                pcp.ProductId = prod.Id;
                productCategoryProductList.add(pcp);
            }
            if(!String.isEmpty(prod.Stocking_Type__c) && prod.Stocking_Type__c.trim() == '60'){
                ProductCategoryProduct pcp = new ProductCategoryProduct();
                pcp.ProductCategoryId = System.Label.ProductObsoletePartCategory;
                pcp.ProductId = prod.Id;
                productCategoryProductList.add(pcp);
            }
        }
        if(!lstCategoryWrapper.isEmpty()){
            for(ProductDataService.productCategoryWrapper categoryWrapper : lstCategoryWrapper){
                System.debug('@@categoryWrapper= '+categoryWrapper);
                for(String category: categoryWrapper.lstCategory){
                    category = category.trim();
                    System.debug('@@category= '+category);
                    if(category.startsWithIgnoreCase('Trade Portal') || category.startsWithIgnoreCase('Trade Portal_')){
                        setCategoryName.add(category);
                        setProductIds.add(categoryWrapper.productId);
                        if(mapCategoryToProductId.containsKey(category)){
                            mapCategoryToProductId.get(category).add(categoryWrapper.productId);
                        }
                        else{
                            mapCategoryToProductId.put(category, new Set<Id> {categoryWrapper.productId});
                        }
                    }
                }
                
                if(categoryWrapper.setproductModel != null && !categoryWrapper.setproductModel.isEmpty()){
                    for(String model :categoryWrapper.setproductModel){
                        setAssociatedModel.add(model.trim());
                        setParentProductIds.add(categoryWrapper.productId);
                        if(mapModelToProductId.containsKey(model)){
                            mapModelToProductId.get(model.trim()).add(categoryWrapper.productId);
                        }
                        else{
                            mapModelToProductId.put(model.trim(), new Set<Id> {categoryWrapper.productId});
                        }
                    }
                    
                }
            }
            Map<Id,Map<Id,Associated_Product__c>> associatedProductMap = new Map<Id,Map<Id,Associated_Product__c>>();
            if(!setAssociatedModel.isEmpty()){
                List<Product2> associatedProductList = [
                                    SELECT
                                        id,ProductCode,Name
                                    FROM
                                        Product2
                                    WHERE
                                        ProductCode IN: setAssociatedModel
                                ];
                Map<String, Id> mapAccociatedProdctId = new Map<String, Id>();
                for(Product2 accProd: associatedProductList){
                    mapAccociatedProdctId.put(accProd.ProductCode, accProd.Id);
                }

                List<Associated_Product__c> associatedProductToBeSaved =  new List<Associated_Product__c>();
                if(!setAssociatedModel.isEmpty()){
                    for(String assModel: setAssociatedModel){
                        if(!mapModelToProductId.isEmpty() && mapModelToProductId.containsKey(assModel.trim())){
                            Set<Id> parentProductIds =  mapModelToProductId.get(assModel.trim());
                            Id accociatedProductId = mapAccociatedProdctId.get(assModel.trim());
                            for(Id parentId: parentProductIds){
                                Associated_Product__c associatedPro = new Associated_Product__c(
                                    Parent_Product__c = parentId,
                                    Product_Associated__c = accociatedProductId,
                                    Name = assModel,
                                    Relationship_Type__c = 'Handle');
                                associatedProductToBeSaved.add(associatedPro);
                            }
                        }
                    }
                }


                if (!associatedProductToBeSaved.isEmpty()){
                    //insert associatedProductToBeSaved;
                    Database.SaveResult[] saveResultList = Database.insert(associatedProductToBeSaved, false);
                    for (Database.SaveResult sr : saveResultList) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully inserted AssociatedProduct: ' + sr.getId());
                        }
                        else {        
                            String error_desc = '';     
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('AssociatedProduct: The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('AssociatedProduct fields that affected this error: ' + err.getFields());
                                error_desc += '\nSTATUS CODE: ' + err.getStatusCode();
                                error_desc += '\nERROR MESSAGE: ' + err.getMessage();
                                error_desc += '\nFIELDS: ' + err.getFields(); 
                                error_desc += '\n\n';
                            }
                            associated_product_errors_list.add(error_desc);
                        }
                    }
                }    
                
            }        

            System.debug('@@ mapCategoryToProductId= '+mapCategoryToProductId);
            if(!setCategoryName.isEmpty()){
                Map<String, Id> mapCategoryToId = new Map<String, Id>();
                Set<Id> setProductCategoryIds = new Set<Id>();
                List<ProductCategory> productCategoryList = [
                                                                SELECT 
                                                                    Id, PDS_Categories__c
                                                                FROM 
                                                                    ProductCategory
                                                                WHERE 
                                                                    PDS_Categories__c IN: setCategoryName
                                                        ];

                if(!productCategoryList.isEmpty()){
                    for(ProductCategory pc: productCategoryList){
                        mapCategoryToId.put(pc.PDS_Categories__c.trim(), pc.Id);
                        setProductCategoryIds.add(pc.Id);
                    }
                }
                System.debug('@@ productCategoryList= '+productCategoryList);
                System.debug('@@ mapCategoryToId= '+mapCategoryToId);
                System.debug('@@ setProductCategoryIds= '+setProductCategoryIds);
                

                //Preparing list of ProductCategoryProduct to insert
                
                for(String categoryName : mapCategoryToProductId.keySet()){
                    Set<Id> productIdSet = mapCategoryToProductId.get(categoryName.trim());
                    for(Id prod_id: productIdSet){
                        system.debug('@@@ Current category: ' + categoryName);
                        system.debug('@@@ ' + mapCategoryToId.containsKey(categoryName.Trim()));
                        if(mapCategoryToId.containsKey(categoryName.Trim())){
                            ProductCategoryProduct pcp = new ProductCategoryProduct();
                            pcp.ProductCategoryId = mapCategoryToId.get(categoryName.Trim());
                            pcp.ProductId = prod_id;
                            if(!String.isEmpty(pcp.ProductCategoryId) && !String.isEmpty(pcp.ProductId)){
                                productCategoryProductList.add(pcp);
                            }
                        }
                    }
                }
            }
        }
        

        System.debug('@@ productCategoryProductList= '+productCategoryProductList);
        if(!productCategoryProductList.isEmpty()){
            //insert productCategoryProductList;
            Database.SaveResult[] saveResultList = Database.insert(productCategoryProductList, false);
            for (Database.SaveResult sr : saveResultList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted ProductCategoryProduct: ' + sr.getId());
                }
                else {       
                    String error_desc = '';      
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('ProductCategoryProduct: The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('ProductCategoryProduct fields that affected this error: ' + err.getFields());
                        error_desc += '\nSTATUS CODE: ' + err.getStatusCode();
                        error_desc += '\nERROR MESSAGE: ' + err.getMessage();
                        error_desc += '\nFIELDS: ' + err.getFields(); 
                        error_desc += '\n\n';
                    }
                    category_errors_list.add(error_desc);
                }
            }
        }
    }*/
    
    public void finish(Database.BatchableContext BC) {
    
        if(productTriggerStatus == true){
            List<Trigger_Setting__c> triggerSettingList = [Select Id, isActive__c From Trigger_Setting__c WHERE name = 'Product'];
            triggerSettingList[0].isActive__c = true;
            update triggerSettingList[0];
        }
        if(!category_errors_list.isEmpty()){
            sendMail('Error found during CategoryProductCategory creation - ' + System.Now(), category_errors_list);
        }
        if(!associated_product_errors_list.isEmpty()){
            sendMail('Error found during Associated Product record creation - ' + System.Now(), associated_product_errors_list);
        }
        if (!Test.isRunningTest() && this.setProductNames.isEmpty()){
           Id batchJobIdCE = Database.executeBatch(new ProductDataServiceCommerceEntitlement());
        }
    }

    private static void sendMail(String subject, List<String> error_list){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<string> to = new List<string>();
        to.add('dhaval.panchal@deltafaucet.com');
        to.add('dhiraj.patil@deltafaucet.com');
        email.setToAddresses(to);
        
        email.setSubject(subject);
        
        email.setHtmlBody(String.join(error_list, '\n========================================================'));
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            system.debug('Errors: ' + e.getMessage());
        }
    }
}