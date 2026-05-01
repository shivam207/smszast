public class thirdquestion 
{
    Public static void third()
    {
        set <Account> ObjAccount = new set <Account>();
        for(Integer i=0; i<5; i++)
        {
             Account objAcc = new Account();
             objAcc.Name = 'Mona'+ i;
             Insert objAcc;
             id accid = objAcc.Id;
            list <Contact> lstOfContact =new  list <Contact>();
        For( Integer j=0;j<5;j++)
        {
            Contact objCon = new Contact();
            objCon.LastName = 'MonikaLAst'+ i;
            objCon.AccountId = accid;
            lstOfContact.add(objCon);
        }
        Insert lstOfContact;
            
            
        }
    }

}