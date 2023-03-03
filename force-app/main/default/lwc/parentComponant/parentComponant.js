import { LightningElement } from 'lwc';

export default class ParentComponant extends LightningElement {
    updateUser() {
        this.template.querySelector('c-person').updateUser();
    }
}