public class SearchBox {
    public list <Account> acc {get;set;}
    public String searchKey {get;set;}
    public Id AccountId {get;set;}
    public SearchBox( ) {
    }
    public void search()
    {
        string searchquery='select Name,id,AnnualRevenue,rating,Industry,Phone,BillingStreet,BillingCity,BillingState,BillingPostalCode, BillingCountry, BillingLatitude,BillingLongitude,AccountNumber from account where name like \'%'+searchKey+'%\' Limit 10';
        acc= Database.query(searchquery);
   
            }
    
}