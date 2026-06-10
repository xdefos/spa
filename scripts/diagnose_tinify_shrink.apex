// Diagnostic script: run a single Tinify "shrink" callout and print response.
// Usage: sf apex run --target-org "SPA Prod" --file scripts/diagnose_tinify_shrink.apex

Id contentVersionId = '068IV000019IIDhYAO';

ContentVersion cv = [
    SELECT Id, Title, FileType, VersionData
    FROM ContentVersion
    WHERE Id = :contentVersionId
    LIMIT 1
];

FilePostProcessSetting__mdt s = [
    SELECT QualifiedApiName, Endpoint__c, APIName__c, APIKey__c
    FROM FilePostProcessSetting__mdt
    WHERE QualifiedApiName = 'TinifyShrink'
    LIMIT 1
];

System.debug('Diagnose TinifyShrink for ContentVersion=' + cv.Id + ' title=' + cv.Title + ' fileType=' + cv.FileType);
String endpoint = 'https://api.tinify.com:443/' + s.APIName__c;
System.debug('Tinify endpoint=' + endpoint);

HttpRequest req = new HttpRequest();
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setHeader('Authorization', 'Basic ' + s.APIKey__c);
req.setHeader('Host', 'api.tinify.com');
req.setHeader('Content-Type', 'application/octet-stream');
req.setHeader('Accept', 'application/json');
req.setHeader('Content-Length', String.valueOf(cv.VersionData.size()));
req.setBodyAsBlob(cv.VersionData);

HttpResponse res;
try {
    res = new Http().send(req);
    System.debug('HTTP status=' + res.getStatus() + ' code=' + res.getStatusCode());
    System.debug('Response headers keys=' + res.getHeaderKeys());
    for (String k : res.getHeaderKeys()) {
        System.debug('Header ' + k + '=' + res.getHeader(k));
    }
    System.debug('Response body=' + res.getBody());
} catch (Exception e) {
    System.debug('Callout exception: ' + e.getTypeName() + ': ' + e.getMessage());
}

