//
//  DMChattingViewController.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import UIKit
import PhotosUI

import RxSwift
import SnapKit

final class DMChattingViewController: BaseNavigationViewController {
    private let disposeBag = DisposeBag()
    private let vm: DMChattingViewModel
    private let imagePicker = BehaviorSubject<[UIImage]>(value: [])
    
    private let dmChattingTableView: UITableView = {
        let view = UITableView()
        view.register(
            DMChattingTableViewCell.self,
            forCellReuseIdentifier: DMChattingTableViewCell.identifier
        )
        view.rowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        return view
    }()
    private let chatBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .gray3
        view.layer.cornerRadius = 8
        return view
    }()
    private let chatTextView: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        view.font = .systemFont(ofSize: 15)
        view.backgroundColor = .gray3
        view.textContainer.lineFragmentPadding = 0
        view.textContainer.lineBreakMode = .byWordWrapping
        return view
    }()
    private let plusButton: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        var imgConfig = UIImage.SymbolConfiguration(pointSize: 16)
        
        config.preferredSymbolConfigurationForImage = imgConfig
        config.image = UIImage(systemName: "plus")
        config.baseForegroundColor = .black
        config.contentInsets = .init(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        view.configuration = config
        view.backgroundColor = .gray3
        
        return view
    }()
    private let sendButton: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        var imgConfig = UIImage.SymbolConfiguration(pointSize: 16)
        
        config.preferredSymbolConfigurationForImage = imgConfig
        config.image = UIImage(named: "send")
        config.baseForegroundColor = .black
        config.contentInsets = .init(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        view.configuration = config
        view.backgroundColor = .clear
        
        return view
    }()
    private lazy var imagePickerCollectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: imagePickerCollectionViewLayout()
        )
        view.register(
            ImagePickerCollectionViewCell.self,
            forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier
        )
        view.isScrollEnabled = false
        view.backgroundColor = .gray3
        return view
    }()
    private let chatImageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    init(vm: DMChattingViewModel) {
        self.vm = vm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setHierarchy() {
        [dmChattingTableView, chatBarBackground].forEach {
            view.addSubview($0)
        }
        [plusButton, chatTextView, imagePickerCollectionView, sendButton].forEach {
            chatBarBackground.addSubview($0)
        }
    }
    
    override func setConstraints() {
        dmChattingTableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(chatBarBackground.snp.top).priority(.high)
        }
        chatBarBackground.snp.makeConstraints { make in
            make.top.equalTo(dmChattingTableView.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        plusButton.snp.makeConstraints { make in
            make.leading.equalTo(chatBarBackground.snp.leading).offset(4)
            make.size.equalTo(44)
            make.bottom.equalToSuperview()
        }
        chatTextView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalTo(plusButton.snp.trailing)
            make.trailing.equalTo(sendButton.snp.leading)
            make.height.equalTo(34)
        }
        imagePickerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(chatTextView.snp.bottom)
            make.leading.equalTo(plusButton.snp.trailing)
            make.trailing.equalTo(sendButton.snp.leading)
            make.height.equalTo(0)
            make.bottom.equalToSuperview().inset(5)
        }
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.size.equalTo(44)
            make.bottom.equalToSuperview()
        }
    }
    
    override func bind() {
        let viewdidLoadTrigger = Observable.just(())
        
        let input = DMChattingViewModel.Input(
            viewWillAppearTrigger: viewdidLoadTrigger,
            sendBtnTapped: sendButton.rx.tap.asObservable(),
            plusBtnTapped: plusButton.rx.tap.asObservable(),
            chatBarText: chatTextView.rx.text.orEmpty.asObservable(),
            imagePicker: imagePicker.asObservable()
        )
        let output = vm.transform(input: input)
        
        output.updateDMListTableView
            .drive(
                dmChattingTableView.rx.items(
                    cellIdentifier: DMChattingTableViewCell.identifier,
                    cellType: DMChattingTableViewCell.self
                )
            ) { (_, element, cell) in
                cell.designCell(element)
            }
            .disposed(by: disposeBag)
        
        output.scrollToDown
            .drive { [weak self] _ in
                guard let self else { return }
                let indexPath = IndexPath(
                    row: dmChattingTableView.numberOfRows(inSection: 0) - 1,
                    section: 0
                )
                
                if indexPath.row >= 0 {
                    dmChattingTableView.scrollToRow(
                        at: indexPath, at: .bottom,
                        animated: false
                    )
                }
            }
            .disposed(by: disposeBag)
        
        output.removeChattingBarText
            .drive { [weak self] _ in
                guard let self else { return }
                chatTextView.text = ""
            }
            .disposed(by: disposeBag)
        
        output.plusBtnTapped
            .drive { [weak self] _ in
                guard let self else { return }
                showPickerView()
            }
            .disposed(by: disposeBag)
        
        output.imagePicker
            .drive { [weak self] value in
                guard let self else { return }
                
                imagePickerCollectionView.isHidden = value.isEmpty
                
                if value.isEmpty {
//                    imagePickerCollectionView.constraints.forEach { constraint in
//                        if constraint.firstAttribute == .height {
//                            constraint.constant = 0
//                        }
//                    }
                } else {
                    imagePickerCollectionView.constraints.forEach { constraint in
                        if constraint.firstAttribute == .height {
                            constraint.constant = self.imagePickerCollectionView.frame.width / 5
                        }
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        output.imagePicker
            .drive(
                imagePickerCollectionView.rx.items(
                    cellIdentifier: ImagePickerCollectionViewCell.identifier,
                    cellType: ImagePickerCollectionViewCell.self
                )
            ) { (_, element, cell) in
                cell.designCell(element)
            }
            .disposed(by: disposeBag)
        
        chatTextView.rx
            .didChange
            .bind(with: self) { owner, _ in
                let size = CGSize(width: owner.chatTextView.frame.width, height: .infinity)
                let estimatedSize = owner.chatTextView.sizeThatFits(size)
                print(estimatedSize, "estimatedSize")

                if estimatedSize.height > 70 {
                    owner.chatTextView.isScrollEnabled = true
                    return
                } else {
                    owner.chatTextView.isScrollEnabled = false

                    owner.chatTextView.constraints.forEach { constraint in
                        if constraint.firstAttribute == .height {
                            constraint.constant = estimatedSize.height
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

extension DMChattingViewController: PHPickerViewControllerDelegate {
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true, completion: nil)
        
        let dispatchGroup = DispatchGroup()
        var selectedImage: [UIImage] = []
        
        for result in results {
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                if let image = object as? UIImage {
                    selectedImage.append(image)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.imagePicker.onNext(selectedImage)
        }
    }
    
    private func showPickerView() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 5
        configuration.filter = .any(of: [.screenshots, .images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true)
    }
}

extension DMChattingViewController {
    private func imagePickerCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}
