public class contactRelationship 
{
    public static void ConRel()
    {
        list<Contact_Relationship__c> ConList= new list <Contact_Relationship__c>();
        list<Contact> lstCon = [Select id,Name,Contact_Relationship__c	 from contact];
        for(Contact newCon:lstCon)
        {
            if(newCon.Contact_Relationship__c==true)
            {
                
                Contact_Relationship__c NewConRel=new Contact_Relationship__c();
                NewConRel.Name = newCon.Name;
                  NewConRel.Contact__c	 = newCon.id;
                ConList.add(NewConRel);    
            }
            
        }
        Insert ConList;
            
           

        
    }
}