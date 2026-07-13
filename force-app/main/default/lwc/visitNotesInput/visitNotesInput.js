import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import VISIT_NOTES_FIELD from '@salesforce/schema/Visit.Visit_Notes_Dictation__c';
import ID_FIELD from '@salesforce/schema/Visit.Id';

export default class VisitNotesInput extends LightningElement {
    @api recordId;
    noteText = '';
    isSaving = false;
    existingNotes = '';

    @wire(getRecord, { recordId: '$recordId', fields: [VISIT_NOTES_FIELD] })
    wiredVisit({ error, data }) {
        if (data) {
            this.existingNotes = data.fields.Visit_Notes_Dictation__c.value || '';
        }
    }

    handleTextChange(event) {
        this.noteText = event.target.value;
    }

    handleSave() {
        if (!this.noteText.trim()) {
            this.showToast('Warning', 'Please enter some notes before saving.', 'warning');
            return;
        }

        this.isSaving = true;

        const timestamp = new Date().toLocaleString();
        const newEntry = `\n\n--- ${timestamp} ---\n${this.noteText}`;
        const updatedNotes = this.existingNotes + newEntry;

        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[VISIT_NOTES_FIELD.fieldApiName] = updatedNotes;

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'Notes saved successfully!', 'success');
                this.existingNotes = updatedNotes;
                this.noteText = '';
            })
            .catch(error => {
                this.showToast('Error', this.extractError(error), 'error');
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    extractError(error) {
        if (error && error.body && error.body.message) return error.body.message;
        if (error && error.message) return error.message;
        return 'An error occurred while saving notes.';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
