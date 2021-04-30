global class mcHttpMock implements HttpCalloutMock {
    
    Map<String,string> respMap = new map<String,string>{
        'Google_oAuth_Token'=>'{"access_token":"QWERTYUIOP","refresh_token":"0987654321"}',
        'Get_Calendar_List'=>'{ "kind": "calendTimear#events", "summary": "andy.toptal@gmail.com", "updated": "2021-04-30T02:50:30.114Z", "timeZone": "Australia/Sydney", "accessRole": "owner", "defaultReminders": [{ "method": "popup", "minutes": 30 }], "items": [{ "id": "0123456IIIM", "primary": true }] }',
        'Get_Calendar_Events'=>'{ "kind": "calendTimeTimear#events", "summary": "andy.toptal@gmail.com", "updated": "2021-04-30T02:50:30.114Z", "timeZone": "Australia/Sydney", "accessRole": "owner", "defaultReminders": [{ "method": "popup", "minutes": 30 }], "items": [ { "start": { "dateTime": "2021-04-25T10:00:00+10:00" }, "end": { "dateTime": "2021-04-25T11:00:00+10:00" } } ] }',
        'GC_Event_Resp'=>'{ "status":"confirmed" }'

    };
    
    
    public string type;
    public integer code;

    public mcHttpMock(String t, integer c){
        this.type = t;
        this.code = c;
    }

    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(respMap.get(type));
        res.setStatusCode(code);
        return res;
    }
}