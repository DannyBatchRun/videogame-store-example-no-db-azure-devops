Feature: Post Request Feature

  Scenario: Making a POST request to User Subscription and Videogame Products
    Given I set POST service api endpoint
    And set request BODY with following details:
      | subscriptionEndpoint | ENDPOINT_USERSUBSCRIPTION |
      | videogameEndpoint    | ENDPOINT_VIDEOGAMEPRODUCTS |
    Then send a POST HTTP request
