/*
* @author Xavier Defossez
* @date 2019-12-07
* @description 
*/
trigger TRG04_Animal on Animal__c(before insert, before update,after Insert,after update) {

    // BEFORE BLOCK EVENT ******************************************************
    if (Trigger.isBefore) {

        // BEFORE INSERT EVENT *************************************************
        if (Trigger.isInsert) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, null, 'Animal__c' );
    	}
        // BEFORE UPDATE EVENT *************************************************
        if (Trigger.isUpdate) {

            //Set various cross Object field : UpperCase Ville 
            UTI01_LocationCallouts.setObjectFields(Trigger.new, Trigger.oldMap,'Animal__c');
           
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