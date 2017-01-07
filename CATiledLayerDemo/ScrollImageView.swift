//
//  ScrollImageView.swift
//  CATiledLayerDemo
//
//  Created by zhangyinglong on 2017/1/6.
//  Copyright © 2017年 ChinaHR. All rights reserved.
//

import UIKit

class ScrollImageView: UIScrollView, UIScrollViewDelegate {

    private var imageSize: CGSize = .zero
    
    private var pointToCenterAfterResize: CGSize = .zero
    
    private var scaleToRestoreAfterResize: CGSize = .zero

    private var tilingView: CATiledLayerImageView?
    
//    private var tilingView: CATiledLayerImageView = {
//        let tilingView = CATiledLayerImageView(frame: .zero, image: nil, scale: 0)
//        
//        return tilingView
//    }()
    
    private lazy var zoomView: UIImageView = {
        let zoomView = UIImageView(frame: .zero)
        
        return zoomView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.bouncesZoom = true;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // UIScrollViewDelegate
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // center the zoom view as it becomes smaller than the size of the screen
        let boundsSize: CGSize = self.bounds.size
        var frameToCenter: CGRect = zoomView.frame
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        zoomView.frame = frameToCenter
    }
    
    func displayTiledImageNamed(imageName: String, size: CGSize) {
        zoomView.removeFromSuperview()
        
        // reset our zoomScale to 1.0 before doing any further calculations
        self.zoomScale = 1.0
        
        // make views to display the new image
        zoomView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//        zoomView.image
        self.addSubview(zoomView)

//        tilingView = CATiledLayerImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height),
//                                           image: nil,
//                                           scale: self.zoomScale)
//        tilingView?.frame = zoomView.bounds;
//        zoomView.addSubview(tilingView!)
        
        self.configureForImageSize(size: size)
    }
    
    func configureForImageSize(size: CGSize) {
        imageSize = size
        self.contentSize = imageSize
        self.setMaxMinZoomScalesForCurrentBounds()
        self.zoomScale = self.minimumZoomScale
    }
    
    func setMaxMinZoomScalesForCurrentBounds() {
        let boundsSize: CGSize = self.bounds.size
        
        // calculate min/max zoomscale
        let xScale = boundsSize.width  / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = boundsSize.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
        
        // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
        let imagePortrait: Bool = imageSize.height > imageSize.width
        let phonePortrait: Bool = boundsSize.height > boundsSize.width
        var minScale: CGFloat = imagePortrait == phonePortrait ? xScale : min(xScale, yScale)
        
        // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
        // maximum zoom scale to 0.5.
        let maxScale: CGFloat = 1.0 / UIScreen.main.scale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if (minScale > maxScale) {
            minScale = maxScale
        }
        
        self.maximumZoomScale = maxScale
        self.minimumZoomScale = minScale
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
}
