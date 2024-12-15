//
//  ChannelAdminTableViewCell.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/13/24.
//

import UIKit

import SnapKit

final class ChannelAdminTableViewCell: BaseTableViewCell {
    private let profileImgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let profileNameLabel: UILabel = {
        let view = UILabel()
        view.font = .bodyBold
        view.textColor = .black
        view.textAlignment = .left
        return view
    }()
    private let emailLabel: UILabel = {
        let view = UILabel()
        view.font = .body
        view.textColor = .gray1
        view.textAlignment = .left
        return view
    }()
    private let labelContainerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.spacing = 0
        view.alignment = .leading
        return view
    }()
    
    override func setHierarchy() {
        [profileImgView, labelContainerView].forEach {
            contentView.addSubview($0)
        }
        [profileNameLabel, emailLabel].forEach {
            labelContainerView.addArrangedSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(40)
        }
        labelContainerView.snp.makeConstraints { make in
            make.leading.equalTo(profileImgView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(12)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImgView.layer.cornerRadius = profileImgView.bounds.width / 2
    }
    
    func setUserProfile(
        profile: String?,
        name: String,
        email: String
    ) {
        profileNameLabel.text = name
        emailLabel.text = email
        
        guard let imgString = profile else {
            return
        }
        
        Task {
            let image = try await CacheManager.shared.loadImg(urlPath: imgString)
            profileImgView.image = image
        }
    }
}
