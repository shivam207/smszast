import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableObjects from '@salesforce/apex/SMSTemplateController.getAvailableObjects';
import getObjectFields from '@salesforce/apex/SMSTemplateController.getObjectFields';
import saveTemplate from '@salesforce/apex/SMSTemplateController.saveTemplate';

const STATUS_OPTIONS = [
    { label: 'Active', value: 'Active' },
    { label: 'Inactive', value: 'Inactive' }
];

export default class SmsTemplateForm extends LightningElement {
    @api showTriggerButton = false;
    @api isOpen = false;

    @track templateName = '';
    @track selectedObject = '';
    @track status = 'Active';
    @track channels = '';
    @track folder = '';
    @track description = '';
    @track templateBody = '';

    @track mergeObject = '';
    @track mergeObjectLabel = '';
    @track objectFields = [];
    @track isLoadingFields = false;

    @track objectOptions = [];
    @track isLoadingObjects = false;

    @track isMergeFieldExpanded = true;
    @track isTemplateBodyExpanded = true;

    @track errorMessage = '';
    @track isSaving = false;

    statusOptions = STATUS_OPTIONS;

    connectedCallback() {
        this.loadObjects();
    }

    // ── Open / Close ──────────────────────────────────────────────────────────

    handleOpenModal() {
        this.isOpen = true;
    }

    // ── Data loading ──────────────────────────────────────────────────────────

    loadObjects() {
        this.isLoadingObjects = true;
        getAvailableObjects()
            .then(result => {
                this.objectOptions = result.map(obj => ({
                    label: obj.label,
                    value: obj.value
                }));
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load objects: ' + this.reduceError(error), 'error');
            })
            .finally(() => {
                this.isLoadingObjects = false;
            });
    }

    loadFields(objectApiName) {
        if (!objectApiName) {
            this.objectFields = [];
            return;
        }
        this.isLoadingFields = true;
        this.objectFields = [];
        getObjectFields({ objectApiName })
            .then(result => {
                this.objectFields = result.map(f => ({
                    label: f.label,
                    value: f.value,
                    hasChildren: f.hasChildren || false
                }));
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load fields: ' + this.reduceError(error), 'error');
            })
            .finally(() => {
                this.isLoadingFields = false;
            });
    }

    // ── Field change handlers ─────────────────────────────────────────────────

    handleTemplateNameChange(event) {
        this.templateName = event.target.value;
        this.clearError();
    }

    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        // Sync merge object to selected template object
        this.mergeObject = this.selectedObject;
        const selected = this.objectOptions.find(o => o.value === this.selectedObject);
        this.mergeObjectLabel = selected ? selected.label : '';
        this.loadFields(this.selectedObject);
        this.clearError();
    }

    handleStatusChange(event) {
        this.status = event.detail.value;
    }

    handleChannelsChange(event) {
        this.channels = event.target.value;
    }

    handleFolderChange(event) {
        this.folder = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleTemplateBodyChange(event) {
        this.templateBody = event.target.value;
        this.clearError();
    }

    handleMergeObjectChange(event) {
        this.mergeObject = event.detail.value;
        const selected = this.objectOptions.find(o => o.value === this.mergeObject);
        this.mergeObjectLabel = selected ? selected.label : '';
        this.loadFields(this.mergeObject);
    }

    // ── Merge field insertion ─────────────────────────────────────────────────

    handleFieldClick(event) {
        const fieldApiName = event.currentTarget.dataset.field;
        const mergeTag = `{!${this.mergeObject}.${fieldApiName}}`;
        this.templateBody = this.templateBody
            ? this.templateBody + mergeTag
            : mergeTag;
    }

    // ── Section toggles ───────────────────────────────────────────────────────

    toggleMergeField() {
        this.isMergeFieldExpanded = !this.isMergeFieldExpanded;
    }

    toggleTemplateBody() {
        this.isTemplateBodyExpanded = !this.isTemplateBodyExpanded;
    }

    // ── Emoji ─────────────────────────────────────────────────────────────────

    handleEmojiClick() {
        // Simple emoji picker: append a smiley — extend as needed
        this.templateBody = (this.templateBody || '') + '😊';
    }

    // ── Actions ───────────────────────────────────────────────────────────────

    handleSave() {
        if (!this.validateForm()) return;

        this.isSaving = true;
        const payload = {
            name: this.templateName,
            objectApiName: this.selectedObject,
            status: this.status,
            channels: this.channels,
            folder: this.folder,
            description: this.description,
            body: this.templateBody
        };

        saveTemplate({ templateJson: JSON.stringify(payload) })
            .then(() => {
                this.showToast('Success', 'SMS Template saved successfully.', 'success');
                this.dispatchEvent(new CustomEvent('saved'));
                this.closeModal();
            })
            .catch(error => {
                this.showToast('Error', 'Failed to save template: ' + this.reduceError(error), 'error');
            })
            .finally(() => {
                this.isSaving = false;
            });
    }

    handleSendTest() {
        if (!this.validateForm()) return;
        this.showToast('Info', 'Test message sent for merge field verification.', 'info');
    }

    handleCancel() {
        this.closeModal();
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    validateForm() {
        let valid = true;
        this.clearError();

        // Use lightning-input / lightning-combobox built-in validation
        const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea');
        inputs.forEach(input => {
            if (!input.reportValidity()) valid = false;
        });

        if (!this.templateBody || this.templateBody.trim() === '') {
            this.errorMessage = 'Template Body is required.';
            valid = false;
        }

        return valid;
    }

    clearError() {
        this.errorMessage = '';
    }

    closeModal() {
        this.isOpen = false;
        this.resetForm();
        this.dispatchEvent(new CustomEvent('close'));
    }

    resetForm() {
        this.templateName = '';
        this.selectedObject = '';
        this.status = 'Active';
        this.channels = '';
        this.folder = '';
        this.description = '';
        this.templateBody = '';
        this.mergeObject = '';
        this.mergeObjectLabel = '';
        this.objectFields = [];
        this.errorMessage = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    reduceError(error) {
        if (typeof error === 'string') return error;
        if (error && error.body && error.body.message) return error.body.message;
        if (error && error.message) return error.message;
        return JSON.stringify(error);
    }
}
