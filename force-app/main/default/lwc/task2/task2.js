/**
 * Created by junliu on 1/10/23.
 */

import {LightningElement} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import callAPIAndUpdateContact from "@salesforce/apex/Task2Controller.callAPIAndUpdateContact";

const columns = [
    {label: 'id', fieldName: 'id'},
    {label: 'First Name', fieldName: 'firstName'},
    {label: 'Last Name', fieldName: 'lastName'},
    {label: 'Email', fieldName: 'email', type: 'email'},
    {label: 'Email Verified', fieldName: 'emailVerified', tyee: 'boolean'},
    {label: 'Date of Birth', fieldName: 'dateOfBirth', type: 'date'},
    {label: 'Signup Date', fieldName: 'signUpDate', type: 'date'}
];

export default class Task2 extends LightningElement {
    data = [];
    columns = columns;

    handleClick(event) {

        // calling apex class
        callAPIAndUpdateContact()
            .then(result => {
                console.log(result);
                this.data = result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Message!!",
                        message: 'Contact Record Updated'
                    })
                );
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error!!",
                        message: JSON.stringify(error),
                        variant: "error"
                    })
                );
            });

    }

    handleReset(event) {
        this.data = [];
    }

}