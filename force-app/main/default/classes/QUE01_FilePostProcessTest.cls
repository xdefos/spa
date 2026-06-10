@isTest
public class QUE01_FilePostProcessTest {

    @testSetup
    static void setup() {

               // Create test data
               DelegueEnqueteur__c de = new DelegueEnqueteur__c();
               de.Adresse__c='15 rue des Poiriers Gris';
               de.Ville__c='Menucourt';
               de.CodePostal__c='95180';
               de.Geolocation__Latitude__s=44.8019097;
               de.Geolocation__Longitude__s=-0.6488505;
               de.Habilitation_Enquete__c = 'Référent';
               insert de;
              
               Signalement__c s = new Signalement__c();
               s.Name='sd@sdf.com';
               s.Adresse__c='15 rue des Poiriers Gris';
               s.Ville__c='Menucourt';
               s.CodePostal__c='95180';
               s.Geolocation__Latitude__s=44.8019097;
               s.Geolocation__Longitude__s=-0.6488505;
               insert s;
       
               Enquete__c e = new Enquete__c();
               e.Adresse__c='15 rue des Poiriers Gris';
               e.Ville__c='Menucourt';
               e.CodePostal__c='95180';
               e.Geolocation__Latitude__s=44.8019097;
               e.Geolocation__Longitude__s=-0.6488505;
               e.Statut__c = 'En cours';
               e.DelegueEnqueteurReferent__c = de.Id;
               e.SignalementOrigine__c = s.Id;
               e.FichiersOptimises__c = true;
               insert e;

               ContentVersion testContentVersion = new ContentVersion();
               testContentVersion.Title = 'Test Content Version';
               testContentVersion.PathOnClient = 'Test File.jpg';
               testContentVersion.Status__c = 'Original';
               testContentVersion.VersionData = Blob.valueOf('Test Data');
               testContentVersion.FirstPublishLocationId = e.Id;
               insert testContentVersion;

               ContentVersion testContentVersion2 = new ContentVersion();
               testContentVersion2.Title = 'Test Content Version';
               testContentVersion2.PathOnClient = 'Test File.jpg';
               testContentVersion2.Status__c = 'In Progress';
               testContentVersion2.OptimizedURL__c = 'https://OptimizedURL__c';
               testContentVersion2.VersionData = Blob.valueOf('Test Data');
               testContentVersion2.FirstPublishLocationId = e.Id;
               insert testContentVersion2;


    }

    @isTest
    static void testCallAPIShrink() {
        
        QUE01_FilePostProcess testQueuable = new QUE01_FilePostProcess();
        QUE01_FilePostProcess.doChainJob = false;

        Test.setMock(HttpCalloutMock.class, new UTI03_WSMock(200, '{"input":{"size":581734,"type":"image/png"},"output":{"size":182987,"type":"image/png","width":1920,"height":1080,"ratio":0.3146,"url":"https://api.tinify.com/output/h6kycfh4ac0pd9jngmvvfvrrqrq3db6z"}}'));
        Test.startTest();
            System.enqueueJob(testQueuable);
        Test.stopTest();
    }

    @isTest
    static void testCallAPIDownload() {

        QUE01_FilePostProcess testQueuable = new QUE01_FilePostProcess();
        QUE01_FilePostProcess.doChainJob = false;

        Test.setMock(HttpCalloutMock.class, new UTI03_WSMock(200, '{"input":{"size":581734,"type":"image/png"},"output":{"size":182987,"type":"image/png","width":1920,"height":1080,"ratio":0.3146,"url":"https://api.tinify.com/output/h6kycfh4ac0pd9jngmvvfvrrqrq3db6z"}}'));
        Test.startTest();
            System.enqueueJob(testQueuable);
        Test.stopTest();
    }
}