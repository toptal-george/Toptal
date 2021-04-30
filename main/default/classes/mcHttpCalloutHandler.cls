public class mcHttpCalloutHandler {
    
    public static HttpResponse sendCallout(String endPoint, String requestBody, string httpReqType, map<String,String> httpHeadersMap){

        System.debug('endPoint:'+endPoint);
        http httpReqWrapper = new http();
        HttpRequest htpReq =  new HttpRequest();
        HttpResponse htpRes = new HttpResponse();
        htpReq.setMethod(httpReqType);
        htpReq.setEndPoint(endPoint);
        System.debug('reqBody:'+requestBody);

        //Set headers
        if(httpHeadersMap.keySet().size()>0){
            for(String key : httpHeadersMap.keySet()){
                htpReq.setHeader(key,httpHeadersMap.get(key));
            }
        }

        System.debug('header Authorization:'+htpReq.getHeader('Authorization'));
        if(!String.isBlank(requestBody)){
            htpReq.setBody(requestBody);
        }
        htpRes = httpReqWrapper.send(htpReq); 
        return htpRes;
    }  
}