public with sharing class GCCreateEventWrapper {

    public string summary;
    public string location;
    public string description;
    public timeWrapper eventStart;
    public timeWrapper eventEnd;
    public List<attendeesWrapper> attendees;


    public GCCreateEventWrapper(){
        this.attendees = new List<attendeesWrapper>();
    }

    public class timeWrapper{
        public DateTime GCdateTime;
        public string timeZone;

        public timeWrapper(){
            this.timeZone = 'Australia/Sydney';
        }
    }

    public class attendeesWrapper{
        public string email;
    }


    public class eventResponse{
        public string status;
        public string GCId;
        public string htmlLink;
    }
}