import XCTest
class SwiftSegmentUserAppUITests: XCTestCase {
  override func setUp() {
    super.setUp()
    // test Failure時にすぐ止める (trueにすると、test失敗しても最後まで処理する)
    continueAfterFailure = false
    // セットアップ毎にアプリを起動
    XCUIApplication().launch()
    // 画面の向きなどを指定したい場合はここで設定しておく
  }
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  func testExample() throws {
    // UI tests must launch the application that they test.
    //app.launch()
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let app = XCUIApplication()
    let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
    let textField = element.children(matching: .textField).element
    textField.tap()
    app.typeText("a")
    //let textField2 = element.children(matching: .secureTextField).element.tap()
    let textField2 = element.children(matching: .secureTextField).element.tap()
    //textField2.tap()
    app.typeText("a")
    app.buttons["LoginBtn"].tap()
    app.staticTexts["SegmentUserApp"].tap()
  }
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
        XCUIApplication().launch()
      }
    }
  }
}
