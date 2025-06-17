//
//  PerformanceTests.swift
//  UltimatePortfolioTests
//
//  Created by Robert Welz on 17.06.25.
//

import XCTest
import CoreData
@testable import UltimatePortfolio

final class PerformanceTests: BaseTestCase {

    class PerformanceTests: BaseTestCase {
        func testAwardCalculationPerformance() {
            dataController.createSampleData()
            let awards = Award.allAwards

            measure {
                _ = awards.filter(dataController.hasEarned)
            }
        }

        func testAwardCalculationPerformance2() {
            for _ in 1...100 {
                dataController.createSampleData()
            }

            let awards = Array(repeating: Award.allAwards, count: 25).joined()
            XCTAssertEqual(awards.count, 500, "This checks the awards count is constant. Change this if you add awards.")

            measure {
                _ = awards.filter(dataController.hasEarned).count
            }
        }
    }

}
