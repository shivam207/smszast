global class ScheduleUpdateContactPhone implements Schedulable 
{
    global void execute(SchedulableContext BC)
    {    
        list<contact> objContactList=new list<Contact>();
        map<id,Account> mapOfAccount=new map<id,Account>();
        list<Account> lstOfAccount= new list<account>();
        for(Account objAccount:lstOfAccount)
        {
            mapOfAccount.put(objAccount.id,objAccount);
        }
        Map<id, Account> accList=new Map<id, Account> ([select id, phone,(select id, phone from contacts) from account where id in:mapOfAccount.keyset()]);

       	for(account objAccount1:lstOfAccount)
		{
   			 list<contact> lstOfContact=accList.get(objAccount1.id).contacts;
    			for(contact objContact:lstOfContact)
    				{
       				 objContact.Phone=objAccount1.phone;
        			  objContactList.add(objContact);
   				     }
		}
					Update objContactLIst;
        
    }

}