public class insertContactController {
    public contact objCon {get;set;}
	
    public insertContactController(){
        objCon = new contact();        
    }    
    
    public void onSave(){
        insert objCon;
    }
}