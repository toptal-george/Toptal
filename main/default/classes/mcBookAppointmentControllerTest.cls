@isTest
public  class mcBookAppointmentControllerTest {
    
    @testSetup static void setup() {

        System.runAs(new user(id=userInfo.getUserId())){
            String userName = 'sample@user.com'+math.Random()*10;
            Insert TestDataFactory.createStndUser(userName);
        }

        User userRec = [Select id from user where username like 'sample@user.com%' limit 1];

        System.runAs(userRec){

            Product2 prod = new Product2(Name = 'General Medicine', Family = 'Hardware', IsActive=true);
            insert prod;

            Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 100, IsActive = true);
            insert standardPrice;

            Contact conRec = new Contact();
            conRec.lastName = 'Jimmy';
            Conrec.Specialisation__c = prod.Id;
            conRec.Calender_Id__c = 'sample@sa.com';
            conRec.oAuth_Code__c = 'POIUYTREW';
            conRec.oAuth_Access_Token__c = '098765432';
            conRec.oAuth_Refresh_Token__c = 'MNBVCXZ';
            Insert conRec;

        }
        
    }


    static testMethod void mcBookAppointmentControllerTest(){


        Contact conRec = [Select id from Contact where lastName = 'Jimmy'];
        

        list<Product2> prodList = mcBookAppointmentController.getAllSpecilizations();

        System.assertEquals(prodList.size()>0, true);

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new mcHttpMock('Google_oAuth_Token',200));

        System.runAs(new user(id=userInfo.getUserId())){


            mcBookAppointmentController.uiDetailsWrapper wrp = mcBookAppointmentController.getPhysicians(prodList[0].id);

            wrp = mcBookAppointmentController.getPhysiciansCalender(conRec.id);

            System.assertEquals(wrp.hasError, false);
            
        }

    }


    static testMethod void getPhysiciansCalenderTest(){

        Contact conRec = [Select id from Contact where lastName = 'Jimmy'];

        User userRec = [Select id from user where username like 'sample@user.com%' limit 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new mcHttpMock('Google_oAuth_Token',200));
        mcBookAppointmentController.uiDetailsWrapper wrp = mcBookAppointmentController.getPhysiciansCalender(conRec.id);
        System.assertEquals(wrp.hasError, false);
        
    }

    static testMethod void createGoogleCalenderEventTest(){

        Product2 prodrec = [Select id from Product2 where name = 'General Medicine' limit 1];
        Contact conRec = [Select id from Contact where lastName = 'Jimmy'];

        User userRec = [Select id from user where username like 'sample@user.com%' limit 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new mcHttpMock('GC_Event_Resp',200));
        String request ='{ "selectedDept":\"'+prodrec.Id+'\", "selectedPhy":\"'+conRec.Id+'\", "description":"sample", "patientName":"George", "patientEmail":"meail@as.com", "selectedContact":"", "eventDate":"24/03/2021", "eventTime":"09:00" }';
        mcBookAppointmentController.bookEventRespWrapper wrp = mcBookAppointmentController.createGoogleCalenderEvent(request);

        System.assertEquals(true, wrp.isSuccess);
        
    }
}