//
//  BTConfiguration.swift
//  BTNavigationDropdownMenu
//
//  Created by Pham Ba Tho on 6/30/15.
//  Copyright (c) 2015 PHAM BA THO. All rights reserved.
//

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

public protocol BTConfigurableItem {
    var title: String { get }
}

private let defaultOffset: CGFloat = 300

// MARK: BTNavigationDropdownMenu
open class BTNavigationDropdownMenu: UIView {

    // Default is darkGray
    open var menuTitleColor: UIColor! {
        get { return configuration.menuTitleColor }
        set { configuration.menuTitleColor = newValue }
    }

    // Default is 50
    open var cellHeight: CGFloat! {
        get { return configuration.cellHeight }
        set { configuration.cellHeight = newValue }
    }

    // Default is white
    open var cellBackgroundColor: UIColor! {
        get { return configuration.cellBackgroundColor }
        set { configuration.cellBackgroundColor = newValue }
    }

    // Default is white
    open var arrowTintColor: UIColor! {
        get { return menuArrow.tintColor }
        set { menuArrow.tintColor = newValue }
    }

    open var cellSeparatorColor: UIColor! {
        get { return configuration.cellSeparatorColor }
        set { configuration.cellSeparatorColor = newValue }
    }

    // The color of the text inside cell. Default is darkGray
    open var cellTextLabelColor: UIColor! {
        get { return configuration.cellTextLabelColor }
        set { configuration.cellTextLabelColor = newValue }
    }
    
    // The color of the text inside a selected cell. Default is darkGray
    open var selectedCellTextLabelColor: UIColor! {
        get { return configuration.selectedCellTextLabelColor }
        set { configuration.selectedCellTextLabelColor = newValue }
    }
    
    // The font of the text inside cell. Default is HelveticaNeue-Bold, size 17
    open var cellTextLabelFont: UIFont! {
        get { return configuration.cellTextLabelFont }
        set { configuration.cellTextLabelFont = newValue }
    }
    
    // The font of the navigation bar title. Default is HelveticaNeue-Bold, size 17
    open var navigationBarTitleFont: UIFont! {
        get { return configuration.navigationBarTitleFont }
        set {
            configuration.navigationBarTitleFont = newValue
            menuTitle.font = newValue
        }
    }
    
    // The alignment of the text inside cell. Default is .Left
    open var cellTextLabelAlignment: NSTextAlignment! {
        get { return configuration.cellTextLabelAlignment }
        set { configuration.cellTextLabelAlignment = newValue }
    }
    
    // The color of the cell when the cell is selected. Default is lightGray
    open var cellSelectionColor: UIColor! {
        get { return configuration.cellSelectionColor }
        set { configuration.cellSelectionColor = newValue }
    }
    
    // The boolean value that decides if selected color of cell is visible when the menu is shown. Default is false
    open var shouldKeepSelectedCellColor: Bool! {
        get { return configuration.shouldKeepSelectedCellColor }
        set { configuration.shouldKeepSelectedCellColor = newValue }
    }
    
    // The animation duration of showing/hiding menu. Default is 0.3
    open var animationDuration: TimeInterval! {
        get { return configuration.animationDuration }
        set { configuration.animationDuration = newValue }
    }

    // The arrow next to navigation title
    open var arrowImage: UIImage! {
        get { return configuration.arrowImage }
        set {
            configuration.arrowImage = newValue.withRenderingMode(.alwaysTemplate)
            menuArrow.image = configuration.arrowImage
        }
    }
    
    // The padding between navigation title and arrow
    open var arrowPadding: CGFloat! {
        get { return configuration.arrowPadding }
        set { configuration.arrowPadding = newValue }
    }
    
    // The color of the mask layer. Default is black
    open var maskBackgroundColor: UIColor! {
        get { return configuration.maskBackgroundColor }
        set { configuration.maskBackgroundColor = newValue }
    }
    
    // The opacity of the mask layer. Default is 0.3
    open var maskBackgroundOpacity: CGFloat! {
        get { return configuration.maskBackgroundOpacity }
        set { configuration.maskBackgroundOpacity = newValue }
    }
    
    // The boolean value that decides if you want to change the title text when a cell is selected. Default is true
    open var shouldChangeTitleText: Bool! {
        get { return configuration.shouldChangeTitleText }
        set { configuration.shouldChangeTitleText = newValue }
    }

    
    open var didSelectItemAtIndexHandler: ((Int) -> Void)?

    fileprivate (set) var isShown = false
    fileprivate (set) var isAttributed = false

    fileprivate weak var navigationController: UINavigationController?
    fileprivate var configuration = BTConfiguration()
    fileprivate var topSeparator: UIView!
    fileprivate var menuButton: UIButton!
    fileprivate var menuTitle: UILabel!
    fileprivate var menuArrow: UIImageView!
    fileprivate var backgroundView: UIView!
    fileprivate var tableView: BTTableView!
    fileprivate var items: [BTConfigurableItem]!
    fileprivate var menuWrapper: UIView!

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(navigationController: UINavigationController? = nil, containerView: UIView = UIApplication.shared.keyWindow!, title: String, items: [BTConfigurableItem]) {
        // Key window
        guard let window = UIApplication.shared.keyWindow else {
            super.init(frame: .zero)
            return
        }

        // Navigation controller
        if let navigationController = navigationController {
            self.navigationController = navigationController
        } else {
            self.navigationController = window.rootViewController?.topMostViewController?.navigationController
        }
        
        // Get titleSize
        let titleSize = (title as NSString).size(attributes: [NSFontAttributeName : configuration.navigationBarTitleFont])
        
        // Set frame
        let size = CGSize(
            width: titleSize.width + (configuration.arrowPadding + configuration.arrowImage.size.width) * 2,
            height: navigationController!.navigationBar.frame.height
        )
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        isShown = false

        self.items = items
        
        // Init button as navigation title
        menuButton = UIButton(frame: frame)
        menuButton.addTarget(self, action: #selector(menuButtonTapped(_:)), for: .touchUpInside)
        addSubview(menuButton)

        menuTitle = UILabel(frame: frame)
        menuTitle.text = title
        menuTitle.textColor = menuTitleColor
        menuTitle.font = configuration.navigationBarTitleFont
        menuTitle.textAlignment = configuration.cellTextLabelAlignment
        menuButton.addSubview(menuTitle)
        
        menuArrow = UIImageView(image: configuration.arrowImage.withRenderingMode(.alwaysTemplate))
        menuButton.addSubview(menuArrow)
        
        let menuWrapperBounds = window.bounds
        
        // Set up DropdownMenu
        menuWrapper = UIView(frame: CGRect(
            origin: CGPoint(x: menuWrapperBounds.origin.x, y: 0),
            size: menuWrapperBounds.size)
        )
        menuWrapper.clipsToBounds = true
        menuWrapper.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Init background view (under table view)
        backgroundView = UIView(frame: menuWrapperBounds)
        backgroundView.backgroundColor = configuration.maskBackgroundColor
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideMenu))
        backgroundView.addGestureRecognizer(backgroundTapRecognizer)
        
        // Init properties
        setupDefaultConfiguration()
        
        // Init table view
        let navBarHeight = navigationController?.navigationBar.bounds.size.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let tabBarHeight = navigationController?.topViewController?.tabBarController?.tabBar.frame.height ?? 0
        tableView = BTTableView(
            frame: CGRect(
                x: menuWrapperBounds.origin.x,
                y: menuWrapperBounds.origin.y + 0.5,
                width: menuWrapperBounds.width,
                height: menuWrapperBounds.height + defaultOffset - navBarHeight - statusBarHeight - tabBarHeight),
            items: items,
            title: title,
            configuration: configuration
        )
        
        tableView.selectRowAtIndexPathHandler = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.didSelectItemAtIndexHandler?($0)
            if strongSelf.shouldChangeTitleText! {
                strongSelf.setMenuTitle("\(strongSelf.tableView.items[$0])")
            }
            strongSelf.hideMenu()
            strongSelf.layoutSubviews()
        }
        
        // Add background view & table view to container view
        menuWrapper.addSubview(backgroundView)
        menuWrapper.addSubview(tableView)
        
        // Add Line on top
        topSeparator = UIView(frame: CGRect(origin: .zero, size: CGSize(width: menuWrapperBounds.size.width, height: 0.5)))
        topSeparator.autoresizingMask = .flexibleWidth
        menuWrapper.addSubview(topSeparator)
        
        // Add Menu View to container view
        containerView.addSubview(menuWrapper)
        
        // By default, hide menu view
        menuWrapper.isHidden = true
    }
    
    override open func layoutSubviews() {
        menuTitle.sizeToFit()
        menuTitle.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        menuTitle.textColor = configuration.menuTitleColor
        menuArrow.sizeToFit()
        menuArrow.center = CGPoint(x: menuTitle.frame.maxX + configuration.arrowPadding, y: frame.size.height / 2)
        menuWrapper.frame.origin.y = navigationController!.navigationBar.frame.maxY
        tableView.reloadData()
    }
    
    open func show() {
        if !isShown {
            showMenu()
        }
    }
    
    open func hide() {
        if isShown {
            hideMenu()
        }
    }

    open func toggle() {
        isShown ? hideMenu() : showMenu()
    }
    
    open func update(with items: [BTConfigurableItem]) {
        if !items.isEmpty {
            tableView.items = items
            tableView.reloadData()
        }
    }
    
    open func setMenuTitle(_ title: String) {
        menuTitle.text = title
    }
}

private extension BTNavigationDropdownMenu {

    @objc func menuButtonTapped(_ sender: UIButton) {
        toggle()
    }

    func setupDefaultConfiguration() {
        let navigationBar = navigationController?.navigationBar
        let foregroundColor = navigationBar?.titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor

        menuTitleColor = foregroundColor
        cellBackgroundColor = navigationBar?.barTintColor
        cellSeparatorColor = foregroundColor
        cellTextLabelColor = foregroundColor
        arrowTintColor = configuration.arrowTintColor
    }

    func showMenu() {
        menuWrapper.frame.origin.y = navigationController!.navigationBar.frame.maxY

        isShown = true

        // Table view header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: defaultOffset))
        headerView.backgroundColor = configuration.cellBackgroundColor
        tableView.tableHeaderView = headerView

        topSeparator.backgroundColor = configuration.cellSeparatorColor

        rotateArrow()

        // Visible menu view
        menuWrapper.isHidden = false

        backgroundView.alpha = 0

        // Animation
        tableView.frame.origin.y = -CGFloat(items.count) * configuration.cellHeight - defaultOffset

        // Reload data to dismiss highlight color of selected cell
        tableView.reloadData()

        menuWrapper.superview?.bringSubview(toFront: menuWrapper)

        UIView.animate(
            withDuration: configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.tableView.frame.origin.y = CGFloat(-defaultOffset)
                self.backgroundView.alpha = self.configuration.maskBackgroundOpacity
        })
    }

    @objc func hideMenu() {
        rotateArrow()

        isShown = false
        backgroundView.alpha = configuration.maskBackgroundOpacity

        UIView.animate(
            withDuration: configuration.animationDuration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.tableView.frame.origin.y = CGFloat(-200)
        }, completion: nil
        )

        let newOrigin =  -CGFloat(items.count) * configuration.cellHeight - defaultOffset

        // Animation
        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            options: UIViewAnimationOptions(),
            animations: {
                self.tableView.frame.origin.y = newOrigin
                self.backgroundView.alpha = 0
        }, completion: { _ in
            if !self.isShown && self.tableView.frame.origin.y == newOrigin {
                self.menuWrapper.isHidden = true
            }
        })
    }

    func rotateArrow() {
        UIView.animate(withDuration: configuration.animationDuration, animations: { [weak self] in
            if let strongSelf = self {
                strongSelf.menuArrow.transform = strongSelf.menuArrow.transform.rotated(by: 180 * CGFloat(M_PI/180))
            }
        })
    }
}

// MARK: BTConfiguration
private class BTConfiguration {

    var menuTitleColor: UIColor?
    var cellHeight: CGFloat!
    var cellBackgroundColor: UIColor?
    var cellSeparatorColor: UIColor?
    var cellTextLabelColor: UIColor?
    var selectedCellTextLabelColor: UIColor?
    var cellTextLabelFont: UIFont!
    var navigationBarTitleFont: UIFont!
    var cellTextLabelAlignment: NSTextAlignment!
    var cellSelectionColor: UIColor?
    var shouldKeepSelectedCellColor: Bool!
    var arrowTintColor: UIColor?
    var arrowImage: UIImage!
    var arrowPadding: CGFloat!
    var animationDuration: TimeInterval!
    var maskBackgroundColor: UIColor!
    var maskBackgroundOpacity: CGFloat!
    var shouldChangeTitleText: Bool!
    
    init() {
        // Path for image
        let bundle = Bundle(for: BTConfiguration.self)
        let url = bundle.url(forResource: "BTNavigationDropdownMenu", withExtension: "bundle")
        let imageBundle = Bundle(url: url!)
        let arrowImagePath = imageBundle?.path(forResource: "arrow_down_icon", ofType: "png")

        // Default values
        menuTitleColor = .darkGray
        cellHeight = 50
        cellBackgroundColor = .white
        arrowTintColor = .white
        cellSeparatorColor = .darkGray
        cellTextLabelColor = .darkGray
        selectedCellTextLabelColor = .darkGray
        cellTextLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 17)
        navigationBarTitleFont = UIFont(name: "HelveticaNeue-Bold", size: 17)
        cellTextLabelAlignment = .left
        cellSelectionColor = .lightGray
        shouldKeepSelectedCellColor = false
        animationDuration = 0.5
        arrowImage = UIImage(contentsOfFile: arrowImagePath!)
        arrowPadding = 15
        maskBackgroundColor = .black
        maskBackgroundOpacity = 0.3
        shouldChangeTitleText = true
    }
}

// MARK: Table View
private class BTTableView: UITableView {

    var configuration: BTConfiguration!
    var selectRowAtIndexPathHandler: ((Int) -> Void)?

    fileprivate var items: [BTConfigurableItem]!
    fileprivate var selectedIndexPath: Int?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, items: [BTConfigurableItem], title: String, configuration: BTConfiguration) {
        super.init(frame: frame, style: UITableViewStyle.plain)
        
        self.items = items
        self.configuration = configuration

        selectedIndexPath = items.index { $0.title == title }

        // Setup table view
        delegate = self
        dataSource = self
        backgroundColor = .clear
        separatorStyle = .none
        autoresizingMask = UIViewAutoresizing.flexibleWidth
        tableFooterView = UIView(frame: .zero)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event), hitView.isKind(of: BTTableCellContentView.self) {
            return hitView
        }
        return nil
    }
}

extension BTTableView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return configuration.cellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BTTableViewCell(style: .default, reuseIdentifier: "Cell", configuration: configuration)
        cell.textLabel?.text = items[indexPath.row].title
        cell.tintColor = configuration.selectedCellTextLabelColor
        cell.accessoryType = indexPath.row == selectedIndexPath ? .checkmark : .none
        if configuration.shouldKeepSelectedCellColor == true {
            cell.backgroundColor = configuration.cellBackgroundColor
            cell.contentView.backgroundColor = indexPath.row == selectedIndexPath ? configuration.cellSelectionColor : configuration.cellBackgroundColor
        }
        return cell
    }
}

extension BTTableView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        selectRowAtIndexPathHandler?(indexPath.row)
        reloadData()
        let cell = tableView.cellForRow(at: indexPath) as? BTTableViewCell
        cell?.contentView.backgroundColor = configuration.cellSelectionColor
        cell?.textLabel?.textColor = configuration.selectedCellTextLabelColor
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? BTTableViewCell
        cell?.contentView.backgroundColor = configuration.cellBackgroundColor
        cell?.textLabel?.textColor = configuration.cellTextLabelColor
    }
}

// MARK: Table view cell
private class BTTableViewCell: UITableViewCell {

    let horizontalMargin: CGFloat = 20

    var cellContentFrame: CGRect!
    var configuration: BTConfiguration!
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, configuration: BTConfiguration) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.configuration = configuration

        cellContentFrame = CGRect(x: 0, y: 0, width: (UIApplication.shared.keyWindow?.frame.width)!, height: configuration.cellHeight)
        contentView.backgroundColor = configuration.cellBackgroundColor
        selectionStyle = UITableViewCellSelectionStyle.none
        textLabel!.textColor = configuration.cellTextLabelColor
        textLabel!.font = configuration.cellTextLabelFont
        textLabel!.textAlignment = configuration.cellTextLabelAlignment

        let separator = BTTableCellContentView(frame: cellContentFrame)
        if let cellSeparatorColor = configuration.cellSeparatorColor {
            separator.separatorColor = cellSeparatorColor
        }
        contentView.addSubview(separator)

        guard let textLabel = textLabel else { return }

        let cellSize = CGSize(width: cellContentFrame.width, height: cellContentFrame.height)

        switch textLabel.textAlignment {
        case .center:
            textLabel.frame = CGRect(origin: .zero, size: cellSize)
        case .left:
            textLabel.frame = CGRect(origin: CGPoint(x: horizontalMargin, y: 0), size: cellSize)
        default:
            textLabel.frame = CGRect(origin: CGPoint(x: -horizontalMargin, y: 0), size: cellSize)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        bounds = cellContentFrame
        contentView.frame = bounds
    }
}

private class BTTableCellContentView: UIView {

    var separatorColor: UIColor = .black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()

        // Set separator color of dropdown menu based on barStyle
        context?.setStrokeColor(separatorColor.cgColor)
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: 0, y: bounds.height))
        context?.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        context?.strokePath()
    }
}

fileprivate extension UIViewController {

    // Get ViewController in top present level
    var topPresentedViewController: UIViewController? {
        var target: UIViewController? = self
        while (target?.presentedViewController != nil) {
            target = target?.presentedViewController
        }
        return target
    }

    // Get top VisibleViewController from ViewController stack in same present level.
    // It should be visibleViewController if self is a UINavigationController instance
    // It should be selectedViewController if self is a UITabBarController instance
    var topVisibleViewController: UIViewController? {
        if let navigation = self as? UINavigationController {
            if let visibleViewController = navigation.visibleViewController {
                return visibleViewController.topVisibleViewController
            }
        }
        if let tab = self as? UITabBarController {
            if let selectedViewController = tab.selectedViewController {
                return selectedViewController.topVisibleViewController
            }
        }
        return self
    }

    // Combine both topPresentedViewController and topVisibleViewController methods, to get top visible viewcontroller in top present level
    var topMostViewController: UIViewController? {
        return self.topPresentedViewController?.topVisibleViewController
    }
}
