public class invokeableLeadMethod {
    @InvocableMethod
        public static void TestProcess(list<ID> ids)
           {
            list<lead> lstOfLead=[select name from lead where id in:ids];
               for(lead objLead: lstOfLead)
               {
                   objLead.firstname='SDFC TEST';
                      
               } Upsert lstOflead;
            }

}