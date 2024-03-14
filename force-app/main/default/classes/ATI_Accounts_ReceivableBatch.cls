/**
* (c) 2018 Tavant Technology.
* -------------------------------------------------------------------------------------------------
This class is used for Accounts Receivable outbound integration
* -------------------------------------------------------------------------------------------------
* @author         (Punam)
* @version        1.0
* @created        17-Mar-2021
* @modified
* -------------------------------------------------------------------------------------------------
* @changes
* -------------------------------------------------------------------------------------------------
*/
public class ATI_Accounts_ReceivableBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
	public Set<WOD_2__Transaction_Memo_History__c> transactMemoHstry= new Set<WOD_2__Transaction_Memo_History__c>();
    public List<WOD_2__Transaction_Memo_History__c> transactMemoUpdatedList= new List<WOD_2__Transaction_Memo_History__c>();
    public static List<WOD_2__Transaction_Memo_History__c> tmhUpdateList = new List<WOD_2__Transaction_Memo_History__c>();
    public Set<Id> claimIdsToUpdateSet = new Set<Id>();
	
    public Database.QueryLocator start(Database.BatchableContext bc) {
    	DateTime dt = DateTime.now().addDays(Integer.valueOf(ATI_Accounts_Receivable_Interface__c.getValues('Days').ATI_Values__c));
        String query = 'SELECT  WOD_2__Claim__r.WOD_2__Model_Number__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name,'+ 
						'WOD_2__Claim__r.WOD_2__Model_Number__r.Name,WOD_2__Claim__r.WOD_2__Model_Number__r.Extended_Base_Model__c,'+
						'WOD_2__Business_Category_Configuration__c,WOD_2__Claim__c,'+
						'WOD_2__Claim__r.Name,WOD_2__Claim__r.WOD_2__Account__r.ATI_Financial_BP_Code__c,'+
						'WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c,WOD_2__Claim__r.WOD_2__Account__r.ATI_Account_Group__c,'+
						'WOD_2__Transaction_Number__c,WOD_2__Transaction_Status__c,'+
						'ATI_Type__c,ATI_Warranty_Registration__c,'+
						'ATI_Warranty_Registration__r.ATI_Unique_WR_No__c,'+
						'ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Financial_BP_Code__c,'+
						'ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Account_Group__c ,'+
						'WOD_2__Claim__r.WOD_2__Warranty_Product__c,ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.Name,'+
						'ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.Extended_Base_Model__c,'+
						'ATI_Warranty_Registration__r.ATI_PO_Number__c,'+
						'WOD_2__Claim__r.WOD_2__Warranty_Product__r.Name,ATI_Warranty_Registration__r.WOD_2__Inventory__r.Name,'+
						'WOD_2__Claim__r.WOD_2__Inventory__r.Name,'+
						'ATI_Warranty_Registration__r.WOD_2__Inventory__r.ATI_Plant_Code__c,'+
						'WOD_2__Claim__r.WOD_2__Model_Number__r.Hierarchy__c,'+
						'WOD_2__Claim__r.WOD_2__Inventory__r.ATI_Plant_Code__c,'+
						'WOD_2__Transaction_Type__c,'+
						'WOD_2__Claim__r.WOD_2__Inventory__c,WOD_2__Amount__c,'+
						'ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c,ATI_Warranty_Registration__r.Name,'+
						'ATI_Warranty_Registration__r.WOD_2__Inventory__c,'+
						'WOD_2__Claim__r.WOD_2__Is_Pre_Authorization_Required__c,'+
						'WOD_2__Claim__r.WOD_2__Applicable_Policy__r.WOD_2__Type__c,'+
						'WOD_2__Claim__r.ATI_Claim_Subtype__c,'+
						'WOD_2__Claim__r.WOD_2__Claim_Type__c,'+
						'createdDate,ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name,'+
						'ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.Hierarchy__c,'+
						'ATI_Week__c,'+
						'(SELECT Id,Name,WOD_2__Financial_Line_Item__c,WOD_2__Quantity__c,WOD_2__Unit_Amount__c,'+
								'WOD_2__Transaction_Memo_History__c,WOD_2__Type__c FROM WOD_2__Transaction_Memo_History_Line_Items__r) '+
					' From WOD_2__Transaction_Memo_History__c '+
					' Where WOD_2__Transaction_Status__c=\'Pending\' AND '+
						' (WOD_2__Claim__c!= null OR ATI_Warranty_Registration__c!= null) AND '+
						' LastModifiedDate >=: dt and IsDeleted = false order by LastModifiedDate desc';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WOD_2__Transaction_Memo_History__c> tmhLst) {
        //ALSN-199 bought the variables outside try block to use in catch block
        String jsonBody;
        HttpResponse response = new HttpResponse();
        //ALSN-199 End
        try{
					system.debug('tmhLst**'+tmhLst);
					String endpointUrl =  ATI_GetEndpoint.getURL(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c);
					
            		Integer randomNumber = Integer.valueof((Math.random() * 100));
					ATI_HttpRequestParameter httpReqparm = new ATI_HttpRequestParameter();
					httpReqparm.endPoint = endpointUrl;
					httpReqparm.httpMethod =ATI_UtilConstants.i203Method;
					httpReqparm.httpHeaderReqId=ATI_UtilConstants.httpHeaderReqId;
					httpReqparm.httpHeaderReqValue=String.valueOf(randomNumber);
            		httpReqparm.httpHeaderClientId=ATI_UtilConstants.httpHeaderClientId;
					httpReqparm.httpHeaderClientIdValue=ATI_UtilConstants.httpHeaderClientIdValue;
					httpReqparm.httpHeaderClientSecret=ATI_UtilConstants.httpHeaderClientSecret;
            		httpReqparm.httpHeaderClientSecretValue=ATI_UtilConstants.httpHeaderClientSecretValue;
			
					jsonBody= createRequestBody(tmhLst);
            		System.debug('jsonBody -> ' + jsonBody);
					httpReqparm.httpBody = jsonBody;
					
					HttpRequest httpReq = ATI_RESTUtility.buildHttpRequest(httpReqparm);
					response = ATI_RESTUtility.executeService(httpReq);

                    if (response.getStatusCode() == Integer.valueOf(ATI_Accounts_Receivable_Interface__c.getValues('Status Code').ATI_Values__c)) {
						for(WOD_2__Transaction_Memo_History__c transObj: tmhLst){
							transactMemoHstry.add(transObj);
							system.debug('transactMemoHstry**'+transactMemoHstry);
						}
					}
            		createLog(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c,jsonBody,response.getStatus(),String.valueOf(response.getStatusCode()),null,null);
                }
                catch(Exception e){
                    System.debug(ATI_UtilConstants.i203Exception + e.getMessage());
                    //ALSN-199 create log if response results in an exception
                    String errorText = 'AR job - Error Message: ' + e.getMessage() + '\n LineNumber: ' + e.getLineNumber();
                    ATI_LogService.createLogForCatchException(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c,errorText,jsonBody);
                    //ALSN-199 end
                }
	}
	
	public Map<String, List<WOD_2__Financial_Line_Item__c>> getFLIData(Set<String> fliIdSet,Set<String> claimIdSet,
																	   Map<String, List<WOD_2__Financial_Line_Item__c>> claimIdFliMap)
	{
		String finObjectName = ATI_UtilConstants.finLineItemObject;
		List<String> finFields = new List<String>{'WOD_2__Approved_Quantity__c','Id','WOD_2__Claim__c','ATI_Landed_Part_Markup__c','ATI_Markup__c','WOD_2__Approved_Amount__c','ATI_Factory_Cost__c','WOD_2__System_PerUnit_Price__c','ATI_Factory_Price__c','WOD_2__Cost_Category_Type__c',
			'ATI_Previously_Computed_Factory_Cost__c','ATI_Previously_Computed_Factory_Price__c','ATI_Previously_Paid_Landed_Part_Markup__c','ATI_Previously_Paid_Markup__c','ATI_Previously_Paid_Amt__c',
			'WOD_2__Percentage_Amount__c','ATI_Previous_Percentage_Amount__c'};
		ATI_Utils.NoAccessObjectFieldWrapper finLineItemReadAccessCheck = ATI_Utils.fetchReadAccess(finObjectName,finFields);
		if(finLineItemReadAccessCheck.noAccessObjectList.size() == 0 && finLineItemReadAccessCheck.noAccessFieldList.size() == 0){
			List<WOD_2__Financial_Line_Item__c>  fliList= [Select Id,Name, WOD_2__Claim__c,WOD_2__Approved_Quantity__c,WOD_2__Cost_Category_Type__c,
																ATI_Landed_Part_Markup__c,ATI_Markup__c,WOD_2__Approved_Amount__c, WOD_2__Claim__r.ATI_Is_Claim_Appealed_Or_Reopened__c,
																ATI_Factory_Cost__c,WOD_2__System_PerUnit_Price__c,ATI_Factory_Price__c,WOD_2__Claim__r.WOD_2__BusinessCategory__c,
																WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.Hierarchy__c,WOD_2__Claim__r.ATI_Exchange_Rate__c,WOD_2__Claim__r.ATI_is_Claim_Rejected__c,
																WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name,ATI_Previously_Computed_Factory_Cost__c,
																ATI_Previously_Paid_Amt__c,ATI_Previously_Paid_Markup__c,ATI_Previously_Paid_Landed_Part_Markup__c,ATI_Previously_Computed_Factory_Price__c,
																ATI_Previously_Approved_Quantity__c,WOD_2__Percentage_Amount__c,ATI_Previous_Percentage_Amount__c
															From WOD_2__Financial_Line_Item__c Where WOD_2__Claim__c IN: claimIdSet
																AND Id IN :fliIdSet];
			if(!fliList.isEmpty()){
				for(WOD_2__Financial_Line_Item__c fli: fliList){
					if(claimIdFliMap.containsKey(fli.WOD_2__Claim__c)){
						claimIdFliMap.get(fli.WOD_2__Claim__c).add(fli);
					}else{
						List<WOD_2__Financial_Line_Item__c> fliListNew= new List<WOD_2__Financial_Line_Item__c>();
						fliListNew.add(fli);
						claimIdFliMap.put(fli.WOD_2__Claim__c,fliListNew);
					}
				}
			}
		}else{
			String errortext = ATI_UtilConstants.insufficientFinLineItemAccess+JSON.serialize(finLineItemReadAccessCheck);
			ATI_LogService.createLogForAccess(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c,errortext);
		}
		return claimIdFliMap;
	}

	public Map<String,String> getVehicleInfo(Set<String> invSet,Map<String,String> vehInfoInventoryMap){
		String objectName = ATI_UtilConstants.vehInfoObject;
		List<String> fields = new List<String>{'Name','Id','ATI_Inventory__c'};
		ATI_Utils.NoAccessObjectFieldWrapper vehInfoReadAccessCheck = ATI_Utils.fetchReadAccess(objectName,fields);
		if(vehInfoReadAccessCheck.noAccessObjectList.size() == 0 && vehInfoReadAccessCheck.noAccessFieldList.size() == 0){
			for(ATI_VIN_Transmission_Mapper__c veh: [Select Id,Name,ATI_Inventory__c,ATI_Vehicle_Information__r.Name 
															From ATI_VIN_Transmission_Mapper__c Where ATI_Inventory__c IN: invSet])
			{
				vehInfoInventoryMap.put(veh.ATI_Inventory__c,veh.ATI_Vehicle_Information__r.Name);
			}
		
		}else{
			String errortext = ATI_UtilConstants.insufficientVehInfoAccess+JSON.serialize(vehInfoReadAccessCheck);
			ATI_LogService.createLogForAccess(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c,errortext);
		}
		return vehInfoInventoryMap;
	}
	
	public String createRequestBody(List<WOD_2__Transaction_Memo_History__c> tmhLst){
		try{
			Set<String> invSet = new Set<String>();
			Map<String,String> vehInfoInventoryMap = new Map<String,String>();
			Map<String,ATI_Rest_Accounts_ReceivableRequest.ClaimInformation> transactHstryClaimInfoMap = new Map<String,ATI_Rest_Accounts_ReceivableRequest.ClaimInformation>();
			Map<String, List<WOD_2__Financial_Line_Item__c>> claimIdFliMap = new Map<String, List<WOD_2__Financial_Line_Item__c>>();				
			Set<String> claimIdSet = new set<String>();
            Set<String> fliIdSet = new set<String>();
			for(WOD_2__Transaction_Memo_History__c tmhObj: tmhLst){
				if(tmhObj.WOD_2__Claim__r.WOD_2__Inventory__c!= null){
					invSet.add(tmhObj.WOD_2__Claim__r.WOD_2__Inventory__c );
					claimIdSet.add(tmhObj.WOD_2__Claim__c);
                }
				if(tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__c != null){
					invSet.add(tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__c );
				}
                if(tmhObj.WOD_2__Claim__c != null){
                	claimIdsToUpdateSet.add(tmhObj.WOD_2__Claim__c);    
				}
				for(WOD_2__Transaction_Memo_History_Line_Item__c transLIObj : tmhObj.WOD_2__Transaction_Memo_History_Line_Items__r){
					if(transLIObj.WOD_2__Financial_Line_Item__c != NULL){
						fliIdSet.add(transLIObj.WOD_2__Financial_Line_Item__c); 
					}
				}
			}
			
			//get vehicle info
			vehInfoInventoryMap = getVehicleInfo(invSet, vehInfoInventoryMap);
			
			//get FLI data
			claimIdFliMap = getFLIData(fliIdSet,claimIdSet,claimIdFliMap);
			
			ATI_Rest_Accounts_ReceivableRequest.ClaimInformation claimInfo = new ATI_Rest_Accounts_ReceivableRequest.ClaimInformation();
			Integer count=1;
			//List<ATI_Rest_Accounts_ReceivableRequest.ClaimInformation> claimInfoLst = new List<ATI_Rest_Accounts_ReceivableRequest.ClaimInformation>();
			ATI_Rest_Accounts_ReceivableRequest request= new ATI_Rest_Accounts_ReceivableRequest();
            request.memo= new List<ATI_Rest_Accounts_ReceivableRequest.ClaimInformation>();
			//tmhUpdateList = new List<WOD_2__Transaction_Memo_History__c>();
			for(WOD_2__Transaction_Memo_History__c tmhObj: tmhLst){
				if(!transactHstryClaimInfoMap.containsKey(tmhObj.Id)){
					claimInfo = new ATI_Rest_Accounts_ReceivableRequest.ClaimInformation();
					if(tmhObj.ATI_Type__c =='Claim'){
						claimInfo.documentRef= tmhObj.WOD_2__Claim__r.Name!= null?tmhObj.WOD_2__Claim__r.Name:'';
						Map<String,String> policySubTypeMap = ATI_Utils.getPicklistOptions('WOD_2__Policy_Definition__c', 'WOD_2__Sub_Type__c');
                        claimInfo.claimType= policySubTypeMap.containsKey(tmhObj.WOD_2__Claim__r.ATI_Claim_Subtype__c) ? policySubTypeMap.get(tmhObj.WOD_2__Claim__r.ATI_Claim_Subtype__c) : tmhObj.WOD_2__Claim__r.ATI_Claim_Subtype__c;
						
						claimInfo.businessCategoryUnit=ATI_Accounts_Receivable_Interface__c.getValues('Business Unit').ATI_Values__c!= null?ATI_Accounts_Receivable_Interface__c.getValues('Business Unit').ATI_Values__c:'';
						if(tmhObj.WOD_2__Claim__c!= null){
							claimInfo.financialPartnerCode=tmhObj.WOD_2__Claim__r.WOD_2__Account__r.ATI_Financial_BP_Code__c!= null?tmhObj.WOD_2__Claim__r.WOD_2__Account__r.ATI_Financial_BP_Code__c:'';
							if(tmhObj.WOD_2__Claim__r.WOD_2__Account__r.ATI_Account_Group__c!= null)
							claimInfo.accountGroup= tmhObj.WOD_2__Claim__r.WOD_2__Account__r.ATI_Account_Group__c.left(2)!= null?tmhObj.WOD_2__Claim__r.WOD_2__Account__r.ATI_Account_Group__c.left(2):'';
							claimInfo.repairingOutlet= tmhObj.WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c!= null?tmhObj.WOD_2__Claim__r.WOD_2__Account__r.SAP_ID__c:'';
							claimInfo.model= tmhObj.WOD_2__Claim__r.WOD_2__Model_Number__r.Extended_Base_Model__c!= null?tmhObj.WOD_2__Claim__r.WOD_2__Model_Number__r.Extended_Base_Model__c:'';
							claimInfo.serialNumber= tmhObj.WOD_2__Claim__r.WOD_2__Inventory__r.Name!= null?tmhObj.WOD_2__Claim__r.WOD_2__Inventory__r.Name:'';
							if(tmhObj.WOD_2__Claim__r.WOD_2__Inventory__r.ATI_Plant_Code__c!= null)
                            //claimInfo.plantCode= tmhObj.WOD_2__Claim__r.WOD_2__Inventory__r.ATI_Plant_Code__c!= null?tmhObj.WOD_2__Claim__r.WOD_2__Inventory__r.ATI_Plant_Code__c:'';
							claimInfo.plantCode = '1391';
                            claimInfo.transactionId= tmhObj.WOD_2__Claim__r.Name!= null?tmhObj.WOD_2__Claim__r.Name:'';
							claimInfo.vin= vehInfoInventoryMap.get(tmhObj.WOD_2__Claim__r.WOD_2__Inventory__c)!= null?vehInfoInventoryMap.get(tmhObj.WOD_2__Claim__r.WOD_2__Inventory__c):'';
						}
						//claimInfo.transactionDate= String.valueOf(tmhObj.createdDate); Date is not needed as confirmed by Noor
						claimInfo.transactionType= 'Claim';
						claimInfo.memoType= tmhObj.WOD_2__Transaction_Type__c!= null?tmhObj.WOD_2__Transaction_Type__c:'';
						
						if(String.valueOf(datetime.now().year())!= null && String.valueOf(datetime.now().formatGmt('w'))!= null){
							//ALSN-13 : 
                            String weekValue = String.valueOf(datetime.now().formatGmt('w')).length() == 1 ? String.valueOf('0' + datetime.now().formatGmt('w')) : String.valueOf(datetime.now().formatGmt('w'));
							claimInfo.week= String.valueOf(datetime.now().year())+ weekValue;
							tmhObj.ATI_Week__c= claimInfo.week;
							tmhUpdateList.add(tmhObj);
						}
						
						if(claimIdFliMap.containsKey(tmhObj.WOD_2__Claim__c)){
							Integer fliCount=1;
							Decimal totalAmountInUSD = 0.0;
							claimInfo.transactionLineItems= new List<ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems>();
							for(WOD_2__Financial_Line_Item__c fli: claimIdFliMap.get(tmhObj.WOD_2__Claim__c)){
                                //ALSN-3
                                if(fli.WOD_2__Approved_Amount__c == null || (fli.WOD_2__Approved_Amount__c == 0 && !fli.WOD_2__Claim__r.ATI_Is_Claim_Appealed_Or_Reopened__c) || (fli.WOD_2__Approved_Amount__c == fli.ATI_Previously_Paid_Amt__c  && fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c == false)){
                                    continue;
                                }
                                Decimal quantity;
                                Integer allowedDecimalPlaces = Integer.valueOf(ATI_Utils.getConfiguration(fli.WOD_2__Claim__r.WOD_2__BusinessCategory__c, 'CA_AllowedDecimalPlaces').WOD_2__Value__c);
                                Decimal exchangeRate = (fli.WOD_2__Claim__r.ATI_Exchange_Rate__c == null) ? 1 : fli.WOD_2__Claim__r.ATI_Exchange_Rate__c;
                                Boolean isPrecentageChange = (fli.ATI_Previous_Percentage_Amount__c != null && fli.WOD_2__Percentage_Amount__c != fli.ATI_Previous_Percentage_Amount__c);
                                //ALSN-3 Condition added for Re-opened then Rejected Claims
                                if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                    quantity = -1 * fli.ATI_Previously_Approved_Quantity__c;
                                }else{
                                    quantity = fli.WOD_2__Approved_Quantity__c - ((fli.ATI_Previously_Approved_Quantity__c != null) ? fli.ATI_Previously_Approved_Quantity__c : 0.0);
                                }
								if(fli.WOD_2__Cost_Category_Type__c.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category OEM').ATI_Values__c)){
									if(fli.WOD_2__Approved_Amount__c != null){
                                        Decimal lineAmt = fli.WOD_2__Approved_Amount__c;
                                        if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                            lineAmt = fli.ATI_Previously_Paid_Amt__c;
                                            lineAmt -= (fli.ATI_Previously_Paid_Landed_Part_Markup__c != null) ? fli.ATI_Previously_Paid_Landed_Part_Markup__c : 0.0;
                                            lineAmt -= (fli.ATI_Previously_Paid_Markup__c != null) ? fli.ATI_Previously_Paid_Markup__c : 0.0;
                                        }
                                        else if(fli.WOD_2__Claim__r.ATI_Is_Claim_Appealed_Or_Reopened__c && fli.ATI_Previously_Paid_Amt__c != NULL && fli.ATI_Previously_Paid_Amt__c != 0.0){
                                            lineAmt -= (fli.ATI_Previously_Paid_Amt__c != null) ? fli.ATI_Previously_Paid_Amt__c : 0.0;
                                            lineAmt -= (fli.ATI_Previously_Paid_Landed_Part_Markup__c != null) ? (fli.ATI_Landed_Part_Markup__c - fli.ATI_Previously_Paid_Landed_Part_Markup__c) : 0.0;
                                            lineAmt -= (fli.ATI_Previously_Paid_Markup__c != null) ? (fli.ATI_Markup__c - fli.ATI_Previously_Paid_Markup__c) : 0.0;
                                        } 
                                        else {
                                            lineAmt -= (fli.ATI_Markup__c != null) ? fli.ATI_Markup__c : 0.0;
                                            lineAmt -= (fli.ATI_Landed_Part_Markup__c != null) ? fli.ATI_Landed_Part_Markup__c : 0.0;
                                        }
                                        //alsn-3
                                        Decimal lineAmtInUSD = getValue((lineAmt * exchangeRate),2);
										ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems transactLineItems = new ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems();
										transactLineItems.lineNumber= String.valueOf(fliCount)!= null?String.valueOf(fliCount):'';
										transactLineItems.name= fli.Name!= null?fli.Name:'';
										transactLineItems.type= ATI_Accounts_Receivable_Interface__c.getValues('TLI Type Expense').ATI_Values__c!= null?ATI_Accounts_Receivable_Interface__c.getValues('TLI Type Expense').ATI_Values__c:'';
										transactLineItems.productCode= fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name!= null?fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name:'';
										//hierarchy
                                        String str = fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.Hierarchy__c;
                                        str = str != NULL ? str : '';
                                        transactLineItems.hierarchy= str;
										transactLineItems.dollarType= 'H';
										transactLineItems.quantity= (isPrecentageChange ? (lineAmt < 0 ? '-1' : String.valueOf(fli.WOD_2__Approved_Quantity__c.setScale(2)) ) : String.valueOf(quantity.setScale(2)));
										transactLineItems.unitPrice= fli.WOD_2__System_PerUnit_Price__c != null ?String.valueOf(getValue((fli.WOD_2__System_PerUnit_Price__c * exchangeRate), allowedDecimalPlaces)):'';
                                        //ALSN-3 Condition added for Re-opened then Rejected Claims
                                        if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                            transactLineItems.lineAmount = '-'+String.valueOf(lineAmtInUSD);
                                        }else{                                            
                                            transactLineItems.lineAmount = String.valueOf(lineAmtInUSD);
                                        }
										claimInfo.transactionLineItems.add(transactLineItems);
                                        totalAmountInUSD += lineAmtInUSD;
										fliCount++;
									}
									
                                    Decimal markUpAmount = 0.0;
                                    if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                        if(fli.ATI_Previously_Paid_Markup__c != null){
                                            markUpAmount += fli.ATI_Previously_Paid_Markup__c;
                                        }
                                        if(fli.ATI_Previously_Paid_Landed_Part_Markup__c != null){
                                            markUpAmount += fli.ATI_Previously_Paid_Landed_Part_Markup__c;
                                        }
                                    }else{
                                        if(fli.ATI_Landed_Part_Markup__c != null){
                                            markUpAmount += fli.ATI_Landed_Part_Markup__c;
                                        }
                                        if(fli.ATI_Markup__c != null){
                                            markUpAmount += fli.ATI_Markup__c;
                                        }
                                        if(fli.WOD_2__Claim__r.ATI_Is_Claim_Appealed_Or_Reopened__c){
                                            markUpAmount -= (fli.ATI_Previously_Paid_Landed_Part_Markup__c != null) ? fli.ATI_Previously_Paid_Landed_Part_Markup__c : 0.0;
                                            markUpAmount -= (fli.ATI_Previously_Paid_Markup__c != null) ? fli.ATI_Previously_Paid_Markup__c : 0.0;
                                        }
                                    }
                                    
									if(markUpAmount != 0){
                                        //alsn-3
                                        markUpAmount = getValue((markUpAmount * exchangeRate),2);
										ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems transactLineItems = new ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems();
										transactLineItems.lineNumber= String.valueOf(fliCount)!= null?String.valueOf(fliCount):'';
										transactLineItems.name= fli.Name!= null?fli.Name:'';
										transactLineItems.type= ATI_Accounts_Receivable_Interface__c.getValues('TLI Type Markup').ATI_Values__c!= null?ATI_Accounts_Receivable_Interface__c.getValues('TLI Type Markup').ATI_Values__c:'';
										transactLineItems.productCode= fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name!= null?fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name:''; 
										transactLineItems.dollarType= 'L';
                                        transactLineItems.quantity= (isPrecentageChange ? (markUpAmount < 0 ? '-1' : String.valueOf(fli.WOD_2__Approved_Quantity__c.setScale(2)) ) : String.valueOf(quantity.setScale(2)));
										transactLineItems.unitPrice= String.valueOf(markUpAmount);
                                        //ALSN-3 Condition added for Re-opened then Rejected Claims
                                        if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                            transactLineItems.lineAmount = '-'+String.valueOf(markUpAmount);
                                        }else{                                            
                                            transactLineItems.lineAmount = String.valueOf(markUpAmount);
                                        }
                                        claimInfo.transactionLineItems.add(transactLineItems);
										fliCount++;
                                        totalAmountInUSD += markupAmount;
									}
									
                                    //ALSN-3 Factory cost not included fix -- Change 2
									if(fli.ATI_Factory_Cost__c != null){
										ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems transactLineItems = new ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems();
										transactLineItems.lineNumber= String.valueOf(fliCount);
										transactLineItems.name= fli.Name!= null?fli.Name:'';
										transactLineItems.type= ATI_Accounts_Receivable_Interface__c.getValues('TLI Type Factory').ATI_Values__c!= null?ATI_Accounts_Receivable_Interface__c.getValues('TLI Type Factory').ATI_Values__c:'';
										transactLineItems.productCode= fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name!= null?fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name:'';  
										//hierarchy
										String str = fli.WOD_2__Installed_Claim_Part__r.WOD_2__Warranty_Product__r.Hierarchy__c;
                                        str = str != NULL ? str : '';
										transactLineItems.hierarchy= str;
										transactLineItems.dollarType= 'J';
										transactLineItems.unitPrice= String.valueOf(fli.ATI_Factory_Price__c)!= null?String.valueOf(fli.ATI_Factory_Price__c.setScale(2)):'';
                                        //ALSN-3 Condition added for Re-opened then Rejected Claims -- Change 2
                                        Decimal lineAmount=0.00;
                                        if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                            lineAmount = fli.ATI_Previously_Computed_Factory_Cost__c;
                                        //ALSN-67 added a null check, changed the line amount calculation based on multiplication of quantity and unit price
                                        }else if(fli.WOD_2__Claim__r.ATI_Is_Claim_Appealed_Or_Reopened__c && fli.ATI_Previously_Computed_Factory_Cost__c != null){
                                            //lineAmount -= (fli.ATI_Previously_Computed_Factory_Cost__c != null) ? fli.ATI_Previously_Computed_Factory_Cost__c : 0.0;
                                            lineAmount = (fli.ATI_Factory_Price__c * quantity.setScale(2));
                                        }else{
                                            lineAmount = fli.ATI_Factory_Price__c * quantity.setScale(2) ;
                                        }
                                        //ALSN-3 Condition added for Re-opened then Rejected Claims
                                        if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                            transactLineItems.lineAmount = '-'+ String.valueOf(lineAmount.setScale(2));
                                        }else{                                            
                                            transactLineItems.lineAmount= String.valueOf(lineAmount.setScale(2));
                                        }

                                        transactLineItems.quantity= (isPrecentageChange ? (lineAmount < 0 ? '-1' : String.valueOf(fli.WOD_2__Approved_Quantity__c.setScale(2)) ) : String.valueOf(quantity.setScale(2)));
										claimInfo.transactionLineItems.add(transactLineItems);
										fliCount++;
									}
								}else{
									ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems transactLineItems = new ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems();
                                    transactLineItems.lineNumber= String.valueOf(fliCount)!= null?String.valueOf(fliCount):'';
                                    transactLineItems.name= fli.Name!= null?fli.Name:'';
                                    transactLineItems.type= fli.WOD_2__Cost_Category_Type__c!= null?fli.WOD_2__Cost_Category_Type__c:'';
                                    transactLineItems.productCode= tmhObj.WOD_2__Claim__r.WOD_2__Model_Number__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name!= null?tmhObj.WOD_2__Claim__r.WOD_2__Model_Number__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name:'';
                                    transactLineItems.dollarType= getDollarType(fli.WOD_2__Cost_Category_Type__c)!= null?getDollarType(fli.WOD_2__Cost_Category_Type__c):'';
                                    transactLineItems.unitPrice= String.valueOf(fli.WOD_2__System_PerUnit_Price__c)!= null?String.valueOf(getValue((fli.WOD_2__System_PerUnit_Price__c * exchangeRate),allowedDecimalPlaces)):'';
                                    Decimal lineAmount = fli.WOD_2__Approved_Amount__c;
                                    if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                        lineAmount = fli.ATI_Previously_Paid_Amt__c;
                                    }
                                    else if(fli.WOD_2__Claim__r.ATI_Is_Claim_Appealed_Or_Reopened__c){
                                        lineAmount -= (fli.ATI_Previously_Paid_Amt__c != null) ? fli.ATI_Previously_Paid_Amt__c : 0.0;
                                    }
                                    //alsn-3
                                    Decimal lineAmtInUSD = getValue((lineAmount * exchangeRate),2);
                                    totalAmountInUSD += lineAmtInUSD;
                                    //ALSN-3 Condition added for Re-opened then Rejected Claims
                                    if(fli.WOD_2__Claim__r.ATI_is_Claim_Rejected__c){
                                        transactLineItems.lineAmount = '-'+ String.valueOf(lineAmtInUSD);
                                    }else{
                                        transactLineItems.lineAmount= String.valueOf(lineAmtInUSD);
                                    }
                                    transactLineItems.quantity= (isPrecentageChange ? (lineAmount < 0 ? '-1' : String.valueOf(fli.WOD_2__Approved_Quantity__c.setScale(2)) ) : String.valueOf(quantity.setScale(2)));
                                    
                                    claimInfo.transactionLineItems.add(transactLineItems);
                                    fliCount++;
								}
							}
                            claimInfo.totalAmount = String.valueOf(Math.abs(totalAmountInUSD));
                            tmhObj.ATI_Amount_USD__c = Math.abs(totalAmountInUSD);
                            if(claimInfo.memoType == 'Debit'){
                                claimInfo.totalAmount = '-' + claimInfo.totalAmount;
                            } 
						}
						
					}else if(tmhObj.ATI_Type__c.equalsIgnoreCase('EWP')){
						for(WOD_2__Transaction_Memo_History_Line_Item__c transLI: tmhObj.WOD_2__Transaction_Memo_History_Line_Items__r){
							claimInfo.documentRef= tmhObj.ATI_Warranty_Registration__r.Name;
							claimInfo.claimType=ATI_Accounts_Receivable_Interface__c.getValues('Claim Type 17').ATI_Values__c!= null?ATI_Accounts_Receivable_Interface__c.getValues('Claim Type 17').ATI_Values__c:'';
							claimInfo.businessCategoryUnit=ATI_Accounts_Receivable_Interface__c.getValues('Business Unit').ATI_Values__c!= null?ATI_Accounts_Receivable_Interface__c.getValues('Business Unit').ATI_Values__c:'';
							claimInfo.financialPartnerCode=tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Financial_BP_Code__c!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Financial_BP_Code__c:'';
							claimInfo.poNumber= tmhObj.ATI_Warranty_Registration__r.ATI_PO_Number__c!= null?tmhObj.ATI_Warranty_Registration__r.ATI_PO_Number__c:'';
							
							if(tmhObj.ATI_Warranty_Registration__c!= null){
								if(tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Account_Group__c!= null)
								claimInfo.accountGroup= tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Account_Group__c.left(2)!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.ATI_Account_Group__c.left(2):'';
								claimInfo.repairingOutlet= tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Account__r.SAP_ID__c:'';
								claimInfo.model= tmhObj.ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.Extended_Base_Model__c!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.Extended_Base_Model__c:'';
								claimInfo.serialNumber= tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__r.Name!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__r.Name:'';
								//claimInfo.plantCode= tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__r.ATI_Plant_Code__c!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__r.ATI_Plant_Code__c:'';
								claimInfo.plantCode = '1391';
								claimInfo.transactionId= tmhObj.ATI_Warranty_Registration__r.Name!= null?tmhObj.ATI_Warranty_Registration__r.Name:'';
								claimInfo.vin= vehInfoInventoryMap.get(tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__c)!=null?vehInfoInventoryMap.get(tmhObj.ATI_Warranty_Registration__r.WOD_2__Inventory__c):'';
							}
							//claimInfo.transactionDate= String.valueOf(tmhObj.createdDate); Date is not needed as confirmed by Noor
							claimInfo.transactionType= 'ETC';
							claimInfo.memoType= tmhObj.WOD_2__Transaction_Type__c!= null?tmhObj.WOD_2__Transaction_Type__c:'';
							
							if(String.valueOf(datetime.now().year())!= null && String.valueOf(datetime.now().formatGmt('w'))!= null){
                               //ALSN13 
                                String weekValue = String.valueOf(datetime.now().formatGmt('w')).length() == 1 ? String.valueOf('0' + datetime.now().formatGmt('w')) : String.valueOf(datetime.now().formatGmt('w'));
								claimInfo.week= String.valueOf(datetime.now().year())+weekValue;
								tmhObj.ATI_Week__c= claimInfo.week;
								tmhUpdateList.add(tmhObj);
							}
							Decimal etcAmount = tmhObj.WOD_2__Amount__c == null ? 0.0 : tmhObj.WOD_2__Amount__c.setScale(2); 
							claimInfo.totalAmount = ((claimInfo.memoType == 'Credit') ? '-' : '') + String.valueOf(etcAmount); 
							claimInfo.transactionLineItems= new List<ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems>();
							
							ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems transactLineItems = new ATI_Rest_Accounts_ReceivableRequest.TransactionLineItems();
							transactLineItems.lineNumber= '1';
							transactLineItems.name= transLI.Name!=null?transLI.Name:'';
							transactLineItems.type= 'EWP';
							transactLineItems.productCode= tmhObj.ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name!= null?tmhObj.ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.WOD_2__Parent_Product__r.WOD_2__Parent_Product__r.Name:'';
							//hierarchy
							String str = tmhObj.ATI_Warranty_Registration__r.WOD_2__Warranty_Product__r.Hierarchy__c;
							str = str != NULL ? str : '';
							transactLineItems.hierarchy= str;
							
							transactLineItems.dollarType= 'K';
							transactLineItems.quantity= String.valueOf(transLI.WOD_2__Quantity__c)!= null?String.valueOf(transLI.WOD_2__Quantity__c.setScale(2)):'';
							transactLineItems.lineAmount =  ((claimInfo.memoType == 'Credit') ? '-' : '') + String.valueOf(etcAmount);
							transactLineItems.unitPrice = transLI.WOD_2__Unit_Amount__c != null ? String.valueOf(transLI.WOD_2__Unit_Amount__c.setScale(2)) : '';
							claimInfo.transactionLineItems.add(transactLineItems);
						}
					}
					request.memo.add(claimInfo);
				}
			}
			system.debug('request.memo**'+request.memo);
			String jsonBody = JSON.serialize(request);
			return jsonBody;
		}catch(Exception ex){
			String errorText = 'Error Message: ' + ex.getMessage() + '\n LineNumber: ' + ex.getLineNumber();
            createLog(ATI_Accounts_Receivable_Interface__c.getValues('Log Name').ATI_Values__c,null,null,'Failed',ex.getMessage()+ex.getStackTraceString(),null);
            return null;
		}
	}
	
	public static String getDollarType(String costcategory){
		String dollarType;
		if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Labor').ATI_Values__c)){
			dollarType= 'K';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Freight').ATI_Values__c)){
			dollarType= 'M';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Duty').ATI_Values__c)){
			dollarType= 'L'
                ;
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Misc').ATI_Values__c)){
			dollarType= 'L';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Overtime').ATI_Values__c)){
			dollarType= 'K';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Sublet').ATI_Values__c)){
			dollarType= 'K';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Towing').ATI_Values__c)){
			dollarType= 'K';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Unit').ATI_Values__c)){
			dollarType= 'L';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Tax').ATI_Values__c)){
			dollarType= 'L';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category OEM').ATI_Values__c)){
			dollarType= 'L';
		}else if(costcategory.equalsIgnoreCase(ATI_Accounts_Receivable_Interface__c.getValues('Cost Category Parts').ATI_Values__c)){
			dollarType= 'L';
		}else if(costcategory.equalsIgnoreCase('Travel By Distance')){
			dollarType= 'K';
		}
		return dollarType;
	}
	
	private static void createLog(String processName, String request, String response, String status,String identifier, String primaryKey){
        WOD_2__Configuration_Setting__mdt logRecordValue = ATI_Utils.getConfigurationSettingMetaData('ATI_Accounts_Receivable_LogRecord_Check');
        if(logRecordValue != null && logRecordValue.WOD_2__Configuration_Value__c != null && logRecordValue.WOD_2__Configuration_Value__c.equalsIgnoreCase('True')){
            ATI_LogServiceWrapper objLogSerWrp = new ATI_LogServiceWrapper();
            objLogSerWrp.statusText = status;
            objLogSerWrp.inputRequestJSON = request;
            objLogSerWrp.outputResponseJSON = response;
            objLogSerWrp.processName = processName;
            objLogSerWrp.identifier = identifier;
            objLogSerWrp.primaryKey  = primaryKey;
            system.debug('objLogSerWrp**'+objLogSerWrp);
            ATI_LogService.logRecord(objLogSerWrp);
        }
    }
    
    
     public void finish(Database.BatchableContext bc) {
		 if(!transactMemoHstry.isEmpty()){
			for (WOD_2__Transaction_Memo_History__c trans: transactMemoHstry){
				trans.WOD_2__Transaction_Status__c	=ATI_UtilConstants.tliStatus;
				transactMemoUpdatedList.add(trans);
			}
			if(transactMemoUpdatedList.size()>0){
				String objectName = ATI_UtilConstants.transactMemoHstry;
				List<String> fields = new List<String>{'WOD_2__Transaction_Status__c'};
				ATI_Utils.NoAccessObjectFieldWrapper transMemoUpdateAccessCheck = ATI_Utils.fetchUpdateAccess(objectName,fields);
                
				if(transMemoUpdateAccessCheck.noAccessObjectList.size() == 0 && transMemoUpdateAccessCheck.noAccessFieldList.size() == 0){
					update transactMemoUpdatedList;
				}
			}
			if(!tmhUpdateList.isEmpty()){
				update tmhUpdateList;
			}
             System.debug('claimIdsToUpdateSet -> ' + claimIdsToUpdateSet);
             if(!claimIdsToUpdateSet.isEmpty()){
                 List<WOD_2__Claim__c> claimsToUpdate = new List<WOD_2__Claim__c>();
                 for(Id claimId : claimIdsToUpdateSet){
                     claimsToUpdate.add(new WOD_2__Claim__c(Id=claimId,WOD_2__Claim_Status__c='Pending Payment Confirmation'));
                 }
                 update claimsToUpdate;
             }
		 }
     }

    private static Decimal getValue(Decimal origValue, Integer allowedDecimalPlaces){
        Decimal returnValue = origValue;
        returnValue = returnValue.setScale(allowedDecimalPlaces,RoundingMode.HALF_UP);
        return returnValue;
    }
    
    //ASLN-151 Method to add the txt document
    public static void uploadChunks(String strJsonArray,String strBatchlogId) {
        //system.debug('strJsonArray='+strJsonArray);
        system.debug('strBatchlogId='+strBatchlogId);
        try{
            // Uploaded claims data saved to file(Content Version) & attached to Batch Log 
            WOD_2.ResponseWrapper objContentVersionAccessCheck =  ATI_Utils.checkCreateAccess('ContentVersion',new List<String>{'PathOnClient','ContentLocation','Title','VersionData'});
            Map<String,Object> accessCheckCVMap = (Map<String,Object>)Json.deserializeUntyped(objContentVersionAccessCheck.data);
            if(objContentVersionAccessCheck.status && ((List<Object>)accessCheckCVMap.get('noAccessObjectList')).isEmpty() && ((List<Object>)accessCheckCVMap.get('noAccessFieldList')).isEmpty()
               && String.isNotBlank(strJsonArray) && String.isNotBlank(strBatchLogId)){
                   // String yourFiles = 'Lets assume this is your binary string of the files';
                   ContentVersion conVer = new ContentVersion();
                   conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
                   conVer.PathOnClient = 'AccountReceivableRequest_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt'; // The files name, extension is very important here which will help the file in preview.
                   conVer.Title = 'AccountReceivableRequest_' + System.now().format('yyyy_MM_dd_hh_mm_ss'); // Display name of the files
                   //conver.Description = 'Uploaded Claims in JSON format';
                   conVer.VersionData = Blob.valueOf(strJsonArray); //EncodingUtil.base64Decode(strJsonArray); // converting your binary string to Blog
                   insert conVer;
                   system.debug('conVer='+conVer);
                   
                   if(conVer.Id != null){
                       // First get the content document Id from ContentVersion
                       Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                       
                       //Create ContentDocumentLink
                       ContentDocumentLink cDoc = new ContentDocumentLink();
                       cDoc.ContentDocumentId = conDoc;
                       cDoc.LinkedEntityId = strBatchlogId; // BatchLog Id
                       cDoc.ShareType = 'V'; //Only View permission 
                       cDoc.Visibility = 'AllUsers'; // AllUsers/InternalUsers/SharedUsers
                       insert cDoc;
                   }
               }
        }
        catch(Exception exp){
            system.debug('Failed');
        }
        //return responseWrapperObj;
    }
    
}