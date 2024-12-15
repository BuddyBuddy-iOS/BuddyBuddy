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
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let nameLabel: UILabel = {
        let view = UILabel()
        view.font = .bodyBold
        view.textColor = .black
        return view
    }()
    
    override func setHierarchy() {
        [profileImgView, nameLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(profileImgView.snp.height)
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImgView.snp.centerY)
            make.leading.equalTo(profileImgView.snp.trailing).offset(16)
            make.height.equalTo(18)
            make.trailing.equalToSuperview()
        }
    }
    
    func setProfileUI(profileImg: String?, profileName: String) async {
        do {
            guard let profileImgString = profileImg else {
                profileImgView.image = UIImage(named: "BasicProfileImage")
                return
            }
            let image = try await CacheManager.shared.loadImg(urlPath: profileImgString)
        } catch {
            profileImgView.image = UIImage(named: "BasicProfileImage")
        }
        nameLabel.text = profileName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
    }
}
