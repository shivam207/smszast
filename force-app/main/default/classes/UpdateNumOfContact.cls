global class UpdateNumOfContact implements Database.Batchable<sObject>{
 global final String gstrQuery = 'select ID, Number_of_Contact__c from Account';

    global Database.QueryLocator start(Database.BatchableContext BC){
     return Database.getQueryLocator(gstrQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
  List<Account> listAccount = new List<Account>();
       for(SObject objSObject : scope){
      Account objAccount = (Account)objSObject;
      Integer intNumberOfContacts = [SELECT count()FROM Contact WHERE AccountID = :objAccount.ID];  
   if (intNumberOfContacts <> objAccount.Number_of_Contact__c)
   {
    objAccount.Number_of_Contact__c = intNumberOfContacts;
       listAccount.add(objAccount);
   }
       }     
       if (listAccount.size() > 0 ) 
       {update listAccount;}
    }

    global void finish(Database.BatchableContext BC){

    }
}