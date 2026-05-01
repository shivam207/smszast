public class SurveyClass
{
    public  lead objlead {get;set;}
    public SurveyClass()
    {
        objlead=new lead();
    }
    public void submit()
    { 
    list<lead> lstOfLead=[select id,name,email from lead];
    list<string> Names=new list<string>();
   // list<string> listOfRecord=new list<string>();
    for(lead leadVar:lstOfLead)
    {
      Names.add(leadVar.name);
      Names.add(leadVar.email);
    }
      list<lead> listOfDuplicate=[select id,name,email from lead where email in :Names];
           if(listOfDuplicate.size() > 0)
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'duplicate email value exist'));
        }
        else
        {
        insert objlead;
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] sendingTo=new String[]{'monikagarg471@gmail.com'};
        email.settoAddresses(sendingTo);
        email.setSubject('Create New Lead');
        email.setPlainTextBody('Welcome Dear');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    
    
    
    
}