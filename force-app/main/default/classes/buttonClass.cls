public class buttonClass 
{
  public list<Account> lstAcc {get;set;}
    public Integer AccIndex{set;get;}
    public Integer AccIndex1{set;get;}
    public buttonClass()
{
lstAcc=[Select id,Name,BillingAddress,AnnualRevenue,Phone,Industry,Rating from account];
}
     public void Accountdelete()
     {
         if(AccIndex!=Null && AccIndex >= 0)
         {
         Account obj = lstAcc[AccIndex];
         delete obj;
         }
        lstAcc=[Select id,Name,BillingAddress,AnnualRevenue,Phone,Industry,Rating from account];
     }
public void Accountedit()
     {
         if(AccIndex1!=Null && AccIndex1>= 0)
         {
         Account obj = lstAcc[AccIndex1];
         update obj;
         }
        lstAcc=[Select id,Name,BillingAddress,AnnualRevenue,Phone,Industry,Rating from account];
     }

}