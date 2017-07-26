//
//  MessageView.swift
//  Messages
//
//  Created by ASAF LEVY on 02/06/2017.
//  Copyright © 2017 ASAF LEVY. All rights reserved.
//

import UIKit

enum MessageType {
    case info
    case error
}

class MessageView: UIView {
    static var configuration = MessageViewConfiguration()
    static fileprivate var dismissOverlayView = UIButton(type: .system)
    
    fileprivate let easeInCurve:[Float] = [0.405, 0.005, 0.770, 0.050]
    fileprivate let easeOutCurve:[Float] = [0.000, 0.880, 0.605, 1]
    fileprivate let contentView = UIView()
    fileprivate let lineView = UIView()
    fileprivate var views:[String:UIView] = [:]
    fileprivate let label = LineAnimatedLabel()
    fileprivate var backgroundViewNotVisibleHeightConstrains:[NSLayoutConstraint] = []
    fileprivate var backgroundViewVisibleHeightConstrains:[NSLayoutConstraint] = []
    fileprivate var lineViewVisibleHeightConstrains:[NSLayoutConstraint] = []
    fileprivate var lineViewNotVisibleHeightConstrains:[NSLayoutConstraint] = []
    fileprivate var type:MessageType = .info
    fileprivate var textColor = UIColor.black
    fileprivate var contentBackgroundColor = UIColor.white
    fileprivate var actionButton = UIButton(type: .system)
    fileprivate var dismissActionButton = UIButton(type: .system)
    fileprivate var dismissButton = UIButton(type: .system)
    fileprivate var actionButtonWidth:CGFloat = 0.0
    fileprivate var lineViewWidth:CGFloat = 4.0
    fileprivate var actionButtonAction:(() -> ())?
    fileprivate var dismissButtonAction:(() -> ())?
    fileprivate var actionButtonText:String?
    var isVisible = false
    
    fileprivate var text:String? {
        didSet {
            guard let textUnwrapped = text else {
                return
            }
            label.text = textUnwrapped
        }
    }
    
    convenience init (withType type:MessageType, buttonText: String?, buttonAction:(() -> ())?, dismissButtonAction: (() -> ())? = nil) {
        self.init(frame:CGRect.zero)
        
        self.type = type
        self.actionButtonText = buttonText
        self.actionButtonAction = buttonAction
        self.dismissButtonAction = dismissButtonAction
        self.textColor = .black
        self.contentBackgroundColor = .white
        setupView()
        setupViewLayout()
    }
    
    override init (frame : CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupView () {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = contentBackgroundColor
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = CGSize.zero
        addSubview(contentView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = (type == .error) ? MessageView.configuration.errorLineColor: MessageView.configuration.infoLineColor
        addSubview(lineView)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = textColor
        label.font = MessageView.configuration.font
        label.textAlignment = MessageView.configuration.textAlignment
        contentView.addSubview(label)
        
        if let text = actionButtonText {
            let buttonFont = MessageView.configuration.buttonFont
            actionButtonWidth = max(60, text.size(attributes: [NSFontAttributeName: buttonFont]).width + 20.0)
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.addTarget(self, action: #selector(actionButtonClicked), for: UIControlEvents.touchUpInside)
            actionButton.titleLabel?.font = buttonFont
            actionButton.layer.borderWidth = 1
            actionButton.layer.borderColor = textColor.cgColor
            actionButton.layer.cornerRadius = 5
            actionButton.setTitle(text, for: .normal)
            actionButton.setTitleColor(textColor, for: .normal)
            contentView.addSubview(actionButton)
            
            actionButtonWidth = max(60, text.size(attributes: [NSFontAttributeName: buttonFont]).width + 35.0)
            dismissActionButton.translatesAutoresizingMaskIntoConstraints = false
            dismissActionButton.addTarget(self, action: #selector(dismissActionButtonClicked), for: UIControlEvents.touchUpInside)
            dismissActionButton.titleLabel?.font = buttonFont
            dismissActionButton.setTitle(MessageView.configuration.dismissActionButtonText, for: .normal)
            dismissActionButton.setTitleColor(textColor, for: .normal)
            contentView.addSubview(dismissActionButton)
            
            views["dismissActionButton"] = dismissActionButton
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
        views["lineView"] = lineView
        views["label"] = label
    }
    
    internal func handleSwipe(_ swipeGesture: UISwipeGestureRecognizer) {
        dismiss()
    }
    
    fileprivate func setupViewLayout() {
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[contentView]-0-|",options: [],metrics: nil,views: views))
        backgroundViewNotVisibleHeightConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-0-[contentView(==superview)]",options: [],metrics: nil,views: views)
        backgroundViewVisibleHeightConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[contentView]-0-|",options: [],metrics: nil,views: views)
        NSLayoutConstraint.activate(backgroundViewNotVisibleHeightConstrains)
        
        lineViewNotVisibleHeightConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=1)-[lineView(lineViewWidth)]", options: [.alignAllCenterX], metrics: ["lineViewWidth":lineViewWidth],views: views)
        
        lineViewVisibleHeightConstrains = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[lineView(==superview)]",options: [.alignAllCenterY],metrics: nil,views: views)
        
        NSLayoutConstraint.activate(lineViewNotVisibleHeightConstrains)
        
        if let _ = actionButtonText {
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-15-[label(>=25)]-20-[actionButton]",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-15-[label]-15-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:[actionButton(==30)]-20-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:[dismissActionButton(==30)]-20-|",options: [],metrics: nil,views: views))
            
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:[lineView(lineViewWidth)]-0-|",options: [],metrics: ["lineViewWidth":lineViewWidth], views: views))
            
            let margin:CGFloat = 25
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-margin-[dismissActionButton(>=actionButtonWidth)]",options: [],metrics: ["actionButtonWidth":actionButtonWidth,"margin":margin],views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:[actionButton(>=actionButtonWidth)]-margin-|",options: [],metrics: ["actionButtonWidth":actionButtonWidth,"margin":margin],views: views))
            
        } else {
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-15-[label(>=25)]-15-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-15-[label]-10-[dismissButton(40)]-0-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[dismissButton]-0-|",options: [],metrics: nil,views: views))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:[lineView(lineViewWidth)]-0-|",options: [],metrics: ["lineViewWidth":lineViewWidth], views: views))
        }
    }
    
    internal func dismissOverlayClicked() {
        dismissActionButtonClicked()
    }
    
    internal func dismissActionButtonClicked() {
        DispatchQueue.main.async() {
            self.dismissButtonAction?()
            self.dismiss()
        }
    }
    
    internal func actionButtonClicked() {
        DispatchQueue.main.async() {
            self.actionButtonAction?()
            self.dismiss()
        }
    }
    
    internal func dismissButtonClicked() {
        DispatchQueue.main.async() {
            self.dismissButtonAction?()
            self.dismiss()
        }
    }
    
    fileprivate func show() {
        isVisible = true
        NSLayoutConstraint.deactivate(backgroundViewNotVisibleHeightConstrains)
        NSLayoutConstraint.activate(backgroundViewVisibleHeightConstrains)
        
        CATransaction.begin()
        let timingFunction = CAMediaTimingFunction(controlPoints: easeOutCurve[0], easeOutCurve[1], easeOutCurve[2], easeOutCurve[3])
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: 0.7, delay: 0.0, options: [], animations: {
            self.layoutIfNeeded()
        })
        CATransaction.setCompletionBlock() {
            NSLayoutConstraint.deactivate(self.lineViewNotVisibleHeightConstrains)
            NSLayoutConstraint.activate(self.lineViewVisibleHeightConstrains)
            UIView.animate(withDuration: 1.0, delay: 0.6, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
        CATransaction.commit()
        label.animateIn(withDuration: 0.7, delay: 0.25, curve: easeOutCurve)
    }
    
    func dismiss() {
        label.animateOut(withDuration: 0.5, delay: 0.0, curve: easeInCurve)
        NSLayoutConstraint.deactivate(backgroundViewVisibleHeightConstrains)
        NSLayoutConstraint.activate(backgroundViewNotVisibleHeightConstrains)
        MessageView.dismissOverlay()
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
    
    static fileprivate func mainWindow() -> UIWindow? {
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
    
    /**
     Display message to the user
     
     - Parameters:
     - type: The type of the message, info/error
     - view: The superview that the message will be displayed over. If nil, main window will be used
     - text: The message text
     - dismissAfter: The expiration time of the message
     
     - Returns: void
     */
    
    static func show(withType type: MessageType, inView view:UIView? = nil, text:String, dismissAfter dismissTime:TimeInterval = TimeInterval.infinity)  {
        _ = show(inView: view == nil ? mainWindow():view, text: text, dismissAfter: dismissTime, type:type)
    }
    
    /**
     Display message to the user, returning (inout) handler of the message
     
     - Parameters:
     - type: The type of the message, info/error
     - view: The superview that the message will be displayed over. If nil, main window will be used
     - text: The message text
     - dismissAfter: The expiration time of the message
     
     - Returns: messageView (inout parameter) to dismiss the message manually.
     */
    static func show(withType type: MessageType, inView view:UIView? = nil, text:String, dismissAfter dismissTime:TimeInterval = TimeInterval.infinity, messageView: inout MessageView?)  {
        messageView = show(inView: view == nil ? mainWindow():view, text: text, dismissAfter: dismissTime, type:type)
    }
    
    /**
     Display message to the user with a custom button
     
     - Parameters:
     - type: The type of the message, info/error
     - view: The superview that the message will be displayed over. If nil, main window will be used
     - text: The message text
     - buttonText: The text to be displayed on the button
     - buttonAction: The button action
     
     - Returns: void
     */
    static func show(withType type: MessageType, inView view:UIView? = nil, text:String, buttonText:String, buttonAction: @escaping () -> (), dismissButtonAction: (() -> ())? = nil) {
        _ = show(inView: view == nil ? mainWindow():view, text: text, dismissAfter: TimeInterval.infinity, type:type, buttonText:buttonText, buttonAction: buttonAction, dismissButtonAction:dismissButtonAction)
    }
    
    /**
     Display message to the user with a custom button, returning (inout) handler of the message
     
     Parameters:
     - type: The type of the message, info/error
     - view: The superview that the message will be displayed over. If nil, main window will be used
     - text: The message text
     - buttonText: The text to be displayed on the button
     - buttonAction: The button action
     
     - Returns: messageView (inout parameter) to dismiss the message manually.
     */
    static func show(withType type: MessageType, inView view:UIView? = nil, text:String, messageView: inout MessageView?, buttonText:String, buttonAction: @escaping () -> (), dismissButtonAction: (() -> ())? = nil) {
        messageView = show(inView: view == nil ? mainWindow():view, text: text, dismissAfter: TimeInterval.infinity, type:type, buttonText:buttonText, buttonAction: buttonAction, dismissButtonAction:dismissButtonAction)
    }
    
    static fileprivate func dismissOverlay() {
        if dismissOverlayView.superview != nil {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                dismissOverlayView.alpha = 0.0
            }, completion: { (completed) in
                dismissOverlayView.removeFromSuperview()
            })
        }
    }
    
    static fileprivate func show(inView view:UIView?, text:String, dismissAfter dismissTime:TimeInterval, type: MessageType, buttonText:String? = nil,
                                 buttonAction: (() -> ())? = nil, dismissButtonAction: (() -> ())? = nil) -> MessageView? {
        
        guard Thread.current.isMainThread else {
            print("MessageView messages can be showed only when calling from Main thread!")
            return nil
        }
        
        guard let parentView = view else {
            print("Parent view is nil")
            return nil
        }
        
        if dismissOverlayView.superview == nil {
            dismissOverlayView.translatesAutoresizingMaskIntoConstraints = false
            dismissOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            //dismissOverlayView.addTarget(self, action: #selector(dismissOverlayClicked), for: UIControlEvents.touchUpInside)
            dismissOverlayView.alpha = 0.0
            parentView.addSubview(dismissOverlayView)
            
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[dismissOverlayView]-0-|",options: [],metrics: nil,views: ["dismissOverlayView":dismissOverlayView]))
            NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[dismissOverlayView]-0-|",options: [],metrics: nil,views: ["dismissOverlayView":dismissOverlayView]))
            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                dismissOverlayView.alpha = 1.0
            }, completion: nil)
        }
        
        let messageView = MessageView(withType: type, buttonText: buttonText, buttonAction:buttonAction, dismissButtonAction:dismissButtonAction)
        messageView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(messageView)
        
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[messageView]-0-|",options: [],metrics: nil,views: ["messageView":messageView]))
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "V:[messageView]-0-|",options: [],metrics: nil,views
            : ["messageView":messageView]))
        
        parentView.layoutIfNeeded()
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
    var errorLineColor = UIColor(red: 206.0/255.0, green:112.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    var infoLineColor = UIColor(red: 26.0/255.0, green: 147.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    var dismissActionButtonText = "Not Now".localized
    var buttonFont = UIFont.boldSystemFont(ofSize: 13)
    var font:UIFont = UIFont.systemFont(ofSize: 15)
    var textAlignment:NSTextAlignment = NSTextAlignment.left
}
