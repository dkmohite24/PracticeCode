import { LightningElement, track } from 'lwc';

export default class UsingLoopLwc extends LightningElement {
    Students= [
        {
            Id : '001',
            Name:'Student1',
            Class :'Class 1',
            Fee : '100 k'

        },
        {
            Id : '002',
            Name : 'Student 2',
            Class : 'Class 2',
            Fee  : '1000 $'

        },
        {
            Id : '003',
            Name : 'Student 3',
            Class : 'Class 3',
            Fee  : '1000 $'

        },
        {
            Id : '004',
            Name : 'Student 4',
            Class : 'Class 4',
            Fee  : '1000 $'

        },
        {
            Id : '005',
            Name : 'Student 5',
            Class : 'Class 5',
            Fee  : '1000 $'

        },
        {
            Id : '006',
            Name : 'Student 6',
            Class : 'Class 6',
            Fee  : '1000 $'

        },
        {
            Id : '007',
            Name : 'Student 7',
            Class : 'Class 7',
            Fee  : '1000 $'

        },
        {
            Id : '008',
            Name : 'Student 8',
            Class : 'Class 8',
            Fee  : '1000 $'

        },
        {
            Id : '009',
            Name : 'Student 9',
            Class : 'Class 9',
            Fee  : '1000 $'

        },
        {
            Id : '010',
            Name : 'Student 10',
            Class : 'Class 10',
            Fee  : '1000 $'

        }


    ]
   
    @track isDropdownOpen= false ;
    


    toggleDropdown() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    navigateWorkout() {
        // Logic to navigate to the Workout page
    }

    navigateHomeWorkout() {
        // Logic to navigate to the Home Workout page
    }

    navigateStretching() {
        // Logic to navigate to the Stretching page
    }








// header
@track isWorkoutDropdownOpen = false; // Tracks dropdown open/close state
@track selectedWorkout = 'Workout';   // Default header text

// Toggles the dropdown visibility
toggleWorkoutDropdown() {
    this.isWorkoutDropdownOpen = !this.isWorkoutDropdownOpen;
}

// Handles selection of a menu item
handleMenuSelect(event) {
    const selectedValue = event.currentTarget.dataset.value;
    this.selectedWorkout = selectedValue;
    this.isWorkoutDropdownOpen = false;
}
}