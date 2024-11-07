//
//  SearchViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

import RxSwift

final class SearchViewController: BaseNavigationViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let vm: SearchViewModel
    
    init(vm: SearchViewModel) {
        self.vm = vm
    }
}
