global class UpdateaccountBillingCity implements Database.Batchable<sObject>,Database.Stateful{
    global database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getqueryLocator('Select id,BillingState,BillingCountry from account where BillingCountry=\'USA\'AND BillingState =\'\'');
        
    }
    global void execute(Database.BatchableContext BC, list<Account> scope)
    {
        list<account> lstOfAccount=new list<Account>();
        for(Account objacc:scope)
        {
            objacc.BillingState = 'California';
                lstOfAccount.add(objacc);
        }
        update lstOfAccount;
        }
    global  void finish(Database.BatchableContext BC){
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