import { LightningElement} from 'lwc';


export default class DataBindingType3 extends LightningElement {


name = 'Ajinkya';


blogName = 'SalesforceKid';


get blogname(){


const completeName = `${this.name} ${this.blogName} `;


return completeName.trim().toLowerCase();


}


}