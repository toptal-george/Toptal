public class AccountTriggerHandler {
    public static void updateFieldHistory(List<Account> newAccountList, map<Id,Account> oldAccMap){
    	List<Account_History__c > accHistoryList = new List<Account_History__c>();
        List<Account_History_fields__mdt> fields = [Select Id,Field_API_Name__c  from Account_History_fields__mdt];
        
        for(Account acc : newAccountList){
            
            for(Account_History_fields__mdt trackRec : fields){
                String trackfield = trackRec.Field_API_Name__c;
                if(oldAccMap!=null && oldAccMap.containsKey(acc.Id)){
                    if(acc.get(trackField)!=oldAccMap.get(acc.Id).get(trackField) ){
                        
                        Account_History__c acchistory = new Account_History__c();
                        acchistory.Field_Name__c = trackfield;
                        acchistory.Old_Value__c = (String)oldAccMap.get(acc.Id).get(trackField);
                        acchistory.New_Value__c  = (String) acc.get(trackField);
                        
                        accHistoryList.add(acchistory);
                    }
				}
                else{
                    if(acc.get(trackField)!=''){
                        Account_History__c acchistory = new Account_History__c();
                        acchistory.Field_Name__c = trackfield;
                        acchistory.Old_Value__c = '';
                        acchistory.New_Value__c  = (String) acc.get(trackField);
                        
                        accHistoryList.add(acchistory);
					}
                }
            }
        }
        
        
        if(accHistoryList.size()>0){
            try{
                insert accHistoryList;
            }
            catch(exception e){
                //Handle exception here
            }
        }
        
    }
}