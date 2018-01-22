//
//  Appearance.swift
//  2DoList
//
//  Created by Marko Tribl on 1/7/18.
//  Copyright © 2018 Marko Tribl. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

struct Appearance {
    static func setGlobalAppearance(for application: UIApplication) {
        let color = UIColor.flatBlue
        let contrastColor = ContrastColorOf(color, returnFlat: true)
        UINavigationBar.appearance().tintColor = contrastColor
        UINavigationBar.appearance().barTintColor = color
        UINavigationBar.appearance().isTranslucent = false
//        UINavigationBar.appearance().barStyle = .blackOpaque
        
        application.statusBarStyle = .lightContent
        
        print(UIColor.flatBlue.hexValue())
        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        } else {
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
    }
    
    static func setGradiantColor(for view: UIView) {
        view.backgroundColor = GradientColor(UIGradientStyle.topToBottom, frame: view.frame, colors: [UIColor.flatBlueDark, UIColor.flatBlue, UIColor.flatWhite])
    }
}

extension String {
    func strikeThroughStyle(_ isChecked: Bool) -> NSMutableAttributedString {
        let atributedString = NSMutableAttributedString(string: self)
        
        if isChecked {
            atributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, atributedString.length))
        }
        
        return atributedString
    }
}
