//
//  StoreView.swift
//  UltimatePortfolio
//
//  Created by Robert Welz on 01.07.25.
//

import Foundation
import SwiftUI

@EnvironmentObject var dataController: DataController // xxx
@Environment(\.dismiss) var dismiss
@State private var products = [Product]()
