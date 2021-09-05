//
//  NetworkServiceRealRequestTests.swift
//  MariannePictureViewerTests
//
//  Created by Roman Kolosov on 05.06.2021.
//
// Tests with use of the real network request.

import XCTest
@testable import MariannePV

class NetworkManagerTests: XCTestCase {
    // Error handling.
    enum LoadDataError: Error {
        case dataLoadFailure
        case paginatedDataLoadFailure
    }
    var sut: NetworkService<ItemNetworkClient>? // System Under Testing.
    var client: ItemNetworkClient?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        client = ItemNetworkClient()
        sut = NetworkService<ItemNetworkClient>(client: client ?? ItemNetworkClient())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        client = nil
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Positive tests

    func testServiceCanReceiveRealResult() {
        // Given
        // Initialize test date and system under test for real network request.
        let expectedElementValue = "Alejandro Escamilla"

        let fetchRealItemComplete = expectation(description: "Fetch real item success")

        // When
        // Call system under test with real network request.
        sut?.fetchItem { (response, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let response = response {
                guard let elementFirst: PhotoElement = response.first else { return }
                // Then
                // Verify that output is as expected.
                XCTAssertEqual(elementFirst.author, expectedElementValue)
                fetchRealItemComplete.fulfill()
            } else {
                XCTFail(LoadDataError.dataLoadFailure.localizedDescription)
            }
        }
        waitForExpectations(timeout: 8.0, handler: nil)
    }

    func testServiceCanReceiveRealResultPaginated() {
        // Given
        // Initialize test date and system under test for real network request.
        let expectedElementValue = "Alejandro Escamilla"

        let fetchRealPaginatedItemComplete = expectation(description: "Fetch real paginated item success")

        // When
        // Call system under test with real network request.
        sut?.fetchPaginatedItem(at: 1) { (response, error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            } else if let response = response {
                guard let elementFirst: PhotoElement = response.first else { return }
                // Then
                // Verify that output is as expected.
                XCTAssertEqual(elementFirst.author, expectedElementValue)
                fetchRealPaginatedItemComplete.fulfill()
            } else {
                XCTFail(LoadDataError.dataLoadFailure.localizedDescription)
            }
        }
        waitForExpectations(timeout: 8.0, handler: nil)
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
