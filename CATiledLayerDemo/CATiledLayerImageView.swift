//
//  CATiledLayerImageView.swift
//  CATiledLayerDemo
//
//  Created by zhangyinglong on 2017/1/5.
//  Copyright © 2017年 ChinaHR. All rights reserved.
//

import UIKit
import QuartzCore

class CATiledLayerImageView: UIView {

    public var image: UIImage!
    
    private var imageScale: CGFloat = 0
    
    private var imageRect: CGRect = .zero
    
    override open class var layerClass: Swift.AnyClass {
        get {
            return CATiledLayer.self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(frame: CGRect, image: UIImage, scale: CGFloat) {
        super.init(frame:frame)
        self.image = image
        self.imageRect = CGRect(x: 0, y: 0, width: image.cgImage!.width, height: image.cgImage!.height)
        self.imageScale = scale
        
        let tiledLayer: CATiledLayer = self.layer as! CATiledLayer
        // levelsOfDetail and levelsOfDetailBias determine how
        // the layer is rendered at different zoom levels.  This
        // only matters while the view is zooming, since once the
        // the view is done zooming a new TiledImageView is created
        // at the correct size and scale.
        tiledLayer.levelsOfDetail = 4
        tiledLayer.levelsOfDetailBias = 4
        tiledLayer.tileSize = CGSize(width: defaultTileSize, height: defaultTileSize)
    }
    
//    override func draw(_ rect: CGRect) {
//        let context: CGContext = UIGraphicsGetCurrentContext()!
//        context.saveGState()
//        context.scaleBy(x: imageScale, y: imageScale)
//        context.draw(image.cgImage!, in: imageRect)
//        context.restoreGState()
//    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.scaleBy(x: imageScale, y: imageScale)
        context.draw(image.cgImage!, in: imageRect)
        context.restoreGState()
        
//        let scale = context.ctm.a
//        let tiledLayer: CATiledLayer = self.layer as! CATiledLayer
//
//        var tileSize: CGSize = tiledLayer.tileSize
//        tileSize.width /= scale
//        tileSize.height /= scale
//
//        
//        let firstCol = Int(rect.minX / tileSize.width)
//        let lastCol = Int(rect.maxX / tileSize.width)
//        let firstRow = Int(rect.minY / tileSize.height)
//        let lastRow = Int(rect.maxY / tileSize.height)
//
//        for row in firstRow ..< lastRow {
//            for col in firstCol ..< lastCol {
//                var tileRect: CGRect = CGRect(x: tileSize.width * CGFloat(col),
//                                              y: tileSize.height * CGFloat(row),
//                                              width: tileSize.width,
//                                              height: tileSize.height);
//                
//                // if the tile would stick outside of our bounds, we need to truncate it so as to avoid
//                // stretching out the partial tiles at the right and bottom edges
//                tileRect = self.bounds.intersection(tileRect);
//                
//                let tile = self.tileForScale(scale: scale, row: row, col: col,
//                                             width: tileRect.size.width,
//                                             height: tileRect.size.height)
//                tile.draw(in: tileRect)
//            }
//        }
    }

    func tileForScale(scale: CGFloat, row: Int, col: Int, width: CGFloat, height: CGFloat) -> UIImage {
        let x = CGFloat(row) * defaultTileSize
        let y = CGFloat(col) * defaultTileSize
        return UIImage(cgImage: (image.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height)))!)
    }
//
//    - (UIImage *)tileForScale:(CGFloat)scale row:(int)row col:(int)col {
//    
//    // we use "imageWithContentsOfFile:" instead of "imageNamed:" here because we don't want UIImage to cache our tiles
//    int scaleFactor = (int)(scale * 100);
//    NSString *tilename = [NSString stringWithFormat:@"1930-%d-%d-%d", scaleFactor, col+1, row+1];
//    NSLog(@"Tilename = %@", tilename);
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:tilename ofType:@"png" inDirectory:@"1930pngs"];
//    
//    NSLog(@"Path = %@", path);
//    
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
//    return image;
//    }

}
