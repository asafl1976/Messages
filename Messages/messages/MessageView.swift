//
//  MessageView.swift
//  Messages
//
//  Created by ASAF LEVY on 02/06/2017.
//  Copyright © 2017 ASAF LEVY. All rights reserved.
//

import UIKit

enum MessageViewType {
    case info
    case error
}

class MessageView: UIView {
    static var configuration = MessageViewConfiguration()
    fileprivate let easeInCurve:[Float] = [0.405, 0.005, 0.770, 0.050]
    fileprivate let easeOutCurve:[Float] = [0.000, 0.880, 0.605, 1]
    fileprivate let contentView = UIView()
    fileprivate var views:[String:UIView] = [:]
    fileprivate let label = LineAnimatedLabel()
    fileprivate var backgroundViewNotVisibleHeightConstrains:[NSLayoutConstraint] = []
    fileprivate var backgroundViewVisibleHeightConstrains:[NSLayoutConstraint] = []
    fileprivate var type:MessageViewType = .info
    fileprivate var textColor = UIColor.black
    fileprivate var contentBackgroundColor = UIColor.white
    fileprivate lazy var actionButton:UIButton = UIButton(type: .system)
    fileprivate lazy var dismissButton:UIButton = UIButton(type: .system)
    fileprivate var actionButtonFont = UIFont.boldSystemFont(ofSize: 13)
    fileprivate var actionButtonWidth:CGFloat = 0.0
    fileprivate var actionButtonAction:(() -> ())?
    fileprivate var actionButtonText:String?
    var isVisible = false
    
    var text:String? {
        didSet {
            guard let textUnwrapped = text else {
                return
            }
            label.text = textUnwrapped
        }
    }
    
    convenience init (withType type:MessageViewType, buttonText: String?, buttonAction:(() -> ())?) {
        self.init(frame:CGRect.zero)
        
        self.type = type
        self.actionButtonText = buttonText
        self.actionButtonAction = buttonAction
        self.textColor = (type == .info) ? .black:.white
        self.contentBackgroundColor = (type == .info) ? .white:.red
        setupView()
        setupViewLayout()
    }
    
    override init (frame : CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView () {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = contentBackgroundColor
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = CGSize.zero
        addSubview(contentView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = textColor
        if let font = MessageView.configuration.font {
            label.font = font
        }
        if let textAlignment = MessageView.configuration.textAlignment {
            label.textAlignment = textAlignment
        }
        contentView.addSubview(label)
        
        if let text = actionButtonText {
            actionButtonWidth = max(60, text.size(attributes: [NSFontAttributeName: actionButtonFont]).width + 10.0)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.addTarget(self, action: #selector(actionButtonClicked), for: UIControlEvents.touchUpInside)
            actionButton.titleLabel?.font = actionButtonFont
            actionButton.layer.borderWidth = 1
            actionButton.layer.borderColor = textColor.cgColor
            actionButton.layer.cornerRadius = 6
            actionButton.setTitle(text, for: .normal)
            actionButton.setTitleColor(textColor, for: .normal)
            contentView.addSubview(actionButton)
            views["actionButton"] = actionButton
        } else {
            dismissButton.translatesAutoresizingMaskIntoConstraints = false
            dismissButton.addTarget(self, action: #selector(dismissButtonClicked), for: UIControlEvents.touchUpInside)
            dismissButton.setImage(UIImage(named: "dismissMessage"), for: .normal)
            dismissButton.tintColor = textColor
            contentView.addSubview(dismissButton)
            views["dismissButton"] = dismissButton
        }
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        gesture.direction = .down
        contentView.addGestureRecognizer(gesture)
        
        views["superview"] = self
        views["contentView"] = contentView
        views["label"] = label
    }
    
    func handleSwipe(_ swipeGesture: UISwipeGestureRecognizer) {
        dismiss()
    }
    
    private func setupViewLayout() {
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[contentView]-0-|",options: [],metrics: nil,views: views))
        backgroundViewNotVisibleHeightConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-0-[contentView(==superview)]",options: [],metrics: nil,views: views)
        backgroundViewVisibleHeightConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[contentView]-0-|",options: [],metrics: nil,views: views)
        NSLayoutConstraint.activate(backgroundViewNotVisibleHeightConstrains)
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-15-[label(>=25)]-15-|",options: [],metrics: nil,views: views))
        
        if let _ = actionButtonText {
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-15-[label]-10-[actionButton]-10-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:[actionButton(==30)]",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:[contentView]-(<=1)-[actionButton(>=actionButtonWidth)]",options: [.alignAllCenterY],metrics: ["actionButtonWidth":actionButtonWidth],views: views))
        } else {
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-15-[label]-10-[dismissButton(40)]-0-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[dismissButton]-0-|",options: [],metrics: nil,views: views))
        }
    }
    
    func actionButtonClicked() {
        DispatchQueue.main.async() {
            self.actionButtonAction?()
            self.dismiss()
        }
    }
    
    func dismissButtonClicked() {
        DispatchQueue.main.async() {
            self.dismiss()
        }
    }
    
    func show() {
        isVisible = true
        NSLayoutConstraint.deactivate(backgroundViewNotVisibleHeightConstrains)
        NSLayoutConstraint.activate(backgroundViewVisibleHeightConstrains)
        
        CATransaction.begin()
        let timingFunction = CAMediaTimingFunction(controlPoints: easeOutCurve[0], easeOutCurve[1], easeOutCurve[2], easeOutCurve[3])
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: 0.7, delay: 0.0, options: [], animations: {
            self.layoutIfNeeded()
        })
        CATransaction.commit()
        label.animateIn(withDuration: 0.7, delay: 0.25, curve: easeOutCurve)
    }
    
    func dismiss() {
        label.animateOut(withDuration: 0.5, delay: 0.0, curve: easeInCurve)
        NSLayoutConstraint.deactivate(backgroundViewVisibleHeightConstrains)
        NSLayoutConstraint.activate(backgroundViewNotVisibleHeightConstrains)
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.removeFromSuperview()
            self.isVisible = false
        }
        let timingFunction = CAMediaTimingFunction(controlPoints: easeInCurve[0], easeInCurve[1], easeInCurve[2], easeInCurve[3])
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: 0.55, delay: 0.1, options: [], animations: {
            self.layoutIfNeeded()
        })
        CATransaction.commit()
    }
    
    static func mainWindow() -> UIWindow? {
        var targetWindow: UIWindow?
        let windows = UIApplication.shared.windows
        for window in windows {
            if window.screen != UIScreen.main { continue }
            if !window.isHidden && window.alpha == 0 { continue }
            if window.windowLevel != UIWindowLevelNormal { continue }
            targetWindow = window
            break
        }
        return targetWindow
    }
    
    static func showError(inView view:UIView?, withText text:String, dismissAfter dismissTime:TimeInterval = TimeInterval.infinity, messageView: inout MessageView?)  {
        messageView = show(inView: view, withText: text, dismissAfter: dismissTime, type:.error)
    }
    
    static func showError(inView view:UIView?, withText text:String, dismissAfter dismissTime:TimeInterval = TimeInterval.infinity)  {
        _ = show(inView: view, withText: text, dismissAfter: dismissTime, type:.error)
    }
    
    static func showError(inView view:UIView?, withText text:String, buttonText:String, messageView: inout MessageView?, buttonAction: @escaping () -> ()) {
        messageView = show(inView: view, withText: text, dismissAfter: TimeInterval.infinity, type:.error, buttonText:buttonText, buttonAction: buttonAction)
    }
    
    static func showError(inView view:UIView?, withText text:String, buttonText:String, buttonAction: @escaping () -> ()) {
        _ = show(inView: view, withText: text, dismissAfter: TimeInterval.infinity, type:.error, buttonText:buttonText, buttonAction: buttonAction)
    }
    
    static func showInfo(inView view:UIView?, withText text:String, dismissAfter dismissTime:TimeInterval = TimeInterval.infinity) {
        _ = show(inView: view, withText: text, dismissAfter: dismissTime, type:.info)
    }
    
    static func showInfo(inView view:UIView?, withText text:String, buttonText:String, buttonAction: @escaping () -> ()) {
        _ = show(inView: view, withText: text, dismissAfter: TimeInterval.infinity, type:.info, buttonText:buttonText, buttonAction: buttonAction)
    }
    
    static fileprivate func show(inView view:UIView?, withText text:String,
                                 dismissAfter dismissTime:TimeInterval,
                                 type: MessageViewType, buttonText:String? = nil,
                                 buttonAction: (() -> ())? = nil) -> MessageView? {
        
        guard Thread.current.isMainThread else {
            print("MessageView messages can be showed only when calling from Main thread!")
            return nil
        }
        
        let messageView = MessageView(withType: type, buttonText: buttonText, buttonAction:buttonAction)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        view?.addSubview(messageView)
        
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[messageView]-0-|",options: [],metrics: nil,views: ["messageView":messageView]))
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "V:[messageView]-0-|",options: [],metrics: nil,views
            : ["messageView":messageView]))
        
        view?.layoutIfNeeded()
        messageView.text = text
        messageView.layoutIfNeeded()
        messageView.show()
        
        if dismissTime != TimeInterval.infinity {
            let delay = dismissTime * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                messageView.dismiss()
            })
        }
        return messageView
    }
}

struct MessageViewConfiguration {
    //var titleFont = UIFont.boldSystemFont(ofSize: 16)
    var font:UIFont? = UIFont.systemFont(ofSize: 15)
    var textAlignment:NSTextAlignment? = NSTextAlignment.left
}
