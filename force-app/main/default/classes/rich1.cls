public class rich1 {
public Contact conObj{set;get;}

public rich1(){
conObj = new Contact();
}
Public void createContact(){
    try{
        if(conObj !=null){
            insert conObj;
        }
        }
        catch(Exception e){
            System.debug(e);
        }

}}