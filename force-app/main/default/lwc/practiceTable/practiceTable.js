import { LightningElement } from 'lwc';

export default class PracticeTable extends LightningElement {
    firstName='';
    mobiNumber='';
    emailId='';
    handleChange(event){
        const field = event.target.name;
        if (field == 'firstName') {
            console.log('###Inside Full Name');
            this.firstName = event.target.value;
        }
        else if (field == 'emailId') {
            this.emailId = event.target.value;
        }
        else if (field == 'mobiNumber') {
            this.mobiNumber = event.target.value;
        }
    }
}