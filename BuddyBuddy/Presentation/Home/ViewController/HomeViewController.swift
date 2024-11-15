//
//  HomeViewController.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

import RxDataSources
import RxSwift
import SnapKit

final class HomeViewController: BaseNavigationViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    @Dependency(NetworkProtocol.self) private var service: NetworkProtocol
    private let vm: HomeViewModel
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fill
        view.backgroundColor = .gray2
        return view
    }()
    private let menuBtn: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.image = .menu
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        view.configuration = config
        return view
    }()
    private let channelTableView: UITableView = {
        let view = UITableView()
        view.register(
            ChannelTitleTableViewCell.self,
            forCellReuseIdentifier: ChannelTitleTableViewCell.identifier
        )
        view.register(
            DefaultChannelTableViewCell.self,
            forCellReuseIdentifier: DefaultChannelTableViewCell.identifier
        )
        view.register(
            UnreadChannelTableViewCell.self,
            forCellReuseIdentifier: UnreadChannelTableViewCell.identifier
        )
        
        view.separatorStyle = .none
        view.isScrollEnabled = false
        return view
    }()
    private let memberAddBtn: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        var imgConfig = UIImage.SymbolConfiguration(pointSize: 13)
        var attr = AttributedString.init("Add Member".localized())
        
        attr.font = UIFont.body
        
        config.attributedTitle = attr
        config.preferredSymbolConfigurationForImage = imgConfig
        config.image = UIImage(systemName: "plus")
        config.imagePlacement = .leading
        config.imagePadding = 12
        config.baseForegroundColor = .gray1
        config.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        view.configuration = config
        view.backgroundColor = .white
        view.contentHorizontalAlignment = .left
        return view
    }()
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    private let floatingBtn: UIButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        
        config.image = .newMessage
        config.contentInsets = .init(top: 16.45, leading: 16.45, bottom: 16.45, trailing: 16.45)
        
        view.configuration = config
        view.layer.cornerRadius = 25
        view.backgroundColor = .primary
        view.drawShadow(
            radius: 25,
            size: CGSize(
                width: 50,
                height: 50
            )
        )
        return view
    }()
    
    init(vm: HomeViewModel) {
        self.vm = vm
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        Observable.just(())
            .flatMap {
                let login = LoginQuery(email: "compose@coffee.com", password: "1q2w3e4rQ!")
                return self.service.callRequest(
                    router: LogInRouter.login(query: login),
                    responseType: LogInDTO.self
                )
            }
            .bind(with: self) { owner, response in
                switch response {
                case .success(let value):
                    print(value)
                    KeyChainManager.shard.saveAccessToken(value.token.accessToken)
                    KeyChainManager.shard.saveRefreshToken(value.token.refreshToken)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func bind() {
        let datasource = createDataSource()
        let sections: [ChannelSectionModel] = [.title(items: [.title(.caret)]),
                                               .list(items: [.channel(Channel(
                                                title: "받아쓰기 할 사람들 모여라",
                                                isRead: true
                                               )), .channel(Channel(
                                                title: "스크립트 외우기",
                                                isRead: false
                                               )), .channel(Channel(
                                                title: "오픽 딸 사람덜~ 여기 모여요",
                                                isRead: true)
                                               )]),
                                               .add(items: [.add(AddChannel())])]
        
        Observable.just(sections)
            .bind(to: channelTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        channelTableView.snp.remakeConstraints { make in
            make.height.equalTo(56 + sections[1].items.count * 41 + 48)
        }
    }
    
    override func setNavigation() {
        super.setNavigation()
        
        title = "영어 마스터 할 사람 모여라"
        
        let appearance = UINavigationBarAppearance()
        appearance.titlePositionAdjustment = UIOffset(
            horizontal: -(view.frame.width/2),
            vertical: 2
        )
        let font = UIFont.title1 ?? UIFont.boldSystemFont(ofSize: 22)
        appearance.titleTextAttributes =
        [NSAttributedString.Key.font: font]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        
        let barItem = UIBarButtonItem(customView: menuBtn)
        
        navigationItem.leftBarButtonItem = barItem
    }
    
    override func setHierarchy() {
        [scrollView, floatingBtn].forEach {
            view.addSubview($0)
        }
        
        scrollView.addSubview(stackView)
        
        [channelTableView, memberAddBtn, emptyView].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    override func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        memberAddBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
        emptyView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(300)
        }
        
        floatingBtn.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.size.equalTo(50)
        }
    }
}

// MARK: RxDataSource
extension HomeViewController {
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<ChannelSectionModel> {
        return RxTableViewSectionedReloadDataSource<ChannelSectionModel> { [weak self] datasource, _, indexpath, _ in
            guard let self else { return UITableViewCell() }
            
            switch datasource[indexpath] {
            case .title(let item):
                guard let cell = channelTableView.dequeueReusableCell(
                    withIdentifier: ChannelTitleTableViewCell.identifier,
                    for: indexpath
                ) as? ChannelTitleTableViewCell else { return UITableViewCell() }
                cell.configureCell(data: item.rawValue)
                cell.selectionStyle = .none
                return cell
            case .channel(let item):
                if item.isRead {
                    guard let cell = channelTableView.dequeueReusableCell(
                        withIdentifier: DefaultChannelTableViewCell.identifier,
                        for: indexpath
                    ) as? DefaultChannelTableViewCell else { return UITableViewCell() }
                    cell.configureCell(title: item.title, image: item.image)
                    cell.selectionStyle = .none
                    return cell
                } else {
                    guard let cell = channelTableView.dequeueReusableCell(
                        withIdentifier: UnreadChannelTableViewCell.identifier,
                        for: indexpath
                    ) as? UnreadChannelTableViewCell else { return UITableViewCell() }
                    cell.configureCell(data: item.title)
                    cell.selectionStyle = .none
                    return cell
                }
            case .add(let item):
                guard let cell = channelTableView.dequeueReusableCell(
                    withIdentifier: DefaultChannelTableViewCell.identifier,
                    for: indexpath
                ) as? DefaultChannelTableViewCell else { return UITableViewCell() }
                cell.configureCell(title: item.title, image: item.imageString)
                cell.selectionStyle = .none
                return cell
            }
        }
    }
}
