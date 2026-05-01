import { LightningElement, api, wire, track } from 'lwc';
import getRelatedTemplates from '@salesforce/apex/SMSController.getRelatedTemplates';

export default class SmsInterface extends LightningElement {
    @api recordId;
    @track messageValue = '';
    @track templateData = []; // To store raw templates from Apex
    
    // Mock data for display
    @track messages = [
        { id: 1, text: 'sms from report normal message', time: '06:01 PM', cssClass: 'msg-outbound' }
    ];

    characterCount = 0;
    segmentCount = 1;

    // Fetch templates and store them
    @wire(getRelatedTemplates, { recordId: '$recordId' })
    wiredTemplates({ error, data }) {
        if (data) {
            this.templateData = data;
        } else if (error) {
            console.error('Error fetching templates', error);
        }
    }

    // Convert templates into options for the combobox
    get templateOptions() {
        return this.templateData.map(temp => ({
            label: temp.Name,
            value: temp.Id
        }));
    }

    // Handle template selection
    handleTemplateChange(event) {
        const selectedId = event.detail.value;
        const selectedTemplate = this.templateData.find(t => t.Id === selectedId);
        
        if (selectedTemplate) {
            this.messageValue = selectedTemplate.Message_Body__c;
            this.updateCounters();
        }
    }

    // Handle manual typing
    handleInputChange(event) {
        this.messageValue = event.target.value;
        this.updateCounters();
    }

    updateCounters() {
        this.characterCount = this.messageValue.length;
        this.segmentCount = Math.ceil(this.characterCount / 160) || 1;
    }

    handleSend() {
        // Logic to create a record or call an SMS API goes here
        console.log('Sending message:', this.messageValue);
        this.messageValue = '';
        this.updateCounters();
    }
}