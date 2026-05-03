public with sharing class SMSController {

    @AuraEnabled(cacheable=true)
    public static List<SMS_Template__c> getRelatedTemplates(Id recordId) {
        // 1. Identify the SObject type from the recordId (e.g., 'Contact')
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        
        // 2. Query templates where the 'Object_Type__c' matches the current record's object
        return [SELECT Id, Name, Message_Body__c 
                FROM SMS_Template__c 
                WHERE Object_Type__c = :sObjName 
                ORDER BY Name ASC];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getSmsTemplates() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://server.shivam207.workers.dev/templates');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return (List<Object>) JSON.deserializeUntyped(response.getBody());
        }
        return new List<Object>();
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getSmsHistory() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://server.shivam207.workers.dev/history');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return (List<Object>) JSON.deserializeUntyped(response.getBody());
        }
        return new List<Object>();
    }

    @AuraEnabled
    public static String sendSMSMessage(String payloadJson) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://server.shivam207.workers.dev/send-sms');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(payloadJson);
        
        HttpResponse response = http.send(request);
        return response.getBody();
    }
}