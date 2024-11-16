//
//  DMListTableViewCell.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/11/24.
//

import UIKit

import SnapKit

final class DMListTableViewCell: BaseTableViewCell {
    private let profileImg: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 25
        view.backgroundColor = .lightGray
        return view
    }()
    private let userName: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        return view
    }()
    private let lastText: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    private let lastTime: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    private let unreadCount: UIView = {
        let view = MessageCountView(count: 10)
        return view
    }()
    
    override func setHierarchy() {
        [profileImg, userName, lastText, lastTime, unreadCount].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImg.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(50)
        }
        userName.snp.makeConstraints { make in
            make.top.equalTo(profileImg.snp.top).offset(4)
            make.leading.equalTo(profileImg.snp.trailing).offset(16)
        }
        lastText.snp.makeConstraints { make in
            make.bottom.equalTo(profileImg.snp.bottom).inset(4)
            make.leading.equalTo(profileImg.snp.trailing).offset(16)
        }
        lastTime.snp.makeConstraints { make in
            make.top.equalTo(profileImg.snp.top).offset(4)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        unreadCount.snp.makeConstraints { make in
            make.centerY.equalTo(lastText)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
    }
    
    func designCell(_ transition: DMList) {
        profileImg.image = UIImage(systemName: "star")
        userName.text = transition.user.nickname
        lastText.text = "저희 수료식 언제?"
        lastTime.text = "pm 06:33"
    }
    
}
