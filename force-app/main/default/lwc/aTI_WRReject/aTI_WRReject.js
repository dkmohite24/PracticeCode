import { LightningElement, track, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateWRANDINV from '@salesforce/apex/ATI_WarrantyRegistrationApprovals.updateWRANDINV';
import reject from '@salesforce/label/c.ATI_Reject';
import cancel from '@salesforce/label/c.ATI_Cancel';
import comments from '@salesforce/label/c.ATI_Registration_Comments';

export default class ATI_WRReject extends LightningElement {
    @api recordId;
    @track wrObj;

    label = {
        reject,
        cancel,
        comments
    };

    connectedCallback() {
        console.log("recordId--------->"+this.recordId);
    }

    handleCancel(){
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleRejectClick(event){
        updateWRANDINV({'action': 'Reject','recordId':this.recordId,'regComments': this.wrObj.WOD_2__Registraion_Comments__c}).then(response => { 
            response = JSON.parse(JSON.stringify(response));
            console.log('response--11------->',response);
            getRecordNotifyChange([{recordId: this.recordId}]);
            this.showToast('Success!!', 'Rejected.', 'success');
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