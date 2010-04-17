Feature: something something
  In order to something something
  A user something something
  something something something

  Scenario: Simple Event handler
    Given I have an Event Engine
    And I tell it to handle all events with a Proc
    When I trigger an event
    Then The proc should fire
    
  Scenario: Event handlers with on_XXX prefix
    Given started is false
    And ended is false
    And I have an Event Engine
    And I tell it to handle on_start
    And I tell it to handle on_end
    When I trigger Start event
    Then started has become true
    And ended has become false
    When I trigger End event
    Then started has become true
    And ended has become true
    