global class BatchAccountNameUpdate implements Database.Batchable<sObject>,Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query='Select id,name from account';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Account> lstOfAccount)
    {
        for(Account objacc:lstOfAccount)
        {
         objacc.name=objacc.name+'Updated';   
        }
        Update lstOfAccount;
    }
    global  void finish(Database.BatchableContext BC){
        
    }

}