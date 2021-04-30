import { LightningElement,api} from 'lwc';

export default class McCalender extends LightningElement {

    @api nextDates;
    @api bookedDatetimes;
    @api bookingDetails;

    /* the following fields will hold the date value */
    sunday;
    monday;
    tuesday;
    wednesday;
    thursday;
    friday;
    saturday;

    /* the following fields will hold the exisitng booking for respective dates */
    sunBooked = [];
    monBooked = [];
    tueBooked = [];
    wedBooked = [];
    thuBooked = [];
    friBooked = [];
    satBooked = [];

    connectedCallback(){
        this.setupCalender();
    }

    setupCalender(){

        if(this.nextDates && this.bookedDatetimes){

            for(let i=0;i<this.nextDates.length;i++){
            
                if(i==0){
                    this.sunday = this.nextDates[i];
                }
                else if(i==1){
                    this.monday = this.nextDates[i];
                }
                else if(i==2){
                    this.tuesday = this.nextDates[i];
                }
                else if(i==3){
                    this.wednesday = this.nextDates[i];
                }
                else if(i==4){
                    this.thursday = this.nextDates[i];
                }
                else if(i==5){
                    this.friday = this.nextDates[i];
                }
                else if(i==6){
                    this.saturday = this.nextDates[i];
                }
    
                let nextDate = this.nextDates[i];
    
                for(let j=0;j<this.bookedDatetimes.length;j++){
                    let bookDatetime = new Date (this.bookedDatetimes[j]);
                    let bookDate = bookDatetime.toLocaleDateString();
                    let bookTime = bookDatetime.toLocaleTimeString();
                    if(bookDate  == nextDate){
                        if(i == 0){
                            this.sunBooked.push(bookTime);
                        }
                        else if(i == 1){
                            this.monBooked.push(bookTime);
                        }
                        else if(i == 2){
                            this.tueBooked.push(bookTime);
                        }
                        else if(i == 3){
                            this.wedBooked.push(bookTime);
                        }
                        else if(i == 4){
                            this.thuBooked.push(bookTime);
                        }
                        else if(i == 5){
                            this.friBooked.push(bookTime);
                        }
                        else if(i == 6){
                            this.satBooked.push(bookTime);
                        }
                    }
                }
            }
        }


    }
    handlerefresh(event){
        this.dispatchEvent(new CustomEvent('refreshcalender',{bubbles: true}));
    }
}