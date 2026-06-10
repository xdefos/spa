// Diagnose whether Authorization header formatting is the issue.
// Usage: sf apex run --target-org "SPA Prod" --file scripts/diagnose_tinify_auth_header.apex

FilePostProcessSetting__mdt s = [
    SELECT APIKey__c
    FROM FilePostProcessSetting__mdt
    WHERE QualifiedApiName = 'TinifyShrink'
    LIMIT 1
];

String raw = s.APIKey__c;
String trimmed = raw == null ? null : raw.trim();

// Normalize base64 to remove any whitespace / odd padding.
String normalized;
Boolean base64Decodes = false;
Integer decodedBytes = null;
try {
    Blob decoded = EncodingUtil.base64Decode(trimmed);
    base64Decodes = true;
    decodedBytes = decoded.size();
    normalized = EncodingUtil.base64Encode(decoded);
} catch (Exception e) {
    normalized = null;
}

System.debug('APIKey__c lengths raw=' + (raw == null ? -1 : raw.length())
    + ' trimmed=' + (trimmed == null ? -1 : trimmed.length())
    + ' normalized=' + (normalized == null ? -1 : normalized.length())
    + ' base64Decodes=' + base64Decodes
    + ' decodedBytes=' + decodedBytes);

class Scenario {
    String name;
    String authHeader; // full value, but we never log it
    Scenario(String n, String a) { name = n; authHeader = a; }
}

List<Scenario> scenarios = new List<Scenario>{
    new Scenario('no-auth', null),
    new Scenario('raw', 'Basic ' + raw),
    new Scenario('trimmed', 'Basic ' + trimmed),
    new Scenario('normalized', normalized == null ? null : 'Basic ' + normalized)
};

List<String> endpoints = new List<String>{
    'https://api.tinify.com/shrink'
};

for (String endpoint : endpoints) {
    for (Scenario sc : scenarios) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        if (sc.authHeader != null) req.setHeader('Authorization', sc.authHeader);

        System.debug('--- GET scenario=' + sc.name + ' endpoint=' + endpoint);
        try {
            HttpResponse res = new Http().send(req);
            System.debug('statusCode=' + res.getStatusCode()
                + ' content-type=' + res.getHeader('content-type')
                + ' body=' + res.getBody());
        } catch (Exception e) {
            System.debug('exception=' + e.getTypeName() + ' msg=' + e.getMessage());
        }
    }
}

