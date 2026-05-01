declare module "@salesforce/apex/SMSController.getRelatedTemplates" {
  export default function getRelatedTemplates(param: {recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSController.getSmsTemplates" {
  export default function getSmsTemplates(): Promise<any>;
}
declare module "@salesforce/apex/SMSController.getSmsHistory" {
  export default function getSmsHistory(): Promise<any>;
}
declare module "@salesforce/apex/SMSController.sendSMSMessage" {
  export default function sendSMSMessage(param: {payloadJson: any}): Promise<any>;
}
