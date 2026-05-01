global class UpdateAccountDaily implements Schedulable {
    global void execute(SchedulableContext SC)
    {
        list<Account> lstOfAccount=[Select id,Name,Description from Account];
        for(Account objAccount:lstOfAccount)
        {
            objAccount.Description=objAccount.name+objAccount.OwnerId;
            
        }
    }

}