//
// Created by Ed Salter on 2019-04-16.
// Copyright (c) 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

import Quick
import Nimble

@testable import BAKit

class AlertControllerSpec: QuickSpec {
	override func spec() {
		describe("AlertController") {
			describe("internal lazy alertWindow") {
				it("is clear") {
					let alertWindow = AlertController().alertWindow
					expect(alertWindow.backgroundColor == .clear).to(beTruthy())
				}
				it("has windowLevelAlert") {
					let alertWindow = AlertController().alertWindow
					expect(alertWindow.windowLevel == UIWindowLevelAlert).to(beTruthy())
				}
				it("has a rootViewController of type UIViewController") {
					let alertWindow = AlertController().alertWindow
					expect(alertWindow.rootViewController).to(beAnInstanceOf(UIViewController.self))
				}
			}
			describe("show alert and accept nil completion handler") {
				it("takes Bool flag dictating animation and accommodates a completion handler") {
                    let alertController = AlertController(title: "title", message: "message", preferredStyle: .alert)
					alertController.showAlert(animated: true, completion: nil)
					expect(alertController.alertWindow.windowLevel).to(beIdenticalTo(UIWindowLevelAlert))
				}
				it("alertWindow should be key") {
                    let alertController = AlertController(title: "title", message: "message", preferredStyle: .alert)
					alertController.showAlert(animated: true, completion: nil)
					expect(alertController.alertWindow.isKeyWindow).to(beTruthy())
				}
			}
			describe("completion handler is executed if populated, but closure remains isolated, capturing x") {
				it("will restore app's original UIWindow to top of stack, hide the created window, and remove created window from superview") {
                    let alertController = AlertController(title: "title", message: "message", preferredStyle: .alert)
                    var x = 0
					alertController.showAlert(animated: true) {
						x = 12
                        expect(x).to(equal(12))
					}
					expect(x).to(equal(0))
				}
			}
			describe("dismiss alert w/animated flag: Bool and optional completion handler") {
				it("will restore app's original UIWindow to top of stack, hide the created window, and remove created window from superview") {
					let alertController = AlertController(title: "title", message: "message", preferredStyle: .alert)
					let alertWindow = alertController.alertWindow
					alertController.showAlert(animated: true, completion: nil)
					var x = 0
					var y = 0
                    alertController.dismissAlert(animated: true, completion: { 
						x = 7
						y = 7
					})
					expect(x).to(equal(y))
                    print("ALERT WINDOW :: \(alertWindow.isHidden)")
					expect(alertWindow.isHidden).to(beTruthy())
				}
			}
		}
	}
}
