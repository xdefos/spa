// Test whether adding a User-Agent changes Tinify response.
// Usage: sf apex run --target-org "SPA Prod" --file scripts/diagnose_tinify_user_agent.apex

List<String> userAgents = new List<String>{
    null,
    'curl/8.6.0',
    'SalesforceApex/1.0'
};

for (String ua : userAgents) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://api.tinify.com/shrink');
    req.setMethod('GET');
    req.setHeader('Accept', 'application/json');
    if (ua != null) req.setHeader('User-Agent', ua);
    System.debug('--- GET /shrink ua=' + (ua == null ? 'null' : ua));
    try {
        HttpResponse res = new Http().send(req);
        System.debug('statusCode=' + res.getStatusCode()
            + ' content-type=' + res.getHeader('content-type')
            + ' body=' + res.getBody());
    } catch (Exception e) {
        System.debug('exception=' + e.getTypeName() + ' msg=' + e.getMessage());
    }
}

