declare module "@salesforce/apex/SMSTemplateController.getAvailableObjects" {
  export default function getAvailableObjects(): Promise<any>;
}
declare module "@salesforce/apex/SMSTemplateController.getObjectFields" {
  export default function getObjectFields(param: {objectApiName: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSTemplateController.getAvailableFolders" {
  export default function getAvailableFolders(): Promise<any>;
}
declare module "@salesforce/apex/SMSTemplateController.createFolder" {
  export default function createFolder(param: {folderName: any}): Promise<any>;
}
declare module "@salesforce/apex/SMSTemplateController.saveTemplate" {
  export default function saveTemplate(param: {templateJson: any}): Promise<any>;
}
