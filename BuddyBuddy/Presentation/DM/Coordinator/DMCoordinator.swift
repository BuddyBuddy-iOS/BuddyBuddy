//
//  DMCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

protocol DMCoordinator: Coordinator {
    func toDMChatting(_ dmListInfo: DMListInfo)
}
