//
//  ScrollerViewController.swift
//  CATiledLayerDemo
//
//  Created by zhangyinglong on 2017/1/6.
//  Copyright © 2017年 ChinaHR. All rights reserved.
//

import UIKit

class ScrollerViewController: UIViewController, UIScrollViewDelegate {

    private lazy var hugeImage: UIImage = {
       return UIImage(contentsOfFile: Bundle.main.path(forResource: ImageFilename, ofType: nil)!)
    }()!
    
    private lazy var scrollerView: UIScrollView = {
        let scroll = UIScrollView(frame: self.view.bounds)
        scroll.delegate = self
        scroll.showsVerticalScrollIndicator = false;
        scroll.showsHorizontalScrollIndicator = false;
        scroll.bouncesZoom = false;
        scroll.decelerationRate = UIScrollViewDecelerationRateFast;
        scroll.delegate = self;
        scroll.maximumZoomScale = 100.0
        scroll.minimumZoomScale = 0.3
        return scroll
    }()
    
    private lazy var imageView: UIImageView = {
        let width = self.hugeImage.size.width
        let height = self.hugeImage.size.height
        return UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
    }()
    
    private lazy var tiledLayerImageView: CATiledLayerImageView = {
        let width = self.imageView.frame.size.width
        let height = self.imageView.frame.size.height
        self.scrollerView.contentSize = CGSize(width: width, height: height)
        let view = CATiledLayerImageView(frame: CGRect(x: 0, y: 0, width: width, height: height),
                                         image: self.hugeImage,
                                         scale: 1.0)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.addSubview(self.tiledLayerImageView)
        self.scrollerView.addSubview(self.imageView)
        self.view.addSubview(self.scrollerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func frameForImageView(image: UIImage, scroll: UIScrollView) -> CGRect {
        let imageSize: CGSize = image.size;
        var scaleWidth: CGFloat = 0;
        var scaleHeight: CGFloat = 0;
        var scaleOriginX: CGFloat = 0;
        var scaleOriginY: CGFloat = 0;
        
        if (UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)) {
            scaleWidth = scroll.frame.width;
            scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
            scaleOriginY = (scroll.frame.height - scaleHeight) / 2;
        } else {
            if (imageSize.height / imageSize.width > 2) { //长图
                scaleWidth = scroll.frame.width;
                scaleHeight = imageSize.height / (imageSize.width / scaleWidth);
                scaleOriginY = (scroll.frame.height - scaleHeight) / 2;
                scaleOriginX = (scroll.frame.width - scaleWidth) / 2;
            } else { //一般图
                scaleHeight = scroll.frame.height;
                scaleWidth = image.size.width / (image.size.height / scaleHeight);
                scaleOriginX = (scroll.frame.width - scaleWidth) / 2;
            }
        }
        
        scroll.contentSize = scroll.bounds.size;
        
        if (scaleHeight > scroll.frame.height) {
            scaleOriginY = 0;
            scroll.contentSize = CGSize(width: scroll.frame.width, height: scaleHeight);
        }
        return CGRect(x: scaleOriginX, y: scaleOriginY, width: scaleWidth, height: scaleHeight);
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        scrollView.zoomScale = scale
//    }
}
