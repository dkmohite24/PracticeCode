import { LightningElement, track } from 'lwc';
import jQuery from '@salesforce/resourceUrl/sdkClover';
import polyfill from "@salesforce/resourceUrl/polyfill";
import {loadScript} from "lightning/platformResourceLoader";

export default class PaymentClover extends LightningElement {
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track url = 'https://checkout.sandbox.dev.clover.com/sdk.js';
    @track width = '100%';
    @track url2 = 'https://cdn.polyfill.io/v3/polyfill.min.js';
    
    @track cardNumber = '';
    @track cardHolder = '';
    @track expirationDate = ''; 
    @track cvv = '';
    @track Clover;
    @track elements;

    /*renderedCallback(){
        if (this.isRendered) {
            return;
        }
        console.log('jQuery:', CloverJs);
        alert('Render Alert',);
        loadScript(this, CloverJs)
            .then(() => {
                alert('Js Loaded successfully');
                console.log('loaded');
            })
            .catch((e) => {
                console.log('error');
                console.log(e);
            });
    }*/
    @track dateValue;
    @track showError = false;
    @track errorMessage = '';
    renderedCallback() {
        if (this.isRendered) {
            return;
        }
        console.log('jQuery:', polyfill);
       
        
    }
    handleInputDateChange(event) {
        this.dateValue = event.target.value;
        this.showError = false;
        console.log('this.dateValue'+this.dateValue);
    }
    
    validateDateFormat() {
        const regex = /^(0[1-9]|1[0-2])\/\d{2}$/;
        if (!regex.test(this.dateValue)) {
            this.showError = true;
            this.errorMessage = 'Invalid date format. Please use MM/YY.';
        } else {
            this.showError = false;
            this.errorMessage = '';
        }
    }


    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'cardNumber') {
            this.cardNumber = event.target.value;
        } else if (field === 'cardHolder') {
            this.cardHolder = event.target.value;
        } else if (field === 'expirationDate') {
            this.expirationDate = event.target.value;
        } else if (field === 'cvv') {
            this.cvv = event.target.value;
        }
    }

    handleSubmit() {
        Promise.all([
            loadScript(this, jQuery),
            loadScript(this, polyfill)
        ])
        .then(() => {
            alert('Js Loaded successfully');
            console.log('Jquery loaded');
        // Post Script Load Code Here
        })
        
       /* loadScript(this, polyfill).then(
            ()=> {
                alert('Js Loaded successfully');
                console.log('Jquery loaded');
        })
        .catch((e) => {
            console.log('error');
            console.log(e);
        });
        */

        let Clover;
       // let elements;
        const clover = new Clover('ee3edfc6-f1c4-b877-12d9-f578351ae346');
        const elements = clover.elements();
        console.log(elements);
        if (this.isFormValid()) {
            // Handle the form submission logic here
            console.log('Form submitted with:', {
                cardNumber: this.cardNumber,
                cardHolder: this.cardHolder,
                expirationDate: this.expirationDate,
                cvv: this.cvv
            });
            clover.createToken()
            .then(function(result) {
            if (result.errors) {
              Object.values(result.errors).forEach(function (value) {
               // displayError.textContent = value;
              });
            } else {
              //cloverTokenHandler(result.token);
              alert('Submitted Successfully',result.token);
            }
          });


        
        } else {
            console.log('Form is invalid');
        }
    }

    isFormValid() {
        return this.cardNumber && this.cardHolder && this.expirationDate && this.cvv;
    }
}