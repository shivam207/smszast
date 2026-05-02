public with sharing class SMSTemplateController {

    /**
     * Returns a list of all createable, non-custom-setting SObjects
     * visible to the current user, formatted as { label, value } pairs.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getAvailableObjects() {
        List<Map<String,String>> result = new List<Map<String,String>>();

        for (Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult describe = objType.getDescribe();
            // Filter: queryable, not deprecated, not a custom setting
            if (describe.isQueryable()
                && describe.isCreateable()
                && !describe.isCustomSetting()
                && describe.getRecordTypeInfos() != null) {

                Map<String,String> entry = new Map<String,String>();
                entry.put('label', describe.getLabel());
                entry.put('value', describe.getName());
                result.add(entry);
            }
        }

        // Sort by label
        result.sort(new ObjectLabelComparator());
        return result;
    }

    /**
     * Returns fields for a given object API name as { label, value, hasChildren } maps.
     * hasChildren = true for reference (lookup) fields.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>> getObjectFields(String objectApiName) {
        List<Map<String,Object>> result = new List<Map<String,Object>>();

        if (String.isBlank(objectApiName)) return result;

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        if (objType == null) return result;

        Map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
            if (!field.isAccessible()) continue;

            Map<String,Object> entry = new Map<String,Object>();
            entry.put('label', field.getLabel());
            entry.put('value', field.getName());
            entry.put('hasChildren',
                field.getType() == Schema.DisplayType.REFERENCE);
            result.add(entry);
        }

        result.sort(new FieldLabelComparator());
        return result;
    }

    /**
     * Returns existing SMS_Folder__c records as { label, value } pairs,
     * where value is the record Id.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getAvailableFolders() {
        List<Map<String,String>> result = new List<Map<String,String>>();

        for (SMS_Folder__c f : [
            SELECT Id, Name
            FROM SMS_Folder__c
            WITH USER_MODE
            ORDER BY Name ASC
            LIMIT 1000
        ]) {
            Map<String,String> entry = new Map<String,String>();
            entry.put('label', f.Name);
            entry.put('value', f.Id);
            result.add(entry);
        }

        return result;
    }

    /**
     * Creates a new SMS_Folder__c record and returns it as a { label, value }
     * map, where value is the new record Id.
     */
    @AuraEnabled
    public static Map<String,String> createFolder(String folderName) {
        if (String.isBlank(folderName)) {
            throw new AuraHandledException('Folder name is required.');
        }

        SMS_Folder__c folder = new SMS_Folder__c(Name = folderName.trim());
        insert folder;

        Map<String,String> result = new Map<String,String>();
        result.put('label', folder.Name);
        result.put('value', folder.Id);
        return result;
    }

    /**
     * Persists a new SMS Template record from a JSON payload.
     * Expected JSON keys: name, objectApiName, status, channels, folder, description, body
     */
    @AuraEnabled
    public static Id saveTemplate(String templateJson) {
        Map<String,Object> payload =
            (Map<String,Object>) JSON.deserializeUntyped(templateJson);

        SMS_Template__c tmpl = new SMS_Template__c();
        tmpl.Name                = (String) payload.get('name');
        tmpl.Object_Type__c      = (String) payload.get('objectApiName');
        tmpl.Message_Body__c     = (String) payload.get('body');

        // Optional fields — add custom fields to SMS_Template__c as needed
        if (payload.containsKey('description') && payload.get('description') != null) {
            // tmpl.Description__c = (String) payload.get('description');
        }
        if (payload.containsKey('channels') && payload.get('channels') != null) {
            // tmpl.Channels__c = (String) payload.get('channels');
        }
        if (payload.containsKey('folder') && payload.get('folder') != null) {
            // tmpl.Folder__c = (String) payload.get('folder');
        }

        insert tmpl;
        return tmpl.Id;
    }

    // ── Comparators ───────────────────────────────────────────────────────────

    private class ObjectLabelComparator implements Comparator<Map<String,String>> {
        public Integer compare(Map<String,String> a, Map<String,String> b) {
            return a.get('label').compareTo(b.get('label'));
        }
    }

    private class FieldLabelComparator implements Comparator<Map<String,Object>> {
        public Integer compare(Map<String,Object> a, Map<String,Object> b) {
            return ((String)a.get('label')).compareTo((String)b.get('label'));
        }
    }
}
