//
//  NetworkManagerTests.swift
//  MariannePictureViewerTests
//
//  Created by Roman Kolosov on 05.06.2021.
//

import XCTest
@testable import MariannePV

class NetworkManagerTests: XCTestCase {

    // MARK: - Positive tests

    func testLoadPhotos() throws {
        // Given
        // Initialize test date and system under test
        let networkManager = NetworkManager.shared

        // When
        // Call system under test
        let loadPhotosComplete = expectation(description: "photos loaded")

        networkManager.loadPhotos { response in
            switch response {
            case .success(let model):
                // Then
                // Verify that output is as expected
                guard let elementFirst: PhotoElement = model.first else { return }
                XCTAssertEqual(elementFirst.author, "Alejandro Escamilla")
                loadPhotosComplete.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 8.0, handler: nil)
    }

    func testLoadPartPhotos() throws {
        // Given
        // Initialize test date and system under test
        let networkManager = NetworkManager.shared

        // When
        // Call system under test
        let loadPartPhotosComplete = expectation(description: "part photos loaded")

        networkManager.loadPartPhotos(from: 1) { response in
            switch response {
            case .success(let model):
                // Then
                // Verify that output is as expected
                guard let elementFirst: PhotoElement = model.first else { return }
                XCTAssertEqual(elementFirst.author, "Alejandro Escamilla")
                loadPartPhotosComplete.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 8.0, handler: nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
