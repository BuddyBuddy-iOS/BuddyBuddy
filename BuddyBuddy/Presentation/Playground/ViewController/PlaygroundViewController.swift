//
//  PlaygroundViewController.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/29/24.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class PlaygroundViewController: BaseViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let vm: PlaygroundViewModel
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Playground".localized()
        view.font = .title1
        return view
    }()
    private let playgroundTableView: UITableView = {
        let view = UITableView()
        view.register(
            PlaygroundTableViewCell.self,
            forCellReuseIdentifier: PlaygroundTableViewCell.identifier
        )
        view.backgroundColor = .clear
        view.rowHeight = 72
        view.separatorStyle = .none
        return view
    }()
    private let bottomView: PlaygroundBottomView = PlaygroundBottomView()
    private let moreBtnTapped = PublishRelay<String>()
    
    init(vm: PlaygroundViewModel) {
        self.vm = vm
        super.init()
    }
    
    override func bind() {
        let actionSheetItemTapped = PublishRelay<ActionSheetType>()
        let input = PlaygroundViewModel.Input(
            viewWillAppearTrigger: rx.viewWillAppear,
            selectedPlayground: playgroundTableView.rx.modelSelected(Workspace.self).asObservable(),
            moreBtnTapped: moreBtnTapped.asObservable(),
            addBtnTapped: bottomView.addButton.rx.tap.asObservable()
        )
        let output = vm.transform(input: input)
        
        output.playgroundList
            .drive(playgroundTableView.rx.items(
                cellIdentifier: PlaygroundTableViewCell.identifier,
                cellType: PlaygroundTableViewCell.self
            )) { _, value, cell in
                cell.configureCell(value)
                cell.moreButton.accessibilityIdentifier = value.workspaceID
                cell.moreButton.addTarget(
                    self,
                    action: #selector(self.moreBtnDidTap),
                    for: .touchUpInside
                )
            }
            .disposed(by: disposeBag)
        
        // TODO: Alert 추가
    }
    
    override func setView() {
        view.backgroundColor = .gray3
    }
    
    override func setHierarchy() {
        [titleLabel, playgroundTableView, bottomView].forEach {
            view.addSubview($0)
        }
    }
    
    override func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(8)
            make.leading.equalToSuperview().inset(16
            )
        }
        playgroundTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.horizontalEdges.equalToSuperview()
        }
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(playgroundTableView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(safeArea)
            make.height.equalTo(82)
        }
    }
    
    @objc func moreBtnDidTap(_ sender: UIButton) {
        guard let id = sender.accessibilityIdentifier else { return }
        moreBtnTapped.accept(id)
    }
}