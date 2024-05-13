import { LightningElement,track} from 'lwc';

export default class RenderLwcComponent extends LightningElement {
    areDetailsVisible = false;

    handleChange(event) {
      this.areDetailsVisible = event.target.checked;
    }
}