@IsTest
public class UTI03_WSMock implements HttpCalloutMock {

    private Integer statusCode;
    private String body;
    private Boolean generateException;
    private String exceptionType;
    private String exceptionMessage;

    public UTI03_WSMock(Integer status, String bodyString){
        this.statusCode = status;
        this.body = bodyString;
        this.generateException = false;
    }

    public UTI03_WSMock(String pExceptionType, String pExceptionMessage){
        this.generateException = true;
        this.exceptionType = pExceptionType;
        this.exceptionMessage = pExceptionMessage;
    }

    public HttpResponse respond(HttpRequest req) {

        if(this.generateException){
            switch on exceptionType {
                when 'CalloutException' {
                    CalloutException e = (CalloutException)CalloutException.class.newInstance();
                    e.setMessage(this.exceptionMessage);
                    throw e;
                }
                when else {
                    Exception e = (Exception)Exception.class.newInstance();
                    e.setMessage(this.exceptionMessage);
                    throw e;
                }
            }
        }

        HttpResponse resp = new HttpResponse();

        resp.setStatusCode(this.statusCode);
        resp.setBody(this.body);

        return resp;
    }
}