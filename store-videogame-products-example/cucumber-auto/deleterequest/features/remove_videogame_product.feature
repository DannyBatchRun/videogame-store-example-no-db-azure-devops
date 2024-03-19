Feature: Post Request Feature

  Scenario: Making a DELETE request
    Given I set DELETE service api endpoint with id 1
    Then send a DELETE HTTP request
