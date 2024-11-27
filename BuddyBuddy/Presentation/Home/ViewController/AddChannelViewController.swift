//
//  AddChannelViewController.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/27/24.
//

import UIKit

import SnapKit

final class AddChannelViewController: BaseViewController {
    private let navigationView: ModalNavigationView
    = ModalNavigationView(title: "CreateChannel".localized())
    private let channelNameTextField: TitledTextField = TitledTextField(
        title: "ChannelName".localized(),
        placeholder: "ChannelNamePlaceholder".localized()
    )
    private let channelContentTextField: TitledTextField = TitledTextField(
        title: "ChannelContent".localized(),
        placeholder: "ChannelContentPlaceholder".localized()
    )
    
    override func setView() {
        super.setView()
        
        view.backgroundColor = .gray3
    }
    
    override func setHierarchy() {
        [navigationView, channelNameTextField, channelContentTextField].forEach {
            view.addSubview($0)
        }
    }
    
    override func setConstraints() {
        navigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(44)
        }
        channelNameTextField.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(76)
        }
        channelContentTextField.snp.makeConstraints { make in
            make.top.equalTo(channelNameTextField.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(76)
        }
    }
}
