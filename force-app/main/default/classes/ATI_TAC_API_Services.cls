/**

* @description       : This class is used for defining service methods required for different operations.

* @author            : Abhishek Mohapatra

* @group             :

* @last modified on  : 09-22-2023

* @last modified by  : Abhishek Mohapatra

**/

global with sharing class ATI_TAC_API_Services {

  public ATI_TAC_API_Services() {

  }

  /**

   * @description This method is a helper method for the "getCases" method of "ATI_TAC_API_CaseList" class. [USER STORY 32606]

   * @author Abhishek Mohapatra | 07-06-2023

   * @param processName [provided by parent class which will show the required operation]

   * @param requestBody [provided by parent which will have all thhe data.]

   * @return RestResponse [It will contain the data related to the cases on the basis of dealer Number.]

   **/

  public static RestResponse getDealerCasesAPIHandler(

    String processName,

    String requestBody

  ) {

    RestResponse res = RestContext.response;

    try {

      if (processName == 'getdealercases') {

        CaseRequestClass reqBody = (CaseRequestClass) System.JSON.deserialize(

          requestBody,

          CaseRequestClass.class

        );
 
        String dealerCode = reqBody.dealerCode;

        List<Case> cases = ATI_TAC_API_DataServices.getCaseListOnDealerCode(

          dealerCode

        );
 
        List<NewCaseDetails> resplist = new List<NewCaseDetails>();
 
        for (Case cs : cases) {

          NewCaseDetails response = new NewCaseDetails();

          response.caseNumber = cs.ATI_TAC_Case_Number__c;

          response.caseStatus = cs.Status;

          response.caseSubStatus = cs.ATI_TAC_Sub_Status__c;

          response.createdDate = cs.CreatedDate.date().format();

           String ownerId = cs.OwnerId;
          if ((OwnerId.startsWith('00G'))){
            response.caseOwner = cs.ATI_TAC_Latest_Group_Owner_Name__c;
          }else {
            response.caseOwner = cs.ATI_TAC_User_Primary_Queue__c;
          }

          response.notes =

            '<b> ' +

            'Description given: ' +

            '\n </b>' +

            cs.Description;
 
          if (cs.Status == 'Closed' || cs.Status == 'Resolved') {

            String temp =

              '\n </br>  <b>' +

              'Resolution Description: ' +

              '\n  </b>' +

              cs.ATI_TAC_Resolution_Description__c;

            response.notes += temp;

          }
 
          if (!String.isBlank(cs.ATI_TAC_Inventory_Serial_Number__c)) {

            WOD_2__Inventory__c tempInv = [

              SELECT Id, Name

              FROM WOD_2__Inventory__c

              WHERE Id = :cs.ATI_TAC_Inventory_Serial_Number__c

            ];

            response.serialNumber = tempInv.Name;

          } else if (!String.isBlank(cs.ATI_TAC_Serial_Number__c)) {

            response.serialNumber = cs.ATI_TAC_Serial_Number__c;

          }
 
          resplist.add(response);

        }
 
        res.responseBody = Blob.valueOf(System.JSON.serialize(resplist));

        res.statusCode = 200;

      }

    } catch (Exception e) {

      System.debug(e.getMessage());

      res.statusCode = 500;

      res.responseBody = Blob.valueOf(String.valueOf(e));
 
      ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();

      err.inputType = true;

      err.className = 'ATI_TAC_API_Services';

      err.methodName = 'getDealerCasesAPIHandler';

      err.input = requestBody;

      err.errorMessage = e.getMessage();

      ATI_ErrorLogService.logError(err);

    }
 
    return res;

  }
 
  /**

   * @description This method is a helper method for "populateVehicleInformation" in "ATI_TAC_API_VehicleInformation" class. [USER STORY 32610]

   * @author Abhishek Mohapatra | 07-06-2023

   * @param res

   * @param vinNumber

   * @param requestBody

   * @return ATI_Vehicle_Information__c [This is the Vehicle_information record data created on the basis of the HTTPResponse and vinNumber provided by parent method. not inserted into Salesforce]

   **/

  public static ATI_Vehicle_Information__c vehicleInfoIntegrationAPIHandler(

    HttpResponse res,

    String vinNumber,

    String requestBody

  ) {

    ATI_Vehicle_Information__c virec = new ATI_Vehicle_Information__c();

    try {

      Map<String, Object> resultParsed = (Map<String, Object>) JSON.deserializeUntyped(

        res.getBody()

      );

      Object result = resultParsed.get('Results');
 
      List<VehicleInfoWrapper> viwrap = (List<VehicleInfoWrapper>) JSON.deserialize(

        JSON.serialize(result),

        List<VehicleInfoWrapper>.class

      );
 
      VehicleInfoWrapper record = viwrap[0];
 
      System.debug('record : ' + record.ErrorCode);

      System.debug('Res: ' + res.getStatusCode());
 
      if (res.getStatusCode() == 200 && record.ErrorCode == '0') {

        virec.ATI_TAC_Axle_Configuration__c = record.AxleConfiguration;

        virec.ATI_TAC_Axles__c = record.Axles;

        virec.ATI_TAC_Body_Cab_Type__c = record.BodyCabType;

        virec.ATI_TAC_Body_Class__c = record.BodyClass;

        virec.ATI_TAC_Bus_Floor_Config_Type__c = record.BusFloorConfigType;

        virec.ATI_TAC_Bus_Length__c = record.BusLength;

        virec.ATI_TAC_Bus_Type__c = record.BusType;
        /*33993- Vehicle Information Update Existing Records changes start*/ 
        virec.ATI_Engine_Make__c = record.EngineManufacturer;          
        virec.ATI_Vehicle_Make__c = record.Make;
        virec.ATI_TAC_Error_Text__c = record.ErrorText;  
		/*33993- Vehicle Information Update Existing Records changes end*/          
        virec.ATI_TAC_Curb_Weight_LB__c = record.CurbWeightLB;

        virec.ATI_TAC_Drive_Type__c = record.DriveType;

        virec.ATI_TAC_Engine_Configuration__c = record.EngineConfiguration;

        virec.ATI_TAC_Engine_Cycles__c = record.EngineCycles;

        virec.ATI_TAC_Engine_Cylinders__c = record.EngineCylinders.isNumeric()

          ? Integer.valueOf(record.EngineCylinders)

          : 0;

        virec.ATI_TAC_Engine_HP__c = record.EngineHP;

        virec.ATI_TAC_Engine_HP_to__c = record.EngineHP_to;

        virec.ATI_TAC_Engine_KW__c = record.EngineKW;

        virec.ATI_TAC_Engine_Manufacturer__c = record.EngineManufacturer;

        virec.ATI_Engine_Model__c = record.EngineModel;

        virec.ATI_TAC_Fuel_Type_Primary__c = record.FuelTypePrimary;

        virec.ATI_TAC_GVWR__c = record.GVWR;

        virec.ATI_TAC_Manufacturer__c = record.Manufacturer;

        virec.ATI_TAC_Model_Year__c = record.ModelYear;

        virec.ATI_TAC_Note__c = record.Note;

        virec.ATI_TAC_Other_Bus_Info__c = record.OtherBusInfo;

        virec.ATI_TAC_Plant_City__c = record.PlantCity;

        virec.ATI_TAC_Plant_Company_Name__c = record.PlantCompanyName;

        virec.ATI_TAC_Plant_Country__c = record.PlantCountry;

        virec.ATI_TAC_Plant_State__c = record.PlantState;

        virec.ATI_TAC_Suggested_VIN__c = record.SuggestedVIN;

        virec.ATI_TAC_Vehicle_Descriptor__c = record.VehicleDescriptor;

        virec.ATI_TAC_Vehicle_Type__c = record.VehicleType;

        virec.ATI_Vehicle_Model__c = record.Model;

        virec.Name = vinNumber;

        virec.ATI_TAC_Source_Of_Data__c = 'NHTSA';

      } else if (res.getStatusCode() == 200) {

        ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();

        err.outputType = true;

        err.className = 'ATI_TAC_API_Services';

        err.methodName = 'vehicleInfoIntegrationAPIHandler';

        err.output = requestBody;

        err.errorMessage = res.getBody();

        ATI_ErrorLogService.logError(err);

      } else {

        ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();

        err.outputType = true;

        err.className = 'ATI_TAC_API_Services';

        err.methodName = 'vehicleInfoIntegrationAPIHandler';

        err.output = requestBody;

        err.errorMessage =

          'Error Code(s):' +

          record.ErrorCode +

          '\n\n' +

          'Error:' +

          record.ErrorText;

        ATI_ErrorLogService.logError(err);

      }

    } catch (Exception e) {

      ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();

      err.outputType = true;

      err.className = 'ATI_TAC_API_Services';

      err.methodName = 'vehicleInfoIntegrationAPIHandler';

      err.output = requestBody;

      err.errorMessage = e.getMessage();

      ATI_ErrorLogService.logError(err);

    }
 
    return virec;

  }
 
  /**

   * @description This method is get the record id of the case and Account and return the Account number as a location id and Token from Elearn System

   * @author Sudheer Kodali | 07-25-2023

   * @param recodid

   * @return RestResponse

   **/

  @AuraEnabled

  public static String getElearntoekn(string recordId) {

    string strElearnTokenURL;

    ElearnToken reqBody;

    try {

      String strAccNumber;

      strAccNumber = ATI_TAC_API_DataServices.getAcountNumber(recordId);

      //Get the Elearn URL and Accesskey values from Custom Metadata

      list<ATI_TAC_Metadata__mdt> metadata = new List<ATI_TAC_Metadata__mdt>();

      String strElearnURL;

      String strElearnAccessKey;

      metadata = [

        SELECT Elearn_Accesskey__c, Elearn_URL__c

        FROM ATI_TAC_Metadata__mdt

        WHERE MasterLabel = 'Default'

        LIMIT 1

      ];

      strElearnURL = metadata[0].Elearn_URL__c;

      strElearnAccessKey = metadata[0].Elearn_Accesskey__c;
 
      String endpoint =

        strElearnURL +

        strAccNumber +

        '&accessKey=' +

        strElearnAccessKey;

      HTTP h = new HTTP();

      HTTPRequest req = new HTTPRequest();

      req.setEndPoint(endpoint);

      req.setMethod('GET');

      HTTPResponse res = h.send(req);
 
      reqBody = (ElearnToken) System.JSON.deserialize(

        res.getBody(),

        ElearnToken.class

      );

      strElearnTokenURL = String.valueOf(reqBody.URL);

    } catch (Exception e) {

      System.debug(e.getMessage());

      ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();

      err.inputType = true;

      err.className = 'ATI_TAC_API_Services';

      err.methodName = 'getElearntoekn';

      err.input = String.valueOf(reqBody);

      err.errorMessage = e.getMessage();

      ATI_ErrorLogService.logError(err);

    }

    return strElearnTokenURL;

  }
 
  // Wrapper class used to deliver the data for cases in "getDealerCasesAPIHandler".

  global class NewCaseDetails {

    public String caseNumber { get; set; }

    public String serialNumber { get; set; }

    public String caseStatus { get; set; }

    public String caseSubStatus { get; set; }

    public String createdDate { get; set; }

    public String caseOwner { get; set; }

    public String notes { get; set; }

  }
 
  //Wrapper Class used for deserialization of the request received in "getDealerCasesAPIHandler".

  global class CaseRequestClass {

    public String caseNum { get; set; }

    public String dealerCode { get; set; }

  }

  global class AccountRequestClass {

    public String dealerCodephonenumber { get; set; }

  }

  global class CaseIdRequestClass {

    public String ctiCaseNumber { get; set; }

  }

  global class AccountIds {

    public String Id { get; set; }

  }

  global class CaseIds {

    public String caseId { get; set; }

  }

  global class ElearnToken {

    public String Token { get; set; }

    public String Expires { get; set; }

    public String DurationSeconds { get; set; }

    public String URL { get; set; }

  }

  //Wrapper Class used for deserialization of the request received in "vehicleInfoIntegrationAPIHandler".

  global class VehicleInfowrapper {

    public String AxleConfiguration { get; set; }

    public String Axles { get; set; }

    public String BodyCabType { get; set; }

    public String BodyClass { get; set; }

    public String BusFloorConfigType { get; set; }

    public String BusLength { get; set; }

    public String BusType { get; set; }

    public String CurbWeightLB { get; set; }

    public String DriveType { get; set; }

    public String EngineConfiguration { get; set; }

    public String EngineCycles { get; set; }

    public String EngineCylinders { get; set; }

    public String EngineHP { get; set; }

    public String EngineHP_to { get; set; }

    public String EngineKW { get; set; }

    public String EngineManufacturer { get; set; }

    public String EngineModel { get; set; }

    public String FuelTypePrimary { get; set; }

    public String GVWR { get; set; }
    /*33993- Vehicle Information Update Existing Records changes end*/  
    public string Make { get; set; }  
	/*33993- Vehicle Information Update Existing Records changes end*/
    public String Model { get; set; }

    public String Manufacturer { get; set; }

    public String ModelYear { get; set; }

    public String Note { get; set; }

    public String OtherBusInfo { get; set; }

    public String PlantCity { get; set; }

    public String PlantCompanyName { get; set; }

    public String PlantCountry { get; set; }

    public String PlantState { get; set; }

    public String SuggestedVIN { get; set; }

    public String VehicleDescriptor { get; set; }

    public String VehicleType { get; set; }
 
    //Below Variables will store the errors that might be coming from the API.

    public String ErrorCode { get; set; }

    public String ErrorText { get; set; }

    public String AdditionalErrorText { get; set; }

  }

}