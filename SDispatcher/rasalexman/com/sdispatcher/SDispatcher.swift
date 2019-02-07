//
//  SDispatcher.swift
//  SDispatcher
//
//  Created by Alexander Minkin on 30/01/2019.
//  Copyright © 2019 Alexander Minkin. All rights reserved.
//
import Foundation

/**
 * Simple data handler class
 */
struct Notification<T : Any> {
    let name:String
    var data:T? = nil
}

typealias Subscriber<T : Any> = (Notification<T?>) -> ()

protocol ISDispatcher {}

protocol IDispatcher {
    var subscribers: [String : [Subscriber<Any>]] {get set}
    var queue: DispatchQueue {get}
}

extension IDispatcher {
    
    /**
     * Add event handler to given notification name
     *
     * @param notifName
     * Event name to subscribe
     *
     * @param sub
     * Event handler function (Notification) -> Void
     */
    mutating func subscribe(notifName:String, callback:@escaping Subscriber<Any>) -> Int {
        queue.sync {
            subscribers[notifName]?.append(callback) ?? (subscribers[notifName] = [callback])
        }
        return subscribers[notifName]!.count - 1
    }
    
    /**
     * Unsubscribe all listeners by notification name
     *
     * @param notifName
     * Event name for remove all notification
     */
    mutating func unsubscribe(notifName:String) {
        queue.sync {
            subscribers[notifName]?.removeAll()
            subscribers.removeValue(forKey: notifName)
        }
    }
    
    mutating func unsubscribeFromIndex(notifName:String, index:Int = -1) {
        if var subscribersList = subscribers[notifName] {
            if index >= 0  {
                _ = subscribersList.remove(at: index)
            }
        }
    }
    
    mutating func hasSubscribers(notifName:String) -> Bool {
        var has: Bool = false
        queue.sync {
            has = ((subscribers[notifName]?.count ?? 0) > 0)
        }
        return has
    }
    
    /**
     * Call notification listeners by given `notif` name and data
     *
     * @param notifName
     * Event name for call all notification listeners
     *
     * @param data
     * Notification data
     */
    func call(notifName:String, data:Any? = nil) {
        queue.sync {
            let subs = self.subscribers[notifName]
            if subs != nil && subs!.count > 0 {
                var notification:Notification<Any?> = Notification(name: notifName, data: data)
                subs?.forEach({ callback in
                    callback(notification)
                })
                notification.data = nil
            }
        }
    }
}

extension ISDispatcher {
    func subscribe(notifName:String, callback:@escaping Subscriber<Any>) -> Int {
        return SDispatcher.subscribe(notifName: notifName, callback: callback)
    }
    func unsubscribe(notifName: String) {
        SDispatcher.unsubscribe(notifName: notifName)
    }
    func call(notifName: String, data: Any? = nil) {
        SDispatcher.call(notifName: notifName, data: data)
    }
}


final class SDispatcher : IDispatcher {
    // Concurrent synchronization queue
    internal let queue: DispatchQueue = DispatchQueue(label: "ThreadSafeCollection.queue", attributes: .concurrent)
    
    private static var instance:IDispatcher = SDispatcher()
    
    lazy var subscribers: [String : [Subscriber<Any>]] = [String : [Subscriber<Any>]]()
    
    private init() {}
    
    private static func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    static func subscribe(notifName: String, callback: @escaping Subscriber<Any>) -> Int {
        return instance.subscribe(notifName: notifName, callback: callback)
    }
    
    static func unsubscribe(notifName: String) {
        instance.unsubscribe(notifName: notifName)
    }
    
    static func call(notifName: String, data: Any? = nil) {
        synced(instance) {
            instance.call(notifName: notifName, data: data)
        }
    }
}
