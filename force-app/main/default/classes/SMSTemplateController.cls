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

            Boolean isRef = (field.getType() == Schema.DisplayType.REFERENCE);

            Map<String,Object> entry = new Map<String,Object>();
            entry.put('label', field.getLabel());
            entry.put('value', field.getName());
            entry.put('hasChildren', isRef);

            if (isRef) {
                String relName = field.getRelationshipName();
                if (relName != null) entry.put('relationshipName', relName);
                List<Schema.SObjectType> refs = field.getReferenceTo();
                if (refs != null && !refs.isEmpty()) {
                    entry.put('referenceTo', refs[0].getDescribe().getName());
                }
            }

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
     * Returns recent records of the given object (Id + display name) so the
     * preview UI can show a list without requiring the user to search first.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getRecentRecords(String objectApiName, Integer maxResults) {
        List<Map<String,String>> result = new List<Map<String,String>>();
        if (String.isBlank(objectApiName)) return result;

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        if (objType == null) return result;

        // Resolve the object's "name" field (Subject for Task, CaseNumber for Case, etc.)
        String nameField = 'Id';
        for (Schema.SObjectField f : objType.getDescribe().fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if (dfr.isNameField()) {
                nameField = dfr.getName();
                break;
            }
        }

        Integer lim = (maxResults == null || maxResults <= 0) ? 10 : maxResults;
        String soql = 'SELECT Id, ' + nameField + ' FROM ' + objectApiName
            + ' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT ' + lim;

        for (SObject rec : Database.query(soql)) {
            Map<String,String> m = new Map<String,String>();
            m.put('id', (String)((Id) rec.get('Id')));
            Object n = rec.get(nameField);
            m.put('name', n == null ? (String)((Id) rec.get('Id')) : String.valueOf(n));
            result.add(m);
        }
        return result;
    }

    /**
     * Renders an SMS template body for a given test record by replacing
     * merge tags (e.g. {!Account.Name}, {!Account.Owner.Email}) with values
     * from the record. Uses dynamic SOQL with relationship traversal.
     */
    @AuraEnabled
    public static String previewTemplate(String objectApiName, Id recordId, String body) {
        if (String.isBlank(objectApiName) || recordId == null || String.isBlank(body)) {
            return body;
        }

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        if (objType == null) {
            throw new AuraHandledException('Unknown object: ' + objectApiName);
        }

        // Map of full tag (e.g. "{!Account.Name}") -> SOQL path ("Name", "Owner.Email")
        Map<String, String> tagToPath = new Map<String, String>();
        Pattern p = Pattern.compile('\\{!([A-Za-z_][A-Za-z0-9_\\.]*)\\}');
        Matcher m = p.matcher(body);
        while (m.find()) {
            String tag = m.group(0);
            String tagBody = m.group(1);
            List<String> parts = tagBody.split('\\.');
            if (parts.size() < 2) continue;
            // The first segment must be the merge object; strip it.
            if (parts[0] != objectApiName) continue;
            List<String> rest = new List<String>();
            for (Integer i = 1; i < parts.size(); i++) rest.add(parts[i]);
            tagToPath.put(tag, String.join(rest, '.'));
        }

        if (tagToPath.isEmpty()) return body;

        Set<String> uniquePaths = new Set<String>(tagToPath.values());
        String soql = 'SELECT ' + String.join(new List<String>(uniquePaths), ', ')
            + ' FROM ' + objectApiName
            + ' WHERE Id = :recordId LIMIT 1';

        List<SObject> records;
        try {
            records = Database.query(soql);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to load record: ' + e.getMessage());
        }
        if (records.isEmpty()) {
            throw new AuraHandledException('Record not found.');
        }
        SObject record = records[0];

        String merged = body;
        for (String tag : tagToPath.keySet()) {
            Object val = traverseField(record, tagToPath.get(tag));
            merged = merged.replace(tag, val == null ? '' : String.valueOf(val));
        }
        return merged;
    }

    private static Object traverseField(SObject record, String path) {
        List<String> parts = path.split('\\.');
        SObject cur = record;
        for (Integer i = 0; i < parts.size() - 1; i++) {
            if (cur == null) return null;
            cur = cur.getSObject(parts[i]);
        }
        if (cur == null) return null;
        return cur.get(parts[parts.size() - 1]);
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
