/*
    
    Description: Controller to handle authentication
*/
public without sharing class oAuthRedirectController {
    public string  oAuthCode {get;set;}
    public string  userId {get;set;}
    public User userRec {get;set;}

    //Method to read the url params returned from oAuth
    public oAuthRedirectController() {
        try{
            oAuthCode = Apexpages.currentPage().getParameters().get('code');
            userId = Apexpages.currentPage().getParameters().get('state');
            userRec = [Select id,Contact_Id__c from user where id=:userId limit 1];
        }
        catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An error has occured, please try again later.'));
        }

    }

    //Updte the oAuth codes in contact record
    public Pagereference updateAuthCode(){
        try{
            Contact conRec;

            System.debug('userRec.Contact_Id__c:'+userRec.Contact_Id__c);
            System.debug('oAuthCode:'+oAuthCode);

            if(userRec.Contact_Id__c!=null && oAuthCode!=null){
                conRec = [Select id,Calender_Id__c,oAuth_Code__c,oAuth_Access_Token__c,oAuth_Refresh_Token__c from Contact where id=:userRec.Contact_Id__c limit 1];
                map<String,String>  tokenMap = mcUtil.getOAuthTokens();
                
                String reqBody = '';
                reqBody +='code='+oAuthCode;
                reqBody +='&client_id='+tokenMap.get('oAuth_ClientId');
                reqBody +='&client_secret='+tokenMap.get('Client_Secret');
                reqBody +='&redirect_uri='+Label.OAuth_Redirect_URL;
                reqBody +='&grant_type=authorization_code';

                External_URLs__mdt urlConfig = [Select Url__c from External_URLs__mdt where DeveloperName = 'Google_oAuth_Token' limit 1];
                HttpResponse htpRes  = mcHttpCalloutHandler.sendCallout(urlConfig.Url__c, reqBody, 'POST', new map<String,string>());
                System.debug('htpRes Body:'+htpRes.getBody());
                
                if(htpRes.getStatusCode() == 200){

                    oAuthResponse respWrapper = (oAuthResponse) JSON.deserialize(htpRes.getBody(), oAuthResponse.class);

                    conRec.oAuth_Access_Token__c = respWrapper.access_token;
                    conRec.oAuth_Refresh_Token__c = respWrapper.refresh_token;
                    conRec.oAuth_Code__c = oAuthCode;
                    update conRec;
                }
                else{
                    //log errors
                    mcUtil.logTransaction('POST',urlConfig.url__c,userRec.Contact_Id__c, htpRes.getBody());
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mcConstants.ERROR));
                    return null;
                }
            }

            Pagereference pg = new Pagereference('/lightning/page/home');
            pg.setRedirect(false) ;

            return pg;
        }
        catch(exception e){
            System.debug('Error message '+e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,mcConstants.ERROR));
            return null;
        }
    }

    //Return back to lightning app
    public Pagereference goBack(){
        Pagereference pg = new Pagereference('/lightning/page/home');
        pg.setRedirect(false);
        return pg;
    }

    public class oAuthResponse{
        public string access_token;
        public string refresh_token;
    }
}