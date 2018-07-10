//
//  GCD.swift
//  On The Map
//
//  Created by Bryan's Air on 7/10/18.
//  Copyright © 2018 Bryborg Inc. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
