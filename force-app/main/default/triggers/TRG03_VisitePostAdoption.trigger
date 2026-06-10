/*
* @author Xavier Defossez
* @date 2019-12-07
* @description 
*/
trigger TRG03_VisitePostAdoption on VisitePostAdoption__c (before insert, before update,after Insert,after update) {

    // BEFORE BLOCK EVENT ******************************************************
    if (Trigger.isBefore) {

        // BEFORE INSERT EVENT *************************************************
        if (Trigger.isInsert) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, null, 'VisitePostAdoption__c' );
    	}
        // BEFORE UPDATE EVENT *************************************************
        if (Trigger.isUpdate) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, Trigger.oldMap,'VisitePostAdoption__c');
            
        	//Set Geolocation for Enquete
        	UTI01_LocationCallouts.setGeolocation(Trigger.new, Trigger.oldMap);
        }

        // BEFORE DELETE EVENT *************************************************
        if (Trigger.isDelete) { }
    }
    // AFTER BLOCK EVENT *******************************************************
    if (Trigger.isAfter) {

        // AFTER INSERT EVENT **************************************************
        if (Trigger.isInsert) {
            //Set Geolocation for Enquete
            UTI01_LocationCallouts.setGeolocation(Trigger.new, null);
        }
        // AFTER UPDATE EVENT **************************************************
        if (Trigger.isUpdate) { }

        // AFTER DELETE EVENT **************************************************
        if (Trigger.isDelete) { }
    }
}