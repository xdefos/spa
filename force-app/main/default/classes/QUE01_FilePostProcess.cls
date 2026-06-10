// Lancement du queuable  : Id jobId = System.enqueueJob(new QUE01_FilePostProcess(),5);
// l'éxécution doit se faire par le créateur de l'Org : Philippe Defossez

public with sharing class QUE01_FilePostProcess implements Queueable, Database.AllowsCallouts {

    private Map<String, FilePostProcessSetting__mdt> mapAPISettingByStatus = new Map<String, FilePostProcessSetting__mdt>();
    Set<String> fileTypes = new Set<String>();
    Set<String> initialStatuses = new Set<String>();
    
    private Integer rowLimit = 150;
    Integer delayInMinutes = 1;
    List<ContentDocument> cdsToDelete = new List<ContentDocument>();
    List<ContentVersion> cvsToUpdate = new List<ContentVersion>();
    @testVisible
    private static Boolean doChainJob = true;

    public QUE01_FilePostProcess() {
        for(FilePostProcessSetting__mdt fpps : [SELECT Id, APIKey__c, APIName__c, AuthorizationMethod__c, QualifiedApiName,
                                                Endpoint__c, ErrorEmailNotification__c, FileExtension__c, FilesLimit__c, 
                                                ImageTargetWidth__c, InitialStatus__c, TargetStatus__c FROM FilePostProcessSetting__mdt WHERE Active__c = TRUE]){
            System.debug('fpps: ' + fpps);
            
            if (fpps.QualifiedApiName == 'FilesLimit') {
                rowLimit = fpps.FilesLimit__c.intValue();
            }
            else {
                for(String fileExtension : fpps.FileExtension__c.split(';')){
                    this.mapAPISettingByStatus.put(fpps.InitialStatus__c + fileExtension.toUpperCase(), fpps);
                    fileTypes.add(fileExtension.toUpperCase());
                }
                System.debug('fileTypes: ' + fileTypes);
                initialStatuses.add(fpps.InitialStatus__c);
                System.debug('initialStatuses: ' + initialStatuses);
            }
        }
    }

    public void execute(QueueableContext context) {
        
        try {
            Map<Id, Enquete__c> enqOuvertes = new Map<Id, Enquete__c>([SELECT Id from Enquete__c where FichiersOptimises__c  = false ]);
            Map<Id, VisitePostAdoption__c> vpaOuvertes = new Map<Id, VisitePostAdoption__c>([SELECT Id from VisitePostAdoption__c where Statut__c  != 'Close' ]);
            Map<Id, Id> mEnqIdbyCV = new Map<Id, Id>();
            
            System.debug('enqOuvertes.keyset().size(): ' + enqOuvertes.keyset().size());
            System.debug('rowLimit : ' + rowLimit);
            List<ContentVersion> cvLists = new List<ContentVersion>();
            Map<Id,ContentVersion> mapContentVersionByContentDocumentId = new Map<Id,ContentVersion>();
            for(ContentVersion cv : [SELECT Id, VersionData, FileType, Status__c, OptimizedURL__c, contentDocumentId, PathOnClient, Title, Description, FirstPublishLocation.Type, FirstPublishLocationId
                                    FROM ContentVersion
                                    WHERE Status__c IN :initialStatuses 
                                        AND FileType IN :fileTypes 
                                        AND FirstPublishLocation.Type IN ('User', 'Enquete__c', 'VisitePostAdoption__c') 
                                        AND (FirstPublishLocationId NOT IN :enqOuvertes.keyset() AND FirstPublishLocationId NOT IN :vpaOuvertes.keyset())
                                    ORDER BY CreatedDate ASC LIMIT :rowLimit]){
                if(cv.FirstPublishLocation.Type == 'User'){
                    mapContentVersionByContentDocumentId.put(cv.ContentDocumentId, cv);
                }else{
                    cvLists.add(cv);
                }
            }
            System.debug('mapContentVersionByContentDocumentId: ' + mapContentVersionByContentDocumentId);
            if (mapContentVersionByContentDocumentId.keySet().size()>0) {
                for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntity.Type, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :mapContentVersionByContentDocumentId.keySet()]){
                    if(cdl.LinkedEntity.Type == 'Enquete__c' && !enqOuvertes.keySet().contains(cdl.LinkedEntityId)){
                        cvLists.add(mapContentVersionByContentDocumentId.get(cdl.ContentDocumentId));
                        mEnqIdbyCV.put(mapContentVersionByContentDocumentId.get(cdl.ContentDocumentId).Id, cdl.LinkedEntityId);
                    }
                }
            }
            System.debug('cvLists: ' + cvLists);
            for(ContentVersion cv : cvLists){
                System.debug('cv: ' + cv);    
                if(this.mapAPISettingByStatus.get(cv.Status__c + cv.FileType) != null){
                    FilePostProcessSetting__mdt relatedAPISetting = this.mapAPISettingByStatus.get(cv.Status__c + cv.FileType);
                    System.debug('relatedAPISetting: ' + relatedAPISetting);
                    if(relatedAPISetting.QualifiedApiName == 'TinifyResize')
                        callAPIDownload(relatedAPISetting, cv, mEnqIdbyCV);
                    if(relatedAPISetting.QualifiedApiName == 'TinifyShrink')
                        callAPIShrink(relatedAPISetting, cv);
                    //if(relatedAPISetting.QualifiedApiName == 'PSPDFKit')
                    //    callAPI_PDFKit(relatedAPISetting, cv);
                }
            }
            
            if (!cvsToUpdate.isEmpty())
                upsert cvsToUpdate;
            if (!cdsToDelete.isEmpty())
                delete cdsToDelete;
                
          } catch (Exception e) {
            System.debug('Exception e: ' + e);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'xdefos@gmail.com'});
            mail.setSubject('Erreur Queuable File Optimization');
            mail.setPlainTextBody('Une erreur est survenue lors de l\'exécution du Queuable');
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

          }
        

        

        // Chain this job to next job by submitting the next job
        if(doChainJob) 
            System.enqueueJob(new QUE01_FilePostProcess(), delayInMinutes);
        
        // TODO: Use Transaction Finalizers
    }

    public void callAPIShrink(FilePostProcessSetting__mdt relatedAPISetting, ContentVersion cv){

        System.debug('cv in callAPIShrink : ' + cv);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(relatedAPISetting.Endpoint__c + relatedAPISetting.APIName__c);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + relatedAPISetting.APIKey__c);
        req.setBodyAsBlob(cv.VersionData);

        HttpResponse response;
        ContentVersion cvToUpdate;

        try{
            Http http = new Http();
            response = http.send(req);
            System.debug('response : '  + response);
            WRP03_TinyShrink wrappedResponse = (WRP03_TinyShrink) JSON.deserialize(response.getBody(), WRP03_TinyShrink.class);
            cvToUpdate = new ContentVersion(
                Id = cv.Id,
                OptimizedURL__c = wrappedResponse.output.url,
                Status__c = relatedAPISetting.TargetStatus__c
            );

        }catch(Exception e){

        }
        if (cvToUpdate!=null)
            cvsToUpdate.add(cvToUpdate);
        
    }

    public void callAPIDownload(FilePostProcessSetting__mdt relatedAPISetting, ContentVersion cv, Map<Id, Id> mEnqIdbyCV){
        System.debug('cv in callAPIDownload : ' + cv);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(cv.OptimizedURL__c);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Basic ' + relatedAPISetting.APIKey__c);
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> mapRequest = new Map<String, Object>();
        Map<String, Object> mapResize = new Map<String, Object>();
        mapResize.put('method', 'scale');
        mapResize.put('width', relatedAPISetting.ImageTargetWidth__c);
        mapRequest.put('resize', mapResize);

        req.setBody(JSON.serialize(mapRequest));
        HttpResponse response;
        ContentVersion cvToUpdate;
        ContentDocument cdToDelete;

        try{
            Http http = new Http();
            response = http.send(req);
            Blob optimizedImage = response.getBodyAsBlob();

            cvToUpdate = new ContentVersion(
                Title = cv.Title,
                PathOnClient = cv.PathOnClient,
                VersionData = optimizedImage,
                IsMajorVersion = true,
                OptimizedURL__c = cv.OptimizedURL__c,
                Status__c = relatedAPISetting.TargetStatus__c,
                Description = cv.Description,
                FirstPublishLocationId = cv.FirstPublishLocation.type =='User' ? mEnqIdbyCV.get(cv.Id): cv.FirstPublishLocationId
            );

            cdToDelete = new ContentDocument(
                Id = cv.ContentDocumentId
            );
            
        }catch(Exception e){

        }
        if (cvToUpdate!=null)
            cvsToUpdate.add(cvToUpdate);
        if (cdToDelete!=null)
            cdsToDelete.add(cdToDelete);
        
    }
    /*
    public void callAPI_PDFKit(FilePostProcessSetting__mdt relatedAPISetting, ContentVersion cv){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(relatedAPISetting.Endpoint__c + relatedAPISetting.APIName__c);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + relatedAPISetting.APIKey__c);
        req.setBodyAsBlob(cv.VersionData);

        HttpResponse response;
        ContentVersion cvToUpdate;
        '{"parts":[{"file":"document"}],"output":{"type":"image","format":"jpg","dpi":100}}'

        try{
            Http http = new Http();
            response = http.send(req);
            System.debug('response : '  + response);
            WRP03_TinyShrink wrappedResponse = (WRP03_TinyShrink) JSON.deserialize(response.getBody(), WRP03_TinyShrink.class);
            cvToUpdate = new ContentVersion(
                Id = cv.Id,
                OptimizedURL__c = wrappedResponse.output.url,
                Status__c = relatedAPISetting.TargetStatus__c
            );

        }catch(Exception e){

        }
        return cvToUpdate;
    }
    */
}