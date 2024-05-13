import { LightningElement,wire ,api} from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import CLOUDHAK_CHANNEL from "@salesforce/messageChannel/CloudHAK__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ReciveData extends LightningElement {
    subscription = null;
    @wire(MessageContext)
    messageContext;

    myfirstName = '';
    mylastName  = '';

    connectedCallback() {

        this.handleSubscribe();
    }

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, CLOUDHAK_CHANNEL, (message) => {
        this.myfirstName = message.firstName;
        this.mylastName = message.lastName;
        this.ShowToast('Success', 'Data Transfer Successfully', 'success', 'dismissable');
        });
    }
    ShowToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}



