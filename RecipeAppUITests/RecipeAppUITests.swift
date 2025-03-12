import XCTest


final class RecipeAppUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment = ["UITest": "true"]
        app.launch()
    }

    func testRecipeListAppears() throws {
        let navigationBar = app.navigationBars["Recipes"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 10), "The 'Recipes' navigation bar should exist")
    }
    
    func testSearchFunctionality() throws {
        let searchField = app.searchFields["Search by name or cuisine"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should exist")
        searchField.tap()
        searchField.typeText("Apple")
        let appleCell = app.cells.staticTexts["Apple Frangipan Tart"]
        XCTAssertTrue(appleCell.waitForExistence(timeout: 5), "A recipe with 'Apple' should appear after searching")
    }
    
    func testErrorStateUI() throws {
        app.terminate()
        app.launchEnvironment["UseMalformedEndpoint"] = "true"
        app.launch()
        let errorText = app.staticTexts["Failed to load recipes. Please try again."]
        XCTAssertTrue(errorText.waitForExistence(timeout: 10), "Error message should be displayed when a malformed endpoint is used")
    }

}
