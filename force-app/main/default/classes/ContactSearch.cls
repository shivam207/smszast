public class ContactSearch{
    public static List<Contact>searchForContacts(String lastName,String mailingPostalCode){
        List<Contact> contactList=[SELECT Id,FirstName,LastName,MailingPostalCode FROM Contact WHERE LastName=:lastName AND MailingPostalCode=:mailingPostalCode];
            return contactList;
            }
}