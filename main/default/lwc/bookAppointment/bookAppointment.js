import { LightningElement } from 'lwc';
import getAllSpecilizations from '@salesforce/apex/mcBookAppointmentController.getAllSpecilizations';
import getPhysicians from '@salesforce/apex/mcBookAppointmentController.getPhysicians';
import getPhysiciansCalender from '@salesforce/apex/mcBookAppointmentController.getPhysiciansCalender';
import getEvents from '@salesforce/apex/mcBookAppointmentController.getEvents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookAppointment extends LightningElement {

    spcialOptions;
    showSpecicializations;
    showPhysicians;
    showspinner;
    physicians;
    deptPrice;
    bookedDatetimes;
    nextDates;
    showPhyCalender;
    selectedDept;
    selectedDeptName;
    selectedPhy;
    selectedPhyName;

    bookingDetails;
    primaryCalid;
    pageNo;

    connectedCallback(){
        this.showSpecicializations = false;
        this.showspinner = false;
        this.showPhyCalender = false;
        this.pageNo = 0;
        this.handleBooking();
    }

    handleBooking(){
        this.showSpecicializations = false;
        this.showspinner = true;
        getAllSpecilizations().then(response=>{
            this.spcialOptions = [];
            for(const specRec of response){
                this.spcialOptions.push(
                    {
                        'label':specRec.Name,
                        'value':specRec.Id
                    }
                );
            }

            this.showSpecicializations = true;
            this.showspinner = false;

        }).catch(error=>{

        });

    }

    handleSpecilization(event){
        console.log('Current target:'+event.target.value);
        this.selectedDept = event.target.value;
        this.physicians = [];
        this.bookedDatetimes = [];
        this.nextDates = [];
        this.showspinner = true;
        this.showPhysicians = false;
        this.showPhyCalender = false;

        try{

            this.selectedDeptName = this.spcialOptions.find(element => element.value == this.selectedDept).label;

            console.log('specName:'+this.selectedDeptName);

            getPhysicians({departmentId: this.selectedDept}).then(response=>{
                console.log('response:'+JSON.stringify(response));
                this.deptPrice = response.price;
                if(response.conList && response.conList.length>0){
                    for(const phyRec of response.conList){

                        console.log('phyRec:'+phyRec);
                        this.physicians.push(
                            {
                                'label':phyRec.Name,
                                'value':phyRec.Id
                            }
                        );

                        this.showPhysicians = true;
                    }
                }
                else{
                    const event = new ShowToastEvent({
                        title: 'Sorry!',
                        variant :'Error',
                        message: 'No physicians available.',
                    });
                    this.dispatchEvent(event);
                }

                this.showspinner = false;
                console.log('physicians:'+JSON.stringify(this.physicians));

            }).catch(error=>{
                this.showspinner = false;
                console.log('response:'+JSON.stringify(error));
            });
        }
        catch(e){
            console.log('Error :'+e);
        }
    }

    handlePhysicians(event){
        console.log('Event target:'+event.target.value);
        this.selectedPhy = event.target.value;
        this.selectedPhyName = this.physicians.find(element => element.value == this.selectedPhy).label;
        console.log('this.selectedPhyName:'+this.selectedPhyName);
        this.fetchPhysicianDetails();
    }   

    handleRefreshCaldr(event){
        console.log('handleRefreshCaldr');
        this.fetchPhysicianDetails();
    }

    fetchPhysicianDetails(){

        if(this.pageNo!==0){
            this.getLatestCalendar();
        }
        else{
            this.showspinner = true;
            this.showPhyCalender = false;
            getPhysiciansCalender({conId:this.selectedPhy}).then(response=>{
                console.log('response:'+JSON.stringify(response));
                this.showspinner = false;
                if(response.hasError){
                    const event = new ShowToastEvent({
                        title: 'Sorry!',
                        variant :'Error',
                        message: response.errorMsgs[0],
                    });
                    this.dispatchEvent(event);
                }
                else{
                    this.bookedDatetimes = response.bookedDatetimes;
                    this.nextDates = response.nextDates;
                    this.showPhyCalender = true;
                    this.primaryCalid = response.primaryCalid;
                    //Set booking details
                    this.bookingDetails = {
                        'selectedDept': this.selectedDept,
                        'selectedPhy': this.selectedPhy,
                        'selectedDeptName':this.selectedDeptName,
                        'selectedPhyName': this.selectedPhyName
                    }
                }
            }).catch(error=>{
                console.log('response:'+JSON.stringify(error));
                this.showspinner = false;
            });
        }

    }

    handlePrevDates(){
        this.pageNo -=1;
        this.getLatestCalendar();
    }

    handleNextDates(){
        this.pageNo +=1; 
        this.getLatestCalendar();
    }

    getLatestCalendar(){

        this.showspinner = true;
        this.showPhyCalender = false;
        getEvents({primaryCalid: this.primaryCalid,accessToken:'',ContactId:this.selectedPhy,pageNo:this.pageNo}).then(response=>{
            console.log('response:'+JSON.stringify(this.response));
            this.showspinner = false;
            this.showPhyCalender = true;
            this.nextDates = response.nextDates;
            this.bookedDatetimes = response.bookedDatetimes;
            this.primaryCalid = response.primaryCalid;
        }).catch(error=>{

        });
    }
}