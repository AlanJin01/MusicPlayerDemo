//
//  ViewOfImage.swift
//  MusicPlay
//
//  Created by J K on 2019/1/15.
//  Copyright © 2019 Kims. All rights reserved.
//

import UIKit

class ViewOfImage: UIView {

    var imageViews: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        let image = UIImage(named: "role2-0")
        imageViews = UIImageView(image: image!)
        imageViews.frame = frame
        imageViews.layer.cornerRadius = frame.width/2
        imageViews.layer.masksToBounds = true
        imageViews.center = CGPoint(x: self.center.x, y: self.center.y)
        imageViews.contentMode = UIView.ContentMode.scaleToFill
        self.addSubview(imageViews)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
