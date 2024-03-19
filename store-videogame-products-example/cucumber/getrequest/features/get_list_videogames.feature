Feature: Get Request Feature

  Scenario: Making a GET request
    Given I set GET service api endpoint
    Then send a GET HTTP request
    And check if the list of videogames is not empty
