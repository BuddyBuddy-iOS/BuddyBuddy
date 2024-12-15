//
//  SearchUserTableViewCell.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 12/6/24.
//

import UIKit

import SnapKit

final class SearchUserTableViewCell: BaseTableViewCell {
    private let profileImage: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    private let userName: UILabel = {
        let view = UILabel()
        view.font = .title2
        view.textColor = .black
        view.textAlignment = .left
        return view
    }()
    private let myLanguage: LanguageLabel = LanguageLabel(languageState: .mine)
    private let changeImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "twowayArrow")?.withTintColor(
            .gray1,
            renderingMode: .alwaysOriginal
        )
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let exchangeLanguage: LanguageLabel = LanguageLabel(languageState: .other)
    
    override func setHierarchy() { 
        [profileImage, userName, myLanguage,
         changeImage, exchangeLanguage].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(profileImage.snp.height)
        }
        userName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.top)
            make.leading.equalTo(profileImage.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalTo(profileImage.snp.centerY)
        }
        myLanguage.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.centerY)
            make.leading.equalTo(userName)
            make.bottom.equalTo(profileImage.snp.bottom).inset(4)
        }
        changeImage.snp.makeConstraints { make in
            make.centerY.equalTo(myLanguage)
            make.leading.equalTo(myLanguage.snp.trailing).offset(8)
            make.width.height.equalTo(20)
        }
        exchangeLanguage.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.centerY)
            make.leading.equalTo(changeImage.snp.trailing).offset(8)
            make.bottom.equalTo(profileImage.snp.bottom).inset(4)
        }
    }
    
    func setupUI(
        nickname: String,
        profile: String?
    ) async {
        do {
            guard let profileString = profile else {
                profileImage.image = UIImage(named: "BasicProfileImage")
                return
            }
            let image = try await CacheManager.shared.loadImg(urlPath: profileString)
            profileImage.image = image
        } catch {
            profileImage.image = UIImage(named: "BasicProfileImage")
        }
        
        userName.text = nickname
        myLanguage.setupLanguages(language: Country.allCases.randomElement() ?? .us)
        exchangeLanguage.setupLanguages(language: Country.allCases.randomElement() ?? .kr)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
    }
}
