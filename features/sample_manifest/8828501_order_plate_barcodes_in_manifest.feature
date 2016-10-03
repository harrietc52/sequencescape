@sample @manifest @barcode-service
Feature: Order plates in a sample manifest by barcode
Also print out the barcodes in the same order as they appear in the manifest

  Background:
    Given I am an "External" user logged in as "john"
    And the configuration exists for creating sample manifest Excel spreadsheets
    And the "96 Well Plate" barcode printer "xyz" exists
      And the plate barcode webservice returns "666"
      And the plate barcode webservice returns "222"
      And the plate barcode webservice returns "555"

    Given a supplier called "Test supplier name" exists
    And I have an active study called "Test study"
    Given the study "Test study" has a abbreviation
    And user "john" is a "manager" of study "Test study"
    And the study have a workflow
    Given I am visiting study "Test study" homepage
    Then I should see "Test study"
    When I follow "Sample Manifests"
    Then I should see "Create manifest for plates"

    Scenario: Out of order barcodes should be sorted in the manifest
      When I follow "Create manifest for plates"
       And I select "Default Plate" from "Template"
       And I select "Test study" from "Study"
       And I select "Test supplier name" from "Supplier"
       And I select "xyz" from "Barcode printer"
        And I fill in "Plates required" with "3"
        And I press "Create manifest and print labels"
      Then I should see "Download Blank Manifest"
      Then the last created sample manifest should be:
        | SANGER PLATE ID | WELL |
        | 222             | A1   |
        | 222             | B1   |
        | 222             | C1   |
        | 222             | D1   |
        | 222             | E1   |
        | 222             | F1   |
        | 222             | G1   |
        | 222             | H1   |
        | 222             | A2   |
        | 222             | B2   |
        | 222             | C2   |
        | 222             | D2   |
        | 222             | E2   |
        | 222             | F2   |
        | 222             | G2   |
        | 222             | H2   |
        | 222             | A3   |
        | 222             | B3   |
        | 222             | C3   |
        | 222             | D3   |
        | 222             | E3   |
        | 222             | F3   |
        | 222             | G3   |
        | 222             | H3   |
        | 222             | A4   |
        | 222             | B4   |
        | 222             | C4   |
        | 222             | D4   |
        | 222             | E4   |
        | 222             | F4   |
        | 222             | G4   |
        | 222             | H4   |
        | 222             | A5   |
        | 222             | B5   |
        | 222             | C5   |
        | 222             | D5   |
        | 222             | E5   |
        | 222             | F5   |
        | 222             | G5   |
        | 222             | H5   |
        | 222             | A6   |
        | 222             | B6   |
        | 222             | C6   |
        | 222             | D6   |
        | 222             | E6   |
        | 222             | F6   |
        | 222             | G6   |
        | 222             | H6   |
        | 222             | A7   |
        | 222             | B7   |
        | 222             | C7   |
        | 222             | D7   |
        | 222             | E7   |
        | 222             | F7   |
        | 222             | G7   |
        | 222             | H7   |
        | 222             | A8   |
        | 222             | B8   |
        | 222             | C8   |
        | 222             | D8   |
        | 222             | E8   |
        | 222             | F8   |
        | 222             | G8   |
        | 222             | H8   |
        | 222             | A9   |
        | 222             | B9   |
        | 222             | C9   |
        | 222             | D9   |
        | 222             | E9   |
        | 222             | F9   |
        | 222             | G9   |
        | 222             | H9   |
        | 222             | A10  |
        | 222             | B10  |
        | 222             | C10  |
        | 222             | D10  |
        | 222             | E10  |
        | 222             | F10  |
        | 222             | G10  |
        | 222             | H10  |
        | 222             | A11  |
        | 222             | B11  |
        | 222             | C11  |
        | 222             | D11  |
        | 222             | E11  |
        | 222             | F11  |
        | 222             | G11  |
        | 222             | H11  |
        | 222             | A12  |
        | 222             | B12  |
        | 222             | C12  |
        | 222             | D12  |
        | 222             | E12  |
        | 222             | F12  |
        | 222             | G12  |
        | 222             | H12  |
        | 555             | A1   |
        | 555             | B1   |
        | 555             | C1   |
        | 555             | D1   |
        | 555             | E1   |
        | 555             | F1   |
        | 555             | G1   |
        | 555             | H1   |
        | 555             | A2   |
        | 555             | B2   |
        | 555             | C2   |
        | 555             | D2   |
        | 555             | E2   |
        | 555             | F2   |
        | 555             | G2   |
        | 555             | H2   |
        | 555             | A3   |
        | 555             | B3   |
        | 555             | C3   |
        | 555             | D3   |
        | 555             | E3   |
        | 555             | F3   |
        | 555             | G3   |
        | 555             | H3   |
        | 555             | A4   |
        | 555             | B4   |
        | 555             | C4   |
        | 555             | D4   |
        | 555             | E4   |
        | 555             | F4   |
        | 555             | G4   |
        | 555             | H4   |
        | 555             | A5   |
        | 555             | B5   |
        | 555             | C5   |
        | 555             | D5   |
        | 555             | E5   |
        | 555             | F5   |
        | 555             | G5   |
        | 555             | H5   |
        | 555             | A6   |
        | 555             | B6   |
        | 555             | C6   |
        | 555             | D6   |
        | 555             | E6   |
        | 555             | F6   |
        | 555             | G6   |
        | 555             | H6   |
        | 555             | A7   |
        | 555             | B7   |
        | 555             | C7   |
        | 555             | D7   |
        | 555             | E7   |
        | 555             | F7   |
        | 555             | G7   |
        | 555             | H7   |
        | 555             | A8   |
        | 555             | B8   |
        | 555             | C8   |
        | 555             | D8   |
        | 555             | E8   |
        | 555             | F8   |
        | 555             | G8   |
        | 555             | H8   |
        | 555             | A9   |
        | 555             | B9   |
        | 555             | C9   |
        | 555             | D9   |
        | 555             | E9   |
        | 555             | F9   |
        | 555             | G9   |
        | 555             | H9   |
        | 555             | A10  |
        | 555             | B10  |
        | 555             | C10  |
        | 555             | D10  |
        | 555             | E10  |
        | 555             | F10  |
        | 555             | G10  |
        | 555             | H10  |
        | 555             | A11  |
        | 555             | B11  |
        | 555             | C11  |
        | 555             | D11  |
        | 555             | E11  |
        | 555             | F11  |
        | 555             | G11  |
        | 555             | H11  |
        | 555             | A12  |
        | 555             | B12  |
        | 555             | C12  |
        | 555             | D12  |
        | 555             | E12  |
        | 555             | F12  |
        | 555             | G12  |
        | 555             | H12  |
        | 666             | A1   |
        | 666             | B1   |
        | 666             | C1   |
        | 666             | D1   |
        | 666             | E1   |
        | 666             | F1   |
        | 666             | G1   |
        | 666             | H1   |
        | 666             | A2   |
        | 666             | B2   |
        | 666             | C2   |
        | 666             | D2   |
        | 666             | E2   |
        | 666             | F2   |
        | 666             | G2   |
        | 666             | H2   |
        | 666             | A3   |
        | 666             | B3   |
        | 666             | C3   |
        | 666             | D3   |
        | 666             | E3   |
        | 666             | F3   |
        | 666             | G3   |
        | 666             | H3   |
        | 666             | A4   |
        | 666             | B4   |
        | 666             | C4   |
        | 666             | D4   |
        | 666             | E4   |
        | 666             | F4   |
        | 666             | G4   |
        | 666             | H4   |
        | 666             | A5   |
        | 666             | B5   |
        | 666             | C5   |
        | 666             | D5   |
        | 666             | E5   |
        | 666             | F5   |
        | 666             | G5   |
        | 666             | H5   |
        | 666             | A6   |
        | 666             | B6   |
        | 666             | C6   |
        | 666             | D6   |
        | 666             | E6   |
        | 666             | F6   |
        | 666             | G6   |
        | 666             | H6   |
        | 666             | A7   |
        | 666             | B7   |
        | 666             | C7   |
        | 666             | D7   |
        | 666             | E7   |
        | 666             | F7   |
        | 666             | G7   |
        | 666             | H7   |
        | 666             | A8   |
        | 666             | B8   |
        | 666             | C8   |
        | 666             | D8   |
        | 666             | E8   |
        | 666             | F8   |
        | 666             | G8   |
        | 666             | H8   |
        | 666             | A9   |
        | 666             | B9   |
        | 666             | C9   |
        | 666             | D9   |
        | 666             | E9   |
        | 666             | F9   |
        | 666             | G9   |
        | 666             | H9   |
        | 666             | A10  |
        | 666             | B10  |
        | 666             | C10  |
        | 666             | D10  |
        | 666             | E10  |
        | 666             | F10  |
        | 666             | G10  |
        | 666             | H10  |
        | 666             | A11  |
        | 666             | B11  |
        | 666             | C11  |
        | 666             | D11  |
        | 666             | E11  |
        | 666             | F11  |
        | 666             | G11  |
        | 666             | H11  |
        | 666             | A12  |
        | 666             | B12  |
        | 666             | C12  |
        | 666             | D12  |
        | 666             | E12  |
        | 666             | F12  |
        | 666             | G12  |
        | 666             | H12  |
