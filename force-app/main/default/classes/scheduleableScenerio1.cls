global class scheduleableScenerio1 implements Schedulable {
           String name1;
          Integer i;
      
        global void execute(SchedulableContext sc)
                        {
                         /// scheduleableScenerio m = new scheduleableScenerio();
                        //String sch = '0 0 * * *';
                        //String jobID = system.schedule('Day 1', sch, m);
                             datetime dt = System.now()-1;
                            List<Opportunity> lstOfOpp = [select id,Name from opportunity where createdDate > :dt];
                            for(i=0;i<lstOfOpp.size();i++)
                              {
                                  Opportunity objopp=new Opportunity();
                                  name1=name1+objopp.name;
                               }
                               sendmail();}
               				public void sendmail()
						                 {
               	          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                         string [] toaddress= New string[]{'monikagarg471@gmail.com'};
                         email.setSubject('this the details of last  24 oppourunity details');
                         //email.setPlainTextBody('the oppourunity name-------'+name1+i<br>);
                          String body ='Dear ' +', '; 
                         body +='the oppourunity name-------'+name1+i;
                                 email.setHtmlBody(body);
                         email.setToAddresses(toaddress);
                         Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
                        }


}