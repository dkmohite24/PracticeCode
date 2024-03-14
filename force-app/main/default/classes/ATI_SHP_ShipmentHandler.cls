/*
	Class Name	:	ATI_SHP_ShipmentHandler
	Description	:	Override class for SHP_ShipmentHandler
	Author		: 	TAVNT (RSG)
*/
global class ATI_SHP_ShipmentHandler extends WOD_2.SHP_ShipmentHandler{
    /*
		Method Name	:	postRequestForUPS
		Description	:	Overriden method to make callout to UPS and returning UPS response to product
	*/
    global override HttpResponse postRequestForUPS(String requestJSON,Integer timeOut,Boolean isShippingRequest){
        System.debug('-------->'+requestJSON);
        System.debug('-------->'+timeOut);
        System.debug('-------->'+isShippingRequest);
        String endPointURL = '';
        endPointURL = 'callout:UPS_EndPoint';
        //endPointURL = 'https://wwwcie.ups.com/rest';
        if(isShippingRequest) {
            endPointURL = endPointURL+'/Ship';
        }else {
            endPointURL = endPointURL+'/Track';
        }
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPointURL);
        request.setTimeOut(timeOut);
        request.setBody(requestJSON);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        HttpResponse response = new HttpResponse();
        response = new Http().send(request);
        System.debug('+++++++++++response+++++++++++'+response.getBody());
        return response;
    }
}