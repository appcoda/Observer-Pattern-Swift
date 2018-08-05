//
//  Observable.swift
//  Swift Observer Design Pattern
//
//  Created by Andrew L. Jaffee on 7/26/18.
//
/*
 
 Copyright (c) 2017-2018 Andrew L. Jaffee, microIT Infrastructure, LLC, and
 iosbrain.com.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

import Foundation

import UIKit

// Make out notification names consistent and avoid stringly-typing.
// Try to use constants instead of strings or numbers.
extension Notification.Name {
    
    static let networkConnection = Notification.Name("networkConnection")
    static let batteryStatus = Notification.Name("batteryStatus")
    static let locationChange = Notification.Name("locationChange")

}

// Various network connection states -- made consistent.
enum NetworkConnectionStatus: String {
    
    case connected
    case disconnected
    case connecting
    case disconnecting
    case error
    
}

// The key to the notification's "userInfo" dictionary.
enum StatusKey: String {
    case networkStatusKey
}

// This protocol forms the basic design for OBSERVERS,
// entities whose operation CRTICIALLY depends
// on the status of some other, usually single, entity.
// Adopters of this protocol SUBSCRIBE to and RECEIVE
// notifications about that critical entity/resource.
protocol ObserverProtocol {
    
    var statusValue: String { get set }
    var statusKey: String { get }
    var notificationOfInterest: Notification.Name { get }
    func subscribe()
    func unsubscribe()
    func handleNotification()
    
}

// This template class abstracts out all the details
// necessary for an entity to SUBSCRIBE to and RECEIVE
// notifications about a critical entity/resource.
// It provides a "hook" (handleNotification()) in which
// subclasses of this base class can pretty much do whatever
// they need to do when specific notifications are received.
// This is basically an "abstract" class, not detectable
// at compile time, but I felt this was an exceptional case.
class Observer: ObserverProtocol {
    
    // This specific state reported by "notificationOfInterest."
    // I use String for maximum portability. Yeah, yeah...
    // stringly-typed...
    var statusValue: String
    // The key to the notification's "userInfo" dictionary, with
    // which we can read the specific state and store in "statusValue."
    // I use String for maximum portability. Yeah, yeah...
    // stringly-typed...
    let statusKey: String
    // The name of the notification this class has registered
    // to receive whenever messages are broadcast.
    let notificationOfInterest: Notification.Name
    
    // Initializer which registers/subscribes/listens for a specific
    // notification and then watches for a specific state as reported
    // by notifications when received.
    init(statusKey: StatusKey, notification: Notification.Name) {
        
        self.statusValue = "N/A"
        self.statusKey = statusKey.rawValue
        self.notificationOfInterest = notification
        
        subscribe()
    }
    
    // We're registering self (this) with NotificationCenter to receive
    // all notifications with the name stored in "notificationOfInterest."
    // Whenever one of those notifications is received, the
    // "receiveNotification(_:)" method is called.
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotification(_:)), name: notificationOfInterest, object: nil)
    }
    
    // It's a good idea to un-register from notifications when we no
    // longer need to listen, but this is more of a historic curiosity
    // as, since iOS 9.0, the OS does some type of cleanup.
    func unsubscribe() {
        NotificationCenter.default.removeObserver(self, name: notificationOfInterest, object: nil)
    }
    
    // Called whenever a message labelled "notificationOfInterest"
    // is received. This is our chance to do something when the
    // state of that critical resource we're observing changes.
    // This method "must have one and only one argument (an instance
    // of NSNotification)."
    @objc func receiveNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo, let status = userInfo[statusKey] as? String {
            
            statusValue = status
            handleNotification()
            
            print("Notification \(notification.name) received; status: \(status)")
            
        }
        
    } // end func receiveNotification
    
    // YOU MUST OVERRIDE THIS METHOD; YOU MUST SUBCLASS THIS CLASS.
    // I've MacGyvered this class into being "abstract" so you
    // can subclass and specialize as much as you want and not
    // have to worry about NotificationCenter details.
    func handleNotification() {
        fatalError("ERROR: You must override the [handleNotification] method.")
    }
    
    // Be kind and stop tapping a resource (NotificationCenter)
    // when we don't need to anymore.
    deinit {
        print("Observer unsubscribing from notifications.")
        unsubscribe()
    }
    
} // end class Observer

// An example of an observer, usually one of several
// (many?) that are all listening for notifications
// from some usually single critical resource. Notice that
// it's brief and can serve as a model for creating
// handlers for all sorts of notifications.
class NetworkConnectionHandler: Observer {
    
    var view: UIView
    
    // As long as you call "super.init" with valid
    // NotificationCenter-compatible values, you can
    // create whatever type of initializer you want.
    init(view: UIView) {
        
        self.view = view
        
        super.init(statusKey: .networkStatusKey, notification: .networkConnection)
    }
    
    // YOU MUST OVERRIDE THIS METHOD, but that
    // gives you the chance to handle notifications
    // in whatever way you deem fit.
    override func handleNotification() {
        
        if statusValue == NetworkConnectionStatus.connected.rawValue {
            view.backgroundColor = UIColor.green
        }
        else {
            view.backgroundColor = UIColor.red
        }
        
    } // end func handleNotification()
    
} // end class NetworkConnectionHandler

// An template for a subject, usually a single
// critical resource, that broadcasts notifications
// about a change in its state to many
// subscribers that depend on that resource.
protocol ObservedProtocol {
    var statusKey: StatusKey { get }
    var notification: Notification.Name { get }
    func notifyObservers(about changeTo: String) -> Void
}

// When an adopter of this ObservedProtocol
// changes status, it notifies ALL subsribed
// observers. It BROADCASTS to ALL SUBSCRIBERS.
extension ObservedProtocol {

    func notifyObservers(about changeTo: String) -> Void {
       NotificationCenter.default.post(name: notification, object: self, userInfo: [statusKey.rawValue : changeTo])
    }
    
} // end extension ObservedProtocol
