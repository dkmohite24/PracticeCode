global with sharing class ATI_SetCurrencyValues {
	
    public static CurrencyType UpdateCurrencyType(HttpResponse res) {

    CurrencyType currrec = new CurrencyType();

    try {
      Map<String, Object> resultParsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
      Object result = resultParsed.get('Results');
      List<Currencywrapper> currWrapp = (List<Currencywrapper>) JSON.deserialize(JSON.serialize(result),List<Currencywrapper>.class);
      Currencywrapper record = currWrapp[0];
     	currrec.ConversionRate = record.ConversionRate;
        currrec.Id = record.Id;
    }
        catch (Exception e) {

      ATI_ErrorLogService.errorLogWrapper err = new ATI_ErrorLogService.errorLogWrapper();

      err.outputType = true;

      err.className = 'ATI_SetCurrencyValues';

      err.methodName = 'UpdateCurrencyType';

     // err.output = requestBody;

      err.errorMessage = e.getMessage();

      ATI_ErrorLogService.logError(err);

    }
 
    return currrec;

  }
 global class Currencywrapper {

    public Integer ConversionRate { get; set; }

    public String Id { get; set; }

  }


}