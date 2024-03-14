import { LightningElement, track,api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getElearntoekn from '@salesforce/apex/ATI_TAC_API_Services.getElearntoekn';

export default class ATI_TAC_ElearnTraningPathData extends NavigationMixin(LightningElement) {
@api recordId;
@track ElearnURL='';
isReloaded = false;
theIframe;
renderedCallback(){
       
        if(!this.isReloaded){
        getElearntoekn({recordId:this.recordId})
		.then(result => {
			
			console.log('getElearntoekn'+result);
          this.ElearnURL = result;  //'https://www.allisonelearn.com/admin/TAC/TAC_Location_User_View.aspx?token=06d2e18e7b31405da1616ff863e8a75c&location=0101500001';
            console.log('this.URL'+ this.ElearnURL);
            this.isReloaded = true;
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {

                       componentName: "c__ATI_ElearnDataComponent"
    
                },
            state: {
                c__elrnurl: result
             
            }
            });
            
           if(this.theIframe==undefined){
                this.theIframe =  this.template.querySelector('iframe');
                this.theIframe.onload = ()=>{
                    console.log('Onload called'+this.isReloaded);
    
                    if(!this.isReloaded){
                        this.isReloaded = true;
                        this.theIframe.src = his.theIframe.src;
    
                    }
                }
            }  
            
		})
		.catch(error => {
			this.error = error;
			console.log('error'+error);
		})
    }
}
}