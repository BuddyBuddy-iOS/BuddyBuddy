//
//  ChannelSettingViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/13/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ChannelSettingViewController: BaseViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let vm: ChannelSettingViewModel
    
    private let settingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return view
    }()
    private let topView = ChannelSettingTopView()
    private let middleView = ChannelSettingMiddleView()
    private let bottomView = ChannelSettingBottomView()
    private let tapGesture = PublishRelay<Void>()
    private let exitAlert = BuddyAlert(
        title: "ExitChannel".localized(),
        leftButtonTitle: "Cancel".localized(),
        rightButtonTitle: "Exit".localized(),
        hasTwoButton: true
    )
    
    init(vm: ChannelSettingViewModel) {
        self.vm = vm
        
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func bind() {
        let input = ChannelSettingViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            blindViewTapped: tapGesture.map { () },
            exitBtnTapped: bottomView.exitBtn.rx.tap.map { () },
            changeAdminBtnTapped: bottomView.adminBtn.rx.tap.map { () },
            cancelBtnTapped: exitAlert.leftButton.rx.tap.map { () },
            exitAlertBtnTapped: exitAlert.rightButton.rx.tap.map { () }
        )
        let output = vm.transform(input: input)
        
        output.channelInfo
            .drive(with: self) { owner, value in
                let name = value.0
                let description = value.1
                owner.topView.setChannelInfo(
                    name: name,
                    intro: description ?? ""
                )
            }
            .disposed(by: disposeBag)
        
        output.channelMembers
            .drive(with: self) { owner, members in
                owner.middleView.setMemberCount(count: members.count)
            }
            .disposed(by: disposeBag)
        
        output.channelMembers
            .drive(middleView.memberTableView.rx.items(
                cellIdentifier: ChannelSettingCell.identifier,
                cellType: ChannelSettingCell.self
            )) { _, data, cell in
                cell.setProfileUI(
                    profileImg: data.profileImage,
                    profileName: data.nickname
                )
            }
            .disposed(by: disposeBag)
        
        output.showChangeAdminBtn
            .drive(with: self) { owner, isAdmin in
                owner.bottomView.showAdminBtn(isAdmin)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .drive(with: self) { owner, showAlert in
                owner.setExitAlertHidden(showAlert)
            }
            .disposed(by: disposeBag)
        
        output.alertInfo
            .drive(with: self) { owner, info in
                owner.exitAlert.setMessageBody(info)
            }
            .disposed(by: disposeBag)
    }
    
    override func setHierarchy() {
        [settingContainerView, exitAlert].forEach {
            view.addSubview($0)
        }
        [topView, middleView, bottomView].forEach {
            settingContainerView.addSubview($0)
        }
        
        exitAlert.isHidden = true
    }
    
    override func setConstraints() {
        settingContainerView.snp.makeConstraints { make in
            make.top.equalTo(safeArea)
            make.bottom.trailing.equalToSuperview()
            make.width.equalTo(safeArea.snp.width)
        }
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalTo(settingContainerView)
        }
        bottomView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(settingContainerView)
            make.height.equalTo(70)
        }
        middleView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.horizontalEdges.equalTo(settingContainerView)
            make.bottom.equalTo(bottomView.snp.top)
        }
        exitAlert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setView() {
        super.setView()
        
        view.backgroundColor = .clear
    }
    
    private func setExitAlertHidden(_ show: Bool) {
        exitAlert.isHidden = show ? false : true
    }
}

extension ChannelSettingViewController: SideMenuHandler {
    @objc func dismissNotification() {
        tapGesture.accept(())
    }
}
