import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import transcribeNote from '@salesforce/apex/OVANoteScannerController.transcribeNote';
import saveToVisit from '@salesforce/apex/OVANoteScannerController.saveToVisit';

export default class MobileHandwritingScanner extends LightningElement {
    @api recordId;
    @track uploadedFileName;
    @track contentDocumentId;
    @track transcription;
    @track isProcessing = false;
    @track statusMessage;

    get showUploader() {
        return !this.uploadedFileName;
    }

    handleUploadFinished(event) {
        const files = event.detail.files;
        if (!files || files.length === 0) return;
        const file = files[0];
        this.uploadedFileName = file.name;
        this.contentDocumentId = file.documentId;
        this.statusMessage = null;
        this.transcription = null;
    }

    handleClear() {
        this.uploadedFileName = null;
        this.contentDocumentId = null;
        this.transcription = null;
        this.statusMessage = null;
    }

    handleTranscribe() {
        if (!this.contentDocumentId) return;
        this.isProcessing = true;
        this.statusMessage = 'Einstein is reading the image...';

        transcribeNote({ contentDocumentId: this.contentDocumentId })
            .then((text) => {
                this.transcription = text;
                this.statusMessage = 'Transcription ready. Review and save below.';
            })
            .catch((error) => {
                this.showToast('Error', this.extractError(error), 'error');
                this.statusMessage = null;
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }

    handleEdit(event) {
        this.transcription = event.target.value;
    }

    handleSave() {
        if (!this.transcription) return;
        this.isProcessing = true;
        this.statusMessage = 'Saving to Visit Notes Dictation...';

        saveToVisit({
            visitId: this.recordId,
            transcription: this.transcription
        })
            .then(() => {
                this.showToast('Success', 'Transcription saved to Visit Notes Dictation field.', 'success');
                this.transcription = null;
                this.uploadedFileName = null;
                this.contentDocumentId = null;
                this.statusMessage = null;
            })
            .catch((error) => {
                this.showToast('Error', this.extractError(error), 'error');
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }

    extractError(error) {
        if (error && error.body && error.body.message) return error.body.message;
        if (error && error.message) return error.message;
        return 'Unexpected error.';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
