import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDaysAddedDate from '@salesforce/apex/ATI_WRCancelController.getDaysAddedDate';
import getWRInfo from '@salesforce/apex/ATI_WRCancelController.getWRInfo';
import getBCCSVal from '@salesforce/apex/ATI_WRCancelController.getBCCSVal';
import getReasonPickListValues from '@salesforce/apex/ATI_WRCancelController.getReasonPickListValues';
import getTransactionLineItems from '@salesforce/apex/ATI_WRCancelController.getTransactionLineItems';
import updateWR from '@salesforce/apex/ATI_WRCancelController.updateWR';
import noExtendedWarranty from '@salesforce/label/c.ATI_NoExtendedWarranty';
import cancelExtendedWRWithinErr1 from '@salesforce/label/c.ATI_CancelExtendedWRWithinErr1';
import cancelExtendedWRWithinErr2 from '@salesforce/label/c.ATI_CancelExtendedWRWithinErr2';
import extendedWRTotalAmtError from '@salesforce/label/c.ATI_ExtendedWRTotalAmtError';

const COLS = [
  { label: 'Name', fieldName: 'Name', editable: false },
  { label: 'Unit Amount', fieldName: 'WOD_2__Unit_Amount__c', editable: false },
  { label: 'Handling Fee', fieldName: 'ATI_Handling_Fee__c', editable: true },
  { label: 'Late Fee', fieldName: 'ATI_Late_Fee__c', editable: true },
  { label: 'Total Amount', fieldName: 'WOD_2__Total_Amount__c', editable: false }
];

export default class ATI_CancelExtendedWarrantyWebComponent extends LightningElement {
    label = {
      noExtendedWarranty,
      cancelExtendedWRWithinErr1,
      cancelExtendedWRWithinErr2,
      extendedWRTotalAmtError
    };

    
		bccsRecVal;
    wrRecordId;
    updateWRRecord;
    reason;
    reasonOptions=[];
    transactionHistLIs=[];
    draftValues = []; 
    updatedValues = []; 
    originalTotalAmount;
    columns=COLS;
    @track userMsg;
    @track allowCancellation=false;
    @api invId;
    @api isLoaded = false;
    
    getWarrantyInfo(){
      getWRInfo({invId:this.invId}).then(response => { 
        var objData = JSON.parse(response.data);
        if(objData.length === 0){
          this.userMsg=this.label.noExtendedWarranty;
          this.allowCancellation=false;
        }
        else{
          if(objData.length === 1){
            this.updateWRRecord=false;
          }
          else{
            this.updateWRRecord=true;
          }
          var wrRecId;
          var inServiceDate;
          objData.forEach(function(data){
            if(data.hasOwnProperty('WOD_2__Warranty_Coverages__r')){
              wrRecId=data.Id;
              inServiceDate=data.WOD_2__Inventory__r.WOD_2__Install_Date__c;
            }
          });
          this.wrRecordId=wrRecId;
          console.log('wrRecordId===>'+this.wrRecordId);
          if(!this.wrRecordId){
            this.userMsg=this.label.noExtendedWarranty;
            this.allowCancellation=false;
          }
          else{
            this.allowCancellation=true;
            getDaysAddedDate({inServiceDate:inServiceDate}).then(response => {
              var result = JSON.parse(response.data);
              if(new Date(result)<new Date()){
                this.userMsg=this.label.cancelExtendedWRWithinErr1+' '+this.bccsRecVal+' '+this.label.cancelExtendedWRWithinErr2;
                this.allowCancellation=false;
              }
            }).catch(error => {
              console.log('getDaysAddedDate Error-------->',error);
            });
            
            getTransactionLineItems({wrObjId:this.wrRecordId}).then(response => {
              var result = JSON.parse(response.data);
              this.originalTotalAmount=result[0].WOD_2__Total_Amount__c;
              this.transactionHistLIs=[];
              this.transactionHistLIs=result;
              this.updatedValues=[];
              this.updatedValues=result;
            }).catch(error => {
              console.log('getTransactionLineItems Error-------->',error);
            });
          }
        }
      }).catch(error => {
        console.log('getWRInfo Error-------->',error);
      });
      this.isLoaded = true;
    }

    populateBCCSVal(){
      getBCCSVal().then(response => {
        var result = JSON.parse(response.data);
        this.bccsRecVal=result;
      }).catch(error => {
        console.log('getBCCSVal Error-------->',error);
      });
    }

    populateReasonPickListValues(){
      getReasonPickListValues().then(response => {
        var result = JSON.parse(response.data);
        this.reasonOptions=[];
        this.reasonOptions.push({label:'--None--', value:'', selected: true});
        for(let key in result){
          this.reasonOptions.push({label:result[key], value:result[key]});
        }
      }).catch(error => {
        console.log('getReasonPickListValues Error-------->',error);
      });   
    }

    connectedCallback() {
      this.populateBCCSVal();
      this.getWarrantyInfo();
      this.populateReasonPickListValues();
    }

    handleReasonChange(event){
      this.reason = event.target.value;
    }
		
    handleCancel(){
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleSave(event){
      for(let key in event.detail.draftValues) {
        if(event.detail.draftValues[key]['ATI_Handling_Fee__c']){
          this.updatedValues[key]['ATI_Handling_Fee__c']=event.detail.draftValues[key]['ATI_Handling_Fee__c'];
        }
        if(event.detail.draftValues[key]['ATI_Late_Fee__c']){
          this.updatedValues[key]['ATI_Late_Fee__c']=event.detail.draftValues[key]['ATI_Late_Fee__c'];
        }
        this.updatedValues[key]['WOD_2__Total_Amount__c']=this.updatedValues[key]['WOD_2__Unit_Amount__c']+parseInt(this.updatedValues[key]['ATI_Late_Fee__c'])-parseInt(this.updatedValues[key]['ATI_Handling_Fee__c']);
        if(this.updatedValues[key]['WOD_2__Total_Amount__c']>this.originalTotalAmount){
          this.showToast('Error!', this.label.extendedWRTotalAmtError, 'error');
        }
      }
    }

    handleSuccess(){
      var isErr=false;
      this.template.querySelectorAll('lightning-combobox').forEach(element => {
        element.reportValidity();
      });
      for(let key in this.updatedValues) {
        if(this.updatedValues[key]['WOD_2__Total_Amount__c']>this.originalTotalAmount){
          isErr=true;
          this.showToast('Error!', this.label.extendedWRTotalAmtError, 'error');
        }
      }
      if(!!this.reason && !isErr){
        updateWR({'recordId':this.wrRecordId,'updateWRRecord':this.updateWRRecord,'reason':this.reason,'lineItemList':JSON.stringify(this.updatedValues)}).then(response => { 
          response = JSON.parse(JSON.stringify(response));
          this.showToast('Success!!', 'Cancelled.', 'success');
          this.handleCancel();
        }).catch(error => {
            console.log('updateWR error-------->',error);
        });
      }
    }

    showToast(theTitle, theMessage, theVariant) {
      const event = new ShowToastEvent({
          title: theTitle,
          message: theMessage,
          variant: theVariant
      });
      this.dispatchEvent(event);
    }

}