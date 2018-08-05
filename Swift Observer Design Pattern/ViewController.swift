//
//  ViewController.swift
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

import UIKit

// By adopting the ObservedProtocol, this view controller
// gains the capability for broadcasting notifications via
// NotificationCenter to ANY entities throughout this
// WHOLE APP whom are interested in receiving those notifications.
// Notice how little this class needs to do to gain
// notification capability?
class ViewController: UIViewController, ObservedProtocol {
    
    @IBOutlet weak var topBox: UIView!
    @IBOutlet weak var middleBox: UIView!
    @IBOutlet weak var bottomBox: UIView!
    
    // Mock up three entities whom are dependent upon a
    // critical resource: network connectivity. They need
    // to observe the status of the critical resource.
    var networkConnectionHandler0: NetworkConnectionHandler?
    var networkConnectionHandler1: NetworkConnectionHandler?
    var networkConnectionHandler2: NetworkConnectionHandler?
    
    // ObservedProtocol conformance -- two properties.
    let statusKey: StatusKey = StatusKey.networkStatusKey
    let notification: Notification.Name = .networkConnection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Here are three entities now listening for notifications
        // from the enclosing ViewController class.
        networkConnectionHandler0 = NetworkConnectionHandler(view: topBox)
        networkConnectionHandler1 = NetworkConnectionHandler(view: middleBox)
        networkConnectionHandler2 = NetworkConnectionHandler(view: bottomBox)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mock up a critical resource whose state can change.
    // I'm pretending that this ViewController is
    // responsible for network reachability/connectivity.
    // When we have a network connection, all interested
    // listeners are informed. When network access is lost,
    // all interested listeners are informed.
    @IBAction func switchChanged(_ sender: Any) {
        
        let swtich:UISwitch = sender as! UISwitch
        
        if swtich.isOn {
            notifyObservers(about: NetworkConnectionStatus.connected.rawValue)
        }
        else {
            notifyObservers(about: NetworkConnectionStatus.disconnected.rawValue)
        }
        
    } // end func switchChanged
    
} // end class ViewController

