//
//  ClapsterWidgetBundle.swift
//  ClapsterWidget
//
//  Created by Michael Cavallaro on 3/11/25.
//

import WidgetKit
import SwiftUI

@main
struct ClapsterWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClapsterWidget()
        ClapsterWidgetControl()
        ClapsterWidgetLiveActivity()
    }
}
