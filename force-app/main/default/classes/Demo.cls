public class Demo {
    String s;
    Integer i;
    Boolean Objboolean=NULL;
    public Demo(){
        this.s='hii';
        this.i=i;
    }
    public Demo(String s,Integer i){
        this.s=s;
        this.i=i;
    }
    public static void sayHello(){
        String say='Hello World';
     //  s='hii';
        System.debug(say);
    }
    public set<String> findDomainSet(List<String> lstofEmails){
        System.debug('listofemails--------,'+lstofEmails);
        set<String> setOfDomains=new set<String>();
        for(String strEmail:lstofEmails){
            System.debug(' strEmail--------'+ strEmail);
            String Domain=strEmail.substringAfter('@');
           setOfDomains.add(Domain);
        }
        return setOfDomains;
    }
    
    
    


}