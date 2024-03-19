Feature: Post Request Feature

  Scenario: Making a POST request
    Given I set POST service api endpoint
    And set request BODY with following details:
      | name    | INSERT_NAME_HERE  |
      | surname   | INSERT_SURNAME_HERE |
    Then send a POST HTTP request
