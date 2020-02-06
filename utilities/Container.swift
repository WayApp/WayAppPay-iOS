//
//  Container.swift
//  WayAppPay
//
//  Created by Oscar Anzola on 2/1/20.
//  Copyright © 2020 WayApp. All rights reserved.
//

import Foundation

protocol ContainerProtocol: Codable {
    var containerID: String { get }
}

struct Container<T: ContainerProtocol>: Sequence, IteratorProtocol, Codable, RandomAccessCollection {
        
    private static var url: URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    }
    
    private var elements = ContiguousArray<T>()
    private var persistanceName: String?
    
    var startIndex: Int {
        return elements.startIndex
    }
    
    var endIndex: Int {
        return elements.endIndex
    }

    var count: Int {
        return elements.count
    }
    
    var all: ContiguousArray<T> {
        return elements
    }
    
    var isEmpty: Bool {
        return elements.isEmpty
    }
    
    private var times = 0
    mutating func next() -> T? {
        if times == count {
            return nil
        } else {
            defer { times += 1 }
            return elements[times]
        }
    }
    
    subscript(index: Int) -> T {
        get {
            return elements[index]
        }
        set {
            elements[index] = newValue
        }
    }
    
    mutating func add(_ element: T) {
        elements.append(element)
    }

    mutating func sort(by: (T, T) -> Bool) {
        elements.sort(by: by)
    }

    mutating func add(_ elements: [T]) {
        self.elements += elements
    }
    
    mutating func addInOrder(_ element: T, by: (T, T) -> Bool) {
        if let index = elements.firstIndex(where: {by($0, element) }) {
            elements.insert(element, at: index)
        } else {
            elements.append(element)
        }
    }

    mutating func setTo(_ elements: [T]) {
        self.elements = ContiguousArray(elements)
    }

    mutating func setToInOrder(_ elements: [T], by: (T, T) -> Bool) {
        self.elements = ContiguousArray(elements.sorted(by: by))
    }

    mutating func setTo(_ elements: Container<T>) {
        self.elements = ContiguousArray(elements)
    }
    
    mutating func remove(_ element: T) {
        if let index = elements.firstIndex(where: { $0.containerID == element.containerID })  {
            self.elements.remove(at: index)
        }
    }

    mutating func remove(_ elements: [T]) {
        for element in elements {
            if let index = self.elements.firstIndex(where: { $0.containerID == element.containerID })  {
                self.elements.remove(at: index)
            }
        }
    }
    
    mutating func remove(at offsets: IndexSet) {
        for offset in offsets {
            self.elements.remove(at: offset)
        }
    }
    
    mutating func remove(at: Int) {
        self.elements.remove(at: at)
    }
    
    func contains(_ element: T) -> Bool {
        if elements.firstIndex(where: { $0.containerID == element.containerID }) != nil {
            return true
        }
        return false
    }

    func index(for element: T) -> Int? {
        if let index = elements.firstIndex(where: { $0.containerID == element.containerID }) {
            return index
        }
        return nil
    }

    func index(forID id: String) -> Int? {
        if let index = elements.firstIndex(where: { $0.containerID == id }) {
            return index
        }
        return nil
    }

    func indices(satisfying condition: (T) -> Bool) -> [Int] {
        let indices = elements.indices.filter({
            let element = elements[$0]
            return condition(element)
        })
        return indices
    }
    
    func filter(satisfying condition: (T) -> Bool) -> [T] {
        return elements.filter({
            return condition($0)
        })
    }

    subscript(index: String) -> T? {
        get {
            return elements.filter( { $0.containerID == index } ).first
        }
        set {
            if let index = elements.firstIndex(where: { $0.containerID == index }),
                let element = newValue {
                elements[index] = element
            }
        }
    }
    
    mutating func empty() {
        elements.removeAll()
    }
    
    mutating func reset() throws {
        empty()
        if let name = persistanceName {
            do {
                try FileManager.default.removeItem(at: Container.url.appendingPathComponent(name))
            } catch {
                WayAppUtils.Log.message("Container: \(#function): \(error.localizedDescription)")
            }
        }
    }
    
    mutating func persist(name: String) throws {
        do {
            let data = try JSONEncoder().encode(elements)
            try data.write(to: Container.url.appendingPathComponent(name))
            persistanceName = name
        } catch {
            throw error
        }
    }
}

extension Container {
    init(fromFile name: String) {
        var elements = ContiguousArray<T>()
        do {
            if let data = try? Data(contentsOf: Container.url.appendingPathComponent(name)) {
                elements = try JSONDecoder().decode(ContiguousArray<T>.self, from: data)
                self.persistanceName = name
            }
        } catch {
            WayAppUtils.Log.message("Container: \(#function): \(error.localizedDescription)")
        }
        self.elements = elements
    }
}

