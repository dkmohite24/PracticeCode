public class fetchPicklistOptsController {
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        system.debug('objType --->' + objType);
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        system.debug('objDescribe --->' + objDescribe);
        // Get a map of fields for the SObject 
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        system.debug('fieldMap --->' + fieldMap);
        // Get the list of picklist values for this field.
        system.debug('fld --->' + fld);
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        system.debug('values --->' + values);
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        system.debug('allOpts ---->' + allOpts);
        return allOpts;
        
        
    }
}