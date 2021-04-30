import { LightningElement, api } from 'lwc';
import createCalenderEvent from '@salesforce/apex/mcBookAppointmentController.createGoogleCalenderEvent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class McBookingPopup extends LightningElement {

    @api showbookingpopup;

    @api bookingDetails;

    showspinner;

    connectedCallback(){
        this.bookingDetails = {... this.bookingDetails};
        this.showspinner = false;
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleConfirmBooking(event){
        this.showspinner = true;
        console.log('this.bookingDetails:'+JSON.stringify(this.bookingDetails));

        let requestWrapper= {
                selectedDept:this.bookingDetails.selectedDept,
                selectedPhy:this.bookingDetails.selectedPhy, 
                eventDate:this.bookingDetails.selectedDate, 
                eventTime:this.bookingDetails.selectedTime,
                description : this.bookingDetails.description,
                patientName: this.bookingDetails.patientName,
                patientEmail: this.bookingDetails.patientEmail
            };
        createCalenderEvent({request:JSON.stringify(requestWrapper)}).then(response=>{

            if(response.isSuccess){
                const evt = new ShowToastEvent({
                    title: 'Great!',
                    message: 'Your booking has been confirmed',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                this.dispatchEvent(new CustomEvent('close',{detail:'refreshcalender'}));
            }
            else{
                const event = new ShowToastEvent({
                    title: 'Sorry!',
                    variant :'Error',
                    message: 'An error has occured, please try again later.',
                });
                this.dispatchEvent(event);
            }

            this.showspinner = false;
            console.log('Response:'+JSON.stringify(response));
        }).catch(error=>{
            this.showspinner = false;
            console.log('Response error:'+JSON.stringify(error));
        });
    }

    handleChange(event){
        let eventSource = event.target;
        try{
            if(eventSource.label == 'Description'){
                this.bookingDetails.description = eventSource.value;
            }
            else if(eventSource.label == 'Patient Name'){

                this.bookingDetails.patientName = eventSource.value;
            }
            else if(eventSource.label == 'Patient Email'){

                this.bookingDetails.patientEmail = eventSource.value;
            }
        }
        catch(e){
            console.log('Error:'+JSON.stringify(e));
        }
    }
}