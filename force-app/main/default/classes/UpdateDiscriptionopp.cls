global class  UpdateDiscriptionopp  implements Database.Batchable<sObject>,Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query='select Name, Description, CreatedDate,Owner.Name from Opportunity';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,list<Opportunity> lstOfopp)
    {
        for(Opportunity objOpportunity:lstOfopp)
        {
          objOpportunity.Description=String.valueOf(objOpportunity.Owner.Name ) + String.valueOf(objOpportunity.CreatedDate);    
        }
        Update lstOfopp;
    }
    global void finish(Database.BatchableContext BC){
        
    }

}