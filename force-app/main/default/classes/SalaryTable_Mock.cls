/**
 * Created by evgeny on 28.12.2022.
 */

@isTest
public class SalaryTable_Mock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        final String endpoint = URL.getSalesforceBaseUrl().toExternalForm() +
                '/services/data/v56.0/composite/tree/CurrencyType/';
        System.assertEquals(endpoint, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"hasErrors":false,"results":[{"referenceId":"JPY","id":"01LDM000000Gyel2AC"}]}');
        res.setStatusCode(201);
        return res;
    }
}