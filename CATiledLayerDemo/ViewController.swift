//
//  ViewController.swift
//  CATiledLayerDemo
//
//  Created by zhangyinglong on 2017/1/5.
//  Copyright © 2017年 ChinaHR. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore
import YYWebImage

class ViewController: UIViewController, UIScrollViewDelegate {

    // The input image file
    private var sourceImage: UIImage?
    // output image file
    public var destImage: UIImage?
    // sub rect of the input image bounds that represents the
    // maximum amount of pixel data to load into mem at one time.
    private var sourceTile: CGRect = .zero
    // sub rect of the output image that is proportionate to the
    // size of the sourceTile.
    private var destTile: CGRect = .zero
    // the ratio of the size of the input image to the output image.
    private var imageScale: CGFloat = 0.0
    // source image width and height
    private var sourceResolution: CGSize = .zero
    // total number of pixels in the source image
    private var sourceTotalPixels: CGFloat = 0.0
    // total number of megabytes of uncompressed pixel data in the source image.
    private var sourceTotalMB: CGFloat = 0.0
    // output image width and height
    private var destResolution: CGSize = .zero
    // the temporary container used to hold the resulting output image pixel
    // data, as it is being assembled.
    private var destContext: CGContext?
    // the number of pixels to overlap tiles as they are assembled.
    private var sourceSeemOverlap: CGFloat = 0.0
    // an image view to visualize the image as it is being pieced together
    private var progressView: UIImageView?
    // a scroll view to display the resulting downsized image
    private var scrollView: ImageScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        progressView = UIImageView(frame: self.view.bounds)
        self.view.addSubview(progressView!)
        
        Thread.detachNewThreadSelector(#selector(downsize), toTarget: self, with: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downsize(arg: Any) {
        // create an autorelease pool to catch calls to -autorelease.
        autoreleasepool {
            // create an image from the image filename constant. Note this
            // doesn't actually read any pixel information from disk, as that
            // is actually done at draw time.
            sourceImage = UIImage(contentsOfFile: Bundle.main.path(forResource: ImageFilename, ofType: nil)!)
            if( sourceImage == nil ) {
                print("input image not found!")
                return
            }
            
            // get the width and height of the input image using
            // core graphics image helper functions.
            sourceResolution.width = CGFloat((sourceImage?.cgImage?.width)!)
            sourceResolution.height = CGFloat((sourceImage?.cgImage?.height)!)
            
            // use the width and height to calculate the total number of pixels
            // in the input image.
            sourceTotalPixels = sourceResolution.width * sourceResolution.height;
            
            // calculate the number of MB that would be required to store
            // this image uncompressed in memory.
            sourceTotalMB = sourceTotalPixels / pixelsPerMB;
            
            // determine the scale ratio to apply to the input image
            // that results in an output image of the defined size.
            // see kDestImageSizeMB, and how it relates to destTotalPixels.
            imageScale = destTotalPixels / sourceTotalPixels;
            
            // use the image scale to calcualte the output image width, height
            destResolution.width = sourceResolution.width * imageScale;
            destResolution.height = sourceResolution.height * imageScale;
            
            // create an offscreen bitmap context that will hold the output image
            // pixel data, as it becomes available by the downscaling routine.
            // use the RGB colorspace as this is the colorspace iOS GPU is optimized for.
            let colorSpace: CGColorSpace = self.colorSpaceForImage(image: (sourceImage?.cgImage)!)
            let bytesPerRow = Int(bytesPerPixel) * Int(destResolution.width);
            
            // allocate enough pixel data to hold the output image.
            let destBitmapData = malloc( bytesPerRow * Int(destResolution.height) );
            if( destBitmapData == nil ) {
                print("failed to allocate space for the output image!")
                return
            }
            
            // create the output bitmap context
            destContext = CGContext( data: destBitmapData,
                                     width: Int(destResolution.width),
                                     height: Int(destResolution.height),
                                     bitsPerComponent: 8,
                                     bytesPerRow: Int(bytesPerRow),
                                     space: colorSpace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue );
            // remember CFTypes assign/check for nil. NSObjects assign/check for nil.
            if( destContext == nil ) {
                print("failed to create the output bitmap context!")
                return
            }

            // flip the output graphics context so that it aligns with the
            // cocoa style orientation of the input document. this is needed
            // because we used cocoa's UIImage -imageNamed to open the input file.
            destContext!.translateBy( x: 0.0, y: destResolution.height );
            destContext!.scaleBy( x: 1.0, y: -1.0 );
            
            // now define the size of the rectangle to be used for the
            // incremental blits from the input image to the output image.
            // we use a source tile width equal to the width of the source
            // image due to the way that iOS retrieves image data from disk.
            // iOS must decode an image from disk in full width 'bands', even
            // if current graphics context is clipped to a subrect within that
            // band. Therefore we fully utilize all of the pixel data that results
            // from a decoding opertion by achnoring our tile size to the full
            // width of the input image.
            sourceTile.size.width = sourceResolution.width;
            
            // the source tile height is dynamic. Since we specified the size
            // of the source tile in MB, see how many rows of pixels high it
            // can be given the input image width.
            sourceTile.size.height = ( tileTotalPixels / sourceTile.size.width )
            print("source tile size: ", sourceTile.size.width, " x ", sourceTile.size.height)
            sourceTile.origin.x = 0.0;
            
            // the output tile is the same proportions as the input tile, but
            // scaled to image scale.
            destTile.size.width = destResolution.width;
            destTile.size.height = sourceTile.size.height * imageScale;
            destTile.origin.x = 0.0;
            print("dest tile size: ", destTile.size.width, " x ", destTile.size.height)
            
            // the source seem overlap is proportionate to the destination seem overlap.
            // this is the amount of pixels to overlap each tile as we assemble the ouput image.
            sourceSeemOverlap = ( ( destSeemOverlap / destResolution.height ) * sourceResolution.height );
            print("dest seem overlap: ", destSeemOverlap, ", source seem overlap: ", sourceSeemOverlap)
            
            var sourceTileImage: CGImage? = nil
            // calculate the number of read/write opertions required to assemble the
            // output image.
            var iterations = ( sourceResolution.height / sourceTile.size.height )
            
            // if tile height doesn't divide the image height evenly, add another iteration
            // to account for the remaining pixels.
            let remainder = Int(sourceResolution.height) % Int(sourceTile.size.height)
            if( remainder > 0 ) {
                iterations += 1
            }
            
            // add seem overlaps to the tiles, but save the original tile height for y coordinate calculations.
            let sourceTileHeightMinusOverlap = Int(sourceTile.size.height)
            sourceTile.size.height += sourceSeemOverlap;
            destTile.size.height += destSeemOverlap;
            print("beginning downsize. iterations: ", iterations, ", tile height: ", sourceTile.size.height, ", remainder height: ",remainder)
            
            //
            for y in 0 ..< Int(iterations) {
                // create an autorelease pool to catch calls to -autorelease made within the downsize loop.
                autoreleasepool {
                    print("iteration ", y+1, " of ", Int(iterations))
                    sourceTile.origin.y = CGFloat(y * sourceTileHeightMinusOverlap) + sourceSeemOverlap;
                    destTile.origin.y = destResolution.height - CGFloat( ( y + 1 ) * sourceTileHeightMinusOverlap * Int(imageScale) ) + destSeemOverlap
                    
                    // create a reference to the source image with its context clipped to the argument rect.
                    sourceTileImage = sourceImage?.cgImage?.cropping(to: sourceTile)
                    
                    // if this is the last tile, it's size may be smaller than the source tile height.
                    // adjust the dest tile size to account for that difference.
                    if( y == Int(iterations) - 1 && remainder > 0 ) {
                        var dify = destTile.size.height;
                        destTile.size.height = CGFloat((sourceTileImage?.height)!) * imageScale;
                        dify -= destTile.size.height;
                        destTile.origin.y += dify;
                    }
                    
                    // read and write a tile sized portion of pixels from the input image to the output image.
                    destContext?.draw(sourceTileImage!, in: destTile)
                }
                
                // we reallocate the source image after the pool is drained since UIImage -imageNamed
                // returns us an autoreleased object.
                if( y < Int(iterations) - 1 ) {
                    sourceImage = UIImage(contentsOfFile: Bundle.main.path(forResource: ImageFilename, ofType: nil)!)
                    self.performSelector(onMainThread: #selector(updateScrollView), with: nil, waitUntilDone: true)
                }
            } // end autoreleasepool
            print("downsize complete.")
            self.performSelector(onMainThread: #selector(initializeScrollView), with: nil, waitUntilDone: true)
        } // end autoreleasepool
    }
    
    func createImageFromContext() {
        // create a CGImage from the offscreen image context
        let destImage = destContext!.makeImage()
        if ( destImage == nil ) {
            print("destImageRef is null.")
        }
        
        // wrap a UIImage around the CGImage
        self.destImage = UIImage(cgImage: destImage!, scale: 1.0, orientation: .downMirrored)
    }
    
    func updateScrollView() {
        self.createImageFromContext()
        // display the output image on the screen.
        progressView?.image = destImage
    }
    
    func initializeScrollView() {
        progressView?.removeFromSuperview()
        self.createImageFromContext()
        
        // create a scroll view to display the resulting image.
        scrollView = ImageScrollView(frame: self.view.bounds, image: destImage!)
        self.view.addSubview(scrollView!)
    }
    
    func colorSpaceForImage(image: CGImage) -> CGColorSpace {
        // current
        var colorspace: CGColorSpace = image.colorSpace!;
        let imageColorSpaceModel: CGColorSpaceModel = colorspace.model
        let unsupportedColorSpace = ( imageColorSpaceModel == CGColorSpaceModel.unknown
            || imageColorSpaceModel == CGColorSpaceModel.monochrome
            || imageColorSpaceModel == CGColorSpaceModel.cmyk
            || imageColorSpaceModel == CGColorSpaceModel.indexed )
        if ( unsupportedColorSpace ) {
            colorspace = CGColorSpaceCreateDeviceRGB()
        }
        return colorspace;
    }
}

