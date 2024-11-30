//
//  ImageTableViewCell.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/28/24.
//

import UIKit

import SnapKit

final class DMImageTableViewCell: BaseTableViewCell {
    private let profileImage: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        return view
    }()
    private let userName: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    private let pickerImageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fillEqually
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
        view.font = .systemFont(ofSize: 12)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    private let firstImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private let secondImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private let thirdImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private let fourthImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private let fifthImage: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [firstImage, secondImage, thirdImage, fourthImage, fifthImage].forEach {
            $0.image = nil
        }
        topImageView.image = nil
        resetStackView(stackView: middleImageStackView)
        resetStackView(stackView: bottomImageStackView)
    }
    
    override func setHierarchy() {
        [profileImage, userName, pickerImageStackView, chatTime].forEach {
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
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(15)
        }
        pickerImageStackView.snp.makeConstraints { make in
            make.top.equalTo(userName.snp.bottom).offset(8)
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
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
        chatTime.snp.makeConstraints { make in
            make.leading.equalTo(pickerImageStackView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func designCell(_ transition: DMHistory) {
        profileImage.backgroundColor = .lightGray
        userName.text = transition.user.nickname
        chatTime.text = "11:55 오전"
        
        pickerImageStackView.backgroundColor = .gray
        
        imageType(dataArray: transition.files)
    }
    
    private func imageType(dataArray: [Data]) {
        switch dataArray.count {
        case 1:
            middleImageStackView.isHidden = true
            bottomImageStackView.isHidden = true
            
            let imageViews: [UIImageView] = [topImageView]
            for (imageView, data) in zip(imageViews, dataArray) {
                if let image = UIImage(data: data) {
                    imageView.image = image
                }
            }
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

extension DMImageTableViewCell {
    private func resetStackView(stackView: UIStackView) {
        for subview in stackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
    }
}
