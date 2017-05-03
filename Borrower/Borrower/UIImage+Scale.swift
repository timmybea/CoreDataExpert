//
//  UIImage+Scale.swift
//  Borrowmatic
//
//  Created by TimBeals on 2017-05-02.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit

extension UIImage {
    
    fileprivate class func scaleImageToSize (image:UIImage, toSize size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func scaleImage (image:UIImage, toWidth width:CGFloat, andHeight height:CGFloat) -> UIImage? {
        let oldWidth = image.size.width
        let oldHeight = image.size.height
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight
        
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return UIImage.scaleImageToSize(image: image, toSize: newSize)
    }
}
