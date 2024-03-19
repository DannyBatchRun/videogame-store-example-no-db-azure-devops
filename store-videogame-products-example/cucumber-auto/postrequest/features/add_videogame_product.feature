Feature: Video Game Product API

  Scenario Outline: Making a POST request for different video games
    Given I set POST service api endpoint
    And set request BODY with following details:
      | idProduct    | <idProduct>  |
      | name   | <name> |
      | type   | <type> |
      | price  | <price> |
    Then send a POST HTTP request

  Examples:
    | idProduct | name          | type       | price |
    | 0         | Super Mario   | Platform  | 59.99 |
    | 1         | Zelda         | Adventure | 59.99 |
    | 2         | Minecraft     | Sandbox   | 29.99 |
    | 3         | Fortnite      | Shooter   | 1.00  |
    | 4         | Among Us      | Strategy  | 4.99  |
    | 5         | FIFA 2024     | Sports    | 59.99 |
    | 6         | Cyberpunk     | RPG       | 59.99 |
    | 7         | Overwatch     | Shooter   | 39.99 |
    | 8         | Rocket League | Sports    | 19.99 |
    | 9         | Fall Guys     | Platform  | 19.99 |
