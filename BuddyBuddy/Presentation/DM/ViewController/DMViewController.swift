//
//  DMViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

import RxSwift

final class DMViewController: BaseNavigationViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let vm: DMViewModel
    
    init(vm: DMViewModel) {
        self.vm = vm
    }
}