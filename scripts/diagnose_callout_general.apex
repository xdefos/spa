// Sanity-check whether Apex callouts work in general.
// Usage: sf apex run --target-org "SPA Prod" --file scripts/diagnose_callout_general.apex

List<String> urls = new List<String>{
    'https://example.com',
    'https://api.tinify.com/shrink'
};

for (String url : urls) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url);
    req.setMethod('GET');
    req.setHeader('Accept', 'text/html,application/json');
    System.debug('--- GET ' + url);
    try {
        HttpResponse res = new Http().send(req);
        System.debug('statusCode=' + res.getStatusCode()
            + ' content-type=' + res.getHeader('content-type')
            + ' bodyPrefix=' + (res.getBody() == null ? null : res.getBody().substring(0, Math.min(120, res.getBody().length()))));
    } catch (Exception e) {
        System.debug('exception=' + e.getTypeName() + ' msg=' + e.getMessage());
    }
}

