import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableObjects from '@salesforce/apex/SMSTemplateController.getAvailableObjects';
import getObjectFields from '@salesforce/apex/SMSTemplateController.getObjectFields';
import getAvailableFolders from '@salesforce/apex/SMSTemplateController.getAvailableFolders';
import createFolder from '@salesforce/apex/SMSTemplateController.createFolder';
import saveTemplate from '@salesforce/apex/SMSTemplateController.saveTemplate';

const STATUS_OPTIONS = [
    { label: 'Active', value: 'Active' },
    { label: 'Inactive', value: 'Inactive' }
];

const ADD_NEW_FOLDER_VALUE = '__add_new_folder__';

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

    @track folderOptions = [];
    @track isCreatingFolder = false;
    @track newFolderName = '';
    @track isSavingFolder = false;

    @track isMergeFieldExpanded = true;
    @track isTemplateBodyExpanded = true;

    @track errorMessage = '';
    @track isSaving = false;

    statusOptions = STATUS_OPTIONS;

    get folderOptionsWithAdd() {
        return [
            { label: '+ Add New Folder', value: ADD_NEW_FOLDER_VALUE },
            ...this.folderOptions
        ];
    }

    connectedCallback() {
        this.loadObjects();
        this.loadFolders();
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

    loadFolders() {
        getAvailableFolders()
            .then(result => {
                this.folderOptions = (result || []).map(f => ({
                    label: f.label,
                    value: f.value
                }));
            })
            .catch(error => {
                this.showToast('Error', 'Failed to load folders: ' + this.reduceError(error), 'error');
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
        const value = event.detail.value;
        if (value === ADD_NEW_FOLDER_VALUE) {
            // Reset the combobox so it doesn't visually stick on the sentinel option.
            const combo = this.template.querySelector('lightning-combobox.folder-input');
            if (combo) combo.value = this.folder;
            this.newFolderName = '';
            this.isCreatingFolder = true;
            return;
        }
        this.folder = value;
    }

    handleNewFolderNameChange(event) {
        this.newFolderName = event.target.value;
    }

    handleCancelNewFolder() {
        this.isCreatingFolder = false;
        this.newFolderName = '';
    }

    handleSaveNewFolder() {
        const name = (this.newFolderName || '').trim();
        if (!name) {
            this.showToast('Error', 'Folder name is required.', 'error');
            return;
        }

        this.isSavingFolder = true;
        createFolder({ folderName: name })
            .then(result => {
                this.folderOptions = [
                    ...this.folderOptions,
                    { label: result.label, value: result.value }
                ].sort((a, b) => a.label.localeCompare(b.label));
                this.folder = result.value;
                this.isCreatingFolder = false;
                this.newFolderName = '';
                this.showToast('Success', 'Folder created.', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Failed to create folder: ' + this.reduceError(error), 'error');
            })
            .finally(() => {
                this.isSavingFolder = false;
            });
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
        this.isCreatingFolder = false;
        this.newFolderName = '';
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
