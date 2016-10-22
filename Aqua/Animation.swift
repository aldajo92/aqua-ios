//
//  Animation.swift
//  Aqua
//
//  Created by Edgard Aguirre Rozo on 10/21/16.
//  Copyright © 2016 Edgard Aguirre Rozo. All rights reserved.
//

import Foundation
import UIKit

struct LoadingIndicatorViewConfig {
    static let AnimationFileNameFormat = "mic_active_%i"
}

class LoadingIndicatorView: UIImageView {
    override init (frame : CGRect) {
        super.init(frame : frame)
        configureInterFace()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureInterFace()
    }
    
    private func configureInterFace() {
        let format = LoadingIndicatorViewConfig.AnimationFileNameFormat
        setAnimationImagesWithImageNameFormat(format: format)
        backgroundColor = UIColor.clear
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        alpha = 0.0
    }
    
    override func startAnimating() {
        super.startAnimating()
        alpha = 1.0
    }
}
