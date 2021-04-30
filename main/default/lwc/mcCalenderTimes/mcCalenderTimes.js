import { LightningElement,api } from 'lwc';

export default class McCalenderTimes extends LightningElement {
    
    @api bookingDetails;
    @api thisDate;
    selectedTime;
    showbookingpopup;
    availbleTimes = [];
    _bookedTimes;
    noSlotsAvailable;
    @api 
    get bookedTimes (){
        return this._bookedTimes;
    }

    set bookedTimes(value){
        if(this._bookedTimes == null){
            this._bookedTimes = value;
            
            !this._bookedTimes.includes('09:00:00')? this.availbleTimes.push('09:00 - 10:00'):'';
            !this._bookedTimes.includes('10:00:00')? this.availbleTimes.push('10:00 - 11:00'):'';
            !this._bookedTimes.includes('11:00:00')? this.availbleTimes.push('11:00 - 12:00'):'';
            !this._bookedTimes.includes('12:00:00')? this.availbleTimes.push('12:00 - 13:00'):'';
            !this._bookedTimes.includes('13:00:00')? this.availbleTimes.push('13:00 - 14:00'):'';
            !this._bookedTimes.includes('14:00:00')? this.availbleTimes.push('14:00 - 15:00'):'';
            !this._bookedTimes.includes('15:00:00')? this.availbleTimes.push('15:00 - 16:00'):'';
            !this._bookedTimes.includes('16:00:00')? this.availbleTimes.push('16:00 - 17:00'):'';
        }

        //Show booked out message if not slots are available
        if(this.availbleTimes && this.availbleTimes.length == 0){
            this.noSlotsAvailable = true;
        }
        else{
            this.noSlotsAvailable = false;
        }
    }

    connectedCallback(){
        this.showbookingpopup = false;
        this.noSlotsAvailable = false;
       
    }

    handleClickTime(event){
        this.bookingDetails = {... this.bookingDetails};
        this.bookingDetails.selectedDate = this.thisDate;
        this.bookingDetails.selectedTime = event.target.label;
        this.showbookingpopup = true;
    }

    handleCloseBooking(event){
        try{
            console.log('this.bookingDetails.selectedTime:'+event.detail);
            if(event.detail && event.detail == 'refreshcalender'){
                console.log('dispatching refreshcalender');
                event.preventDefault();
                this.dispatchEvent(new CustomEvent('refreshcalender',{bubbles: true}));
            }
            
            this.showbookingpopup = false;
        }
        catch(e){
            console.log('Error :'+JSON.stringify(e));
        }
    }
}