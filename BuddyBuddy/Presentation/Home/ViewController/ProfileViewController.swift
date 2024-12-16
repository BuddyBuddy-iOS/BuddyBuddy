//
//  ProfileViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/14/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class ProfileViewController: BaseViewController {
    @Dependency(CacheManager.self)
    private var cache: CacheManager
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let vm: ProfileViewModel
    
    private let profileImgView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()
    private let profileBottomView: ProfileBottomView = ProfileBottomView()
    
    init(vm: ProfileViewModel) {
        self.vm = vm
        
        super.init()
    }
    
    override func bind() {
        let input = ProfileViewModel.Input(
            viewWillAppear: rx.viewWillAppear,
            dmBtnTapped: profileBottomView.dmBtn.rx.tap.map { () }
        )
        let output = vm.transform(input: input)
        
        output.userProfile
            .drive(with: self) { owner, user in
                owner.profileBottomView.setProfileView(
                    name: user.nickname,
                    email: user.email
                )
                guard let imgPath = user.profileImage else {
                    owner.profileImgView.image = UIImage(named: "BasicProfileImage")
                    return
                }
                Task {
                    owner.profileImgView.image = try await owner.cache.loadImg(urlPath: imgPath)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func setHierarchy() {
        [profileImgView, profileBottomView].forEach {
            view.addSubview($0)
        }
    }
    
    override func setConstraints() {
        profileImgView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(profileBottomView.snp.top)
        }
        
        profileBottomView.snp.makeConstraints { make in
            make.top.equalTo(profileImgView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
        }
    }
}
