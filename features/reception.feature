@reception
Feature: I want to scan an asset into a lab reception freezer
  Background:
    Given I am an "External" user logged in as "abc123"
    And I am on the homepage

    Scenario: Scan a plate into SLF
      Given a plate of type "Plate" with barcode "1221234567841" exists
      When I follow "Reception"
      Then I should see "Scan your sample"
      And I fill in "barcode_0" with "1221234567841"
      And I press "Submit"
      Then I should see "I have placed the above barcoded labware in the appropriate reception fridge"
      And I should see "DN1234567"
      And I press "Confirm"
      Then I should see "Successfully updated"
