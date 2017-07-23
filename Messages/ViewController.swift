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
        messageViewConfiguration.font = UIFont(name: "OpenSans", size: 16)!
        messageViewConfiguration.buttonFont = UIFont(name: "OpenSans-Bold", size: 13)!
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
        
//        var messageView:MessageView? = nil
//        MessageView.show(withType: .error, inView: view, text: "Notifications aren't enabled, this app requires notifications to be enabled to get downloads & alerts. Please update your settings", messageView: &messageView)
//        
//        
//        let delay = 4 * Double(NSEC_PER_SEC)
//        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
//        DispatchQueue.main.asyncAfter(deadline: time, execute: {
//            messageView?.dismiss()
//        })

        let delay1 = 0 * Double(NSEC_PER_SEC)
        let time1 = DispatchTime.now() + Double(Int64(delay1)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time1, execute: {
            MessageView.show(withType: .error, text: "Notifications aren't enabled, this app requires notifications to be enabled to get downloads & alerts. Please update your settings", buttonText: "UPDATE", buttonAction: {
                print("fix")
            })
        })
    }
}

