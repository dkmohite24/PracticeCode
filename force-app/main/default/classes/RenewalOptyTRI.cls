Public class RenewalOptyTRI{
    public void RenewalOptyMeth(list<opportunity> Opty){
        
    system.debug('trigger.new list opportunity'+Opty);
    
    List<Opportunity> listOppor = new List<Opportunity>();
    
    system.debug('empty list opportunity'+listOppor);
    
    for (Opportunity o: Opty){
        system.debug('trigger.new list opportunity:::::::::'+O);
    
    
        if (o.StageName == 'Closed Won'){
            Opportunity oppNew = new Opportunity();
            oppNew = o.clone();
            
            system.debug('Clone list opportunity'+oppNew);
            
            oppNew.Name = oppNew.Name + '_Renewal';
            oppNew.StageName = 'Needs Analysis';
            
            system.debug('Clone Name list opportunity'+oppNew.Name);
            
            //oppNew.Renewal_Indicator__c = true;
            OppNew.CloseDate = oppNew.CloseDate.addyears(1);
            //OppNew.Insured_period_from__c = OppNew.Insured_period_from__c.addyears(1);
            
            //OppNew.Insured_period_to__c = OppNew.Insured_period_to__c.addyears(1);
            OppNew.Probability = 20 ;
            //OppNew.OwnerID = o.CreatedByID;
            //o.Renewal_Created__c = 'Yes';
            //Oppnew.Renewed_Opportunity__c = oppNew.Name;
            OppNew.Description = ' renewal Opty : ';
            listOppor.add(oppNew);
        }// end if
        
    }//end for
    If(listOppor.size() > 0){
        insert listOppor;
        system.debug('Fulle list opportunity::'+listOppor);
        
          
        
        system.debug('Fulle list opportunity::'+listOppor.Size());
        }//if end
    }//Meth end
         
           
}//Class end