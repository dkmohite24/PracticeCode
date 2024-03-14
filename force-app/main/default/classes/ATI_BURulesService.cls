/**
 -------------------------------------------------------------------------------------------------
* @author         Tavant
* @created        5th Feb 2021
* @modified
* @description :   Service class to run BU rules
* --------------------------------------------------------------------------------------------------
*/
public class ATI_BURulesService {
    /*
		Method Name	:	runBURules
		Params		: 	1) buId -> Business Configuration setting Id
						2) ruleObjectAPIName -> Object API name on which rules should be triggered (ex. 'WOD_2__Claim__c')
						3) ruleObjectIdList -> list of records Ids , on which rules should be triggered
						4) moduleName	-> module name (ex. for claim , we have 'Claim' , you can get from BCCS object)
						5) subModuleName -> sub module name(ex Basic information under claim , we have 'Claim UI - Basic Info', you can get from BCCS object)
	*/
    public static List<WOD_2__Business_Rule__c> runBURules(Id buId,String ruleObjectAPIName,List<Id> ruleObjectIdList,String moduleName,String subModuleName){
        WOD_2.BR_BusinessRuleEngineWrapper wrapper = new WOD_2.BR_BusinessRuleEngineWrapper();
        wrapper.buId = buId;
        wrapper.configType = 'Rule';
        wrapper.configNameList = NULL;
        wrapper.flowName = '';
        wrapper.ruleObjectAPIName = ruleObjectAPIName; 
        wrapper.ruleObjectIdList = ruleObjectIdList;
        wrapper.moduleName = moduleName; //'Claim'
        wrapper.subModuleName = subModuleName; //'Claim UI - Basic Info'
        
        WOD_2.BR_BusinessRuleEngineOutputWrapper response = WOD_2.BR_BusinessRuleEngineUtility.runBusinessRuleEngine(wrapper);
        System.debug('------'+response);
        List<WOD_2__Business_Rule__c> buRulesLst = new List<WOD_2__Business_Rule__c>();
        if(!response.brRuleObjectList.isEmpty()){
            buRulesLst = response.brRuleObjectList;
        }
        return buRulesLst;
    }
}