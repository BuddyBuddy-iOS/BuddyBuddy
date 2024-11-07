//
//  SettingViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

import RxSwift

final class SettingViewController: BaseNavigationViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let vm: SettingViewModel
    
    init(vm: SettingViewModel) {
        self.vm = vm
    }
}
