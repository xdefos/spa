/**
* @author Xavier Defossez
* @date 2022-12-16
* @description  Handler class for ContentVersion trigger methods
* @group Trigger Handler
*/

public with sharing class TRG07_ContentVersionHandler {

    /*******************************************************************************************************
    * @description 
    * @author Xavier Defossez
    * @param List<ContentVersion>, Map<id,ContentVersion>
    * @return void
    */
    
     public static void setContentVersionFields(List<ContentVersion> cv, Map<Id,ContentVersion> oldCv) {
        
        List<ContentDocumentLink > lCDLs = new List<ContentDocumentLink >();
        Organization Org = [select Id, CreatedById from Organization Limit 1];

        for(ContentVersion c: cv) {
            if (UserInfo.getUserId()!=Org.CreatedById) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = Org.CreatedById;
                cdl.ContentDocumentId = c.ContentDocumentId;
                cdl.ShareType = 'C';
                lCDLs.add(cdl);
            }
        }
        insert lCDLs;
    }
}