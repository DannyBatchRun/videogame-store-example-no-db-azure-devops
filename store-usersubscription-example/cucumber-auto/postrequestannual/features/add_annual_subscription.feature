Feature: Post Request Feature

  Scenario Outline: Making a POST request with different names and surnames
    Given I set POST service api endpoint
    And set request BODY with following details:
      | name    | <name>  |
      | surname | <surname> |
    Then send a POST HTTP request

    Examples:
      | name     | surname   |
      | Pietro   | Neri      |
      | Francesco| Sorrentino|
      | Luigi    | Esposito  |
      | Michela  | Lete      |
