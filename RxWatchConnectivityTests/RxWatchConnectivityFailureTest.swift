//
//  RxWatchConnectivityFailureTest.swift
//  RxWatchConnectivityTests
//
//  Created by Agus Widhiyasa on 05/06/23.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import WatchConnectivity
@testable import RxWatchConnectivity

final class RxWatchConnectivityFailureTests: XCTestCase {
    
    class WatchConnectivityInactiveSessionMock: WCSession, RxWatchConnectivityProtocol {
        override var isReachable: Bool { false }
        override var activationState: WCSessionActivationState { .notActivated }
        
        override func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)? = nil) {
            delegate!.session!(self, didReceiveMessage: message)
        }
        
        override func updateApplicationContext(_ applicationContext: [String : Any]) throws {
            delegate!.session?(self, didReceiveApplicationContext: applicationContext)
        }
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInreachableMessage() {
        let sess = RxWatchConnectivity(WatchConnectivityInactiveSessionMock.default)
        let sendMessage = sess.sendMessage(["message": "hello world"]).toBlocking().materialize()
        
        guard case .failed(_, _) = sendMessage else {
            XCTFail("Not supposed to send message when inactive")
            return
        }
        
        XCTAssertTrue(true)
    }
    
    
}
