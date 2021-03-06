//
//  UIView.swift
//  TeachUs
//
//  Created by ios on 10/25/17.
//  Copyright © 2017 TeachUs. All rights reserved.
//

import Foundation

extension UIView {
        
        func left() -> CGFloat {
            return frame.origin.x
        }
        
        func setLeft(_ x: CGFloat) {
            var frame: CGRect = self.frame
            frame.origin.x = x
            self.frame = frame
        }
        
        func top() -> CGFloat {
            return frame.origin.y
        }
        
        func setTop(_ y: CGFloat) {
            var frame: CGRect = self.frame
            frame.origin.y = y
            self.frame = frame
        }
        
        func right() -> CGFloat {
            return frame.origin.x + frame.size.width
        }
        
        func setRight(_ `right`: CGFloat) {
            var frame: CGRect = self.frame
            frame.origin.x = `right` - frame.size.width
            self.frame = frame
        }
        
        func bottom() -> CGFloat {
            return frame.origin.y + frame.size.height
        }
        
        func setBottom(_ bottom: CGFloat) {
            var frame: CGRect = self.frame
            frame.origin.y = bottom - frame.size.height
            self.frame = frame
        }
        
        func centerX() -> CGFloat {
            return center.x
        }
        
        func setCenterX(_ centerX: CGFloat) {
            center = CGPoint(x: centerX, y: CGFloat(center.y))
        }
        
        func centerY() -> CGFloat {
            return center.y
        }
        
        func setCenterY(_ centerY: CGFloat) {
            center = CGPoint(x: CGFloat(center.x), y: centerY)
        }
        
        func width() -> CGFloat {
            return frame.size.width
        }
        
        func setWidth(_ width: CGFloat) {
            var frame: CGRect = self.frame
            frame.size.width = width
            self.frame = frame
        }
        
        func height() -> CGFloat {
            return frame.size.height
        }
        
        func setHeight(_ height: CGFloat) {
            var frame: CGRect = self.frame
            frame.size.height = height
            self.frame = frame
        }
        
        func origin() -> CGPoint {
            return frame.origin
        }
        
        func setOrigin(_ origin: CGPoint) {
            var frame: CGRect = self.frame
            frame.origin = origin
            self.frame = frame
        }
        
        func size() -> CGSize {
            return frame.size
        }
        
        func setSize(_ size: CGSize) {
            var frame: CGRect = self.frame
            frame.size = size
            self.frame = frame
        }
        
        func makeEdgesRoundedWith(radius:CGFloat){
            self.layer.cornerRadius = radius
            self.clipsToBounds = true
        }
        
        func makeEdgesRounded(){
            self.makeEdgesRoundedWith(radius: 10.0)
        }
}
