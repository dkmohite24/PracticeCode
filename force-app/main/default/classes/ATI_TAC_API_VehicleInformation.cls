/**
 * @description       : This is an API handler class for Vehicle Information.
 * @author            : Abhishek Mohapatra
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Abhishek Mohapatra
**/
public with sharing class ATI_TAC_API_VehicleInformation {

    /**
    * @description Method used for creating Vehicle Information data from the NHTSA api and returns the vehicle information record without inserting it. [USER STORY 32610]
    * @author Abhishek Mohapatra | 07-06-2023 
    * @param vinNumber [This will be the VIN number that will be requirted for finding the vehicle information from the NHTSA API.]
    * @return ATI_Vehicle_Information__c [This will be the uninserted record of "ATI_Vehicle_Information__c" created as per the data received from the API. ]
    **/
    public static ATI_Vehicle_Information__c populateVehicleInformation(String vinNumber){
        Http htp = new Http();
        HttpRequest req = new HttpRequest();
        String Endpoint = 'callout:VIN_Endpoint/'+vinNumber+'?format=json';
        req.setEndpoint(Endpoint);
        req.setMethod('GET');
        HttpResponse res = htp.send(req);


        System.debug('Response: '+res);
        ATI_Vehicle_Information__c virec = new ATI_Vehicle_Information__c();
        virec = ATI_TAC_API_Services.vehicleInfoIntegrationAPIHandler(res, vinNumber, Endpoint);

        return virec;
    }
}