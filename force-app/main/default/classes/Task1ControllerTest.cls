/**
 * Created by junliu on 1/11/23.
 */

@IsTest
private class Task1ControllerTest {
    @IsTest
    static void testContactsUpload() {

        String concantenatedStr = 'FirstName,LastName,Email\n' +
                'Liz,D\'Cruz,ldcruz@uog.com\n' +
                'Edna,Frank,efrank@genepoint.com\n' +
                'Avi,Green,agreen@uog.com\n' +
                'Siddartha,Nedaerk,""\n' +
                'Jake,Llorrac,""\n' +
                'Rose,Gonzalez,rose@edge.com\n' +
                'Sean,Forbes,sean@edge.com\n' +
                'Jack,Rogers,jrogers@burlington.com\n' +
                'Pat,Stumuller,pat@pyramid.net\n' +
                'Andy,Young,a_young@dickenson.com\n' +
                'Tim,Barr,barr_tim@grandhotels.com\n' +
                'John,Bond,bond_john@grandhotels.com\n' +
                'Stella,Pavlova,spavlova@uog.com\n' +
                'Lauren,Boyle,lboyle@uog.com\n' +
                'Babara,Levy,b.levy@expresslt.net\n' +
                'Josh,Davis,j.davis@expresslt.net\n' +
                'Jane,Grey,jane_gray@uoa.edu\n' +
                'Arthur,Song,asong@uog.com\n' +
                'Ashley,James,ajames@uog.com\n' +
                'Tom,Ripley,tripley@uog.com\n' +
                'Alice,Smith,alice.smith@gmail.com';

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = 'contacts.csv'; //title of the file
        cv.PathOnClient = 'contacts.csv'; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(concantenatedStr); //file data
        insert cv;

        Contact testcont = new Contact(FirstName='Alice', LastName='Smith');
        insert testcont;

        cv = [SELECT ContentDocumentId FROM ContentVersion];

        System.debug(cv.ContentDocumentId);

        Test.startTest();
        Map<String, String> result = Task1Controller.uploadContacts(cv.ContentDocumentId);
        System.assertEquals(result.get('message').contains('20'), true);
        System.assertNotEquals(result.get('duplicateDownloadLink'), null);
        System.assertEquals([SELECT Id FROM ContentDocument].size(), 1);
        Task1Controller.removeUploadTestContacts();
        Test.stopTest();

    }
}