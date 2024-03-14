/*   This class extends ClaimAction_FinancialLogicOverride which allows subscribers to override Claim Action screen financial logic. */
global class ATI_ClaimAction_FinancialLogicOverride extends WOD_2.ClaimAction_FinancialLogicOverride {        
    /*@description : This method is used to override the calculation logic for FLI Total Approved amount when the BCCS - 'CA_AdditionalEditableFieldsBeforeTotal' is used.
					 This method is invoked from both trigger and non-trigger contexts.                      
					 i.   FinancialLineItemTriggerHandler.beforeInsert()                       
 					ii.  FinancialLineItemTriggerHandler.beforeUpdate()                       
					iii. PaymentModifierEngine.updateFinancialLineItem()        
	  @param: List<WOD_2__Financial_Line_Item__c> fliList, Map<Id,Map<String,String>> bccsValueMap, String origin        
	  @returnType: ResponseWrapper    */	
    global override List<WOD_2__Financial_Line_Item__c> evalTotalAppAmtForAddtnlFieldsBeforeTotal(List<WOD_2__Financial_Line_Item__c> fliList, Map<Id,Map<String,String>> bccsValueMap, String origin) {
        for(WOD_2__Financial_Line_Item__c fli : fliList){            
            if(bccsValueMap.containsKey(fli.WOD_2__Claim__c) && bccsValueMap.get(fli.WOD_2__Claim__c).containsKey('CA_AdditionalEditableFieldsBeforeTotal') 
               && bccsValueMap.get(fli.WOD_2__Claim__c).get('CA_AdditionalEditableFieldsBeforeTotal') != null 
               && bccsValueMap.get(fli.WOD_2__Claim__c).get('CA_AdditionalEditableFieldsBeforeTotal') != '')
            {              
                for(String fieldObj : bccsValueMap.get(fli.WOD_2__Claim__c).get('CA_AdditionalEditableFieldsBeforeTotal').split(',')){
                    if(fli.get(fieldObj.split(':')[1]) != null){
                        if(Trigger.isExecuting && Trigger.isUpdate && Trigger.oldMap.get(fli.Id).get(fieldObj.split(':')[1]) != null 
                           && origin == 'fliTrigger')
                        {
                            if(Decimal.valueOf(String.valueOf(fli.get(fieldObj.split(':')[1]))) != Decimal.valueOf(String.valueOf(Trigger.oldMap.get(fli.Id).get(fieldObj.split(':')[1])))){
                                //Subscribers need to override logic to calculate Total Approved Amt below    
                                System.debug('=====>'+fli.get(fieldObj.split(':')[1]) );          
                                System.debug('=====>'+Decimal.valueOf(String.valueOf(fli.get(fieldObj.split(':')[1]))));          
                                System.debug('=====>'+Trigger.oldMap.get(fli.Id).get(fieldObj.split(':')[1]) );          
                                if(fli.get('WOD_2__Cost_Category_Type__c') == 'OEM Parts' && fieldObj.split(':')[1] == 'ATI_Markup__c'){
                                    //ALSN-171 If Approved amount is null, skip the logic
                                    if(fli.WOD_2__Approved_Amount__c != Null){
                                        fli.WOD_2__Approved_Amount__c += Decimal.valueOf(String.valueOf(fli.get(fieldObj.split(':')[1]))) - Decimal.valueOf(String.valueOf(Trigger.oldMap.get(fli.Id).get(fieldObj.split(':')[1])));
                                        fli.WOD_2__Total_Approved_Amt__c = fli.WOD_2__Approved_Amount__c;   
                                    }
                                }
                                else if(fli.get('WOD_2__Cost_Category_Type__c') != 'OEM Parts' && fieldObj.split(':')[1] == 'ATI_Markup__c'){
                                    throw new TWoDException(Label.ATI_Markup_Error_on_Labor_And_Other_Cost);
                                }else{
                                    fli.WOD_2__Total_Approved_Amt__c += Decimal.valueOf(String.valueOf(fli.get(fieldObj.split(':')[1]))) - Decimal.valueOf(String.valueOf(Trigger.oldMap.get(fli.Id).get(fieldObj.split(':')[1])));
                                }
                            }
                        }
                    }
                }
            }
        }
        return fliList;
    }
}