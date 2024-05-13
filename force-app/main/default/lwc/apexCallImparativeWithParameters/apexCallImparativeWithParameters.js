import { LightningElement } from 'lwc';
import findContact from '@salesforce/apex/contactControllerLwcImparativeCall.findContact';

export default class ApexCallImparativeWithParameters extends LightningElement {

    searchKey ;
    contacts;
    error;
    handleSearchKeyChange(event){
        this.searchKey = event.target.value;

        console.log('this.searchKey '+ this.searchKey);
    }

    handleClick(){
        console.log('inside handleClick');
        findContact({ searchKey: this.searchKey })
        .then(result => {
            this.contacts= result;
                        console.log('this.contacts '+ this.contacts);
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.contacts = undefined;
        });

    }
}