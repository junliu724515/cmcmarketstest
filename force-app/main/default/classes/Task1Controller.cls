/**
 * Created by junliu on 1/11/23.
 *
 * test class: Task1ControllerTest
 *
 *
 * Given the test is required to upload 1000 contacts, so it won't exceed the limits of a single
 * synchronized transaction,
 *
 * but for checking duplicats, since The input array is limited to 50 elements for findDuplicates method.
 * I split the 1000 records into 20 batches, 50 records for each batch to reduce the APEX API calls.
 */

public with sharing class Task1Controller {


    @AuraEnabled
    public static Map<String, String> uploadContacts(String idContentDocument) {

        Map<String, String> result = new Map<String, String>();
        try {
            Map<String, Contact> contactMap = new Map<String, Contact>();
            List<List<Contact>> contactMapList = new List<List<Contact>>();
            List<SObject> duplicatedContacts = new List<SObject>();
            if (idContentDocument != null) {
                ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :idContentDocument WITH SECURITY_ENFORCED];
                CsvReader reader = new CsvReader(objVersion.VersionData.toString());
                String[] titles = reader.readLine();
                String[] lineValues;
                //split 1000 records into 20 batches
                Integer i = 0;
                List<Contact> contactList = new List<Contact>();
                contactMapList.add(contactList);
                while (true) {
                    lineValues = reader.readLine();
                    if (lineValues != null && lineValues.size() > 1) {
                        Contact newCont = new Contact(FirstName = lineValues[0], LastName = lineValues[1], Email = lineValues[2]);
                        contactMap.put(newCont.FirstName + ' ' + newCont.LastName, newCont);
                        contactList.add(newCont);
                    } else {
                        break;
                    }
                    i++;
                    if (Math.mod(i, 50) == 0) {
                        contactList = new List<Contact>();
                        contactMapList.add(contactList);
                    }
                }

                //check duplicate in batches
                for (List<Contact> contactMapTemp : contactMapList) {
                    //   System.debug(contactMapTemp.size());
                    if (contactMapTemp.size() > 0) {
                        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(contactMapTemp);
                        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                                        System.debug('Duplicate Record: ' + matchRecord.getRecord());
                                        duplicatedContacts.add(matchRecord.getRecord());
                                        contactMap.remove((String) matchRecord.getRecord().get('Name'));
                                    }
                                }
                            }
                        }
                    }
                }
                insert contactMap.values();
                result.put('success', 'true');
                if (duplicatedContacts.size() > 0) {
                    String resultFile = createCSVDuplicateFile(duplicatedContacts);
                    result.put('duplicateDownloadLink', resultFile);
                }
                result.put('message', contactMap.size() + ' contacts uploaded');

            } else {
                result.put('success', 'false');
                result.put('message', 'the content id is empty');
            }
        } catch (Exception ex) {
            result.put('success', 'false');
            result.put('message', ex.getMessage());
        } finally {
            //delete document
            List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where Id = :idContentDocument WITH SECURITY_ENFORCED];
            System.assertEquals(cdList.size(), 1);
            Database.delete(cdList, false);
        }
        return result;
    }

    //Create a duplicated records file to download
    private static String createCSVDuplicateFile(List<Sobject> duplicatedContacts) {
        List<String> csvHeaders = new List<String>{
                'Id', 'Name'
        };
        String headerRow = String.join(csvHeaders, ',') + '\n';
        String concantenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = duplicatedContacts.size();
        for (sObject row : duplicatedContacts) {
            concantenatedStr += (String) row.get('Id') + ',';
            concantenatedStr += (String) row.get('Name');
            i++;
            if (i != rowListSize) concantenatedStr += '\n';//add new line
        }
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = 'DuplicatedContact.csv'; //title of the file
        cv.PathOnClient = 'DuplicatedContact.csv'; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(concantenatedStr); //file data
        insert cv;
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'Test';
        cd.ContentVersionId = cv.Id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        insert cd;
        cd = [SELECT ContentDownloadUrl from ContentDistribution where Id = :cd.Id WITH SECURITY_ENFORCED];
        return cd.ContentDownloadUrl;
    }


    @AuraEnabled
    public static Map<String, String> removeUploadTestContacts() {

        List<Contact> testContacts = [SELECT Id FROM Contact where Email like '%@test%' WITH SECURITY_ENFORCED];
        if (testContacts.size() > 0) {
            delete testContacts;
            Database.emptyRecycleBin(testContacts);
        }
        return new Map<String, String>{
                'message' => 'test contacts all deleted'
        };

    }

    public class CsvReader {
        private String delim = ',';
        // the input data
        private String[] buffer;

        public CsvReader(String data) {
            this.buffer = data.split('\n');
        }

        public CsvReader(String data, String delim) {
            this.buffer = data.split('\n');
            this.delim = delim;
        }

        /**
         * Read and parse next available line.  Return null if end of stream.
         */
        public String[] readLine() {
            if (buffer.size() == 0)
                return null;
            String line = this.buffer.remove(0);
            String[] parts = new String[]{
            };
            while (line != '') {
                Integer next = 0;
                if (line.startsWith('"')) {
                    line = line.substring(1); // strip initial
                    Integer quoteIndex = findQuote(line, 0);
                    while (quoteIndex == -1) {
                        if (buffer.size() == 0) {
                            // EOT!
                            quoteIndex = line.length();
                        } else {
                            // grab the next line
                            Integer skip = line.length();
                            line += '\n' + this.buffer.remove(0);
                            quoteIndex = findQuote(line, skip);
                        }
                    }
                    // advance to comma
                    next = quoteIndex + 1;
                    parts.add(line.substring(0, quoteIndex).replace('""', '"'));
                } else {
                    next = line.indexOf(this.delim, next);
                    if (next == -1)
                        next = line.length();
                    // NB in Substring, "endindex" is the index of the character AFTER the last index to get
                    parts.add(line.substring(0, next));
                }
                if (next == line.length() - 1)
                    // case of a terminating comma.
                    parts.add('');
                line = next < line.length() ? line.substring(next + 1) : '';
            }
            if (parts.size() == 0)
                // empty string - we still want to return something...
                parts.add('');
            return parts;
        }

        private Pattern quotePattern = Pattern.compile('(?<!")"(?!")');
        /**
         * Find next quote in the line
         */
        private Integer findQuote(String line, Integer skip) {
            Matcher m = quotePattern.matcher(line);
            m.region(skip, m.regionEnd());
            if (!m.find())
                return -1;
            return m.start();
        }
    }

}