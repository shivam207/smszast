public class AccountCreation {

    Public Static void AccountCreate()
    {
       
        
            Account objAccount = new Account();
           
           objAccount.Name = 'Mona';
           objAccount.Phone = '9787878787';
          
          Insert objAccount;
        id accid = objAccount.id;
         list <Contact> lstOfContact =new  list <Contact>();
        For( Integer i=1;i<=3;i++)
        {
            Contact objCon = new Contact();
            objCon.LastName = 'MonikaLAst'+ i;
            objCon.AccountId = accid;
            objCon.Phone = '9838838838'+ i; 
            lstOfContact.add(objCon);
        }
        Insert lstOfContact;
        
    }
        
}