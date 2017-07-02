//
//  ViewController.swift
//  Messages
//
//  Created by ASAF LEVY on 02/06/2017.
//  Copyright © 2017 ASAF LEVY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var showBtn : UIButton = UIButton(type: .custom)


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        var messageViewConfiguration = MessageViewConfiguration()
        messageViewConfiguration.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
        messageViewConfiguration.textAlignment = .left
        MessageView.configuration = messageViewConfiguration
        
        showBtn.addTarget(self, action: #selector(showBtnClicked), for: UIControlEvents.touchUpInside)
        showBtn.setTitle("Show", for: .normal)
        showBtn.setTitleColor(.blue, for: .normal)
        showBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showBtn)

        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-50-[showBtn]-50-|",options: [],metrics: nil,views: ["showBtn":showBtn]))
        NSLayoutConstraint.activate( NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-100-[showBtn(70)]",options: [],metrics: nil,views: ["showBtn":showBtn]))        
    }
    
    
    func showBtnClicked() {
        
        var messageView:MessageView? = nil
        MessageView.showError(inView: view, withText: "Notifications aren't enabled, this app requires notifications to be enabled to get downloads & alerts. Please update your settings", messageView: &messageView)
        
        
        let delay = 4 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            messageView?.dismiss()
        })

        
        
//        let delay = 4 * Double(NSEC_PER_SEC)
//        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: time, execute: {
//            MessageView.showError(inView: self.view, withText: "Notifications aren't enabled", buttonText: "FIX", buttonAction: {
//                print("fixed")
//            })
//        })
//        
//        let delay1 = 8 * Double(NSEC_PER_SEC)
//        let time1 = DispatchTime.now() + Double(Int64(delay1)) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: time1, execute: {
//            MessageView.showInfo(inView: self.view, withText: "Notifications aren't enabled Notifications aren't enabled, yout must update your settings to get download & alerts update your settings to get download", buttonText: "FIX", buttonAction: {
//                print("fixed")
//            })
//        })
//        
//        let delay2 = 16 * Double(NSEC_PER_SEC)
//        let time2 = DispatchTime.now() + Double(Int64(delay2)) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: time2, execute: {
//            MessageView.showError(inView: self.view, withText: "Notifications aren't enabled")
//        })

//
//        let delay1 = 8 * Double(NSEC_PER_SEC)
//        let time1 = DispatchTime.now() + Double(Int64(delay1)) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: time1, execute: {
//            MessageView.show(withText: "Notifications aren't enabled, yout must update your settings to get download & alerts", dismissAfter: 2)
//        })

    }
}

