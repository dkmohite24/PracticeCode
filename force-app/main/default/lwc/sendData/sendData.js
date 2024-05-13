import { LightningElement,wire ,api} from 'lwc';
import { publish, MessageContext } from "lightning/messageService";
import CLOUDHAK_CHANNEL from "@salesforce/messageChannel/CloudHAK__c";
export default class SendData extends LightningElement {


    
    @api firstName;
    @api lastName;
    
    @wire(MessageContext)
    messageContext;
    handlefirstName(event){
        this.firstName = event.target.value;
    }
        
    handlelastName(event){
        this.lastName = event.target.value; 
    } 
    handleClick(){
        const messaage = {
            firstName: this.firstName,
            lastName: this.lastName
          };
        publish(this.messageContext, CLOUDHAK_CHANNEL, messaage);  
    }
}