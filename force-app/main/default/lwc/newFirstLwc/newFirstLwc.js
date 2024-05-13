import { LightningElement,track } from 'lwc';

export default class NewFirstLwc extends LightningElement {


  @track  Variables ;
   
    handleChange(event) {
        this.Variables = event.target.value;
    }
    get greeting() {
        return this.Variables ? `Nice to meet you, ${this.Variables}!` : 'Please enter your name.';
    }
}