//
//  LineAnimatedLabel.swift
//  TestProject
//
//  Created by ASAF LEVY on 29/05/2017.
//  Copyright © 2017 ASAF LEVY. All rights reserved.
//

import UIKit

class LineAnimatedLabel: UIView {

    static let defaultAppearanceCurve:[Float] = [0.000, 0.880, 0.605, 1]
    fileprivate var lineLabels:[UILabel] = []
    fileprivate var lineLabelsConstrains:[NSLayoutConstraint] = []
    fileprivate var verticalSpacing:CGFloat = 2
    fileprivate var views:[String:UIView] = [:]

    var textColor:UIColor = .black {
        didSet {
            lineLabels.forEach({ $0.textColor = textColor })
        }
    }
    var textAlignment:NSTextAlignment = .left {
        didSet {
            lineLabels.forEach({ $0.textAlignment = textAlignment })
        }
    }
    var text:String? {
        didSet {
            createAndLayoutLineLabels()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var font:UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            createAndLayoutLineLabels()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
        
    fileprivate func lineComponents() -> [String] {
        guard let textUnwrapped = text, bounds.width > 0 else {
            return []
        }
        let rectWidth = bounds.width
        let components = textUnwrapped.components(separatedBy: " ")
        var lines:[String] = []
        if components.count > 0 {
            var line = components[0]
            for index in 1..<components.count {
                let size = (line + " " + components[index]).size(attributes: [NSFontAttributeName: font])
                if size.width > rectWidth {
                    lines.append(line)
                    line = components[index]
                } else {
                    line = line + " " + components[index]
                }
            }
            let lastLine = line.trimmingCharacters(in: CharacterSet.whitespaces)
            if !lastLine.isEmpty {
                lines.append(lastLine)
            }
        }
        return lines
    }
    
    fileprivate func resetLayout()  {
        NSLayoutConstraint.deactivate(lineLabelsConstrains)
        lineLabels.forEach({ $0.removeFromSuperview() })
        lineLabels = []
        lineLabelsConstrains = []
        views = [:]
    }
    
    fileprivate func createLabel(withText text:String) -> UILabel {
        let lineLabel = UILabel()
        lineLabel.translatesAutoresizingMaskIntoConstraints = false
        lineLabel.font = font
        lineLabel.textAlignment = textAlignment
        lineLabel.text = text
        lineLabel.textColor = textColor
        lineLabel.alpha = 0.0
        return lineLabel
    }
    
    fileprivate func createAndLayoutLineLabels()  {
        resetLayout()
        let lines = lineComponents()
        var verticalVisualFormatString = ""
        for (index, line) in lines.enumerated() {
            let lineLabel = createLabel(withText: line)
            addSubview(lineLabel)
            lineLabels.append(lineLabel)
            
            let lineLabelName = "lineLabel\(index)"
            let labelVisualFormatString = "[\(lineLabelName)]"
            views[lineLabelName] = lineLabel

            //Vertical constraints
            verticalVisualFormatString += "-(verticalSpacing)-" + labelVisualFormatString
            if index == 0 {
                verticalVisualFormatString = "V:|-0-" + labelVisualFormatString
            }
            if index == (lines.count - 1) {
                verticalVisualFormatString += "-0-|"
                lineLabelsConstrains.append(contentsOf:  NSLayoutConstraint.constraints(
                    withVisualFormat: verticalVisualFormatString, options: [], metrics: ["verticalSpacing":verticalSpacing], views: views ))
            }
            
            //Horizontal constraints
            lineLabelsConstrains.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[\(lineLabelName)]-0-|", options: [],metrics: nil, views: ["\(lineLabelName)":lineLabel] ))
        }
        NSLayoutConstraint.activate(lineLabelsConstrains)
    }
    
    func prepareViewsForAppearanceAnimation()  {
        
        for (index, label) in lineLabels.enumerated() {
            label.alpha = 0.0
            label.transform = CGAffineTransform(translationX: 0, y: 10 + CGFloat(index*15))
        }
    }
    
    func animateIn(withDuration duration:TimeInterval, delay:TimeInterval = 0.0, curve:[Float] = defaultAppearanceCurve, completion:(() -> ())? = nil)  {
        prepareViewsForAppearanceAnimation()
        CATransaction.begin()
        let timingFunction = CAMediaTimingFunction(controlPoints: curve[0], curve[1], curve[2], curve[3])
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: duration, delay: delay,
                       options: [],
                       animations: {
                        self.lineLabels.forEach({
                            $0.alpha = 1.0
                            $0.transform = .identity
                        })
        }, completion: { (completed) in
            completion?()
        })
        CATransaction.commit()
    }
    
    func animateOut(withDuration duration:TimeInterval, delay:TimeInterval = 0.0, curve:[Float] = defaultAppearanceCurve, completion:(() -> ())? = nil)  {
        CATransaction.begin()
        let timingFunction = CAMediaTimingFunction(controlPoints: curve[0], curve[1], curve[2], curve[3])
        CATransaction.setAnimationTimingFunction(timingFunction)
        UIView.animate(withDuration: duration, delay: delay,
                       options: [],
                       animations: {
                        for (index, label) in self.lineLabels.reversed().enumerated() {
                            label.alpha = 0.0
                            label.transform = CGAffineTransform(translationX: 0, y: 10 + CGFloat((self.lineLabels.count -  (index + 1))*8))
                        }
        }, completion: { (completed) in
            completion?()
        })
        CATransaction.commit()
        
    }

}
