//
//  SettingsController.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    let floatingButtonHeightMargin: CGFloat = UIDevice.current.hasNotch ? 0 : -15
    
    private let reuseIdentifier = "SettingsCell"
    
    let navSeparatorView = UIView()
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 60
        tv.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 100, right: 0)
        tv.contentOffset.y = -20
        tv.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        return tv
    }()
    
    private let floatingButton = FloatingButton()
    
    private func setupFloatingButton() {
        floatingButton.delegate = self
        
        guard let mainWindow = UIApplication.shared.keyWindow else { return }
        floatingButton.mainView = mainWindow
        
        floatingButton.show(icon: "ok", iconSize: 24, color: UIColor(r: 244, g: 25, b: 110))
        floatingButton.bottomConstraint?.constant = floatingButtonHeightMargin
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.fillSuperview()
    }
    
    var titleView = CustomNavigationTitleView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 38))
    
    func hideNavItems() {
        navigationItem.setLeftBarButtonItems(nil, animated: false)
        navigationItem.setRightBarButtonItems(nil, animated: false)
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func setupNavigationBottomLine() {
        view.addSubview(navSeparatorView)
        navSeparatorView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .zero, size: CGSize(width: 0, height: 2.0))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTheming()
        
        hideNavItems()
        
        navigationItem.titleView = titleView
        titleView.setupTitle(title: NSLocalizedString("Settings", comment: ""))
        titleView.hideMenuButton()
        titleView.changeBackIconImage(image: "arrow_bottom")
        titleView.delegate = self
        
        setupTableView()
        
        setupNavigationBottomLine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.hide()
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupFloatingButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        floatingButton.destroy()
    }
    
    func closeView() {
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    private func addOnSnapchat() {
        let username = "zzebinou"
        if let url = URL(string: "https://www.snapchat.com/add/\(username)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func followOnInstagram() {
        let username = "sebastienmenozzi"
        if let url = URL(string: "instagram://user?username=\(username)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func contactMail() {
        let email = "seb.menozzi@hotmail.fr"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        if let url = URL(string: "https://www.snap.com/fr-FR/terms/") {
            UIApplication.shared.open(url)
        }
    }
    
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = TableViewTitle()
        view.title.text = SettingsSection(rawValue: section)?.description
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
            case .Theme: return 40
            case .App: return 40
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
            case .Theme: return SettingsThemeOptions.allCases.count
            case .App: return SettingsAppOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(r: 229, g: 233, b: 236)
        cell.selectedBackgroundView = bgColorView
        
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
            case .Theme:
               let theme = SettingsThemeOptions(rawValue: indexPath.row)
               cell.sectionType = theme
            case .App:
                let app = SettingsAppOptions(rawValue: indexPath.row)
                cell.sectionType = app
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
            case .Theme:
                if indexPath.item == 0 {
                    AppThemeProvider.shared.currentTheme = .basic
                    UserDefaults.standard.set("", forKey: "theme")
                } else if indexPath.item == 1 {
                    AppThemeProvider.shared.currentTheme = .christmas
                    UserDefaults.standard.set("christmas", forKey: "theme")
                } else if indexPath.item == 2 {
                    AppThemeProvider.shared.currentTheme = .purple
                    UserDefaults.standard.set("purple", forKey: "theme")
                } else if indexPath.item == 3 {
                    AppThemeProvider.shared.currentTheme = .emerald
                    UserDefaults.standard.set("emerald", forKey: "theme")
                } else if indexPath.item == 4 {
                    AppThemeProvider.shared.currentTheme = .pink
                    UserDefaults.standard.set("pink", forKey: "theme")
                }
            
            case .App:
                if indexPath.item == 0 {
                    addOnSnapchat()
                } else if indexPath.item == 1 {
                    followOnInstagram()
                } else if indexPath.item == 2 {
                    contactMail()
                } else if indexPath.item == 3 {
                    openTerms()
                }
        }
    }
    
}

extension SettingsController: FloatingButtonDelegate {
    func onPress() {
        self.closeView()
    }
}

extension SettingsController: Themed {
    
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.separatorColor
        navSeparatorView.backgroundColor = theme.separatorColor
    }
    
}

extension SettingsController: CustomNavigationTitleViewDelegate {
    
    func didGoBack() {
        self.closeView()
    }
    
    func didGoMenu() {
        
    }
    
}

