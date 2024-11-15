//
//  ChannelSettingCell.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/13/24.
//

import UIKit

import SnapKit

final class ChannelSettingCell: BaseTableViewCell {
    private let profileImgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = .bodyBold
        view.textColor = .black
        return view
    }()
    
    override func setHierarchy() {
        [profileImgView, nameLabel]
            .forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        profileImgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(8)
            make.width.equalTo(profileImgView.snp.height)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImgView.snp.centerY)
            make.leading.equalTo(profileImgView.snp.trailing).offset(16)
            make.height.equalTo(18)
            make.trailing.equalToSuperview()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
        }
    }
    
    func setProfileUI(profileImg: UIImage, profileName: String) {
        // TODO: 프로필 이미지 없을 때 처리 필요
        profileImgView.image = profileImg
        nameLabel.text = profileName
    }
}