global class UpdateAccountBatch implements Database.Batchable<sObject>,Database.Stateful
{
   global database.QueryLocator start(Database.BatchableContext BC)
   {
       String query='Select id,name,BatchExcecute__c from Account';
       return Database.getQueryLocator(query);
   }
    global void execute(Database.BatchableContext Bc,list<Account> lstOfAccount)
    {
        for(Account objAccount:lstOfAccount)
        {
            if(objAccount.BatchExcecute__c==false)
            {
                objAccount.BatchExcecute__c=true;
            }
            Update lstOfAccount;
         }
    }
    global  void finish(Database.BatchableContext BC)
    {
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] email = new String[]{'monikagarg471@gmail.com'};
             mail.setToAddresses(email);
			mail.setReplyTo('monikagarg471@gmail.com');
			mail.setSenderDisplayName('Batch Processing');
			mail.setSubject('Batch Process Completed');
			mail.setPlainTextBody('Batch Process has completed');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}