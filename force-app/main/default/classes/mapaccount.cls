public class mapaccount {
    
    map<id,Account> mapidaccount= new map<id,Account>();
    public void mapname(){
        account acc1=new account(name='account1',type='Industry');
        account acc2=new account(name='account2',type='Agriculture');
        account acc3=new account(name='account3',type='banking');
        account acc4=new account(name='account4',type='Industry');
    
     mapidaccount.put(acc1.id, acc1);
     mapidaccount.put(acc2.id, acc2);
     mapidaccount.put(acc3.id, acc3);
     mapidaccount.put(acc4.id, acc4);
        System.debug('the value od mapaccount-----'+mapidaccount);
        set<id> mapofkeyset=mapidaccount.keySet();
        System.debug('tyhe value of keyset===='+mapofkeyset);
        
            
        
    }

}