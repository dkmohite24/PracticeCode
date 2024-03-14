@isTest
global class MockCalloutClass implements HttpCalloutMock{
     public HTTPResponse respond(HTTPRequest req) 
     {
         //Create a fake request
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/plain');
        res.setBody('{"example":"test"}');
        res.setStatusCode(200);
        return res;
     }
}