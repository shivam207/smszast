@isTest
public class UpdateAccountRatingTest {
    public static TestMethod void Method3(){
        try{
        System.Test.startTest();
        Opportunity opp=new Opportunity();
        opp.StageName = 'Closed Won';
        opp.name='mona';
        Account acc=new Account();
        acc.Rating='warm';
         acc.name='mona';
          insert acc;
            
          Opportunity oppp=new Opportunity();
        oppp.StageName = 'closed won';
        oppp.name='mona';
        Account accc=new Account();
        accc.Rating='hot';
         accc.name='mona';
          update accc;
        System.test.stopTest();
        }
        catch(Exception e){
           
        }
    }
}