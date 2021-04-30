public with sharing class McAuthoriseCalenderController {

    @AuraEnabled
    public static mcAuthWrapper getCalendarInfo(){
        try {
            mcAuthWrapper wrp = new mcAuthWrapper();
            User userRec = [Select Contact_Id__c from user where id=:userInfo.getUserId() limit 1];
            Contact conRec = [Select id,Calender_Id__c,oAuth_Code__c from Contact where id=:userRec.Contact_Id__c limit 1];
            wrp.calendarId = conRec.Calender_Id__c;
            wrp.oAuthCode = conRec.oAuth_Code__c;
            return wrp;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static boolean hasGrantedCalender(){
        try {
            User userRec = [Select Contact_Id__c from user where id=:userInfo.getUserId() limit 1];
            Contact conRec = [Select id,Calender_Id__c,oAuth_Code__c,oAuth_Access_Token__c,oAuth_Refresh_Token__c  from Contact where id=:userRec.Contact_Id__c limit 1];

            if(!String.isBlank(conRec.oAuth_Code__c) && !String.isBlank(conRec.oAuth_Access_Token__c) && !String.isBlank(conRec.oAuth_Refresh_Token__c)){
                return true;
            }
            else{
                return false;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static mcAuthWrapper getoAuthUrl(){
        mcAuthWrapper wrp = new mcAuthWrapper();
        try {
            wrp.userid = userinfo.getUserId();
            String oAuthUrl;

            External_URLs__mdt urlConfig = [Select Url__c from External_URLs__mdt where MasterLabel = 'Google oAuth Url' limit 1];
            
            if(urlConfig!=null){
                oAuthUrl = urlConfig.URL__c;
                if(!String.isBlank(oAuthUrl)){
                    oAuthUrl = oAuthUrl.replace('{clientid}',Label.Google_oAuth_ClientId);
                    oAuthUrl = oAuthUrl.replace('{redirecturl}',Label.OAuth_Redirect_URL);
                }   
            }

            wrp.oAuthUrl = oAuthUrl;
            return wrp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class mcAuthWrapper{
        @AuraEnabled public string oAuthUrl {get;set;}
        @AuraEnabled public string userid {get;set;}
        @AuraEnabled public string oAuthCode {get;set;}
        @AuraEnabled public string calendarId {get;set;}
    }
}