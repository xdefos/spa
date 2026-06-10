// Quick connectivity check to Tinify API endpoints.
// Usage: sf apex run --target-org "SPA Prod" --file scripts/diagnose_tinify_get.apex

FilePostProcessSetting__mdt s = [
    SELECT Endpoint__c, APIKey__c
    FROM FilePostProcessSetting__mdt
    WHERE QualifiedApiName = 'TinifyShrink'
    LIMIT 1
];

List<String> urls = new List<String>{
    'https://api.tinify.com/',
    'https://api.tinify.com/shrink',
    'https://api.tinify.com/does-not-exist'
};

for (String url : urls) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    req.setHeader('Authorization', 'Basic ' + s.APIKey__c);
    req.setHeader('Accept', 'application/json');

    System.debug('--- GET ' + url);
    try {
        HttpResponse res = new Http().send(req);
        System.debug('HTTP status=' + res.getStatus() + ' code=' + res.getStatusCode());
        System.debug('Content-Type=' + res.getHeader('content-type'));
        System.debug('Body=' + res.getBody());
    } catch (Exception e) {
        System.debug('Exception: ' + e.getTypeName() + ': ' + e.getMessage());
    }
}

