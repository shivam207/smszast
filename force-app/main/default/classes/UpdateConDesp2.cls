global class UpdateConDesp2 implements Database.Batchable<sObject>,Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query='select Name,Description from contact';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Contact> lstOfContact)
    {
        for(Contact objContact:lstOfContact)
        {
             objContact.Description=objContact.Name;
          
        }
        Update lstOfContact;
    }
    global void finish(Database.BatchableContext BC){}

}