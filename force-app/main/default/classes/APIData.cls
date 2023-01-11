/**
 * Created by junliu on 1/10/23.
 */

public with sharing class APIData {

    @AuraEnabled
    public String firstName;
    @AuraEnabled
    public String lastName;
    @AuraEnabled
    public String id;
    @AuraEnabled
    public Date dateOfBirth;
    @AuraEnabled
    public Boolean emailVerified;
    @AuraEnabled
    public Date signUpDate;
    @AuraEnabled
    public String email;
}