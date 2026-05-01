public class Product {
    
    public static void four()
    {
     
        For(Integer i=0; i<10; i++)
        {
            Product2 objPro = new Product2();
            objPro.Name = 'Product'+ i;
            objPro.numberOfFlowers__c = 1+i;
            objPro.percentOfOpening__c =4+i;
           Insert objPro;
        }
        
        
    }
}