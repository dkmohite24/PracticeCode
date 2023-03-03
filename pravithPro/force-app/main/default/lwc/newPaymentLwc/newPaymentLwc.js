import {  LightningElement,  wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import Opportunity_OBJECT from '@salesforce/schema/Opportunity';

import StageName_FIELD from '@salesforce/schema/Payment__C.Payment_Method__c';

export default class NewPaymentLwc extends LightningElement {
    
    StageValue ='';
    Prospecting= '';
    Qualification = '';
    NeedsAnalysis = '';
    ValueProposition = '';
    IdDecisionMakers = '';
    PerceptionAnalysis = '';

    // getting the default record type id, if you dont' then it will get master

    @wire(getObjectInfo, { objectApiName: Opportunity_OBJECT })

    opportunityMetadata;

    // now retriving the StageName picklist values of Opportunity

    @wire(getPicklistValues,

        {

            recordTypeId: '$opportunityMetadata.data.defaultRecordTypeId', 

            fieldApiName: StageName_FIELD

        }

    )

    OpportunityPicklist;

    // display the selected picklist value
  
  
    handleChange(event) {

        this.StageValue = event.detail.value;
        this.picklistVal = this.StageValue;
       if(this.picklistVal === 'Prospecting'){
          this.Prospecting = this.StageValue ;
       }else{
        this.Prospecting = '';
       }

       if(this.picklistVal === 'Qualification'){
         this.Qualification = this.StageValue ;
       }else{
        this.Qualification = '';
       }

       if(this.picklistVal === 'Needs Analysis'){
          this.NeedsAnalysis = this.StageValue ;
       }else{
        this.NeedsAnalysis = '';
       }

       if(this.picklistVal === 'Value Proposition'){
        this.ValueProposition = this.StageValue ;
     }else{
        this.ValueProposition = '';
     }

     if(this.picklistVal === 'Id. Decision Makers'){
        this.IdDecisionMakers = this.StageValue ;
     }else{
        this.IdDecisionMakers = '';
     }
     
     if(this.picklistVal === 'Perception Analysis'){
        this.PerceptionAnalysis = this.StageValue ;
     }else{
        this.PerceptionAnalysis = '';
     } 

       
    }

}