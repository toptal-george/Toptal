@isTest
public class McAuthoriseCalenderControllerTest {

    @testSetup static void setup() {

        System.runAs(new user(id=userInfo.getUserId())){
            String userName = 'sample@user.com'+math.Random()*10;
            Insert TestDataFactory.createStndUser(userName);
        }

        User userRec = [Select id from user where username like 'sample@user.com%' limit 1];
        Contact conRec;
        System.runAs(userRec){

            Product2 prod = new Product2(Name = 'General Medicine', Family = 'Hardware', IsActive=true);
            insert prod;

            Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 100, IsActive = true);
            insert standardPrice;

            conRec = new Contact();
            conRec.lastName = 'Jimmy';
            Conrec.Specialisation__c = prod.Id;
            conRec.Calender_Id__c = 'sample@sa.com';
            conRec.oAuth_Code__c = 'POIUYTREW';
            conRec.oAuth_Access_Token__c = '098765432';
            conRec.oAuth_Refresh_Token__c = 'MNBVCXZ';
            Insert conRec;

        }
        
        conRec = [Select id from contact where lastname ='Jimmy' limit 1];
        userRec.Contact_Id__c = conRec.Id;
        update userRec;
    }


    static testMethod void  McAuthoriseCalenderControllerTest() {


        User userRec = [Select id,Contact_Id__c from user where username like 'sample@user.com%' limit 1];

        System.runAs(userRec){
            McAuthoriseCalenderController.mcAuthWrapper wrp = McAuthoriseCalenderController.getCalendarInfo();

            System.assertNotEquals(wrp.calendarId, null);
            System.assertNotEquals(wrp.oAuthCode, null);


            boolean hasGrantedAccess = McAuthoriseCalenderController.hasGrantedCalender();


            System.assertEquals(hasGrantedAccess, true);

            wrp = McAuthoriseCalenderController.getoAuthUrl();

            System.assertNOtEquals(wrp.oAuthUrl, null);
        }
    }
}