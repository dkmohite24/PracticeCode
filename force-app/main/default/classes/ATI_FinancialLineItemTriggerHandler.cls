/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        1-2-2021
* @modified
* @description :   Trigger Handler Class for ATI_FinancialLineItemTrigger 
* --------------------------------------------------------------------------------------------------
*/
public class ATI_FinancialLineItemTriggerHandler extends TriggerHandler {
    public static Boolean skipFLITriggerHandlerForITR = false; 
    @TestVisible static Boolean skipQueryExecution = false;
    static WOD_2__Claim__c claimObj = null;
    static List<ATI_Part_Markup__c> partMarkupLst = null;
    static List<WOD_2__Rates_Details__c> ratesLst = null;
    //map of installed claim part id to wp id
    static Map<Id,WOD_2__Claim_Part__c> partIdToWPIdMap = new Map<Id,WOD_2__Claim_Part__c>();
    //Map of warranty product Id to wp pricebook price
    static Map<Id,Decimal> wpIdToPriceMap = new Map<Id,Decimal>();
    static ATI_ExchangeRateService.ExchangeWrapper erObj = new ATI_ExchangeRateService.ExchangeWrapper();
    public override void beforeInsert() {
        if(!skipFLITriggerHandlerForITR){
            calculatePriceForFLI();
            calculatePriceAfterUpdate();
        }
        setEligibleAmountBasedOnPolicy();
        setRecordTypeOnFLI();
    }
    
    public override void beforeUpdate() {
        setEligibleAmountBasedOnPolicy();
        if(!skipFLITriggerHandlerForITR){
            calculatePriceForFLI();
            calculatePriceAfterUpdate();
        }
        financialLineNameUpdate();
    }
    
    private void setEligibleAmountBasedOnPolicy(){
        Set<Id> claimIdsSet = new Set<Id>();
        List<WOD_2__Financial_Line_Item__c> fliList = (List<WOD_2__Financial_Line_Item__c>)Trigger.new;
        for(WOD_2__Financial_Line_Item__c fliObj : fliList ){
            if(fliObj.WOD_2__Cost_Category_Type__c == 'OEM Parts' || fliObj.WOD_2__Cost_Category_Type__c == 'Labor'){
            	claimIdsSet.add(fliObj.WOD_2__Claim__c);
            }
        }
        if(!claimIdsSet.isEmpty()){
            Map<Id, WOD_2__Claim__c> claimMap = new Map<Id, WOD_2__Claim__c>(
                [select Id, ATI_Part_Covered__c, ATI_Labor_Covered__c from WOD_2__Claim__c where id in :claimIdsSet]);
            for(WOD_2__Financial_Line_Item__c fliObj : fliList ){
                WOD_2__Claim__c claim = claimMap.get(fliObj.WOD_2__Claim__c);
                if(fliObj.WOD_2__Cost_Category_Type__c == 'OEM Parts' && claim.ATI_Part_Covered__c != null){
                    fliObj.WOD_2__Total_Eligible_Amount__c = (fliObj.WOD_2__Total_Requested_Amount__c * claim.ATI_Part_Covered__c) / 100;     
                } else if(fliObj.WOD_2__Cost_Category_Type__c == 'Labor' && claim.ATI_Labor_Covered__c != null){
                        fliObj.WOD_2__Total_Eligible_Amount__c = (fliObj.WOD_2__Total_Requested_Amount__c * claim.ATI_Labor_Covered__c) / 100;     
                }
            }
        }
    }
    
    public static void calculatePriceForFLI(){
        Set<Id> claimIdsSet = new Set<Id>();
        Set<Id> installedClaimPartIdSet = new Set<Id>();
        for(WOD_2__Financial_Line_Item__c fliObj: (List<WOD_2__Financial_Line_Item__c>)Trigger.new ){
            claimIdsSet.add(fliObj.WOD_2__Claim__c);
            if(fliObj.WOD_2__Installed_Claim_Part__c != NULL){
                installedClaimPartIdSet.add(fliObj.WOD_2__Installed_Claim_Part__c);
            }
        }
        //ALSN-03
		Integer allowedDecimalPlaces = 4;
        if(!skipQueryExecution){
            claimObj = [SELECT Id,CurrencyIsoCode,WOD_2__Model_Number__c,WOD_2__Account__c,WOD_2__Date_Of_Failure__c,WOD_2__Claim_Status__c,WOD_2__Applicable_Policy__c,
                        WOD_2__Model_Number__r.Part_Markup_Percentage__c,WOD_2__Account__r.Type,WOD_2__BusinessCategory__c,WOD_2__Applicable_Policy__r.WOD_2__Sub_Type__c,
                        WOD_2__Claim_Type__c, WOD_2__Date_Of_Purchase__c,WOD_2__Date_Of_Repair__c,WOD_2__Account__r.ATI_Customer_Group__c,ATI_Exchange_Rate__c,
                        ATI_Claim_Subtype__c
                        FROM WOD_2__Claim__c WHERE Id in :claimIdsSet LIMIT 1];
            allowedDecimalPlaces = Integer.valueOf(ATI_Utils.getConfiguration(claimObj.WOD_2__BusinessCategory__c, 'CA_AllowedDecimalPlaces').WOD_2__Value__c);
            if(!installedClaimPartIdSet.isEmpty()){
                String dateFieldForPriceFetchStr = ATI_Utils.getConfiguration(claimObj.WOD_2__BusinessCategory__c, 'CLM_Price_Fetch_ClaimField_Tobe_Compare').WOD_2__Value__c;
                Date dateFieldForPriceFetch = (Date) claimObj.get(dateFieldForPriceFetchStr);
                //PartMarkup
                //ALSN-191 Removed claimObj.WOD_2__Account__r.Type != NULL check as Type is not being really used in the Query
                if(claimObj.ATI_Claim_Subtype__c != null && claimObj.WOD_2__Model_Number__c != NULL 
                && claimObj.WOD_2__Account__c != NULL && dateFieldForPriceFetch != NULL){
                    partMarkupLst = [SELECT Id,ATI_Part_Markup_Percentage__c
                                        FROM ATI_Part_Markup__c
                                        WHERE ATI_Claim_Type__c=:claimObj.ATI_Claim_Subtype__c AND ATI_Active__c = true
                                        AND ATI_Customer_Group_Type__c=:claimObj.WOD_2__Account__r.ATI_Customer_Group__c
                                        AND ATI_Active_From__c <=:dateFieldForPriceFetch
                                        AND ATI_Active_Until__c >=:dateFieldForPriceFetch order by ATI_Active_From__c desc LIMIT 1];
                }
                //LandingCostRate
                if(claimObj.WOD_2__Account__c != NULL && dateFieldForPriceFetch != NULL){
                    ratesLst = [SELECT Id,ATI_Landed_Cost_Markup__c FROM WOD_2__Rates_Details__c 
                                WHERE WOD_2__Dealer__c=:claimObj.WOD_2__Account__c
                                AND WOD_2__Active_From__c <=:dateFieldForPriceFetch AND WOD_2__Status__c='Active'
                                AND WOD_2__Active_Until__c >=:dateFieldForPriceFetch 
                                AND RecordType.DeveloperName='ATI_Landing_Cost_Rate' order by WOD_2__Active_From__c LIMIT 1];
                }
            
                List<WOD_2__Claim_Part__c> claimPartLst = [SELECT Id,WOD_2__Warranty_Product__c, WOD_2__Warranty_Product__r.Part_Markup_Percentage__c
                                                           FROM WOD_2__Claim_Part__c WHERE Id IN :installedClaimPartIdSet];
                partIdToWPIdMap = new Map<Id, WOD_2__Claim_Part__c>(claimPartLst);
            }
            if(Trigger.isInsert){
            	//skipQueryExecution = true;    
            }
        }
		Map<Id, WOD_2__Financial_Line_Item__c> fliOldMap = (Map<Id, WOD_2__Financial_Line_Item__c>) Trigger.oldMap;
        for(WOD_2__Financial_Line_Item__c fliObj : (List<WOD_2__Financial_Line_Item__c>)Trigger.new){
            //fliObj.ATI_Total_Requested_Amount_USD__c = fliObj.ATI_Total_Requested_Amount_In_USD__c;
            //fliObj.ATI_Markup__c = 0.0;
            //fliObj.ATI_Landed_Part_Markup__c = 0.0;
            Decimal amountToCalculate;
            if(Trigger.isInsert || fliObj.WOD_2__Total_Requested_Amount__c != fliOldMap.get(fliObj.Id).WOD_2__Total_Requested_Amount__c){
                amountToCalculate = fliObj.WOD_2__Total_Requested_Amount__c;
            }else if(Trigger.isUpdate && fliObj.WOD_2__Approved_Amount__c != NULL
                    && (fliObj.WOD_2__Approved_Amount__c != fliOldMap.get(fliObj.Id).WOD_2__Approved_Amount__c
                        || fliObj.WOD_2__Approved_Quantity__c != fliOldMap.get(fliObj.Id).WOD_2__Approved_Quantity__c)
                    && fliObj.ATI_Markup__c == fliOldMap.get(fliObj.Id).ATI_Markup__c){
                           if(fliOldMap.get(fliObj.Id).WOD_2__Percentage_Amount__c != null && fliObj.WOD_2__Percentage_Amount__c != fliOldMap.get(fliObj.Id).WOD_2__Percentage_Amount__c){
                                amountToCalculate = (fliObj.WOD_2__Requested_Per_Unit_Amt__c * fliObj.WOD_2__Requested_Quantity__c) * fliObj.WOD_2__Percentage_Amount__c/100;
                            } else {
                                amountToCalculate = fliObj.WOD_2__Requested_Per_Unit_Amt__c * fliObj.WOD_2__Approved_Quantity__c; 
                            }
            }
            System.debug('Amount To Calculate -> ' + amountToCalculate);
            if(fliObj.WOD_2__Installed_Claim_Part__c != null){
                if(amountToCalculate != NULL ){
                    if(partIdToWPIdMap.containsKey(fliObj.WOD_2__Installed_Claim_Part__c) && 
                       partIdToWPIdMap.get(fliObj.WOD_2__Installed_Claim_Part__c).WOD_2__Warranty_Product__r.Part_Markup_Percentage__c != null){
                           Decimal partMarkupPercentage  = partIdToWPIdMap.get(fliObj.WOD_2__Installed_Claim_Part__c).WOD_2__Warranty_Product__r.Part_Markup_Percentage__c;
                           fliObj.ATI_Markup__c = getValue((amountToCalculate * partMarkupPercentage/100),allowedDecimalPlaces) ; 
                    } else if(partMarkupLst != null && !partMarkupLst.isEmpty() && partMarkupLst[0].ATI_Part_Markup_Percentage__c != NULL){
                        fliObj.ATI_Markup__c = getValue((amountToCalculate * partMarkupLst[0].ATI_Part_Markup_Percentage__c/100),allowedDecimalPlaces);
                    }
                    if(ratesLst != null && !ratesLst.isEmpty() && ratesLst[0].ATI_Landed_Cost_Markup__c != NULL){
                        fliObj.ATI_Landed_Part_Markup__c = getValue((amountToCalculate * ratesLst[0].ATI_Landed_Cost_Markup__c/100), allowedDecimalPlaces);
                    }                  	
                }
            }
            fliObj.ATI_Markup__c = (fliObj.ATI_Markup__c == null) ? 0.0 : fliObj.ATI_Markup__c;
            fliObj.ATI_Landed_Part_Markup__c = (fliObj.ATI_Landed_Part_Markup__c == null) ? 0.0 : fliObj.ATI_Landed_Part_Markup__c;
            if(amountToCalculate != NULL){
                System.debug('Total Requested Amount -> ' + fliObj.WOD_2__Total_Requested_Amount__c);
                if((Trigger.isInsert || fliObj.WOD_2__Total_Requested_Amount__c != fliOldMap.get(fliObj.Id).WOD_2__Total_Requested_Amount__c) &&  
                   fliObj.WOD_2__Total_Requested_Amount__c != null){
                    fliObj.WOD_2__Total_Requested_Amount__c = getValue((fliObj.WOD_2__Total_Requested_Amount__c+fliObj.ATI_Markup__c+fliObj.ATI_Landed_Part_Markup__c),allowedDecimalPlaces);
                    Decimal exchangeRate = (claimObj.ATI_Exchange_Rate__c != NULL) ? claimObj.ATI_Exchange_Rate__c : 1;
                    fliObj.ATI_Total_Requested_Amount_USD__c = getValue((fliObj.WOD_2__Total_Requested_Amount__c * exchangeRate),2);    
                    System.debug('In USD -> ' + fliObj.ATI_Total_Requested_Amount_USD__c);   
                }else if(Trigger.isUpdate && fliObj.WOD_2__Approved_Amount__c != NULL
                        && (fliObj.WOD_2__Approved_Amount__c != fliOldMap.get(fliObj.Id).WOD_2__Approved_Amount__c
                            || fliObj.WOD_2__Approved_Quantity__c != fliOldMap.get(fliObj.Id).WOD_2__Approved_Quantity__c
                            || fliObj.ATI_Markup__c != fliOldMap.get(fliObj.Id).ATI_Markup__c)){
                   fliObj.WOD_2__Approved_Amount__c = getValue((amountToCalculate+fliObj.ATI_Markup__c+fliObj.ATI_Landed_Part_Markup__c),allowedDecimalPlaces);
                    Decimal exchangeRate = (claimObj.ATI_Exchange_Rate__c != NULL) ? claimObj.ATI_Exchange_Rate__c : 1;
					fliObj.ATI_Total_Approved_Amount_in_USD__c = getValue((fliObj.WOD_2__Approved_Amount__c * exchangeRate), 2);    
                }
            }
        }
    }
    

    /**
     * Description  :   Set factory cost , factory price and update approved amount in USD
     */
    public static void calculatePriceAfterUpdate(){
        Set<Id> claimIdsSet = new Set<Id>();
        Set<Id> installedClaimPartIdSet = new Set<Id>();
        for(WOD_2__Financial_Line_Item__c fliObj: (List<WOD_2__Financial_Line_Item__c>)Trigger.new ){
            claimIdsSet.add(fliObj.WOD_2__Claim__c);
            if(fliObj.WOD_2__Installed_Claim_Part__c != NULL){
                installedClaimPartIdSet.add(fliObj.WOD_2__Installed_Claim_Part__c);
            }
        }
        Integer allowedDecimalPlaces = 4;
        if(!skipQueryExecution){
            claimObj = [SELECT Id,ATI_Exchange_Rate__c,WOD_2__Date_Of_Failure__c,WOD_2__Date_Of_Purchase__c,WOD_2__Date_Of_Repair__c,WOD_2__BusinessCategory__c
                        FROM WOD_2__Claim__c WHERE Id in :claimIdsSet LIMIT 1];
            allowedDecimalPlaces = Integer.valueOf(ATI_Utils.getConfiguration(claimObj.WOD_2__BusinessCategory__c, 'CA_AllowedDecimalPlaces').WOD_2__Value__c);
            if(!installedClaimPartIdSet.isEmpty()){
                String dateFieldForPriceFetchStr = ATI_Utils.getConfiguration(claimObj.WOD_2__BusinessCategory__c, 'CLM_Price_Fetch_ClaimField_Tobe_Compare').WOD_2__Value__c;
                Date dateFieldForPriceFetch = (Date) claimObj.get(dateFieldForPriceFetchStr);
                List<WOD_2__Claim_Part__c> claimPartLst = [SELECT Id,WOD_2__Warranty_Product__c, WOD_2__Warranty_Product__r.Part_Markup_Percentage__c
                                                                FROM WOD_2__Claim_Part__c WHERE Id IN :installedClaimPartIdSet];
                List<Id> installedPartIdList = new List<Id>();
                for(WOD_2__Claim_Part__c partObj : claimPartLst){
                    installedPartIdList.add(partObj.WOD_2__Warranty_Product__c);
                }
                partIdToWPIdMap = new Map<Id, WOD_2__Claim_Part__c>(claimPartLst);
                List<WOD_2__Warranty_Product_Pricebook__c> wpPbLst = [SELECT Id,WOD_2__Price__c,WOD_2__Warranty_Product__c FROM WOD_2__Warranty_Product_Pricebook__c 
                                                                        WHERE WOD_2__Warranty_Product__c IN :installedPartIdList
                                                                        AND WOD_2__Valid_From__c <=:dateFieldForPriceFetch AND ATI_Active__c=true
                                                                        AND WOD_2__Valid_Until__c >=:dateFieldForPriceFetch 
                                                                        AND RecordType.DeveloperName='ATI_Part_Cost'];
                for(WOD_2__Warranty_Product_Pricebook__c wpPbObj : wpPbLst){
                    if(wpPbObj.WOD_2__Price__c != NULL){
                        System.debug('wpPbObj------->'+wpPbObj);
                        wpIdToPriceMap.put(wpPbObj.WOD_2__Warranty_Product__c,wpPbObj.WOD_2__Price__c);
                    }
                }
            }
    		skipQueryExecution = true;
        }
        for(WOD_2__Financial_Line_Item__c fliObj : (List<WOD_2__Financial_Line_Item__c>)Trigger.new){
            if(partIdToWPIdMap.containsKey(fliObj.WOD_2__Installed_Claim_Part__c) 
               && wpIdToPriceMap.containsKey(partIdToWPIdMap.get(fliObj.WOD_2__Installed_Claim_Part__c).WOD_2__Warranty_Product__c)){
                fliObj.ATI_Factory_Price__c = wpIdToPriceMap.get(partIdToWPIdMap.get(fliObj.WOD_2__Installed_Claim_Part__c).WOD_2__Warranty_Product__c);
                Decimal quantiy = (fliObj.WOD_2__Approved_Quantity__c != NULL) ? fliObj.WOD_2__Approved_Quantity__c : fliObj.WOD_2__Requested_Quantity__c;
                if(quantiy != NULL){
                    fliObj.ATI_Factory_Cost__c = fliObj.ATI_Factory_Price__c * quantiy;
                    Decimal approvedPercentage = fliObj.WOD_2__Percentage_Amount__c == null ? 100.0 : fliObj.WOD_2__Percentage_Amount__c;
                    fliObj.ATI_Factory_Cost__c = fliObj.ATI_Factory_Cost__c * approvedPercentage/100;
                }
            }
            if(fliObj.WOD_2__Total_Approved_Amt__c != NULL && claimObj.ATI_Exchange_Rate__c != NULL){
                fliObj.ATI_Total_Approved_Amount_in_USD__c = getValue((fliObj.WOD_2__Total_Approved_Amt__c * claimObj.ATI_Exchange_Rate__c), 2);
            }
        }
    }
     /*
	Method Name :   financialLineNameUpdate
	Params      :   Set Financial Line Name 
    Added by Dishari 05/27/2021
	*/
     public void financialLineNameUpdate(){
        Map<Id,WOD_2__Financial_Line_Item__c> mapOfFinancialLine = New Map<Id,WOD_2__Financial_Line_Item__c>(
                                                           [Select id,Name,WOD_2__Other_Cost__c,
                                                            WOD_2__Other_Cost__r.Name,WOD_2__Type__c 
                                                            From WOD_2__Financial_Line_Item__c 
                                                            Where Id IN: Trigger.new]);
         List<WOD_2__Financial_Line_Item__c> listFinancialLine = (List<WOD_2__Financial_Line_Item__c>)Trigger.new;
         
         for(WOD_2__Financial_Line_Item__c nFinancialLine : listFinancialLine){
            if(nFinancialLine.WOD_2__Other_Cost__c != NULL && nFinancialLine.WOD_2__Type__c == 'Other'){
               nFinancialLine.Name = mapOfFinancialLine.get(nFinancialLine.Id).WOD_2__Other_Cost__r.Name;
            }
         
         }
    }
    
    //set record type
    public static void setRecordTypeOnFLI(){
        Id oemPartRTId = Schema.SObjectType.WOD_2__Financial_Line_Item__c.getRecordTypeInfosByDeveloperName().get('OEM_Part').getRecordTypeId();
        Id laborRTId = Schema.SObjectType.WOD_2__Financial_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Labor').getRecordTypeId();
        Id otherCostRTId = Schema.SObjectType.WOD_2__Financial_Line_Item__c.getRecordTypeInfosByDeveloperName().get('Other_Cost').getRecordTypeId();
        for(WOD_2__Financial_Line_Item__c fliObj : (List<WOD_2__Financial_Line_Item__c>)Trigger.New){
            if(fliObj.WOD_2__Type__c=='Part'){
                fliObj.RecordTypeId = oemPartRTId;
            }else if(fliObj.WOD_2__Type__c=='Labor'){
                fliObj.RecordTypeId = laborRTId;
            }else if(fliObj.WOD_2__Type__c=='Other'){
                fliObj.RecordTypeId = otherCostRTId;
            }
        }
    }
    
    private static Decimal getValue(Decimal origValue, Integer allowedDecimalPlaces){
        Decimal returnValue = origValue;
        returnValue = returnValue.setScale(allowedDecimalPlaces,RoundingMode.HALF_UP);
        return returnValue;
    }
}