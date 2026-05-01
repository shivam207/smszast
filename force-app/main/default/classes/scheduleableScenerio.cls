global class scheduleableScenerio implements Schedulable {
    
      datetime dt = System.now()-1;
      List<Opportunity> ops = [select id,Name from opportunity where createdDate > :dt];
        global void execute(SchedulableContext sc)
                        {
                          scheduleableScenerio m = new scheduleableScenerio();
                        String sch = '0 0 * * *';
                         String jobID = system.schedule('Day 1', sch, m);

                          sendmail();
                        }
               public void sendmail()
                 {
                         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                         string [] toaddress= New string[]{'monikagarg471@gmail.com'};
                         email.setSubject('this the details of last  24 oppourunity details');
                         email.setPlainTextBody('ops.Name');
                         email.setToAddresses(toaddress);
                         Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
                        }


}