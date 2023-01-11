/**
 * Created by junliu on 1/11/23.
 */

@IsTest
private class Task2ControllerTest {

    @IsTest
    static void testAPICallAndNew() {

        Test.setMock(HttpCalloutMock.class, new APIMock());
        System.assertEquals([SELECT Name FROM Contact].size(), 0);
        Test.startTest();
        List<APIData> testData = Task2Controller.callAPIAndUpdateContact();
        System.assertEquals(testData.size() == 1, true);
        System.assertEquals(testData[0].id, '142');
        System.assertEquals(testData[0].firstName, 'Alice');
        System.assertEquals(testData[0].lastName, 'Smith');
        System.assertEquals(testData[0].emailVerified, true);
        System.assertEquals(testData[0].dateOfBirth, Date.newInstance(1997, 10, 31));
        System.assertEquals(testData[0].signUpDate, Date.newInstance(2019, 08, 24));
        System.assertEquals(testData[0].Email, 'alice.smith@gmail.com');
        System.assertEquals([SELECT Name FROM Contact].size(), 1);
        Test.stopTest();

    }

    @IsTest
    static void testAPICallAndUpdate() {


        Contact testcont = new Contact(FirstName='Alice', LastName='Smith');
        insert testcont;

        Test.setMock(HttpCalloutMock.class, new APIMock());
        System.assertEquals([SELECT Name FROM Contact].size(), 1);
        Test.startTest();
        List<APIData> testData = Task2Controller.callAPIAndUpdateContact();
        System.assertEquals(testData.size() == 1, true);
        System.assertEquals(testData[0].id, '142');
        System.assertEquals(testData[0].firstName, 'Alice');
        System.assertEquals(testData[0].lastName, 'Smith');
        System.assertEquals(testData[0].emailVerified, true);
        System.assertEquals(testData[0].dateOfBirth, Date.newInstance(1997, 10, 31));
        System.assertEquals(testData[0].signUpDate, Date.newInstance(2019, 08, 24));
        System.assertEquals(testData[0].Email, 'alice.smith@gmail.com');
        //test update
        System.assertEquals([SELECT Name FROM Contact where Email = 'alice.smith@gmail.com'].size(), 1);
        Test.stopTest();
    }


    private class APIMock implements HttpCalloutMock {

        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            if (req.getMethod() == 'GET') {
                resp.setBody('{"firstName":"Alice","lastName":"Smith","emailVerified":true,"dateOfBirth":"1997-10-31","signUpDate":"2019-08-24","id":142,"email":"alice.smith@gmail.com"}');
                resp.setStatusCode(200);
            }
            return resp;
        }
    }
}