Feature: Combination Feature
  This feature represents the combination of ontologies,
  while utilizing DOL.

Scenario: Failing to create a Combination (insufficient permissions)
  Given that I have a valid API-Key
  And I know of a repository with path: "default"
  And I have 2 ontologies
  When I create a combination via the API of these ontologies
  Then I should get a 403 response

Scenario: Failing to create a Combination (invalid key)
  Given that I have an invalid API-Key
  And I have a repository with path: "default"
  And I have 2 ontologies
  When I create a combination via the API of these ontologies
  Then I should get a 403 response

Scenario: Failing to create a Combination (without key)
  Given I have a repository with path: "default"
  And I have 2 ontologies
  When I create a combination via the API of these ontologies
  Then I should get a 403 response

Scenario: Creating a Combination
  Given that I have a valid API-Key
  And I have a repository with path: "default"
  And I have 2 ontologies
  When I create a combination via the API of these ontologies
  Then I should get a 202 response
  And a location-header to an action
  And the body should be valid for a 202 combination-response

Scenario: Creating a Combination with invalid request
  Given that I have a valid API-Key
  And I have a repository with path: "default"
  When I create a combination via the API with these:
    | nodes |
    | "foobar" |
  Then I should get a 400 response
  And the body should be valid for a 400 combination-response
