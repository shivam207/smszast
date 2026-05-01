global class ScheduleUpdateNumOfContact implements Schedulable 
{
     global void execute(SchedulableContext BC){
  List<Account> listAccount = [select ID, Number_of_Contact__c from Account];
         List<sObject> scope=new list<sObject>();
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

}