/**
 * Created by junliu on 1/10/23.
 *
 * Test Class: Task2ControllerTest
 */

public with sharing class Task2Controller {

    @AuraEnabled
    public static List<APIData> callAPIAndUpdateContact() {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        //API callout using named credential endpoint
        req.setEndpoint('Callout:Task_2_endpoint');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        HttpResponse resp = h.send(req);
        APIData apiData = (APIData) JSON.deserialize(resp.getBody(), APIData.class);
        List<Contact> contacts = [SELECT Name FROM Contact where FirstName =: apiData.firstName and LastName = : apiData.lastName WITH SECURITY_ENFORCED];
        if (contacts.size() == 0) {
            Contact newContact = new Contact(FirstName=APIData.firstName, LastName=APIData.lastName, Email=APIData.email, Date_of_Birth__c = APIData.dateOfBirth);
            insert newContact;
        }else{
            contacts[0].FirstName=APIData.firstName;
            contacts[0].LastName=APIData.lastName;
            contacts[0].Email=APIData.email;
            contacts[0].Date_of_Birth__c = APIData.dateOfBirth;
            update contacts;
        }
        return new List<APIData>{
                apiData
        };
    }
}