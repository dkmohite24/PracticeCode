import { LightningElement } from 'lwc';

export default class BindExpressionsfromJS extends LightningElement {
    fullName = '';
    email = '';
    phone = '';
    handleChange(event) {
        const field = event.target.name;
        if (field == 'fullName') {
            console.log('###Inside Full Name');
            this.fullName = event.target.value;
        }
        else if (field == 'email') {
            this.email = event.target.value;
        }
        else if (field == 'phone') {
            this.phone = event.target.value; 
        }
    }
    get upperCase() {
        return `${this.fullName}`.toUpperCase();
    }
}