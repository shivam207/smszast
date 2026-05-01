global class OwnerReassignment implements Database.Batchable<sObject> 
{
    String query;
    String email;
    id  toUserId;
    id fromUserId;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {
        list<Account> lstOfAccount=new list<Account>();
        for(sObject s:scope)
        {
            Account a=(Account)s;
            if(a.OwnerId==fromUserId)
            {
                a.Ownerid=toUserId;
                lstOfAccount.add(a);
            }
        }Update lstOfAccount;
    }
            
        global void finish(Database.BatchableContext BC)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] {email});
			mail.setReplyTo('monikagarg471@gmail.com');
			mail.setSenderDisplayName('Batch Processing');
			mail.setSubject('Batch Process Completed');
			mail.setPlainTextBody('Batch Process has completed');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        }
            
            
            

}