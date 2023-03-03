({
	doInit : function(component) {
        var visualforceDomain = "https://" + component.get("v.visualforceDomain");
        /**
         * Adding a new event listner on window object
         * to listen for message event
         **/
        window.addEventListener("message", function(event) {
            //Check if origin is not your org's my domain url, in this case, simply return out of function
            if (visualforceDomain.indexOf(event.origin) == -1) {
                // Not the expected origin: reject message!
                console.error('Discarding Message | Message received from invalid domain: ',event.origin);
                return;
            }
            // Handle the message event here
            console.log('Lightning Gets: ', event.data);
            document.querySelector('#allMessages').innerHTML += '<p>'+event.data+'</p>';
        }, false);
    },
    
    /**
     * This function will be sending the data to visualforce page's window
     * object using postMessage function
     * */
    sendToVF : function(component, event, helper) {
		console.log('Lightning Sends: ', component.get("v.message"));
        const visualforceDomain = 'https://'+component.get('v.visualforceDomain');

        //Visualforce Page's iframe window object
        const vfWindow = component.find("vfFrame").getElement().contentWindow;
		//Sending message using postMessage function
		//If sending an json object, its better to stringify first and send the object
        vfWindow.postMessage(component.get("v.message"), visualforceDomain);
        //resetting my text box with blank value
        component.set("v.message", "");
	}
})