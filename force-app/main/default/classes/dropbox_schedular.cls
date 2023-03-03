/*
 * Name :- dhananjay mohite
 * Details :- SchedularDropbox Every hour for access token from refresh token
 * 
 * 
 * 
 * 
*/



global class dropbox_schedular implements Schedulable 
{
    global void execute(SchedulableContext SC){
        
        list<IntBox__c> BoxList = [SELECT id,Access_Token__c, Refresh_Token__c,ClientID__c,ClientSecret__c FROM IntBox__c 
                                   where name='DropBox' limit 1];
        system.debug('BoxList'+BoxList);
        system.debug('Access_Token__c'+BoxList[0].Access_Token__c);
        system.debug('Refresh_Token__c'+BoxList[0].Refresh_Token__c);
        system.debug('Refresh_Token__c'+BoxList[0].ClientID__c);
        system.debug('Refresh_Token__c'+BoxList[0].ClientSecret__c);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint('https://api.dropbox.com/oauth2/token');  
        string bodyRequest = '';
        bodyRequest+= '&client_id=' + BoxList[0].ClientID__c;
        bodyRequest+= '&client_secret=' + BoxList[0].ClientSecret__c;
        bodyRequest+= '&refresh_token=' + BoxList[0].Refresh_Token__c;
        bodyRequest+= '&grant_type=refresh_token';
        system.debug('bodyRequest : '+bodyRequest);	
        req.setBody(bodyRequest);    
        req.setHeader('Content-length', string.ValueOf(bodyRequest.length()));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        system.debug('req : '+req);
        HttpResponse res = h.send(req);  
        system.debug('Response e : '+res.getBody());
        Map<String,Object> jsonResp = (Map<String,Object>)JSON.deserializeUntyped( res.getBody() );        
        system.debug('jsonResp' + jsonResp);   
        IntBox__c box = new IntBox__c();
        if( jsonResp != null && jsonResp.containsKey( 'access_token' ) )
        {             
            box.Access_Token__c = (String)jsonResp.get( 'access_token' );
            box.id =BoxList[0].id;
            update box;
        }
        
    }
}