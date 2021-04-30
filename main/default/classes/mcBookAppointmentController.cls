public with sharing class mcBookAppointmentController {

    public list<Product2> productList {get;set;}


    public mcBookAppointmentController() {
        productList = new list<Product2>();
    }

    @AuraEnabled
    public static list<Product2> getAllSpecilizations(){

        return [Select name from Product2 where isActive=true];
    }

    @AuraEnabled
    public static uiDetailsWrapper getPhysicians(String departmentId){
        uiDetailsWrapper wrp = new uiDetailsWrapper();
        wrp.conList =  [Select id,Name,firstName,lastName from Contact where Specialisation__c = :departmentId];

        //Set up price
        Product2 productRec = [Select id from Product2 where id =:departmentId limit 1];

        PricebookEntry priceRec = [Select unitPrice from PricebookEntry where product2Id =:productRec.Id limit 1];

        wrp.price = priceRec.UnitPrice;

        return wrp;

    }

    @AuraEnabled
    public static uiDetailsWrapper getPhysiciansCalender(String conId){

        uiDetailsWrapper wrp = new uiDetailsWrapper();

        Contact phyContact = [Select id,Calender_Id__c,oAuth_Code__c,oAuth_Access_Token__c,oAuth_Refresh_Token__c from Contact where id=:conId limit 1];

        map<String,String>  tokenMap = mcUtil.getOAuthTokens();

        String reqBody = '';
        reqBody +='client_id='+tokenMap.get('oAuth_ClientId');
        reqBody +='&client_secret='+tokenMap.get('Client_Secret');
        reqBody +='&grant_type=refresh_token';
        reqBody +='&refresh_token='+phyContact.oAuth_Refresh_Token__c;

        if(String.isBlank(phyContact.oAuth_Code__c) || String.isBlank(phyContact.oAuth_Access_Token__c) || String.isBlank(phyContact.oAuth_Refresh_Token__c)){
            wrp.hasError = true;
            wrp.errorMsgs.add(mcConstants.NO_CAL_ACCESS);
            return wrp;
        }

        External_URLs__mdt oAuthTokenConfig = [Select Url__c from External_URLs__mdt where DeveloperName = 'Google_oAuth_Token' limit 1];

        //Get Access and refresh tokens
        HttpResponse htpRes  = mcHttpCalloutHandler.sendCallout(oAuthTokenConfig.Url__c, reqBody, 'POST', new map<String,string>());

        if(htpRes.getStatusCode()==200){

            System.debug('htpRes Body:'+htpRes.getBody());
            
            oAuthResponse respWrapper = (oAuthResponse) JSON.deserialize(htpRes.getBody(), oAuthResponse.class);

            External_URLs__mdt getCalndrConfig = [Select Url__c from External_URLs__mdt where DeveloperName = 'Get_Calendar_List' limit 1];

            map<String,String> headerMap = new Map<String,String>();
            headerMap.put('Authorization','Bearer '+respWrapper.access_token);


            if(Test.isRunningTest()){
                Test.setMock(HttpCalloutMock.class, new mcHttpMock('Get_Calendar_List',200));
            }

            //Get Calendar list
            htpRes  = mcHttpCalloutHandler.sendCallout(getCalndrConfig.Url__c, '', 'GET',headerMap);
            
            System.debug('Get_Calendar_List htpRes:'+htpRes.getBody());
            String primaryCalid;
            if(htpRes.getStatusCode()==200){
                calenderListWrapper calenderWrap = (calenderListWrapper) JSON.deserialize(htpRes.getBody(), calenderListWrapper.class);
                
                System.debug('calenderWrap:'+calenderWrap);
                for(calenderItems calItem : calenderWrap.items){
                    System.debug('calItem:'+calItem);
                    if(calItem.primary!=null){
                        primaryCalid = calItem.Id;
                    }
                }
                
                System.debug('primaryCalid:'+primaryCalid);

                http httpReqWrapper = new http();

                if(!String.isBlank(primaryCalid)){

                    System.debug('respWrapper.access_token:'+respWrapper.access_token);
                    wrp = getEvents(primaryCalid,respWrapper.access_token,conId,0);
                    
                    phyContact.Calender_Id__c = primaryCalid;
                    phyContact.oAuth_Access_Token__c = respWrapper.access_token;
                    Update phyContact;
                    
                }
            }  
            else{
                // log transaction
                mcUtil.logTransaction('POST',oAuthTokenConfig.url__c,phyContact.Id, htpRes.getBody());

                wrp.hasError = true;
                wrp.errorMsgs.add(mcConstants.ERROR);
                return wrp;
            }
        } 
        //if request has returned response code other than 200 then send error message on the screen
        else{

            // log transaction
            mcUtil.logTransaction('POST',oAuthTokenConfig.url__c,phyContact.Id, htpRes.getBody());

            
            wrp.hasError = true;
            wrp.errorMsgs.add(mcConstants.ERROR);
            return wrp;
        }


        return wrp;
    }

    @AuraEnabled
    public static uiDetailsWrapper getEvents(String primaryCalid,String accessToken, String ContactId,Integer pageNo){

        uiDetailsWrapper wrp = new uiDetailsWrapper();
        HttpResponse htpRes ;
        Contact phyContact;

        External_URLs__mdt getEventsConfig = [Select Url__c from External_URLs__mdt where DeveloperName = 'Get_Calendar_Events' limit 1];

        String evtUrl = getEventsConfig.Url__c;

        evtUrl = evtUrl.replaceAll('primaryCalid', primaryCalid);

        map<String,String> headerMap = new Map<String,String>();

        if(!String.isBlank(accessToken)){
            headerMap.put('Authorization','Bearer '+accessToken);
        }
        else if(String.isBlank(accessToken) && !String.isBlank(ContactId) ){
            phyContact = [Select id,Calender_Id__c,oAuth_Code__c,oAuth_Access_Token__c,oAuth_Refresh_Token__c from Contact where id=:ContactId limit 1];
            headerMap.put('Authorization','Bearer '+phyContact.oAuth_Access_Token__c);
        }

        if(Test.isRunningTest()){
            Test.setMock(HttpCalloutMock.class, new mcHttpMock('Get_Calendar_Events',200));
        }

        //Get Calendar events
        htpRes  = mcHttpCalloutHandler.sendCallout(evtUrl, '', 'GET',headerMap);

        //if request has returned response code other than 200 then send error message on the screen
        if(htpRes.getStatusCode()!=200){

            // log transaction
            mcUtil.logTransaction('GET',evtUrl, ContactId,htpRes.getBody());

            wrp.hasError = true;
            wrp.errorMsgs.add(mcConstants.ERROR);
            return wrp;
        }
        else{
            //Convert HttpResponse to string to replace reserved keywords
            string respString = String.valueOf(htpRes.getBody());
            respString = respString.replaceAll('dateTime', 'GCdateTime');
            respString = respString.replaceAll('start', 'startTime');
            respString = respString.replaceAll('end', 'endTime');

            System.debug('respString:'+respString);

            eventListWrapper eventWrp = (eventListWrapper)JSON.deserialize(respString, eventListWrapper.class);

            //Set next seven days to display in calender
            Date startDate = System.today().addDays(pageNo*7).toStartOfWeek();
        
            System.debug('startDate:'+startDate);

            //wrp.nextDates.add(startDate);
            for(integer i=0;i<=6;i++){
                Date d =  startDate.addDays(i);
                wrp.nextDates.add(DateTime.newInstance(d.year(),d.month(),d.day()).format('dd/MM/YYYY'));
            }

            for(eventItems evtItem : eventWrp.items){
                wrp.bookedDatetimes.add(evtItem.startTime.GCdateTime);
            }

            wrp.primaryCalid = primaryCalid;
        }
        return wrp;
    }

    @AuraEnabled
    public static bookEventRespWrapper createGoogleCalenderEvent(String request){
        try {
            
            System.debug('request:'+request);
            bookEventWrapper bookEvent = (bookEventWrapper) JSON.deserialize(request, bookEventWrapper.class);

            Contact phyRec = [Select email,Calender_Id__c,oAuth_Access_Token__c from Contact where id=:bookEvent.selectedPhy limit 1];
            
            GCCreateEventWrapper eventRec = new GCCreateEventWrapper();
            eventRec.summary = bookEvent.description;
            eventRec.description = bookEvent.description;
            eventRec.location = '';

            GCCreateEventWrapper.timeWrapper startTimeRec = new GCCreateEventWrapper.timeWrapper();
            GCCreateEventWrapper.timeWrapper endTimeRec = new GCCreateEventWrapper.timeWrapper();

            startTimeRec.GCdateTime = getDateTime(bookEvent.eventDate,bookEvent.eventTime,0);
            endTimeRec.GCdateTime = getDateTime(bookEvent.eventDate,bookEvent.eventTime,1);

            eventRec.eventStart = startTimeRec;
            eventRec.eventEnd = endTimeRec;

            GCCreateEventWrapper.attendeesWrapper attRec = new GCCreateEventWrapper.attendeesWrapper();
            attRec.email = phyRec.Calender_Id__c;

            eventRec.attendees.add(attRec);

            System.debug('Event Request Wrapper :'+JSON.serialize(eventRec));

            String requestBody = JSON.serialize(eventRec);
            requestBody = requestBody.replaceAll('GCdateTime', 'dateTime');
            requestBody = requestBody.replaceAll('eventStart', 'start');           
            requestBody = requestBody.replaceAll('eventEnd', 'end');

            System.debug('requestBody:'+requestBody);

            HttpResponse htpRes = new HttpResponse();

            External_URLs__mdt createEventConfig = [Select Url__c from External_URLs__mdt where DeveloperName = 'Create_Event' limit 1];

            String endpoint = createEventConfig.URL__c;
            endpoint = endpoint.replaceAll('calendarId', phyRec.Calender_Id__c);
            
            map<String,String> headerMap = new Map<String,String>();
            headerMap.put('Authorization','Bearer '+phyRec.oAuth_Access_Token__c);

            htpRes  = mcHttpCalloutHandler.sendCallout(endpoint, requestBody, 'POST',headerMap);
            String eventRespStr = htpRes.getBody();

            bookEventRespWrapper bookResp = new bookEventRespWrapper();
            
            if(htpRes.getStatusCode() == 200){

                eventRespStr = eventRespStr.replaceAll('id','GCId');

                GCCreateEventWrapper.eventResponse eventResp = (GCCreateEventWrapper.eventResponse) JSON.deserialize(eventRespStr, GCCreateEventWrapper.eventResponse.class);

                //Event successfully created
                if(eventResp.status!=null && eventResp.status.equalsIgnoreCase('confirmed')){

                    //Create booking record
                    Booking__c bookRec = new Booking__c();
                    bookRec.Department__c = bookEvent.selectedDept;
                    bookRec.Physician__c = bookEvent.selectedPhy;
                    bookRec.Description__c = bookEvent.description;
                    bookRec.Patient_Name__c = bookEvent.patientName;
                    bookRec.Patient_Email__c = bookEvent.patientEmail;
                    bookRec.Start_Date__c = startTimeRec.GCdateTime;
                    bookRec.End_Date__c = endTimeRec.GCdateTime;
                    Insert bookRec;

                    bookResp.isSuccess = true;
                }
            }
            else{ //handle error resoponses

                //log transaction erros
                mcUtil.logTransaction('POST',endpoint,bookEvent.selectedPhy , htpRes.getBody());

                bookResp.isSuccess = false;
            }

            return bookResp;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static dateTime getDateTime(string eventDate,string eventTime, Integer addHours){

        Integer year = integer.valueOf(eventDate.split('/')[2]);
        Integer month = integer.valueOf(eventDate.split('/')[1]);
        Integer day = integer.valueOf(eventDate.split('/')[0]);

        Integer hour = integer.valueOf(eventTime.split('-')[0].split(':')[0])+addHours;

        return Datetime.newInstance(year,month,day,hour,0,0);

    }

    public class uiDetailsWrapper{
        @AuraEnabled public string primaryCalid{get;set;}
        @AuraEnabled public List<Contact> conList{get;set;}
        @AuraEnabled public double price {get;set;}
        @auraEnabled public list<string> nextDates {get;set;}
        @auraEnabled public list<String> bookedDatetimes {get;set;}
        @auraEnabled public boolean hasError {get;set;}
        @auraEnabled public list<String> errorMsgs {get;set;}

        uiDetailsWrapper(){
            this.hasError = false;
            this.nextDates = new list<string>();
            this.bookedDatetimes = new list<String>();
            this.conList = new List<Contact>();
            this.errorMsgs = new list<String>();
        }
    }

    public class oAuthResponse{
        public string access_token;
        public string refresh_token;
    }

    public class calenderListWrapper{
        public string kind;
        public string etag;
        public string nextSyncToken;
        public List<calenderItems> items;
        
    }

    public class calenderItems{
        public string Id;
        public boolean primary;
    }


    public class eventListWrapper{
        public string kind;
        public string etag;
        public string nextSyncToken;
        public List<eventItems> items;
        
    }

    public class eventItems{
        public eventDate startTime;
        public eventDate endTime;
    }

    public class eventDate{
        public string GCdateTime;
    }

    public class bookEventWrapper{
        public string selectedDept;
        public string selectedPhy;
        public string description;
        public string patientName;
        public string patientEmail;
        public string selectedContact;
        public string eventDate; 
        public string eventTime;
    }

    public class bookEventRespWrapper{
        @AuraEnabled public boolean isSuccess {get;set;}

        public bookEventRespWrapper(){
            this.isSuccess = false;
        }
    }
}