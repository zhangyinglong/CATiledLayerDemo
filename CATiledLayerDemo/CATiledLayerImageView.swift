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

    let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
    
    private var name: String!
    
    override open class var layerClass: Swift.AnyClass {
        get {
            return CATiledLayer.self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(frame: CGRect, name: String) {
        super.init(frame:frame)
        self.name = name
        
        let tiledLayer: CATiledLayer = self.layer as! CATiledLayer
        // levelsOfDetail and levelsOfDetailBias determine how
        // the layer is rendered at different zoom levels.  This
        // only matters while the view is zooming, since once the
        // the view is done zooming a new TiledImageView is created
        // at the correct size and scale.
        tiledLayer.contentsScale = UIScreen.main.scale
        tiledLayer.levelsOfDetail = 4
        tiledLayer.levelsOfDetailBias = 4
        tiledLayer.tileSize = CGSize(width: defaultTileSize, height: defaultTileSize)
    }
    
    override func draw(_ rect: CGRect) {
        
        let firstColumn = Int(rect.minX / defaultTileSize)
        let lastColumn = Int(rect.maxX / defaultTileSize)
        let firstRow = Int(rect.minY / defaultTileSize)
        let lastRow = Int(rect.maxY / defaultTileSize)
        
        for row in firstRow...lastRow {
            for column in firstColumn...lastColumn {
                if let tile = imageForTileAtColumn(column, row: row) {
                    let x = defaultTileSize * CGFloat(column)
                    let y = defaultTileSize * CGFloat(row)
                    let point = CGPoint(x: x, y: y)
                    let size = CGSize(width: defaultTileSize, height: defaultTileSize)
                    var tileRect = CGRect(origin: point, size: size)
                    tileRect = bounds.intersection(tileRect)
                    tile.draw(in: tileRect)
                }
            }
        }
    }

    func imageForTileAtColumn(_ column: Int, row: Int) -> UIImage? {
        let filePath = "\(cachesPath)/\(name)_\(column)_\(row)"
        return UIImage(contentsOfFile: filePath)
    }

}
