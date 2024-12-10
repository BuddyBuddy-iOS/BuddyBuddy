//
//  ChannelTextImageTableViewCell.swift
//  BuddyBuddy
//
//  Created by 김성률 on 12/3/24.
//

import UIKit

import SnapKit

final class ChannelTextImageTableViewCell: BaseTableViewCell {
    private let profileImage: ProfileImageView = {
        let view = ProfileImageView()
        view.layer.cornerRadius = 10
        return view
    }()
    private let userName: UILabel = {
        let view = UILabel()
        view.font = .body
        return view
    }()
    private let speechBubble: SpeechBubbleView = {
        let view = SpeechBubbleView(text: "")
        return view
    }()
    private let pickerImageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    private let topImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private let middleImageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        view.distribution = .fillEqually
        return view
    }()
    private let bottomImageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        view.distribution = .fillEqually
        return view
    }()
    private let chatTime: UILabel = {
        let view = UILabel()
        view.textColor = .gray1
        view.font = .caption
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    private let firstImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        return view
    }()
    private let secondImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .orange
        return view
    }()
    private let thirdImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .yellow
        return view
    }()
    private let fourthImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .green
        return view
    }()
    private let fifthImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .blue
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [firstImage, secondImage, thirdImage, fourthImage, fifthImage].forEach {
            $0.image = nil
        }
        speechBubble.content.text = nil
        topImageView.image = nil
        
        resetStackView(stackView: middleImageStackView)
        resetStackView(stackView: bottomImageStackView)
        
        [topImageView, middleImageStackView, bottomImageStackView].forEach {
            $0.isHidden = false
        }
        contentView.layoutIfNeeded()
    }
    
    override func setHierarchy() {
        [profileImage, userName, speechBubble, pickerImageStackView, chatTime].forEach {
            contentView.addSubview($0)
        }
        [topImageView, middleImageStackView, bottomImageStackView].forEach {
            pickerImageStackView.addArrangedSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(40)
        }
        userName.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.top)
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.height.equalTo(15)
        }
        speechBubble.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(92)
        }
        chatTime.snp.makeConstraints { make in
            make.centerY.equalTo(userName)
            make.leading.equalTo(userName.snp.trailing).offset(16)
        }
        pickerImageStackView.snp.makeConstraints { make in
            make.top.equalTo(speechBubble.snp.bottom).offset(4)
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(92)
            make.bottom.equalToSuperview().inset(8)
        }
        topImageView.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        middleImageStackView.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
        bottomImageStackView.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
    }
    
    func designCell(_ transition: ChannelHistory) {
        userName.text = transition.user.nickname
        chatTime.text = transition.createdAt
            .toDate(format: .defaultDate)?
            .toString(format: .HourMinute)
        
        speechBubble.updateText(transition.content)
        profileImage.updateURL(url: transition.user.profileImage ?? "")
        
        imageType(dataArray: transition.files)
    }
    
    private func imageType(dataArray: [Data]) {
        switch dataArray.count {
        case 1:
            let imageViews: [UIImageView] = [topImageView]
            for (imageView, data) in zip(imageViews, dataArray) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
            middleImageStackView.isHidden = true
            bottomImageStackView.isHidden = true
        case 2:
            [firstImage, secondImage].forEach {
                middleImageStackView.addArrangedSubview($0)
            }
            topImageView.isHidden = true
            bottomImageStackView.isHidden = true
            
            let imageViews: [UIImageView] = [firstImage, secondImage]
            for (imageView, data) in zip(imageViews, dataArray) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
        case 3:
            [firstImage, secondImage, thirdImage].forEach {
                middleImageStackView.addArrangedSubview($0)
            }
            topImageView.isHidden = true
            bottomImageStackView.isHidden = true
            
            let imageViews: [UIImageView] = [firstImage, secondImage, thirdImage]
            for (imageView, data) in zip(imageViews, dataArray) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
        case 4:
            [firstImage, secondImage].forEach {
                middleImageStackView.addArrangedSubview($0)
            }
            [thirdImage, fourthImage].forEach {
                bottomImageStackView.addArrangedSubview($0)
            }
            topImageView.isHidden = true
            
            let imageViews: [UIImageView] = [firstImage, secondImage, thirdImage, fourthImage]
            for (imageView, data) in zip(imageViews, dataArray) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
        case 5:
            [firstImage, secondImage].forEach {
                middleImageStackView.addArrangedSubview($0)
            }
            [thirdImage, fourthImage, fifthImage].forEach {
                bottomImageStackView.addArrangedSubview($0)
            }
            topImageView.isHidden = true
            
            let imageViews: [UIImageView] = [firstImage, secondImage, thirdImage, fourthImage, fifthImage]
            for (imageView, data) in zip(imageViews, dataArray) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
        default: break
            
        }
    }
}

extension ChannelTextImageTableViewCell {
    private func resetStackView(stackView: UIStackView) {
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}
