@isTest(SeeAllData=false)
public class oAuthRedirectControllerTest {
    
    @testSetup static void setup() {
        System.runAs(new user(id=userInfo.getUserId())){
            String userName = 'sample@user.com'+math.Random()*10;
            Insert TestDataFactory.createStndUser(userName);
        }

        User userRec = [Select id,Contact_Id__c from user where username like 'sample@user.com%' limit 1];
        Contact conRec;

        System.runAs(userRec){
            
            conRec = new Contact();
            conRec.lastName = 'sampleUser';
            insert conRec;

            System.debug('conRec:'+conRec);
        }

        conRec = [Select id from contact where lastname ='sampleUser' limit 1];

        userRec.Contact_Id__c = conRec.Id;
        update userRec;
    }


    static testMethod void oAuthRedirectControllerTest(){

        test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        

        User userrec = [Select id from user where Contact_Id__c!=null limit 1];

        PageReference oAuthRedirectPage = Page.oAuthRedirectPage;
        Test.setCurrentPage(oAuthRedirectPage);

        Apexpages.currentPage().getParameters().put('state',userrec.Id);
        Apexpages.currentPage().getParameters().put('code','1234567890');

        oAuthRedirectController ctrl = new oAuthRedirectController();

        System.assertEquals(userRec.Id, ctrl.userId);

        //Test with no state param
        Apexpages.currentPage().getParameters().put('state','');
        oAuthRedirectController ctrl2 = new oAuthRedirectController();

        System.assertEquals('', ctrl2.userId);

        Pagereference pg = ctrl2.goBack();
        System.assertNotEquals(null, pg);


        test.stopTest();
    }

    static testMethod void updateAuthCodeTest(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new mcHttpMock('Google_oAuth_Token',200));


        User userRec = [Select id,Contact_Id__c from user where username like 'sample@user.com%' limit 1];

        System.runAs(userRec){
            Contact ConRec = [Select id from Contact where Id=:userrec.Contact_Id__c limit 1];

            PageReference oAuthRedirectPage = Page.oAuthRedirectPage;
            Test.setCurrentPage(oAuthRedirectPage);

            Apexpages.currentPage().getParameters().put('state',userrec.Id);
            Apexpages.currentPage().getParameters().put('code','1234567890');


            oAuthRedirectController ctrl = new oAuthRedirectController();
            ctrl.userRec = userrec;
            ctrl.oAuthCode = '0987654321';

            ctrl.updateAuthCode();


            //verify update 
            ConRec = [Select id,oAuth_Code__c,oAuth_Access_Token__c,oAuth_Refresh_Token__c  from Contact where Id=:userrec.Contact_Id__c limit 1];

            System.assertNotEquals(ConRec.oAuth_Code__c, null);
            System.assertNotEquals(ConRec.oAuth_Access_Token__c, null);
            System.assertNotEquals(ConRec.oAuth_Refresh_Token__c, null);

            Test.stopTest();
        }
    }

    static testMethod void updateAuthCodeFailTest(){

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new mcHttpMock('Google_oAuth_Token',400));


        User userRec = [Select id,Contact_Id__c from user where username like 'sample@user.com%' limit 1];

        System.runAs(userRec){
            Contact ConRec = [Select id from Contact where Id=:userrec.Contact_Id__c limit 1];

            PageReference oAuthRedirectPage = Page.oAuthRedirectPage;
            Test.setCurrentPage(oAuthRedirectPage);

            Apexpages.currentPage().getParameters().put('state',userrec.Id);
            Apexpages.currentPage().getParameters().put('code','1234567890');


            oAuthRedirectController ctrl = new oAuthRedirectController();

            ctrl.updateAuthCode();


            //verify update 
            ConRec = [Select id,oAuth_Code__c,oAuth_Access_Token__c,oAuth_Refresh_Token__c  from Contact where Id=:userrec.Contact_Id__c limit 1];

            System.assertEquals(ConRec.oAuth_Code__c, null);
            System.assertEquals(ConRec.oAuth_Access_Token__c, null);
            System.assertEquals(ConRec.oAuth_Refresh_Token__c, null);

            Test.stopTest();
        }
    }

}