/**
 * Created by junliu on 1/11/23.
 */

import {LightningElement} from 'lwc';
import uploadContacts from "@salesforce/apex/Task1Controller.uploadContacts";
import removeUploadTestContacts from "@salesforce/apex/Task1Controller.removeUploadTestContacts";
import {ShowToastEvent} from "lightning/platformShowToastEvent";

export default class Task1 extends LightningElement {

    showSpinner = false;

    get acceptedFormats() {
        return ['.csv'];
    }

    //After the file is uploaded into Salesforce
    //retrieve the content from the document and process it to upload contacts
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.showSpinner = true;
        uploadContacts({idContentDocument: uploadedFiles[0].documentId})
            .then(result => {
                this.showSpinner = false;
                if (result.duplicateDownloadLink){
                    this.showDuplicatedResult(result.duplicateDownloadLink);
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Message!!",
                        message: result.message
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

    //Delete all the uploaded test data
    handleReset(event) {
        this.showSpinner = true;
        removeUploadTestContacts()
            .then(result => {
                this.showSpinner = false;
                let anchorTag = this.template.querySelector('a');
                anchorTag.setAttribute('href','');
                anchorTag.setAttribute('download', '');
                anchorTag.innerText = '';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Message!!",
                        message: result.message
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

    //show the download link of the duplicated records
    showDuplicatedResult(url) {
        let anchorTag = this.template.querySelector('a');
        anchorTag.setAttribute('href',url);
        anchorTag.setAttribute('download', 'Duplicated records');
        anchorTag.innerText = 'Duplicated records!';
    }

}