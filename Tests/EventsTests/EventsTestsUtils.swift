//
//  EventsTestsUtils.swift
//
//
//  Created by Anton Nguyen on 11/4/23.
//

import Events
import Foundation

internal final class TestEvent: Event {
  static let FOO = TestEvent.ET("foo")
  static let BAR = TestEvent.ET("bar")

  init() {
    super.init(eventType: TestEvent.FOO)
  }
}

internal enum TestEnum {
  case ABC
  case JKL
  case XYZ
}

internal let dummyClosure = { (e: Event) in return }

internal final class TestHashable: NSObject {
}
