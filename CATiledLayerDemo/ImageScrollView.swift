//
//  ImageScrollView.swift
//  CATiledLayerDemo
//
//  Created by zhangyinglong on 2017/1/5.
//  Copyright © 2017年 ChinaHR. All rights reserved.
//

import UIKit
import QuartzCore

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    private var frontTiledView: CATiledLayerImageView? = nil
    
    public var backTiledView: CATiledLayerImageView? = nil
    
    private var backgroundImageView: UIImageView? = nil
    
    private var minimumScale: CGFloat = 0
    
    private var imageScale: CGFloat = 0
    
    public var image: UIImage? = nil
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(frame: CGRect, image: UIImage) {
        super.init(frame: frame)
        
        // Set up the UIScrollView
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.bouncesZoom = true;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.maximumZoomScale = 5.0;
        self.minimumZoomScale = 0.25;
        
        // determine the size of the image
        self.image = image;
        var imageRect: CGRect = CGRect(x: 0, y: 0, width: image.cgImage!.width, height: image.cgImage!.height)
        imageScale = self.frame.size.width/imageRect.size.width
        print("imageScale: ", imageScale)
        minimumScale = imageScale * 0.75
        imageRect.size = CGSize(width: imageRect.size.width*imageScale, height: imageRect.size.height*imageScale);
        
        // Create a low res image representation of the image to display before the CATiledLayerImageView
        // renders its content.
        UIGraphicsBeginImageContext(imageRect.size);
        let context: CGContext = UIGraphicsGetCurrentContext()!;
        context.saveGState()
        context.draw(image.cgImage!, in: imageRect)
        context.restoreGState()
        let backgroundImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView?.frame = imageRect;
        backgroundImageView?.contentMode = .scaleAspectFit
        self.addSubview(backgroundImageView!)
        self.sendSubview(toBack: backgroundImageView!)
        
        // Create the CATiledLayerImageView based on the size of the image and scale it to fit the view.
        frontTiledView = CATiledLayerImageView(frame: imageRect, image: image, scale: imageScale)
        self.addSubview(frontTiledView!)
    }

    // We use layoutSubviews to center the image in the view
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // center the image as it becomes smaller than the size of the screen
        let boundsSize: CGSize  = self.bounds.size;
        var frameToCenter: CGRect = frontTiledView!.frame;
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        } else {
            frameToCenter.origin.x = 0;
        }
        // center vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        } else {
            frameToCenter.origin.y = 0;
        }
        frontTiledView?.frame = frameToCenter;
        backgroundImageView?.frame = frameToCenter;
        // to handle the interaction between CATiledLayer and high resolution screens, we need to manually set the
        // tiling view's contentScaleFactor to 1.0. (If we omitted this, it would be 2.0 on high resolution screens,
        // which would cause the CATiledLayer to ask us for tiles of the wrong scales.)
        frontTiledView?.contentScaleFactor = 1.0;
    }
    
    // A UIScrollView delegate callback, called when the user starts zooming.
    // We return our current CATiledLayerImageView.
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView {
        return frontTiledView!
    }
    
    // A UIScrollView delegate callback, called when the user stops zooming.  When the user stops zooming
    // we create a new CATiledLayerImageView based on the new zoom level and draw it on top of the old CATiledLayerImageView.
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // set the new scale factor for the CATiledLayerImageView
        imageScale = imageScale * scale;
        if( imageScale < minimumScale ) {
            imageScale = minimumScale;
        }
        let imageRect: CGRect  = CGRect(x: 0, y: 0,
                                        width: CGFloat(image!.cgImage!.width) * imageScale,
                                        height: CGFloat(image!.cgImage!.height) * imageScale);
        // Create a new CATiledLayerImageView based on new frame and scaling.
        frontTiledView = CATiledLayerImageView(frame: imageRect, image: image!, scale: imageScale)
        self.addSubview(frontTiledView!)
    }
    
    // A UIScrollView delegate callback, called when the user begins zooming.  When the user begins zooming
    // we remove the old CATiledLayerImageView and set the current CATiledLayerImageView to be the old view so we can create a
    // a new CATiledLayerImageView when the zooming ends.
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        backTiledView?.removeFromSuperview()
        self.backTiledView = frontTiledView
    }

}
