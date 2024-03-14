import { LightningElement, track, api, wire } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateWRANDINV from '@salesforce/apex/ATI_WarrantyRegistrationApprovals.updateWRANDINV';
import approve from '@salesforce/label/c.ATI_Approve';
import cancel from '@salesforce/label/c.ATI_Cancel';
import comments from '@salesforce/label/c.ATI_Registration_Comments';

export default class ATI_WRApprove extends LightningElement {
    @api recordId;
    @api wrObj;
    @track regComments;

    label = {
        approve,
        cancel,
        comments
    };
    
    connectedCallback() {
        console.log("recordId--------->"+this.wrObj);
        console.log("recordId--------->"+JSON.stringify(this.wrObj));
        this.regComments = '';
        //if(this.wrObj.WOD_2__Registraion_Comments__c){
            //this.regComments = wrObj.WOD_2__Registraion_Comments__c;
        //}
        console.log("recordId--------->"+this.recordId);
    }

    handleCancel(){
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleApproveClick(event){
        console.log("SuccessFull--------->"+event.detail.id);
        updateWRANDINV({'action': 'Approve','recordId':this.recordId,'regComments': this.regComments}).then(response => { 
            response = JSON.parse(JSON.stringify(response));
            console.log('response--11------->',response);
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.showToast('Success!!', 'Approved.', 'success');
            this.handleCancel();
        }).catch(error => {
            console.log('error-------->',error);
        });
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