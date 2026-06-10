/*
* @author Xavier Defossez
* @date 2020-07-05
* @description 
*/
trigger TRG06_Signalement on Signalement__c(before insert, before update,after Insert,after update) {

    // BEFORE BLOCK EVENT ******************************************************
    if (Trigger.isBefore) {

        // BEFORE INSERT EVENT *************************************************
        if (Trigger.isInsert) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, null, 'Signalement__c' );
    	}
        // BEFORE UPDATE EVENT *************************************************
        if (Trigger.isUpdate) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, Trigger.oldMap,'Signalement__c');
           
        }

        // BEFORE DELETE EVENT *************************************************
        if (Trigger.isDelete) { }
    }
    // AFTER BLOCK EVENT *******************************************************
    if (Trigger.isAfter) {

        // AFTER INSERT EVENT **************************************************
        if (Trigger.isInsert) { }
        // AFTER UPDATE EVENT **************************************************
        if (Trigger.isUpdate) { }

        // AFTER DELETE EVENT **************************************************
        if (Trigger.isDelete) { }
    }
}