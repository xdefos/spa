/**
* @author Xavier Defossez
* @date 2023-02-24
* @description Test Class for TRG07_ContentVersionHandler
* @group Tests 
*/

@IsTest
public with sharing class TRG07_ContentVersionHandlerTest {
    
    @IsTest
    static void setEnqueteFieldsTest() {
        ContentVersion cvToUpdate;
        cvToUpdate = new ContentVersion(
                Title = 'cvTitle',
                PathOnClient = 'cvPathOnClient',
                VersionData = Blob.valueOf('Test File 2 Content'),
                IsMajorVersion = true,
                Description = 'cvDescription'
            );

        

        Test.startTest();
            	insert cvToUpdate;
        Test.stopTest();
        
    }
}