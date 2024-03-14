/* Name: ATI_WR_WntyCoverageBeforeSaveOverirde
Description : ATI_WR_WntyCoverageBeforeSaveOverirde - Warranty Coverage Handler for ATI.
Author : Tavant (PR)
History :
VERSION      AUTHOR          DATE                DETAIL                                    UserStory/Req#
1.0 -       Tavant (PR)      31-DEC-2020          INITIAL DEVELOPMENT
*/
global class ATI_WR_WntyCoverageBeforeSaveOverirde implements WOD_2.WR_WarrantyCoverageBeforeSaveInterface {
    global WOD_2.WR_PolicyPickOutputWrapper saveWarrantyCoverages(WOD_2.WR_CoverageInputWrapper coverageInputWrapper){
        List<Id> wrIds = coverageInputWrapper.wrRecordIds;
        System.debug('Inside ATI_WR_WntyCoverageBeforeSaveOverirde -> ' + wrIds);
        List<Id> invIdList = new List<Id>();
        ATI_Utils.NoAccessObjectFieldWrapper access1 = ATI_Utils.fetchReadAccess('WOD_2__Warranty_Registration__c', new List<String>{'WOD_2__Inventory__c','ATI_Vocation_Code__c'});
		if(access1.noAccessFieldList.isEmpty() && access1.noAccessObjectList.isEmpty()){
        	List<WOD_2__Warranty_Registration__c> wrList= [Select Id, WOD_2__Inventory__c,ATI_Vocation_Code__c From WOD_2__Warranty_Registration__c Where Id IN: wrIds];
            for(WOD_2__Warranty_Registration__c wr: wrList){
                invIdList.add(wr.WOD_2__Inventory__c);
            }
        }
        System.debug('ATI_WR_WntyCoverageBeforeSaveOverirde Inv Ids -> ' + wrIds);
        //ATI_Utils.NoAccessObjectFieldWrapper access = ATI_Utils.fetchReadAccess('ATI_Vehicle_Information__c', new List<String>{'ATI_Inventory__c'});
        ATI_Utils.NoAccessObjectFieldWrapper access = ATI_Utils.fetchReadAccess('ATI_VIN_Transmission_Mapper__c', new List<String>{'ATI_Inventory__c'});
        if(access.noAccessFieldList.isEmpty() && access.noAccessObjectList.isEmpty()){
            //List<ATI_Vehicle_Information__c> viList = [select id, ATI_Inventory__c from ATI_Vehicle_Information__c where ATI_Inventory__c in :invIdList];
             
            //Added Punam -Veh Transmission Mapper implementation 
            List<ATI_VIN_Transmission_Mapper__c> viList = [Select id,ATI_Inventory__c From  ATI_VIN_Transmission_Mapper__c Where ATI_Inventory__c in :invIdList];
            System.debug('ATI_WR_WntyCoverageBeforeSaveOverirde viList -> ' + wrIds);
            if(viList.isEmpty()){
                throw new TWoDException('Vehicle information is mandatory!!!');
            }
           // change the before save override to product provided class, This is reuqired to change inventory status
            coverageInputWrapper.warrantyCoverageBeforeSaveOverrideClassName = 'WR_WarrantyCoverageBeforeSaveOverride';
            WOD_2.ResponseWrapper resp= WOD_2.WR_UnmanagedUtility.saveWarrantyCoverages(coverageInputWrapper);
            return null;
        }
        throw new TWoDException('(Vehicle Information) ' + Label.ATI_Log_Insufficient_access);
    }
}