import { LightningElement, track } from 'lwc';

export default class IframLwc extends LightningElement {
    @track iframeUrl = 'https://checkout.sandbox.dev.clover.com/sdk.js'; // Replace with actual URL

    connectedCallback() {
        window.addEventListener('message', this.handleMessage.bind(this));
    }

    handleMessage(event) {
        if (event.origin !== 'https://checkout.sandbox.dev.clover.com/sdk.js') { // Replace with actual origin
            return;
        }
        // Handle the message from Clover iFrame
        console.log('Message from Clover iFrame:', event.data);
    }
}