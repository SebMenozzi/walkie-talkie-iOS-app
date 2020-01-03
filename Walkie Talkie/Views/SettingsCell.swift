//
//  SettingsCell.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    var iconViewWidthContraint: NSLayoutConstraint!
    var iconViewHeightContraint: NSLayoutConstraint!
    var titleLabelLeadingContraint: NSLayoutConstraint!
    
    var sectionType: SettingsItemSection? {
        didSet {
            bind()
        }
    }
    
    private func bind() {
        guard let sectionType = sectionType else { return }
        
        titleLabel.alpha = sectionType.isDisabled ? 0.4 : 1.0
        titleLabel.isHidden = sectionType.hasInput
        titleLabel.text = sectionType.description
        
        switchControl.isHidden = !sectionType.hasSwitch
        switchControl.isOn = sectionType.switchValue
        
        selectionStyle = .none
        
        valueLabel.text = sectionType.value != "" ? sectionType.value : NSLocalizedString("Add", comment: "")
        valueLabel.alpha = sectionType.value != "" ? 1.0 : 0.3
        valueLabel.isHidden = !sectionType.hasValue
        
        arrowImageView.isHidden = !sectionType.hasArrow
        
        if sectionType.icon != "" {
            iconImageView.image = UIImage(named: sectionType.icon)
        } else {
            iconImageView.image = nil
        }
        
        if sectionType.icon != "" {
            iconViewWidthContraint.constant = iconImageSize
            iconViewHeightContraint.constant = iconImageSize
        
        } else {
            iconViewWidthContraint.constant = 0
            iconViewHeightContraint.constant = 0
        }
        
        if sectionType.icon != "" {
            titleLabelLeadingContraint.constant = 10
        } else {
            titleLabelLeadingContraint.constant = 0
        }
    }
    
    /* Icon */
    
    private let iconImageSize: CGFloat = 35
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(cornerRadius: iconImageSize / 2)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .white)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    let darkLoadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.alpha = 0
        return view
    }()
    
    /* Title */
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 18)!
        label.text = "Title"
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /* Value */
    
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GothamRounded-Medium", size: 18)
        label.text = "Value"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /* Switch */
    
    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        return switchControl
    }()
    
    @objc func handleSwitchAction(sender: UISwitch) {
        sectionType?.switchValue = sender.isOn
    }
    
    /* Arrow */
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "arrow")!.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    /* Setup everything */
    
    private func setupSwitchControl() {
        addSubview(switchControl)
        switchControl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        switchControl.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
    
    private func setupArrowImageView() {
        addSubview(arrowImageView)
        arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
    }
    
    private func setupIconImageView() {
        addSubview(iconImageView)
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        
        iconViewWidthContraint = iconImageView.widthAnchor.constraint(equalToConstant: iconImageSize)
        iconViewWidthContraint.isActive = true
        
        iconViewHeightContraint = iconImageView.heightAnchor.constraint(equalToConstant: iconImageSize)
        iconViewHeightContraint.isActive = true
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -25).isActive = true
        
        titleLabelLeadingContraint = titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10)
        titleLabelLeadingContraint.isActive = true
    }
    
    private func setupValueLabel() {
        addSubview(valueLabel)
        valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
    }
    
    /* Public functions */
    
    private func showLoadingForPicture() {
        activityIndicator.startAnimating()
        
        darkLoadingView.alpha = 1.0
    }
    
    private func hideLoadingForPicture() {
        activityIndicator.stopAnimating()
        
        darkLoadingView.alpha = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpTheming()
        
        setupSwitchControl()
        
        setupArrowImageView()
        
        setupIconImageView()
        
        setupTitleLabel()
        
        setupValueLabel()
        
        showLoadingForPicture()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SettingsCell: Themed {
    
    func applyTheme(_ theme: AppTheme) {
        backgroundColor = theme.cellbackgroundColor
    }
    
}
