import { api, LightningElement, track } from 'lwc';

export default class EditCartButtonLwc extends LightningElement {
    @api recordId; // This is the Id of the record to be edited
    @api objectApiName;// This is the API name of the Salesforce object

    @track isFormVisible = false; // Track property to control form visibility

    // Method to handle button click to open the form
    handleOpenForm() {
        this.isFormVisible = !this.isFormVisible;
        console.log('isFormVisible'+this.isFormVisible);
    }

    // Method to handle the success event of the form
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Record has been updated successfully!',
            variant: 'success'
        });
        this.dispatchEvent(evt);
        this.isFormVisible = false; // Hide the form after success
    }

    // Custom method to handle save action
    handleSave() {
        const recordForm = this.template.querySelector('lightning-record-form');
        recordForm.submit(); // Programmatically submit the form
    }

    // Custom method to handle cancel action
    handleCancel() {
        this.isFormVisible = false; // Hide the form
        // Optionally, clear the form or perform any other cancel actions
    }
}