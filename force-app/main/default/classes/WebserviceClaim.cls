@RestResource(urlMapping='/getClaims/*')
   global with sharing class WebserviceClaim {
     @Httpget
      global static ResultClaimQueryWrapper fetchClaim(){
            List<ClaimQueryWrapper> Claims = new List<ClaimQueryWrapper>();
          ResultClaimQueryWrapper result = new ResultClaimQueryWrapper();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
       // String CustomerCode = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String CustomerCode = RestContext.request.params.get('CustomerCode');
        string BeginDateRange = RestContext.request.params.get('BeginDateRange');
          String EndDateRange = RestContext.request.params.get('EndDateRange');
          Date d1= date.parse(BeginDateRange);
           Date d2= date.parse(EndDateRange);
        String s='';
        
        list<WOD_2__Claim__c> claimlist =[Select  ATI_Claim_Number__c,
                                          WOD_2__Inventory__r.WOD_2__Serial_Number__c,
                                          WOD_2__Work_Order__c,
                                          WOD_2__Submit_Date__c,
                                          ATI_Total_Requested_Amount__c,
                                          WOD_2__Claim_Status__c,
                                          ATI_Total_Approved_Amount__c,
                                          (select Name from  WOD_2__Transaction_Memo_Historys__r),
                                          WOD_2__Account__r.SAP_ID__c,
                                          WOD_2__Account__r.Name
                                          
                                          from WOD_2__Claim__c where WOD_2__Account__r.SAP_ID__c=:CustomerCode AND WOD_2__Submit_Date__c>=: d1 AND WOD_2__Submit_Date__c<=: d2 ]; 
         
          if(claimlist.size()!=0){
              for(WOD_2__Claim__c clm:claimlist){
                  ClaimQueryWrapper c = new ClaimQueryWrapper();
                  	c.BusinessPartnerCode= clm.WOD_2__Account__r.SAP_ID__c!=NULL?clm.WOD_2__Account__r.SAP_ID__c:'';
                  	c.ClaimNumber=clm.ATI_Claim_Number__c!=NULL?clm.ATI_Claim_Number__c:'';
                    c.SerialNumber=clm.WOD_2__Inventory__r.WOD_2__Serial_Number__c!=NULL?clm.WOD_2__Inventory__r.WOD_2__Serial_Number__c:'';
        			c.RepairOrder=clm.WOD_2__Work_Order__c!=NULL?clm.WOD_2__Work_Order__c:'';
         			c.SubmissionDate=clm.WOD_2__Submit_Date__c!=NULL?clm.WOD_2__Submit_Date__c:NULL;
        			c.CustomerName=clm.WOD_2__Account__r.Name!=NULL?clm.WOD_2__Account__r.Name:'';
                    String a='';
                    String i='';
                    String b='';
                    String str1='';
                    String str2='';
                    String p='';
                    String q='';
        			a=clm.ATI_Total_Requested_Amount__c!=NULL?(clm.ATI_Total_Requested_Amount__c.setScale(2)).toPlainString():'0.00';
                  //system.debug('A'+a);
                    i=a.replaceAll(',', '');
                 // system.debug('I'+i);
                  if(i.length()>6 && i.length()<=9){
                      system.debug('LOOP 1');
                      str1=i.right(6);
                      str2=i.remove(str1);
                      b=str2 + ','+str1;
                      //system.debug('B'+b);
                       c.AmountRequested=b;
                      }
                   if(i.length()>9 && i.length()<=12){
                      system.debug('LOOP 2');
                      
                      str1=i.right(9);
                      p=i.right(6);
                      str2=i.remove(str1);
                      q=str1.remove(p);
                      b=str2 + ','+q+ ','+p;
                      //system.debug('B'+b);
                       c.AmountRequested=b;
                      
                  }
                  if(i.length()<=6){
                      system.debug('LOOP 3');

                      c.AmountRequested=a;
                  }
                   if(clm.WOD_2__Claim_Status__c=='Submitted'){
        			c.Status='Pending Approval';
                      }
                  else{
                      c.Status=clm.WOD_2__Claim_Status__c!=NULL?clm.WOD_2__Claim_Status__c:'';
                  }
        			
                    String x='';
                    String y='';
                    String str3='';
                    String str4='';
                    String m ='';
                    String n='';
        			x=clm.ATI_Total_Approved_Amount__c!=NULL?(clm.ATI_Total_Approved_Amount__c.setScale(2)).toPlainString():'0.00';
                    if(x.length()>6 && x.length()<=9){
                      str3=x.right(6);
                      str4=x.remove(str3);
                      y=str4 + ','+str3;
                      c.AmountPaid=y;
                      }
                    if(x.length()>9 && x.length()<=12){
                      
                      str3=x.right(9);
                      m=x.right(6);
                      str4=x.remove(str3);
                      n=str3.remove(m);
                      y=str4 + ','+n+ ','+m;
                       c.AmountPaid=y;
                      
                  }
                  if(x.length()<=6){
                      c.AmountPaid=x;
                  }
                    
        			//c.CreditReference =clm.WOD_2__Transaction_Memo_Historys__r.size()>0?clm.WOD_2__Transaction_Memo_Historys__r.get(0).Name:'';
                  	for(WOD_2__Transaction_Memo_History__c mh : clm.WOD_2__Transaction_Memo_Historys__r){
                        if(clm.WOD_2__Transaction_Memo_Historys__r.size()==1){
                            s+=mh.Name ;
                        	}
                        if(clm.WOD_2__Transaction_Memo_Historys__r.size()>1){
                        
                      		s+=mh.Name + ',';
                        }
               		 }
                  
                    c.CreditReference = s;
                  	s='';
                  claims.add(c);
                  
              }
          }
          result.claims=claims;

          
          return result ;
      }
       @TestVisible
       global class ClaimQueryWrapper{
        public string BusinessPartnerCode{get;set;}
        public string ClaimNumber{get;set;}
        public string SerialNumber{get;set;}
        public string RepairOrder{get;set;}
        public date SubmissionDate{get;set;}
        public string CustomerName{get;set;}
        public string AmountRequested{get;set;}
        public string Status{get;set;}
        public string AmountPaid {get;set;}
        public string CreditReference {get;set;}
        

    }
       @TestVisible
        global class ResultClaimQueryWrapper{
        public List<ClaimQueryWrapper> Claims {get;set;}
        

    }
   }