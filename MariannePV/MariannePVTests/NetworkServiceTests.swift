//
//  NetworkServiceTests.swift
//  MariannePVTests
//
//  Created by Roman Kolosov on 04.09.2021.
//
// Tests with use of Mock Network Client.

import XCTest
@testable import MariannePV

final class NetworkServiceTests: XCTestCase {
    var sut: NetworkService<MockNetworkClient<Item>>? // System Under Testing.
    var client: MockNetworkClient<Item>?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        client = MockNetworkClient<Item>()
        sut = NetworkService<MockNetworkClient<Item>>(client: client ?? MockNetworkClient())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        client = nil
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Positive tests

    func testServiceCanReceiveResultLite() {
        // Given
        // Initialize test date and system under test.
        let expectedItem = Item()
        var resultItem: Item?

        client?.stubResponse = expectedItem

        // When
        // Call system under test.
        sut?.fetchItem { (item, _) in
            resultItem = item
        }
        // Then
        // Verify that output is as expected.
        XCTAssertEqual(expectedItem, resultItem)
    }

    func testServiceCanReceiveResultPaginatedLite() {
        // Given
        // Initialize test date and system under test.
        let expectedItem = Item()
        var resultItem: Item?

        client?.stubResponse = expectedItem

        // When
        // Call system under test.
        sut?.fetchPaginatedItem(at: 0) { (item, _) in
            resultItem = item
        }
        // Then
        // Verify that output is as expected.
        XCTAssertEqual(expectedItem, resultItem)
    }

    func testServiceCanReceiveResult() {
        // Given
        // Initialize test date and system under test.
        let expectedItem = Item()
        var resultItem: Item?

        client?.stubResponse = expectedItem

        let fetchItemComplete = expectation(description: "Fetch item success")

        // When
        // Call system under test.
        sut?.fetchItem { (item, error) in
            guard error == nil else {
                XCTFail("Must have succeeded but not: \(String(describing: error))")
                return
            }
            resultItem = item
            // Then
            // Verify that output is as expected.
            XCTAssertEqual(expectedItem, resultItem)
            fetchItemComplete.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testServiceCanReceiveResultPaginated() {
        // Given
        // Initialize test date and system under test.
        let expectedItem = Item()
        var resultItem: Item?

        client?.stubResponse = expectedItem

        let fetchPaginatedItemComplete = expectation(description: "Fetch paginated item success")

        // When
        // Call system under test.
        sut?.fetchPaginatedItem(at: 0) { (item, error) in
            guard error == nil else {
                XCTFail("Must have succeeded but not: \(String(describing: error))")
                return
            }
            resultItem = item
            // Then
            // Verify that output is as expected.
            XCTAssertEqual(expectedItem, resultItem)
            fetchPaginatedItemComplete.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    // MARK: - Negative tests

    func testFailedServiceCanReceiveResult() {
        // Given
        // Initialize test date and system under test.
        let expectedItem = Item()
        var resultItem: Item?

        client?.stubError = true
        client?.stubResponse = expectedItem

        let failedFetchItem = expectation(description: "Fetch item failure")

        // When
        // Call system under test.
        sut?.fetchItem { (item, error) in
            resultItem = item
            guard resultItem == nil else {
                XCTFail("Must have failed but not: \(String(describing: resultItem))")
                return
            }
            // Then
            // Verify that output is as expected.
            XCTAssertEqual(
                error as? MockNetworkClient<Item>.MockNetworkClientError,
                MockNetworkClient<Item>.MockNetworkClientError.stubError
            )
            failedFetchItem.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testFailedServiceCanReceiveResultPaginated() {
        // Given
        // Initialize test date and system under test.
        let expectedItem = Item()
        var resultItem: Item?

        client?.stubError = true
        client?.stubResponse = expectedItem

        let failedFetchPaginatedItem = expectation(description: "Fetch paginated item failure")

        // When
        // Call system under test.
        sut?.fetchPaginatedItem(at: 0) { (item, error) in
            resultItem = item
            guard resultItem == nil else {
                XCTFail("Must have failed but not: \(String(describing: resultItem))")
                return
            }
            // Then
            // Verify that output is as expected.
            XCTAssertEqual(
                error as? MockNetworkClient<Item>.MockNetworkClientError,
                MockNetworkClient<Item>.MockNetworkClientError.stubError
            )
            failedFetchPaginatedItem.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }

/*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
*/

}
