Feature: Post Request Feature

  Scenario: Making a POST request
    Given I set POST service api endpoint
    And set request BODY with following details:
      | idProduct    | INSERT_PRODUCT_ID  |
      | name   | INSERT_NAME_HERE |
      | type   | INSERT_TYPE_HERE |
      | price  | INSERT_PRICE_HERE |
    Then send a POST HTTP request
