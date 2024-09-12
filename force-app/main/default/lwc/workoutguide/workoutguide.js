import { LightningElement, track } from 'lwc';
import uppperBody from '@salesforce/resourceUrl/Upper_body_parts'; 

export default class WorkOutGuideComponent extends LightningElement {
    
    UppperBody =uppperBody;
    navigateHome() {
   
    // Navigate to the home page
    console.log('Navigating to Home Page');
}
@track isDropdownOpen= false ;
    
toggleDropdown() {
    this.isDropdownOpen = !this.isDropdownOpen;
}


navigateWorkout(event) {
    const workoutType = event.target.dataset.id;
    // Navigate to the selected workout type page
    console.log('Navigating to Workout:', workoutType);
}

navigateHomeWorkout(event) {
    const workoutType = event.target.dataset.id;
    // Navigate to the selected home workout type page
    console.log('Navigating to Home Workout:', workoutType);
}

navigateStretching(event) {
    const stretchType = event.target.dataset.id;
    // Navigate to the selected stretching type page
    console.log('Navigating to Stretching:', stretchType);
}

navigateBmiCalculator() {
    // Navigate to the BMI Calculator page
    console.log('Navigating to BMI Calculator');
}

}
