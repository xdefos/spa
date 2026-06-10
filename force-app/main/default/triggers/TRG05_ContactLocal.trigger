/*
* @author Xavier Defossez
* @date 2019-12-07
* @description 
*/
trigger TRG05_ContactLocal on ContactLocal__c(before insert, before update,after Insert,after Update) {

    // BEFORE BLOCK EVENT ******************************************************
    if (Trigger.isBefore) {

        // BEFORE INSERT EVENT *************************************************
        if (Trigger.isInsert) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, null, 'ContactLocal__c' );
    	}
        // BEFORE UPDATE EVENT *************************************************
        if (Trigger.isUpdate) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, Trigger.oldMap,'ContactLocal__c');

            //Set Geolocation for ContactLocal
            UTI01_LocationCallouts.setGeolocation(Trigger.new, Trigger.oldMap);
        }

        // BEFORE DELETE EVENT *************************************************
        if (Trigger.isDelete) { }
    }
    // AFTER BLOCK EVENT *******************************************************
    if (Trigger.isAfter) {

        // AFTER INSERT EVENT **************************************************
        if (Trigger.isInsert) {
            //Set Geolocation for ContactLocal
            UTI01_LocationCallouts.setGeolocation(Trigger.new, null); 
        }
        // AFTER UPDATE EVENT **************************************************
        if (Trigger.isUpdate) { }

        // AFTER DELETE EVENT **************************************************
        if (Trigger.isDelete) { }
    }
}