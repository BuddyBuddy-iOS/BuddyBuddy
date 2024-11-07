//
//  AuthViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

import RxSwift

final class AuthViewController: BaseNavigationViewController {
    private let disposeBag: DisposeBag = DisposeBag()

    private let vm: AuthViewModel
    
    init(vm: AuthViewModel) {
        self.vm = vm
        
    }
}
