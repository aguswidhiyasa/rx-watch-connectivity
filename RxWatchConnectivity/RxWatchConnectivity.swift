//
//  RxWatchConnectivity.swift
//  RxWatchConnectivity
//
//  Created by Agus Widhiyasa on 04/06/23.
//

import Foundation
import WatchConnectivity
import RxSwift

public enum RxWatchConnectivityError: Error {
    case wrongMessageFormat
    case errorSendingMessage(String?)
    case watchSessionInavtive
}

protocol RxWatchConnectivityProtocol {
    var isReachable: Bool { get }
    var activationState: WCSessionActivationState { get }
    var isWatchAppInstalled: Bool { get }
}

public class RxWatchConnectivity: NSObject, RxWatchConnectivityProtocol {
    var watchSession: WCSession
    
    @_spi(Private) public var helloWorld = ""
    
    var isReachable: Bool { self.watchSession.isReachable }
    var activationState: WCSessionActivationState { self.watchSession.activationState }
    var isWatchAppInstalled: Bool { self.watchSession.isWatchAppInstalled }
    
    private var messageSubject = PublishSubject<String>()
    
    public init(_ session: WCSession = WCSession.default) {
        self.watchSession = session
        super.init()
        
        self.watchSession.delegate = self
    }
    
    public func applicationContext() -> Single<String> {
        return Single.just(self.parseMessage(from: self.watchSession.applicationContext))
    }
    
    public func activate() { watchSession.activate() }
    
    public func listenForMessage() -> Observable<String> {
        self.messageSubject.asObservable()
    }
    
    public func sendMessage(_ messsage: [String: Any]) -> Completable {
        Completable.create { observer in
            // Check if Apple Watch is Active
            if self.isReachable {
                self.watchSession.sendMessage(
                    messsage,
                    replyHandler: nil
//                    replyHandler: { reply in
//                        self.messageSubject.on(.next(self.parseMessage(from: reply)))
//                    }
                    )
                observer(.completed)
            } else {
                // If watch session not activated, it's mean maybe watch is turned off or somewhere!
                if self.activationState == .notActivated {
                    observer(.error(RxWatchConnectivityError.watchSessionInavtive))
                } else {
                    do {
                        try self.watchSession.updateApplicationContext(messsage)
                        observer(.completed)
                    } catch {
                        observer(.error(RxWatchConnectivityError.errorSendingMessage(error.localizedDescription)))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    internal func parseMessage(from message: [String: Any]) -> String {
        if let _message = message["message"] as? String {
            return _message
        } else {
            return ""
        }
    }
}

extension RxWatchConnectivity {
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let message = message["message"] as? String {
                self.messageSubject.on(.next(message))
            } else {
                self.messageSubject.on(.error(RxWatchConnectivityError.wrongMessageFormat))
            }
        }
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        // TODO: Reply Handler
        DispatchQueue.main.async {
            if let message = message["message"] as? String {
                self.messageSubject.on(.next(message))
            } else {
                self.messageSubject.on(.error(RxWatchConnectivityError.wrongMessageFormat))
            }
        }
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            self.messageSubject.on(.next(self.parseMessage(from: applicationContext)))
        }
    }
}

extension RxWatchConnectivity: WCSessionDelegate {
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Ready to Communicate")
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
