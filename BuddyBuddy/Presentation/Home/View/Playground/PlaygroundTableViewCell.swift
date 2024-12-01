//
//  PlaygroundTableViewCell.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/1/24.
//

import UIKit

import SnapKit

final class PlaygroundTableViewCell: BaseTableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    private let corverImgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    private let titleLable: UILabel = {
        let view = UILabel()
        view.font = .bodyBold
        view.textColor = .black
        return view
    }()
    private let dateLabel: UILabel = {
        let view = UILabel()
        view.font = .body
        view.textColor = .gray1
        return view
    }()
    private let moreButton: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.image = UIImage(systemName: "ellipsis")
        view.configuration = config
        return view
    }()
    
    override func setHierarchy() {
        contentView.addSubview(containerView)
        
        [corverImgView, titleLable, dateLabel, moreButton].forEach {
            containerView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        containerView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(6)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        corverImgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(44)
        }
        titleLable.snp.makeConstraints { make in
            make.leading.equalTo(corverImgView.snp.trailing).offset(8)
            make.bottom.equalTo(corverImgView.snp.centerY)
        }
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(corverImgView.snp.trailing).offset(8)
            make.top.equalTo(corverImgView.snp.centerY)
        }
        moreButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.size.equalTo(40)
        }
    }
}
