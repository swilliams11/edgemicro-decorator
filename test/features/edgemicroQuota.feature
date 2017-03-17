Feature:
    Make sure that the quota works correctly. By default EM starts with
    two child processes, therefore, we need to send at least 3 requests to trigger
    the quota. Quota should be set to 3 rpm in Edge.

    Scenario: Get token
      Given I set headers to
        | name          | value            |
        | Content-type        | application/json |
      And I pipe contents of file ./features/fixtures/token.json to body
      When I POST domain `edgeAuthTokenEndpoint`
      Then response body should be valid json
      And response code should be 200
      And I store the value of body path $.token as accessToken in global scope

    Scenario: Send first valid request to Cloud Foundry which returns hello world
      Given I set Authorization header to Bearer `accessToken`
      When I GET /edgemicro_hello/greeting
      Then response body should be valid json
      And response code should be 200
      And response body should contain Hello, World!

    Scenario: Send send request to Cloud Foundry which returns hello world
      Given I set Authorization header to Bearer `accessToken`
      When I GET /edgemicro_hello/greeting
      Then response body should be valid json
      And response code should be 200
      And response body should contain Hello, World!

    Scenario: Send third valid request to Cloud Foundry which should fail
      Given I set Authorization header to Bearer `accessToken`
      When I GET /edgemicro_hello/greeting
      Then response body should be valid json
      And response code should be 403
      And response body should contain exceeded quota
