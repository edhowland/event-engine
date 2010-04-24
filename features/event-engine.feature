Feature: Processing Events with EventEngine
  In order to see events being p
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
    And I tell it to setup those handlers
    When I trigger the Start event
    Then started has become true
    And ended has become false
    When I trigger the End event
    Then started has become true
    And ended has become true
    
  Scenario: Event handler on_prefix using predicates fir directory tree
    Given I have an Event Engine
    And I give it predicate on_file with '{|ev| @last_stdout << "file #{ev.to_s}\n"}'
    And I give it predicate on_directory with '{|ev| puts "in dir"; @last_stdout <<  "directory #{ev.to_s}\n"}'
    # And show me the evals
    And I tell it to setup those handlers
    And I have the following directory structure
      |dir | file |
      |ruby|      |
      |ruby/1.8|file.rb|
      |ruby/1.9|file.rb|
    Then the following files should exist:
      | ruby/1.8/file.rb |
      | ruby/1.9/file.rb |
    When I cd to "." 
    When I trigger using a Dir
    Then I should see:
      """
      directory ruby
      directory ruby/1.8
      file ruby/1.8/file.rb
      directory ruby/1.9
      file ruby/1.9/file.rb
      """
    