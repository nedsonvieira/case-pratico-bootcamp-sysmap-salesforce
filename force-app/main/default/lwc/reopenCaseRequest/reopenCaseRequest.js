import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

import reopenCase from '@salesforce/apex/ReopenCaseRequest.reopenCase';
import STATUS_FIELD from '@salesforce/schema/Case_Request__c.Status__c';

export default class ReopenCaseRequest extends LightningElement {

    @api recordId;
    status;

    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    wiredCase({ data, error }) {
        if (data) {
            this.status = data.fields.Status__c.value;
        } else if (error) {
            console.error(error);
        }
    }

    onReopenCase() {
        reopenCase({ caseId: this.recordId, status: this.status })
            .then(() => {
                notifyRecordUpdateAvailable([{ recordId: this.recordId }]);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Case Reopened',
                        message: 'The case has been successfully reopened.',
                        variant: 'success'
                    })
                );

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Reopening Case',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}