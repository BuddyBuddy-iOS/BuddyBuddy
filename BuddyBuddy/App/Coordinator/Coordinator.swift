//
//  Coordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

protocol Coordinator: AnyObject {
    var parent: Coordinator? { get set }
    var childs: [Coordinator] { get set }
    var navigationController: UINavigationController { get }
    
    func start()
    func finish()
}

extension Coordinator {
    func finish() {
        childDidFinish(self)
    }
    
    func childDidFinish(_ coordinator: Coordinator) {
        if let index = childs.firstIndex(where: { $0 === coordinator }) {
            childs.remove(at: index)
        }
    }
}
