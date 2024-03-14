/* Name: ATI_REST_BatchETCSubmittal_Validator
Description : This Class is used to validate Batch ETC Submittal JSON request data
Author : Tavant(Punam)
History:
VERSION     AUTHOR              DATE               DETAIL                   UserStory/Req#
1.0 -     Tavant(Punam)       03/02/2021        INITIAL DEVELOPMENT                               
*/
public with sharing class ATI_REST_BatchETCSubmittal_Validator {
    public List<ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation> batchETCReqLst{get; set;}	
    public Map<Integer,List<String>> mapOfFailure{get; private set;}

    public Set<String> buSet{get; private set;}
    public Set<String> sapIdSet{get; private set;}
	public Set<String> vinSet{get; private set;}
	public Set<String> vocationCodeSet{get; private set;}
    public Set<String> etcWRNumberSet{get; private set;}
    public Set<String> serialNumberSet{get; private set;}
    public Set<String> customerName{get; private set;}
    public Set<String> customerCity{get; private set;}
    public Set<String> customerPostal{get; private set;}
	public Set<String> etcPolicySet{get; private set;}
    public Set<String> modelSet{get; private set;}
    public Set<String> countrySet{get; private set;}
    
    public Map<String,String> buNameIdMap{get; private set;}
    public Map<String,Account> accSapIdAccountMap{get; private set;}
	public Map<String,ATI_Vehicle_Information__c> vehInfoMapDetails{get; private set;}
	public Map<String,WOD_2__Warranty_Code__c> vocCodeMap{get; private set;}
	public Map<String,WOD_2__Warranty_Registration__c> mapOfWarrantyReg{get; private set;}
    public Map<String,WOD_2__Inventory__c> invMapDetails{get; private set;}
    public Map<String,Account> endCustomerAccountMap{get; private set;}
    public Map<String,WOD_2__Policy_Definition__c> etcPolicyMap{get; private set;}
    public Map<String,List<ATI_Extended_Warranty_Pricing__c>> extPriceMap{get; private set;}
    public Map<String,ATI_Extended_Warranty_Pricing__c> invExtPriceMap{get; private set;}
    public Map<String,WOD_2__Warranty_Registration__c> existingWarrantyRegMap{get; private set;}
    
    public Set<String> setOfSuccessRecords{get; private set;}
    public Set<String> setOfFailedRecords{get; private set;}
    public Integer totalrecords{get; set;}
    public Integer totalFailedRecords{get; set;}
    public Map<String, String> countryMap{get; set;}
    
    public ATI_REST_BatchETCSubmittal_Validator(){
		
        batchETCReqLst = new List<ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation>();
        
        buSet = new Set<String>();
        sapIdSet = new Set<String>();
        vinSet = new Set<String>();
        vocationCodeSet = new Set<String>();
        etcWRNumberSet = new Set<String>();
        serialNumberSet = new Set<String>();
        customerName = new Set<String>();
        customerCity = new Set<String>();
        customerPostal = new Set<String>();
        etcPolicySet = new Set<String>();
        modelSet = new Set<String>();
        countrySet = new Set<String>();
        
        buNameIdMap= new Map<String,String>();
        accSapIdAccountMap = new Map<String,Account>();
        vehInfoMapDetails = new Map<String,ATI_Vehicle_Information__c>();
        vocCodeMap = new Map<String,WOD_2__Warranty_Code__c>();
        mapOfWarrantyReg = new Map<String,WOD_2__Warranty_Registration__c>();
        invMapDetails = new Map<String,WOD_2__Inventory__c>();
        endCustomerAccountMap = new Map<String,Account>();
        etcPolicyMap = new Map<String,WOD_2__Policy_Definition__c>();
        extPriceMap = new Map<String,List<ATI_Extended_Warranty_Pricing__c>>();
		invExtPriceMap = new Map<String,ATI_Extended_Warranty_Pricing__c>();
        existingWarrantyRegMap = new Map<String,WOD_2__Warranty_Registration__c>();
        
        countryMap = ATI_UTILS.getPicklistOptions('Account', 'ATI_Billing_Country__c');
        
        mapOfFailure = new Map<Integer,List<String>>();
        accSapIdAccountMap = new Map<String,Account>();
        setOfSuccessRecords = new Set<String>();
        setOfFailedRecords= new Set<String>();
        totalrecords = 0;
        totalFailedRecords = 0;
    }
    
    public void validateReqest(ATI_REST_BatchETCSubmittalRequest batchETCRequestBody){
        initAllParameters(batchETCRequestBody);
        queryBatchETCData(batchETCRequestBody);
        verifyBatchETCRequest(batchETCRequestBody);
    }
    
    private void initAllParameters(ATI_REST_BatchETCSubmittalRequest batchETCRequestBody){
        System.debug('batchETCRequestBody----------->'+batchETCRequestBody);
        for(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation req : batchETCRequestBody.etcPurchase){
            etcPolicySet.add(req.etcCoverageCode);
            etcWRNumberSet.add(req.etcRegistrationNumber);    
            buSet.add(req.businessCategoryConfiguration);    
            sapIdSet.add(req.repairOutlet);
            serialNumberSet.add(req.vehicleInfo.serialNumber);    
            vocationCodeSet.add(req.vehicleInfo.vocationCode);    
            vinSet.add(req.vehicleInfo.vehicleIdentificationNumber);    
            customerName.add(req.customerInfo.customerName);
            customerCity.add(req.customerInfo.city);
            customerPostal.add(req.customerInfo.postalCode);
        }
    }
    
    private void queryBatchETCData(ATI_REST_BatchETCSubmittalRequest batchETCRequestBody){
        List<String> fieldsForBusinessUnit = new List<String> {'Name'};
        String sObjName = 'WOD_2__Business_Category_Configuration__c';
        ATI_Utils.checkForAccess(sObjName, 'READ', fieldsForBusinessUnit);
        List<WOD_2__Business_Category_Configuration__c> buConfigList =[Select Id,Name From WOD_2__Business_Category_Configuration__c Where Name IN:buSet];
        if(buConfigList != null && !buConfigList.isEmpty()){
            for(WOD_2__Business_Category_Configuration__c bu: buConfigList){
                buNameIdMap.put(bu.Name, bu.Id);
            }
        }

        String warrRegSObjName = 'WOD_2__Warranty_Registration__c';
        List<String> wRegFields = new List<String>{'Name', 'WOD_2__Inventory__c','WOD_2__Customer__c','WOD_2__Registration_Comments__c','WOD_2__Registration_Type__c','WOD_2__Usage_Type__c',
                     'WOD_2__Account__c','WOD_2__Registration_Date__c','WOD_2__Status__c','WOD_2__Inventory__r.WOD_2__Serial_Number__c','ATI_isExtended__c'};
        ATI_Utils.checkForAccess(warrRegSObjName, 'READ', wRegFields);
        System.debug('etcWRNumberSet -> ' + etcWRNumberSet);
        String wrQuery = 'Select Id, ' + String.join(wRegFields, ', ') + ' FROM WOD_2__Warranty_Registration__c WHERE Name IN :etcWRNumberSet';
        List<WOD_2__Warranty_Registration__c> warrantyRegLst = DataBase.query(wrQuery);
        System.debug('warrantyRegLst -> ' + warrantyRegLst);
        for(WOD_2__Warranty_Registration__c wReg:warrantyRegLst){
            mapOfWarrantyReg.put(wReg.Name,wReg);
        }
        // there can be only one WR in Draft, Pending Approval or Registered status at given time
        wrQuery = 'Select Id, ' + String.join(wRegFields, ', ') + ' FROM WOD_2__Warranty_Registration__c WHERE WOD_2__Inventory__r.WOD_2__Serial_Number__c IN :serialNumberSet and WOD_2__Status__c in (\'DRAFT\',\'PENDING APPROVAL\',\'REGISTERED\',\'In Progress\')';
        List<WOD_2__Warranty_Registration__c> existingWarrantyRegLst = DataBase.query(wrQuery);
        for(WOD_2__Warranty_Registration__c wReg : existingWarrantyRegLst){
            existingWarrantyRegMap.put(wReg.WOD_2__Inventory__r.WOD_2__Serial_Number__c,wReg);
        }
        
        
        List<String> accountFields = new List<String>{'Name', 'ATI_Financial_BP_Code__c','SAP_ID__c','BillingCity','BillingPostalCode','Country__c'};
        ATI_Utils.checkForAccess('Account', 'READ', accountFields);
        String accQuery = 'Select Id, ' + String.join(accountFields, ', ') + ' FROM Account WHERE SAP_ID__c IN :sapIdSet';
        List<Account> accLst = DataBase.query(accQuery);
        for(Account acc : accLst){
            accSapIdAccountMap.put(acc.SAP_ID__c,acc);
            countrySet.add(acc.Country__c);
        }

        String endCustomerQuery = 'Select Id, ' + String.join(accountFields, ', ') + ' FROM Account WHERE (Name IN: customerName AND BillingCity IN: customerCity AND BillingPostalCode IN: customerPostal)';
        List<Account> endCustomerList = DataBase.query(endCustomerQuery);
        for(Account acc : endCustomerList){
            String key = acc.Name + '-' + acc.BillingCity + '-' + acc.BillingPostalCode; 
            endCustomerAccountMap.put(key,acc);
        }
        
        List<String> policyDefFields = new List<String>{'Name','WOD_2__Months_Covered__c','WOD_2__Type__c','WOD_2__Status__c'};
        ATI_Utils.checkForAccess('WOD_2__Policy_Definition__c', 'READ', policyDefFields);
        String policyQuery = 'Select Id, ' + String.join(policyDefFields, ', ') + ' FROM WOD_2__Policy_Definition__c WHERE Name IN :etcPolicySet AND WOD_2__Type__c=\'Extended\' AND WOD_2__Status__c=\'Active\'';
        List<WOD_2__Policy_Definition__c> policyLst = DataBase.query(policyQuery);
        for(WOD_2__Policy_Definition__c policyDef : policyLst){
            etcPolicyMap.put(policyDef.Name,policyDef);
        }
        
		String wCodeObj = 'WOD_2__Warranty_Code__c';
		List<String> wCodefields = new List<String>{'Name','RecordType.Name'};
		vocCodeMap = getVocationCodeMap(wCodeObj,wCodefields);
		
		String invObj = 'WOD_2__Inventory__c';
		List<String> invfields = new List<String>{'Name','ATI_Active__c','WOD_2__Business_Unit__c','ATI_Program_Level__c',
            'WOD_2__Serial_Number__c','WOD_2__Type__c','WOD_2__Account__c','WOD_2__Item__c','ATI_Vocation_Code__c',
            'WOD_2__Install_Date__c','WOD_2__Item__r.WOD_2__Parent_Product__c','WOD_2__Item__r.WOD_2__Parent_Product__r.Name'};
		invMapDetails = getInvMap(invObj,invfields,serialNumberSet);

        List<String> extWrntyPricingFields = new List<String>{'ATI_Active_From__c','ATI_Active_Until__c','ATI_Base_Price__c',
                'ATI_Country__c','ATI_Handling_Fee__c','ATI_Policy_Definition__c','ATI_Vocation_Code__c','ATI_Vocation_Code__r.Name',
            	'ATI_Warranty_Product__c','ATI_Warranty_Product__r.Name','ATI_Policy_Definition__r.Name','ATI_Program_Level__c'};
        ATI_Utils.checkForAccess('ATI_Extended_Warranty_Pricing__c', 'READ', extWrntyPricingFields);
        String extWrntyPricingQuery = 'Select Id, ' + String.join(extWrntyPricingFields, ', ') +
            ' FROM ATI_Extended_Warranty_Pricing__c WHERE ' + 
            ' ATI_Policy_Definition__r.Name in :etcPolicySet AND ATI_Policy_Definition__r.WOD_2__Type__c = \'Extended\'' +
            ' AND (ATI_Warranty_Product__c IN :modelSet) '+ 
            ' AND (ATI_Vocation_Code__r.Name IN :vocationCodeSet) ' +
            ' AND (ATI_Country__c = null or ATI_Country__c IN :countrySet)';
        List<ATI_Extended_Warranty_Pricing__c> extPricingLst = DataBase.query(extWrntyPricingQuery);
        for(ATI_Extended_Warranty_Pricing__c extPrice : extPricingLst){
            String key = extPrice.ATI_Policy_Definition__r.Name;
            if(!extPriceMap.containsKey(key)){
                extPriceMap.put(key, new List<ATI_Extended_Warranty_Pricing__c>());
            }
            extPriceMap.get(key).add(extPrice);
        }
        
        
		String vehObj = 'ATI_Vehicle_Information__c';
		List<String> vehfields = new List<String>{'Name'/*,'ATI_Inventory__r.WOD_2__Serial_Number__c'*/};
		vehInfoMapDetails = getVehInfoMap(vehObj,vehfields);
        
        
    }
    
    private void verifyBatchETCRequest(ATI_REST_BatchETCSubmittalRequest batchETCRequestBody){
        Integer  i = 1;
        Set<String> identifierLst = new Set<String>();
        
        for(ATI_REST_BatchETCSubmittalRequest.ETCPurchaseInformation batchEtcReq : batchETCRequestBody.etcPurchase){
            List<String> errorList = new List<String>();
            try{
                Date inServiceDate;
                /*if(ATI_Utils.checkIsBlankData(batchEtcReq.identifier)){
                    errorList.add('Identifier is mandatory.');
                }else{
                    if(!identifierLst.add(batchEtcReq.identifier.trim())){
                        errorList.add('Duplicate Identifier :'+batchEtcReq.identifier.trim());
                    }
                }*/
                if(ATI_Utils.checkIsBlankData(batchEtcReq.businessCategoryConfiguration)){
                    errorList.add(Label.ATI_MandatoryBu);
                }else if(!buNameIdMap.containskey(batchEtcReq.businessCategoryConfiguration.trim())){
                    errorList.add(Label.ATI_ValidBuName);
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.businessPartnerCode)){
                    errorList.add('Business partner Code is mandatory.');
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.repairOutlet)){
                    errorList.add('Repair Outlet is mandatory.');
                }else if(!accSapIdAccountMap.containsKey(batchEtcReq.repairOutlet.trim())){
                    errorList.add('Repair Outlet is invalid.');
                }
                
                if(ATI_Utils.checkIsBlankData(batchEtcReq.submittalIndicator)){
                    errorList.add('Submittal Indicator cannot be blank.');
                }else if(batchEtcReq.submittalIndicator.equalsIgnoreCase('I') && ATI_Utils.checkIsNotBlankData(batchEtcReq.etcRegistrationNumber)){
                    errorList.add('Registration Number not expected for Submittal Indicator - I');
                }else if(batchEtcReq.submittalIndicator.equalsIgnoreCase('M') && ATI_Utils.checkIsBlankData(batchEtcReq.etcRegistrationNumber)){
                    errorList.add('Registration Number is Mandatory for Submittal Indicator - M');
                }else if(!(batchEtcReq.submittalIndicator.equalsIgnoreCase('M') || batchEtcReq.submittalIndicator.equalsIgnoreCase('I'))){
                    errorList.add('Submittal Indicator can be I or M only');
                } else if(batchEtcReq.submittalIndicator.equalsIgnoreCase('M') && !mapOfWarrantyReg.containsKey(batchEtcReq.etcRegistrationNumber)){
                    errorList.add('ETC Registration Number is invalid.');
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.submitterName)){
                    errorList.add('Submitter name cannot be blank.');
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.submitterPhone)){
                    errorList.add('Submitter Phone cannot be blank.');
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.purchaseOrderNumber)){
                    errorList.add('Purchase Order cannot be blank.');
                }
                
                if(ATI_Utils.checkIsBlankData(batchEtcReq.eTCCoverageCode)){
                    errorList.add('ETC Coverage Code is mandatory');
                }else if(!etcPolicyMap.containsKey(batchEtcReq.eTCCoverageCode.trim())){
                    errorList.add('ETC Coverage Code is Invalid');
                }else if(!extPriceMap.containsKey(batchEtcReq.eTCCoverageCode.trim())){
                    errorList.add('Pricing is not defined for ETC Coverage Code');
                }else if(ATI_Utils.checkIsBlankData(batchEtcReq.vehicleInfo.inServiceDate)){
                    errorList.add('In-Service Date is mandatory.');
                }else if(ATI_Utils.parseDate(batchEtcReq.vehicleInfo.inServiceDate) > Date.today()){
                    errorList.add('In-Service Date can not be in future.');
                }else if(ATI_Utils.checkIsNotBlankData(batchEtcReq.vehicleInfo.serialNumber) && invMapDetails.containsKey(batchEtcReq.vehicleInfo.serialNumber.trim())){
                    inServiceDate = ATI_Utils.parseDate(batchEtcReq.vehicleInfo.inServiceDate.trim());
                    WOD_2__Inventory__c inv = invMapDetails.get(batchEtcReq.vehicleInfo.serialNumber.trim());
                    String model = inv.WOD_2__Item__r.WOD_2__Parent_Product__r.Name;
                    String vocCode = ATI_Utils.checkIsNotBlankData(batchEtcReq.vehicleInfo.vocationCode) ? batchEtcReq.vehicleInfo.vocationCode.trim() : '';                    
                    String country = ATI_Utils.checkIsNotBlankData(batchEtcReq.repairOutlet) ? batchEtcReq.repairOutlet.trim() : '';
                    String programLvl = inv.ATI_Program_Level__c;
                    Boolean priceFound = false;
                    System.debug('model----->'+model +'vocationCode---->'+vocCode + 'country----->'+country+' programLvl------->'+programLvl); 
                    List<ATI_Extended_Warranty_Pricing__c> pricingList = extPriceMap.get(batchEtcReq.eTCCoverageCode.trim());
                    for(ATI_Extended_Warranty_Pricing__c extPrice : pricingList){
                        if(extPrice.ATI_Warranty_Product__r.Name.equalsIgnoreCase(model) &&
                           extPrice.ATI_Vocation_Code__r.Name.equalsIgnoreCase(vocCode) &&
                           (extPrice.ATI_Country__c == null || extPrice.ATI_Country__c.equalsIgnoreCase(country)) &&
                           (extPrice.ATI_Program_Level__c == null || extPrice.ATI_Program_Level__c.equalsIgnoreCase(programLvl)) && 
                           (extPrice.ATI_Active_From__c <= inServiceDate && extPrice.ATI_Active_Until__c >= inServiceDate)){
                               invExtPriceMap.put(batchEtcReq.vehicleInfo.serialNumber.trim(), extPrice);
                               priceFound = true;
                               break;
                           }
                    }
                    if(!priceFound){
                        errorList.add('Pricing not found for the model and vocation code');
                    }
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.vehicleInfo.preDelivery)){
                    errorList.add('Pre-Delivery is mandatory.');
                }else if(batchEtcReq.vehicleInfo.preDelivery.trim().equalsIgnoreCase('true')){
                    errorList.add('Pre-Delivery cannot be true.');
                }else if(!(batchEtcReq.vehicleInfo.preDelivery.trim().equalsIgnoreCase('false'))){
                    errorList.add('Pre-Delivery should be false.');
                }
                
                
                if(ATI_Utils.checkIsBlankData(batchEtcReq.vehicleInfo.serialNumber)){
                    errorList.add('Serial Number is mandatory.');
                }else if(!invMapDetails.containskey(batchEtcReq.vehicleInfo.serialNumber.trim())){
                    errorList.add('Please Enter valid Serial Number.');
                }else if(!invMapDetails.get(batchEtcReq.vehicleInfo.serialNumber.trim()).ATI_Active__c){
                    errorList.add('Inventory is not active.');
                }
                else if(ATI_Utils.checkIsBlankData(batchEtcReq.etcRegistrationNumber) && existingWarrantyRegMap.containsKey(batchEtcReq.vehicleInfo.serialNumber.trim())){ // existing registration on Inventory
                    WOD_2__Warranty_Registration__c wr = existingWarrantyRegMap.get(batchEtcReq.vehicleInfo.serialNumber.trim());
                    if(wr.WOD_2__Status__c == 'Registered' && wr.ATI_isExtended__c){                
                       errorList.add('ETC is already completed on this transmission');
                    }else if(wr.WOD_2__Status__c == 'Pending Approval' || wr.WOD_2__Status__c == 'In Progress'){
                        errorList.add('ETC is under Pending Approval Status');
                    }
                }
                
                
                if(ATI_Utils.checkIsBlankData(batchEtcReq.vehicleInfo.vocationCode)){
                    errorList.add('Vocation Code is mandatory.');
                }else if(!vocCodeMap.containskey(batchEtcReq.vehicleInfo.vocationCode.trim())){
                    errorList.add('Vocation Code is Invalid.');
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.vehicleInfo.vehicleIdentificationNumber)){
                    errorList.add('VIN is mandatory.');
                }
                //Punam-- Removed vehicleInfo.ATI_Inventory__c as part of Veh Transmission mapper object implementation Start
                /*else if(vehInfoMapDetails.containsKey(batchEtcReq.vehicleInfo.vehicleIdentificationNumber.trim())){
                    ATI_Vehicle_Information__c vehicleInfo = vehInfoMapDetails.get(batchEtcReq.vehicleInfo.vehicleIdentificationNumber.trim());
                    if(vehicleInfo.ATI_Inventory__c != null && !vehicleInfo.ATI_Inventory__r.WOD_2__Serial_Number__c.equalsIgnoreCase(batchEtcReq.vehicleInfo.serialNumber.trim())){
                        errorList.add('Vehicle Info is associated to another serial number.');
                    }
                }*/
                //Removed vehicleInfo.ATI_Inventory__c as part of Veh Transmission mapper object implementation End
                if(ATI_Utils.checkIsNotBlankData(batchEtcReq.etcRegistrationNumber) &&  mapOfWarrantyReg.containsKey(batchEtcReq.etcRegistrationNumber.trim())){
                    WOD_2__Warranty_Registration__c wr = mapOfWarrantyReg.get(batchEtcReq.etcRegistrationNumber.trim());
                    if(wr.WOD_2__Status__c != 'Draft'){                
                       errorList.add('Cant update Warranty Registration which is not in Draft status.');
                    }
                    if(!wr.WOD_2__Inventory__r.WOD_2__Serial_Number__c.equalsIgnoreCase(batchEtcReq.vehicleInfo.serialNumber.trim())){
                        errorList.add('ETC Registration Number belongs to different inventory.');
                    }
                }
                
                if(String.isBlank(batchEtcReq.vehicleInfo.vehicleMileage)){
                    errorList.add('Vehicle Mileage is mandatory.');
                }
                if(String.isBlank(batchEtcReq.vehicleInfo.vehicleMake)){
                    errorList.add('Vehicle Make is mandatory.');
                }
                if(String.isBlank(batchEtcReq.vehicleInfo.vehicleModel)){
                    errorList.add('Vehicle Model is mandatory.');
                }
                
                if(String.isBlank(batchEtcReq.customerInfo.customerName)){
                    errorList.add('Customer Name is mandatory.');
                }
                if(String.isBlank(batchEtcReq.customerInfo.street)){
                    errorList.add('Please enter Street.');
                }
                if(String.isBlank(batchEtcReq.customerInfo.city)){
                    errorList.add('Please enter city.');
                }
                if(String.isBlank(batchEtcReq.customerInfo.state)){
                    errorList.add('Please enter state.');
                }
                if(String.isBlank(batchEtcReq.customerInfo.postalCode)){
                    errorList.add('PostalCode is mandatory.');
                }
                if(String.isBlank(batchEtcReq.customerInfo.countryCode)){
                    errorList.add('CountryCode is mandatory.');
                }else if(!countryMap.containsKey(batchEtcReq.customerInfo.countryCode.toUpperCase()) && 
                        !countryMap.values().contains(batchEtcReq.customerInfo.countryCode.toUpperCase())){
                    errorList.add('CountryCode is invalid.');
                }
                if(ATI_Utils.checkIsBlankData(batchEtcReq.agreementDate)){
                    errorList.add('Agreement Date is mandatory.');
                }else if(ATI_Utils.parseDate(batchEtcReq.agreementDate) > Date.today()){
                    errorList.add('Agreement Date can not be in future.');
                }else{
                    Date dt= date.valueOf(batchEtcReq.agreementDate);
                    if(dt != NULL && inServiceDate != NULL && dt < inServiceDate){
                        errorList.add('Agreement Date must be greater than inservice date.');
                    }
                }
        }catch(Exception ex){
            errorList.add(ex.getMessage());
        }
            
            totalrecords = totalrecords++;
            system.debug('totalrecords**'+totalrecords);
            if(errorList.isEmpty()){
                batchETCReqLst.add(batchEtcReq);
                setOfSuccessRecords.add(batchEtcReq.vehicleInfo.serialNumber);
            }
            else{
                setOfFailedRecords.add(batchEtcReq.vehicleInfo.serialNumber);
                totalFailedRecords++;
                mapOfFailure.put(i,errorList);
            }
            i++;
        }
        
    }
    
	public Map<String,ATI_Vehicle_Information__c> getVehInfoMap(String vehObj,List<String> vehfields){

        ATI_Utils.checkForAccess(vehObj, 'READ', vehfields);
        String vinQuery = 'Select Id, ' + String.join(vehfields, ', ') + ' FROM ATI_Vehicle_Information__c WHERE Name IN :vinSet';
        List<ATI_Vehicle_Information__c> vehInfoLst = DataBase.query(vinQuery);
        for(ATI_Vehicle_Information__c vehInfo: vehInfoLst){
            vehInfoMapDetails.put(vehInfo.Name,vehInfo);
        }
		return vehInfoMapDetails;
	}
	
	public Map<String,WOD_2__Warranty_Code__c> getVocationCodeMap(String wCodeObj,List<String> wCodefields){

        ATI_Utils.checkForAccess(wCodeObj, 'READ', wCodefields);
        String vocCodeQuery = 'Select Id, ' + String.join(wCodefields, ', ') + ' FROM WOD_2__Warranty_Code__c WHERE Name IN :vocationCodeSet AND RecordType.DeveloperName = \'Vocation_Codes\'';
        List<WOD_2__Warranty_Code__c> vocCodeLst = DataBase.query(vocCodeQuery);
        for(WOD_2__Warranty_Code__c vocCode : vocCodeLst){
            vocCodeMap.put(vocCode.Name,vocCode);
        }
		return vocCodeMap;
	}
    
	public Map<String,WOD_2__Inventory__c> getInvMap(String invObj,List<String> invfields,Set<String> serialNumberSet){
        
        ATI_Utils.checkForAccess(invObj, 'READ', invfields);
        String invQuery = 'Select Id,' + String.join(invfields, ', ') + ' FROM WOD_2__Inventory__c WHERE WOD_2__Serial_Number__c IN :serialNumberSet';
        List<WOD_2__Inventory__c> invLst = DataBase.query(invQuery);
        for(WOD_2__Inventory__c inv : invLst){
            invMapDetails.put(inv.WOD_2__Serial_Number__c,inv);
            modelSet.add(inv.WOD_2__Item__r.WOD_2__Parent_Product__c);
        }
		return invMapDetails;
	}
    
}