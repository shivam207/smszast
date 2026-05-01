public class practice {
    public static void Prac(){
      //  Account objAccount = new Account();
     //  objAccount.Name = 'ABC Customer';
            // objAccount.Description = 'Test Account';
            // objAccount.First_Name__c='Monika';
             //objAccount.Last_Name__c='Garg';
            // System.debug('objAccount variable value'+objAccount);
     //   Insert objAccount;
       /* list<Contact> objCon= new list<Contact>
        {
        new Contact(FirstName='Joe',LastName='Smith',Department='Finance'),
        new Contact(FirstName='Kathy',LastName='Smith',Department='Technology'),
        new Contact(FirstName='Caroline',LastName='Roth',Department='Finance'),
        new Contact(FirstName='Kim',LastName='Shain',Department='Education')
         };
         insert objCon;
        list<Contact> UpCon= new List<Contact>();
        for(Contact con: objcon)
        {
            if(con.Department=='Finance')
            {
                con.Title='Yes,You Updated the Title Field';
            }
            UpCon.add(con);
        }
Update UpCon;*/
        
           /*  Account objAccount = new Account();
            objAccount.Name = 'Ms Monika Garg';
            objAccount.Description = 'Add Contact To This Account';
             objAccount.First_Name__c='Monika';
             objAccount.Last_Name__c='Garg';
              Insert objAccount;
        
        id Accid = objAccount.Id;
        Contact AddCon= new Contact(
       FirstName='Mario',
       LastName='Ruiz',
       Phone='415.555.1212',
       AccountId = Accid);
        Insert AddCon;*/
        
        Contact ObjCon=[Select Account.Name from Contact where FirstName='Mario'AND LastName='Ruiz' Limit 1];
        ObjCon.Phone='1234567898';
        ObjCon.Account.Industry='Technology';
        Update objCon; 
        Update ObjCon.Account;
        
        
        
    }
}