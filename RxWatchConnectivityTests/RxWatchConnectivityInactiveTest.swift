//
//  RxWatchConnectivityInactiveTest.swift
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

class RxWatchConnectivityInactiveTest: XCTestCase {
    
    class WatchConnectivityInactiveSessionMock: WCSession, RxWatchConnectivityProtocol {
        override var isReachable: Bool { false }
        override var activationState: WCSessionActivationState { .inactive }
        
        override var applicationContext: [String : Any] { ["message": "hello world"] }
        
        override func updateApplicationContext(_ applicationContext: [String : Any]) throws {
            delegate!.session?(self, didReceiveApplicationContext: applicationContext)
        }
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func testApplicationContext() {
        let session = RxWatchConnectivity(WatchConnectivityInactiveSessionMock.default)
        session.activate()
        
        session.sendMessage(["message": "hello world"])
            .subscribe()
            .disposed(by: DisposeBag())
        
        let messages = try? session.listenForMessage()
            .toBlocking(timeout: 5)
            .first()
        
        XCTAssertEqual("hello world", messages)
    }
    
    func testGetRecentApplicationContext() {
        let session = RxWatchConnectivity(WatchConnectivityInactiveSessionMock.default)
        session.activate()
        
        let message = try? session.applicationContext()
            .toBlocking()
            .first()!
        
        XCTAssertEqual("hello world", message)
    }
}
