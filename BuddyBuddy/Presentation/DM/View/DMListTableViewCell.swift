//
//  DMListTableViewCell.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/11/24.
//

import UIKit

import SnapKit

final class DMListTableViewCell: BaseTableViewCell {
    private let profileImage: ProfileImageView = {
        let view = ProfileImageView()
        view.layer.cornerRadius = 25
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
    private let unreadCount: MessageCountView = {
        let view = MessageCountView(count: 10)
        return view
    }()
    
    override func setHierarchy() {
        [profileImage, userName, lastText, lastTime, unreadCount].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(50)
        }
        userName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.top).offset(4)
            make.leading.equalTo(profileImage.snp.trailing).offset(16)
        }
        lastText.snp.makeConstraints { make in
            make.bottom.equalTo(profileImage.snp.bottom).inset(4)
            make.leading.equalTo(profileImage.snp.trailing).offset(16)
            make.trailing.equalTo(unreadCount.snp.leading).offset(-16)
        }
        lastTime.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.top).offset(4)
            make.trailing.equalToSuperview().inset(16)
        }
        unreadCount.snp.makeConstraints { make in
            make.top.equalTo(lastTime.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    func designCell(_ transition: DMListInfo) {
        profileImage.updateURL(url: transition.profileImg)
        userName.text = transition.userName
        lastText.text = transition.lastText
        
        let defaultDate = transition.lastTime.toDate(format: .defaultDate)
        lastTime.text = defaultDate?.isToday() ?? true ? 
        defaultDate?.toString(format: .HourMinute) : defaultDate?.toString(format: .yearMonthDay)
        
        print(transition.unReadCount, "🤪")
        if transition.unReadCount > 0 {
            unreadCount.isHidden = false
            unreadCount.updateCount(transition.unReadCount)
        } else {
            unreadCount.isHidden = true
        }
    }
}
