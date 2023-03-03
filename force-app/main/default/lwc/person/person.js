import { LightningElement, track, api } from 'lwc';

export default class Person extends LightningElement {
    name = 'Cat'
    age = 0;
    actionButtonLabel = 'Show Details';
    location;
    showDetails = false;
    details = 'Richard is the CEO and Founder of Pied Piper';
    /*
    *   @track - Whenever you want to make a propery of a data member reactive
    *   @api - Whenever you want to make a data member or member function public
    *
    *   Note:-
    *   When you need to update the whole data member, no decorator is required
    *   but, if you need to update the property of your data member in lwc component
    *   you need to use a decorator - track
    */

    @track
    user = {
        firstName: 'Richard',
        lastName: 'Hendricks'
    };

    @api
    updateUser() {
        console.log('function called');
        // this.user = {
        //     firstName: 'Gavin',
        //     lastName: 'Belson'
        // };
        //this.user.firstName = 'Gavin';
        
        if (this.user.firstName === 'Gavin') {
            this.user.firstName = 'Richard';
          }
          else {
            this.user.firstName = 'Gavin';
          }

    }
   
    toggleDetails(){

        this.showDetails = !this.showDetails;
        this.actionButtonLabel = this.showDetails ? 'Hide Details' : 'Show Details';
        console.log(this.showDetails);
    }

    actionChange(event){
        this.age = event.target.value;
    
        console.log(this.newAge);
    }

}