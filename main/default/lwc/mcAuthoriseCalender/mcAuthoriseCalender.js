import { LightningElement,wire } from 'lwc';
import getoAuthUrl from '@salesforce/apex/McAuthoriseCalenderController.getoAuthUrl';
import hasGrantedCalender from '@salesforce/apex/McAuthoriseCalenderController.hasGrantedCalender';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class McAuthoriseCalender extends NavigationMixin (LightningElement){

    accessGranted;
    showspinner;
    connectedCallback(){
        this.showspinner = true;

        hasGrantedCalender().then(response=>{

            this.showspinner = false;
            this.accessGranted = response;

        }).catch(error=>{

            this.showspinner = false;
            const event = new ShowToastEvent({
                title: 'Sorry!',
                variant :'Error',
                message: 'An error has occured, please try again later.',
            });
            this.dispatchEvent(event);
        });
    }

    handleGrantAccess(event){
        
        getoAuthUrl().then(response=>{

            let oAuthUrl = response.oAuthUrl+'&state='+response.userid;

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                    attributes: {
                        url: oAuthUrl
                    }
                }
            );

        }).catch(error=>{
            
            const event = new ShowToastEvent({
                title: 'Sorry!',
                variant :'Error',
                message: 'An error has occured, please try again later.',
            });
            this.dispatchEvent(event);
        });        
    }
}