//
//  ViewController.swift
//  SDispatcher
//
//  Created by Alexander on 08/02/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ISDispatcher {

    // MARK: Properties
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelField: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private let EVENT_CALL = "event_call"
    private let EVENT_CALL_NEXT = "event_call_next"
    
    private var eventCallIndex = 0
    private var eventCallNext = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /**eventCallIndex = subscribe(notifName: EVENT_CALL, callback: { notif in
         print("EVENT NAME \(notif.name) and data = \(notif.data ?? "")")
         self.textField.text = notif.data as? String ?? "THERE IS NO DATA IN NOTIF"
         })**/
        
        SDispatcher.subscribe(notifName: EVENT_CALL) { notif in
            print("ANOTHER STATIC SDISPATCHER HANDLER \(notif.data)")
        }
        
        eventCallIndex = subscribe(notifName: EVENT_CALL, callback:eventHandler)
        eventCallNext = subscribe(notifName: EVENT_CALL_NEXT) { notif in
            //print("NEXT EVENT \(notif.name) and data = \(String(describing: notif.data ?? "" ))")
            self.labelField.text = notif.data as? String ?? "THERE IS NO DATA IN NOTIFICATION"
            self.unsubscribe(notifName: notif.name)
        }
    }
    
    func eventHandler(notif:Notification<Any?>) {
        print("EVENT NAME \(notif.name) and data = \(String(describing: notif.data ?? "" ))")
        self.textField.text = notif.data as? String ?? "THERE IS NO DATA IN NOTIF"
        let randomString = NSUUID().uuidString
        call(notifName: EVENT_CALL_NEXT, data: randomString)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    
    @IBAction func onButtonClicked(_ sender: UIButton) {
        let randomString = NSUUID().uuidString
        call(notifName: EVENT_CALL, data: randomString)
    }

}

