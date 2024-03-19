Feature: Post Request Feature

  Scenario Outline: Making a POST request
    Given I set POST service api endpoint
    And set request BODY with following details:
      | videogameName  | <videogameName>  |
      | clientName     | <clientName>     |
      | clientSurname  | <clientSurname>  |
    Then send a POST HTTP request

  Examples:
    | videogameName | clientName | clientSurname |
    | Super Mario   | Sofia      | Ricci         |
    | Super Mario   | Maria      | Bianchi       |
    | Minecraft     | Luca       | Verdi         |
    | Fortnite      | Giovanni   | Rossi         |
    | Cyberpunk     | Giovanni   | Rossi         |
    | Rocket League | Pietro     | Neri          |
    | Fall Guys     | Pietro     | Neri          |
    | Overwatch     | Michela    | Lete          |
    | Among Us      | Francesco  | Sorrentino    |
    | FIFA 2024     | Luigi      | Esposito      |
