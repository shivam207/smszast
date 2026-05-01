import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import sendSMSMessage from '@salesforce/apex/SMSController.sendSMSMessage';
import getSmsTemplates from '@salesforce/apex/SMSController.getSmsTemplates';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SendSms extends LightningElement {
    @api recordId; // Automatically populated by the Aura wrapper

    @track messageBody = '';
    @track title = '';
    @track saveAsTemplate = false;
    @track templates = [];
    @track record;
    @track phone = '';
    @track name = '';

    // Recipients list
    @track selectedRecipients = [];

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.record = data;
            console.log('Record Data:', JSON.stringify(data.fields));

            // Try to get Name, falling back to FirstName/LastName or other common fields
            const firstName = data.fields.FirstName ? data.fields.FirstName.value : '';
            const lastName = data.fields.LastName ? data.fields.LastName.value : '';
            const combinedName = (firstName + ' ' + lastName).trim();

            this.name = combinedName || (data.fields.Name ? data.fields.Name.value :
                (data.fields.Subject ? data.fields.Subject.value :
                    (data.fields.CaseNumber ? data.fields.CaseNumber.value : 'Unknown')));

            this.phone = data.fields.MobilePhone ? data.fields.MobilePhone.value :
                (data.fields.Phone ? data.fields.Phone.value : '');

            this.selectedRecipients = [
                {
                    label: this.name,
                    name: 'recipient_1',
                    type: 'icon',
                    fallbackIconName: 'standard:user',
                    variant: 'circle',
                    phone: this.phone
                }
            ];
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }

    @wire(getSmsTemplates)
    wiredTemplates({ error, data }) {
        if (data) {
            this.templates = data;
        } else if (error) {
            console.error('Error fetching templates:', error);
        }
    }

    get templateOptions() {
        return this.templates.map(temp => {
            return { label: temp.name || temp.title, value: temp.id || temp.name };
        });
    }

    handleRemovePill(event) {
        const index = event.detail.index;
        this.selectedRecipients.splice(index, 1);
    }

    handleTemplateChange(event) {
        const selectedValue = event.detail.value;
        const selectedTemplate = this.templates.find(temp => (temp.id || temp.name) === selectedValue);

        if (selectedTemplate) {
            let body = selectedTemplate.body || selectedTemplate.message || '';

            // Basic Merge Field Replacement
            if (this.record && this.record.fields) {
                Object.keys(this.record.fields).forEach(fieldName => {
                    const fieldValue = this.record.fields[fieldName].value || '';
                    const placeholder = `{${fieldName}}`;
                    body = body.replace(new RegExp(placeholder, 'g'), fieldValue);
                });
            }

            this.messageBody = body;
            this.title = selectedTemplate.name || selectedTemplate.title || '';
        }
    }

    handleTitleChange(event) {
        this.title = event.target.value;
    }

    handleMessageChange(event) {
        this.messageBody = event.target.value;
    }

    handleSaveTemplateChange(event) {
        this.saveAsTemplate = event.target.checked;
    }

    async handleSendMessage() {
        console.log('Sending message:', this.messageBody);
        console.log('Record ID:', this.recordId);
        console.log("Name", this.name, "Phone", this.phone)
        console.log(this.selectedRecipients)

        const payload = {
            recipients: this.selectedRecipients.map(r => ({ name: r.label, phone: r.phone })),
            message: this.messageBody,
            title: this.title,
            saveTemplate: this.saveAsTemplate,
            recordId: this.recordId
        };

        try {
            const result = await sendSMSMessage({ payloadJson: JSON.stringify(payload) });
            console.log("Message Sent successfully:", result);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'SMS sent successfully via Hono API',
                    variant: 'success'
                })
            );

            this.handleCancel(); // Close modal
        } catch (error) {
            console.error('Error sending message:', error);

            let errorMessage = 'Unknown error';
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error && error.message) {
                errorMessage = error.message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        }
    }

    handleCancel() {
        // Logic to close the modal
        this.dispatchEvent(new CloseActionScreenEvent());
        // Also dispatch custom event for backward compatibility or if used in other wrappers
        this.dispatchEvent(new CustomEvent('close'));
    }
}