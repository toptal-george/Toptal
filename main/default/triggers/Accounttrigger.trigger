trigger Accounttrigger on Account (after Insert, after update) {

    if((Trigger.isUpdate || Trigger.IsInsert) && Trigger.IsAfter){
        AccountTriggerhandler.updateFieldHistory(trigger.new, trigger.oldMap);
    }

}