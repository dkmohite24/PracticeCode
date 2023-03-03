import { LightningElement } from 'lwc';
import findAccountList from '@salesforce/apex/AccountController.searchAccount';

export default class BindImperativewithParam extends LightningElement {
    searchKey='';
    accounts;
    error;

    handleonchange(event){
        this.searchKey = event.target.value;
    }

    buttonClick(){
        findAccountList({accName: this.searchKey})
        .then((result) =>{
            this.accounts = result;
            this.error = undefined;
        })
        .catch((error)=>{
            this.error = error;
            this.accounts = undefined;
        });

    }
}