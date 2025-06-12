//
//  UltimatePortfolioTests.swift
//  UltimatePortfolioTests
//
//  Created by Robert Welz on 12.06.25.
//

import CoreData
import XCTest
@testable import UltimatePortfolio

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}

