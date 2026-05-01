public class attachment {
 public static void Attach()
  {
     list<Contact> lstOfContact = new list<Contact>();
     set<id> accid = new set<id>();
      for(Contact acc: lstOfContact)
      {
          accid.add(acc.Accountid);
      }
      list<Account> lstOfAccount=[Select id,Accounter__c,name,(Select id ,accountId,name from Contacts) from account where id in:accid];
      for(Account a :lstOfAccount)
      {
     list <aggregateresult> ar = [select count(Id)aver from attachment where id in : accid ];
       
           Decimal decimalRevenue = 0 ;
               if(ar.size() > 0)
                  {
                String str = '' + ar[0].get('aver') ;
                decimalRevenue = Decimal.ValueOf(str) ;
                a.Accounter__c=decimalRevenue;
                System.debug('========='+a);  
                  }
      }
      
  }

}