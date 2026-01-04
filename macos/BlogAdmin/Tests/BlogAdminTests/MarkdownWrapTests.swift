import XCTest
@testable import BlogAdmin

final class MarkdownWrapTests: XCTestCase {
  func testWrapPreservesHeadings() {
    let input = "# Heading"
    let output = MarkdownWrap.hardWrap(text: input, width: 10)
    XCTAssertEqual(output, input)
  }

  func testWrapPreservesCodeFence() {
    let input = """
```swift
let value = 1
```
"""
    let output = MarkdownWrap.hardWrap(text: input, width: 10)
    XCTAssertEqual(output, input)
  }

  func testWrapListItemsIndent() {
    let input = "- This is a long line that should wrap"
    let output = MarkdownWrap.hardWrap(text: input, width: 20)
    let expected = """
- This is a long
  line that should
  wrap
"""
    XCTAssertEqual(output, expected)
  }

  func testWrapBlockquotesMaintainPrefix() {
    let input = "> This is a longer blockquote that should wrap"
    let output = MarkdownWrap.hardWrap(text: input, width: 24)
    let expected = """
> This is a longer
> blockquote that should
> wrap
"""
    XCTAssertEqual(output, expected)
  }
}
