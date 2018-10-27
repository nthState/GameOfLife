//
//  ViewController.swift
//  GameOfLife
//
//  Created by Chris Davis on 27/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController {

    @IBOutlet weak var mtkView: MTKView!
    var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let device = MTLCreateSystemDefaultDevice()!
        mtkView.device = device
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.framebufferOnly = false
        mtkView.drawableSize = self.view.frame.size
        
        renderer = Renderer(view: mtkView, device: device)
        mtkView.delegate = renderer
    }
}

