//
//  RxWatchConnectivityTests.swift
//  RxWatchConnectivityTests
//
//  Created by Agus Widhiyasa on 04/06/23.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import WatchConnectivity
@testable import RxWatchConnectivity

final class RxWatchConnectivityTests: XCTestCase {
    
    class WatchConnectivitySessionMock: WCSession, RxWatchConnectivityProtocol {
        override var isReachable: Bool { true }
        override var activationState: WCSessionActivationState { .activated }
        
        override func activate() {
            delegate!.session(self, activationDidCompleteWith: .activated, error: nil)
        }
        
        override func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)? = nil) {
            if let replyHandler {
                fatalError("Need to implement with reply handler")
//                delegate!.session?(self, didReceiveMessage: message, replyHandler: <#T##([String : Any]) -> Void#>)
//                replyHandler(["message": "replied message"])
            } else {
                delegate!.session!(self, didReceiveMessage: message)
            }
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

    func testListeningMessage() {
        let session = RxWatchConnectivity(WatchConnectivitySessionMock.default)
        session.activate()
        
        session.sendMessage(["message": "hello world"])
            .subscribe()
            .disposed(by: DisposeBag())
        
        let messages = try? session.listenForMessage()
            .toBlocking(timeout: 5)
            .first()
        
        XCTAssertEqual("hello world", messages)
    }
    
    func testSendMessage() throws {
        let session = RxWatchConnectivity(WatchConnectivitySessionMock.default)
        session.activate()
        let sendMessage = session.sendMessage(["message": "hello world"]).toBlocking().materialize()
        
        guard case .completed(_) = sendMessage else {
            XCTFail("Fail to send message")
            return
        }
        
        XCTAssert(true)
    }
    
    func testMessageWithReplyHandler() {
//        let session = RxWatchConnectivity(WatchConnectivitySessionMock.default)
//        session.activate()
//        
//        session.sendMessage(["message": "hello world"])
//            .subscribe()
//            .disposed(by: DisposeBag())
//        
//        let messages = try? session.listenForMessage()
//            .toBlocking(timeout: 5)
//            .toArray()
//        
//        XCTAssertEqual(["hello world", "replied message"], messages)
    }
}
