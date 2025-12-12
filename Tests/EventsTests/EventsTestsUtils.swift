//
//  EventsTestsUtils.swift
//
//
//  Created by Anton Nguyen on 11/4/23.
//

import Events
import Foundation

final class TestEvent: Event {
  static let FOO = TestEvent.ET("foo")
  static let BAR = TestEvent.ET("bar")

  init() {
    super.init(eventType: TestEvent.FOO)
  }
}

enum TestEnum {
  case ABC
  case JKL
  case XYZ
}

let dummyClosure = { (e: Event) in return }

final class TestHashable: NSObject {
}
