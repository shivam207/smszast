declare module "@salesforce/apex/EinsteinVisionController.predict" {
  export default function predict(param: {fileName: any, content: any, modelId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.predictReal" {
  export default function predictReal(param: {fileName: any, content: any, modelId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.predictDemo" {
  export default function predictDemo(param: {fileName: any, content: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.getDatasets" {
  export default function getDatasets(): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.getModelsByDataset" {
  export default function getModelsByDataset(param: {datasetId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.deleteDataset" {
  export default function deleteDataset(param: {datasetId: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.createDataset" {
  export default function createDataset(param: {pathToZip: any}): Promise<any>;
}
declare module "@salesforce/apex/EinsteinVisionController.trainModel" {
  export default function trainModel(param: {modelName: any, datasetId: any}): Promise<any>;
}
