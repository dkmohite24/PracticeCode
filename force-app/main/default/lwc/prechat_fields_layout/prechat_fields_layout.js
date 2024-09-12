import BasePrechat from 'lightningsnapin/basePrechat';
import { api, track } from 'lwc';


export default class Prechat_fields_layout extends BasePrechat {
    @api prechatFields;
    @api backgroundImgURL;
    @track otherFields;
    @track nameFields;
    @track fields;
    @track fieldsToBeDisplay;
    @track namelist;
   // @track fielsAll;
    startChatLabel;
    errorMessages;
    @track isShowErrorModal = false;
    
   
    /**
     * Set the button label and prepare the prechat fields to be shown in the form.
     */
    connectedCallback() {
        var fielsAll = [];
        this.startChatLabel = 'Start Chatting';

        
        this.fields = this.prechatFields.map(field => {
            console.log('field= '+JSON.stringify(field));
            //const { label, name, value, required, maxLength } = field;
            //return { label, name, value, required, maxLength };
            const {type, name, label, required, readOnly, className, maxLength} = field;
            return {type, name, label, required, readOnly, className, maxLength};
        });
        this.namelist = this.fields.map(field => field.name);
        const iterator = this.fields.values();
        for (var value of iterator) {
            console.log('val name',value.name);
            if(value.name == 'FirstName' ){
                value.isFirstName = true;
                value.isLastName=false;
                console.log('FirstName if');
            }
            else if(value.name == 'LastName')
            {
                value.isFirstName = false;
                value.isLastName = true;
                console.log('LastName if');
            }
            else if(value.name == 'Email')
            {
                value.isFirstName = false;
                value.isLastName = false;
                value.isEmail=true;
                console.log('Email if');
            }
            else{
                console.log('else');
                value.isExtra=true;
                value.isFirstName = false;
                value.isLastName = false;
                value.isEmail=false;
            }
            fielsAll.push(value);
            console.log('val= '+JSON.stringify(value));
            
            this.fieldsToBeDisplay = fielsAll
        }
        console.log('@@fielsAll= '+fielsAll);
        console.log('@@ this.fields1= '+this.fieldsToBeDisplay);
    }

    /**
     * Focus on the first input after this component renders.
     */
    renderedCallback() {
        
        console.log('here render call back');
        this.template.querySelector("input").focus();
        console.log('@@  this.fields in render= '+ this.fields);
        console.log('iterator ',JSON.stringify(this.fields));
        const elements = this.template.querySelectorAll("INPUT");
        console.log('->',JSON.stringify(elements));
        for (let element of elements) {
            element.setAttribute("data-lpignore", "true");
        }
      
    }

    /**
     * On clicking the 'Start Chatting' button, send a chat request.
     */
    handleStartChat() {
        
        const isInputsCorrect = [...this.template.querySelectorAll('input')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        
        this.template.querySelectorAll("input").forEach(input => {
            this.fields[this.namelist.indexOf(input.name)].value = input.value;
        });
    


        if ( this.validateFields( this.fields ).valid ) {
        // validation fields start cm-2915  Dhannjay  
            let checkBool = true;
            this.errorMessages = 'Please fix the following error(s):<br/>';

            for ( let field of this.fields ) {
                if ( !field.value ) {
                    
                    checkBool = false;
                    this.errorMessages += 'Please fill ' + field.label + '<br/>';
                    
                }

                if ( field.label === 'Phone' ) {

                    if ( field.value ) { 
                        
                        if (!/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/.test(field.value)) {

                            checkBool = false;
                            this.errorMessages += 'Please enter a valid phone number.<br/>';

                        }

                    }

                } 

                if (field.label === 'Email') {

                    console.log(
                        'Inside Email Validation'
                    );
   
                    if (field.value) {
                        let strEmailRegEx = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
   
                        if (
                            !strEmailRegEx.test(
                                field.value
                            )
                        ) {
   
                            checkBool = false;
                            this.errorMessages += 'Please enter a valid email address.<br/>';
   
                        }
   
                 }  }   

            }
            if (checkBool === true && isInputsCorrect) {

                console.log('Starting Chat');
                this.startChat(this.fields);
   
            } else {
               this.isShowErrorModal = true;

                console.log(
                    'Error Message(s)',
                    this.errorMessages
                );
   
            }
            // validation fields End cm-2915  Dhannjay  

        }
       
        


        // var inputs = this.template.querySelectorAll('input');
        // var email=inputs[2].value;
        // var mailformat='^[A-Za-z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$';
       
        // var elements = this.template.querySelectorAll("INPUT");
        // console.log('inputs 0',elements[0].value);
        // console.log('inputs 1',elements[1].value);
        // console.log('inputs 2',elements[2].value);
        // console.log('inputs 3',elements[3].value);
        // console.log('inputs 4',elements[4].value);
        // if(mailformat.match(elements[2].value))
        // {
        //     elements[2].setCustomvalidity("");
        // }
        // else{elements[2].setCustomvalidity("Please Enter Valid Email");}
        // for (var i = 0; i < elements.length; i++) {
        //     elements[2].oninvalid = function(e) {
        //         e.target.setCustomValidity("");
        //         if (!e.target.validity.valid) {
        //             e.target.setCustomValidity("Please Enter Valid Email");
                    
        //         }
        //     };
        //     elements[i].oninput = function(e) {
        //         e.target.setCustomValidity("");
        //     }
        // } 
       // if (isInputsCorrect) {
       //     this.startChat(this.fields);
      //  } else {
            // Error handling if fields do not pass validation.
      //  }   
    }
    hideErrorModalBox() {  
        this.isShowErrorModal = false;
    }
}