/* eslint-disable no-console */
import { LightningElement,track,wire } from 'lwc';
import getAccLwc from '@salesforce/apex/retriveAccData.getAccLwc';
import getconLwc from '@salesforce/apex/retriveAccData.getconLwc';
export default class RetriveDataFromObj extends LightningElement {
    @track searchKey;
    @track Error;
    @track accountList;
    @track searchCon
    @track conList;
    @wire(getAccLwc ,{
        Name : '$searchKey'
    })
    wiredAccount({error,data}){
        if(data){
            this.accountList = data;
            console.log('Contact**'+JSON.stringify(this.accountList))
        }
        if(error){
            if(error){
                this.error = error;
            }  
        }

    }
    
    getContacts(){
        getconLwc({searchCon: this.searchCon}).
        then(result =>{
            this.conList = result;
            console.log('ContactList**'+JSON.stringify(this.conList));
            
        })

    }
    handleChangeCon(event){
        event.preventDefault();
    
        console.log('value@@@@@'+event.target.value);
        console.log(this.contactList);
        console.log('Contact**'+JSON.stringify(this.contactList));
        this.searchCon = event.target.value;
    }
    handleChange(event){
        event.preventDefault();
    
        console.log('value'+event.target.value);
        console.log(this.contactList)
        this.searchKey = event.target.value;
    }

}