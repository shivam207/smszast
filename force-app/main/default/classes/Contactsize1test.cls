@istest
public class Contactsize1test {
    public static TestMethod void method1()
    {
        try{
      set<id>acc1=new set<id>();
            list<Contact> lstOfContact=new list<Contact>();
            for(Integer i=0;i<100;i++){
        Contact con = new Contact();
        con.LastName ='test1';
        con.AccountId = 'monikafinal';
                lstOfContact.add(con);
        }
           Test.startTest();
        insert lstOfContact;
          Test.stopTest();
             Account Ac = new Account();
        Ac.AccountNumber=String.valueOf(lstOfContact);
              Test.startTest();
        insert ac;
        Test.stopTest();
        }
        catch(exception e)
        {    System.debug('Error Message.....'+e.getMessage());}
    }

}