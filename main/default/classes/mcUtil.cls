public class mcUtil {
   
    public static map<String,String> getOAuthTokens(){
        map<string,string> mapNameToken = new Map<String,string>();

        for(OAuth_Tokens__mdt token : [Select id,developerName,token__c from OAuth_Tokens__mdt where developerName in ('Client_Secret','oAuth_ClientId','Google_oAuth_ClientId')]){
            mapNameToken.put(token.developerName,token.token__c);
        }

        return mapNameToken;
    }

    public static void logTransaction(String requestType, String url, String ConId, String response){
        Integration_Logs__c logRec = new Integration_Logs__c();
        logRec.Date__c = System.now();
        logRec.User__c = userInfo.getUserId();
        logRec.Response__c = response;
        logRec.Request_Type__c = requestType;
        logRec.End_point__c = url;
        logRec.Contact__c = ConId;
        Insert logRec;
    }
}