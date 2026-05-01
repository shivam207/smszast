global class DeleteAcccountRecord  implements Database.Batchable<sObject>,Database.Stateful
   {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query='Select Number_of_Contact__c,Name from Account';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Account> lstOfAccount)
    {
        integer count1;
        list<Account> finallstOfAccount=new list<Account>();
        for(Account objAccount: lstOfAccount)
        {
            if(objAccount.Number_of_Contact__c<2)
                finallstOfAccount.add(objAccount);
            System.debug('the delete contact are-----'+finallstOfAccount);
                //count1=count(objAccount.Number_of_Contact__c);
        }
        delete finallstOfAccount;
    }
    global void finish(Database.BatchableContext BC)
    {}
}