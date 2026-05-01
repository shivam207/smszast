public class listOfAccount {
public String IndustryStatus {get;set;}
public list<Account> lstAcc {get;set;}
  public String rId{get;set;}


// public list<Contact> lstCon {get;set;}
public listOfAccount()
{
lstAcc=[Select id,Name,BillingAddress,AnnualRevenue,Phone,Industry,Rating,(select Id,lastname,phone from contacts ),(select id,Name,CloseDate from Opportunities) from account];
}
public void save()
{
if(String.isNotBlank( IndustryStatus))
lstAcc=[Select id,Name,BillingAddress,AnnualRevenue,Phone,Industry,Rating,(select Id,lastname,phone from contacts ) ,(select id,Name,CloseDate from Opportunities) from account where Industry=: IndustryStatus];
}
    public pageReference switch()
    {
        PageReference pageRef = new PageReference('https://ap15.lightning.force.com/lightning/r/Contact/Id/view');
        pageRef.setRedirect(true);
        return pageRef;
    }  
      
}