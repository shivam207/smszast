public class StringArrayTest {
    
    
    public static List<String> generateStringArray(Integer n)
    {
        List<String>arr=new List<String>();
        for(Integer i=0;i<n;i++)
        {
            arr.add('Test'+i);
            
        }
            
        return arr;
    }
}