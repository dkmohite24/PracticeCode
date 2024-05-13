import { LightningElement ,track} from 'lwc';

export default class RenderLwcComp extends LightningElement {
    @track ischeck = 'false';
    handleChange(event) {
        this.ischeck = event.target.checked;
      }
}
