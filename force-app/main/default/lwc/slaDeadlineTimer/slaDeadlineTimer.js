import { LightningElement, api, wire } from 'lwc';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SLA_DEADLINE_FIELD from '@salesforce/schema/Case_Request__c.SLA_Deadline__c';
import STATUS_FIELD from '@salesforce/schema/Case_Request__c.Status__c';

export default class SlaDeadlineTimer extends LightningElement {

    @api recordId;
    sla_deadline;
    status;
    timer = '';
    setTimer;
    timerClass = 'timer slds-theme_success';

    isTimerInitialized = false;
    timerRunning = true;
    timerHandle;

    @wire(getRecord, { recordId: '$recordId', fields: [SLA_DEADLINE_FIELD, STATUS_FIELD] })
    handleRecord({ data, error }) {
        if (data) {
            this.sla_deadline = getFieldValue(data, SLA_DEADLINE_FIELD);
            this.status = getFieldValue(data, STATUS_FIELD);

            if (this.status === 'Closed') {
                this.stopTimer();

            } else if (!this.isTimerInitialized) {
                this.isTimerInitialized = true;
                this.timerRunning = true; // Ativa a execução do timer
                this.updateTimer();
            }

        } else if (error) {
            this.error = error;
            this.deadline = undefined;
            console.log('Error: ' + error.body.message);
        }
    }

    renderedCallback() {
        if (!this.isTimerInitialized && this.status !== 'Closed') {
            this.isTimerInitialized = true;
            this.timerRunning = true;
            this.updateTimer();
        }
    }

    stopTimer() {
        this.timerRunning = false;
        if (this.timerHandle) {
            clearTimeout(this.timerHandle);
        }
        this.timer = 'Case Request Closed';
        this.timerClass = 'timer slds-theme_success';
        this.isTimerInitialized = false;
    }


    updateTimer() {

        if (!this.timerRunning) {
            return;
        }

        const deadline = new Date(this.sla_deadline).getTime();
        const timeLeft = deadline - Date.now();

        if (timeLeft < 0) {

            this.timer = 'SLA Deadline Lapsed';
            this.timerClass = 'timer slds-theme_error';

        } else {

            let seconds = Math.floor((timeLeft % (1000 * 60) / 1000));
            let minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
            let hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));

            this.timer = `${hours}hrs ${minutes}mins ${seconds}secs`;

            this.timerClass =
                hours >= 2 ? 'timer slds-theme_success' :
                    hours >= 1 ? 'timer slds-theme_warning' :
                        'timer slds-theme_error';

            if (this.timerRunning) {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                this.timerHandle = setTimeout(() => this.updateTimer(), 1000);
            }
        }
    }
}