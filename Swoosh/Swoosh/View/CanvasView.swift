//
//  CanvasView.swift
//  Swoosh
//
//  Created by Sashen Pillay on 2019/03/24.
//  Copyright © 2019 Sashen Pillay. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    var strokes = [[CGPoint]]()

    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        self.backgroundColor = .white
        
        let context = UIGraphicsGetCurrentContext() ?? nil
        
        for stroke in strokes {
            for(i, s) in stroke.enumerated() {
                if ( i == 0) {
                    context?.move(to: s)
                } else {
                    context?.addLine(to: s)
                }
            }
        }
        
        context?.strokePath()
    }
    

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: nil) else { return }
        guard var lastStroke = strokes.popLast() else { return }
        lastStroke.append(point)
        strokes.append(lastStroke)
        setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        strokes.append([CGPoint]())
    }

}
