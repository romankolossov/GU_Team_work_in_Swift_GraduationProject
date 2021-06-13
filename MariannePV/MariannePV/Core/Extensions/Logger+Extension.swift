//
//  Logger+Extension.swift
//  Maps
//
//  Created by Roman Kolosov on 05.06.2021.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? ""

    // Logs the view cycles like viewDidLoad
    static let viewCycle = Logger(subsystem: subsystem, category: "viewCycle")
}
