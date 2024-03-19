Feature: Post Request Feature

  Scenario: Making a DELETE request
    Given I set DELETE service api endpoint with id INSERT_ID_HERE
    Then send a DELETE HTTP request
