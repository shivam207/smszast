@isTest

public class insertNumOfempTest{
    
    public static TestMethod void  method1(){
        Test.startTest();
        Account ac = new Account();
        ac.Name = 'test';
        ac.NumberOfEmployees = 2;
        insert ac;
	Contact con = new contact();
	con.lastName = 'test';
	con.accountId = ac.Id;
	insert con;
        Test.stopTest();
    }
}