//
//  ChannelAdminViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/13/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ChannelAdminViewController: BaseViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let vm: ChangeAdminViewModel
    
    private let topView: ModalNavigationView = ModalNavigationView(
        title: "ChangeChannelAdmin".localized()
    )
    private let userTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.register(
            ChannelAdminTableViewCell.self,
            forCellReuseIdentifier: ChannelAdminTableViewCell.identifier
        )
        view.showsVerticalScrollIndicator = false
        return view
    }()
    private let adminAlert: BuddyAlert = BuddyAlert(
        title: "",
        leftButtonTitle: "Cancel".localized(),
        rightButtonTitle: "Confirm".localized(),
        hasTwoButton: true
    )
    
    init(vm: ChangeAdminViewModel) {
        self.vm = vm
        
        super.init()
    }
    
    override func bind() {
        let input = ChangeAdminViewModel.Input(
            backBtnTapped: topView.backBtn.rx.tap.map { () },
            viewWillAppear: rx.viewWillAppear,
            selectedUser: userTableView.rx.modelSelected(UserProfile.self).map { $0 },
            cancelBtnTapped: adminAlert.leftButton.rx.tap.map { () },
            changeBtnTapped: adminAlert.rightButton.rx.tap.map { () }
        )
        let output = vm.transform(input: input)
        
        output.channelMembers
            .drive(userTableView.rx.items(
                cellIdentifier: ChannelAdminTableViewCell.identifier,
                cellType: ChannelAdminTableViewCell.self
            )) { _, value, cell in
                cell.setUserProfile(
                    profile: value.profileImage,
                    name: value.nickname,
                    email: value.email
                )
            }
            .disposed(by: disposeBag)
        
        output.alertContents
            .drive(with: self) { owner, content in
                owner.adminAlert.setTitleBody(AlertLiteral.changeChannelAdmin(userName: content))
                owner.adminAlert.setMessageBody(AlertLiteral.changeChannelAdmin(userName: content))
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .drive(with: self) { owner, showAlert in
                owner.setAdminAlertHidden(showAlert)
            }
            .disposed(by: disposeBag)
    }
    
    override func setHierarchy() {
        [topView, userTableView, adminAlert].forEach {
            view.addSubview($0)
        }
        
        adminAlert.isHidden = true
    }
    
    override func setConstraints() {
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(54)
        }
        userTableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeArea)
        }
        adminAlert.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
    }
    
    func setAdminAlertHidden(_ show: Bool) {
        adminAlert.isHidden = show ? false : true
    }
}
