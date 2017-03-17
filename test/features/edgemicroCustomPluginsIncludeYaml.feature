Feature:
    Make sure that any changes to the edgemico-decorator are backwards compatible.

    Scenario: Get token
      Given I set headers to
        | name          | value            |
        | Content-type        | application/json |
      And I pipe contents of file ./features/fixtures/token.json to body
      When I POST domain `edgeAuthTokenEndpoint`
      Then response body should be valid json
      And response code should be 200
      And I store the value of body path $.token as accessToken in global scope

    Scenario: Send valid request to Cloud Foundry which returns hello world
      Given I set Authorization header to Bearer `accessToken`
      When I GET /edgemicro_hello/greeting
      Then response body should be valid json
      And response body should contain Hello, World!
      And response header x-plugin1 should be plugin1
      And response header x-plugin2 should be plugin2
      And response header x-testPlugin should be testPlugin

    Scenario: Send second valid request to Cloud Foundry which returns hello world
      Given I set Authorization header to Bearer `accessToken`
      When I GET /edgemicro_hello/greeting
      Then response body should be valid json
      And response body should contain Hello, World!
      And response header x-plugin1 should be plugin1
      And response header x-plugin2 should be plugin2
      And response header x-testPlugin should be testPlugin
