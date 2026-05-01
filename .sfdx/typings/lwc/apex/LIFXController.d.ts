declare module "@salesforce/apex/LIFXController.getLights" {
  export default function getLights(): Promise<any>;
}
declare module "@salesforce/apex/LIFXController.setPower" {
  export default function setPower(param: {lightId: any, isOn: any}): Promise<any>;
}
declare module "@salesforce/apex/LIFXController.setBrightness" {
  export default function setBrightness(param: {lightId: any, brightness: any}): Promise<any>;
}
