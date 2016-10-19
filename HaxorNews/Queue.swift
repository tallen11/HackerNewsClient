//
//  Queue.swift
//  HaxorNews
//
//  Created by Tate Allen on 10/19/16.
//  Copyright © 2016 Tate Allen. All rights reserved.
//

import Foundation

// singly rather than doubly linked list implementation
// private, as users of Queue never use this directly
internal final class QueueNode<T> {
    // note, not optional – every node has a value
    var value: T
    // but the last node doesn't have a next
    var next: QueueNode<T>? = nil
    
    init(value: T) { self.value = value }
}

// Ideally, Queue would be a struct with value semantics but
// I'll leave that for now
public final class Queue<T> {
    // note, these are both optionals, to handle
    // an empty queue
    internal var head: QueueNode<T>? = nil
    internal var tail: QueueNode<T>? = nil
    
    public init() { }
}

extension Queue {
    // append is the standard name in Swift for this operation
    public func append(newElement: T) {
        let oldTail = tail
        self.tail = QueueNode(value: newElement)
        if  head == nil { head = tail }
        else { oldTail?.next = self.tail }
    }
    
    public func dequeue() -> T? {
        if let head = self.head {
            self.head = head.next
            if head.next == nil { tail = nil }
            return head.value
        }
        else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        return head == nil
    }
}
