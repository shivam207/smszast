public class preventduplicate 
{
    public static void Duplicate()
    {
       Account objAcc= new Account();
        objAcc.Name='Add 5 Contact Name';
       
          objAcc.Phone='6397193633';
        Insert objAcc;
        
        id accid= objacc.id;
        
       list<Contact> addlist =new list<Contact>();
        for(integer i=0;i<5;i++)
        {
                    Contact objCon=new Contact();

          objCon.LastName='Contact'+i;
            objCon.AccountId = accid;
            
            addlist.add(objCon);
        }
        Insert addlist;
        
    }
    
}