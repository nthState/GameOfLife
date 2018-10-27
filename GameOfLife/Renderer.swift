//
//  Renderer.swift
//  GameOfLife
//
//  Created by Chris Davis on 27/10/2018.
//  Copyright © 2018 nthState. All rights reserved.
//

import Foundation
import Metal
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    
    let device: MTLDevice
    let mtkView: MTKView
    
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var seedLifeFunction:MTLFunction?
    var seedLifePipeline: MTLComputePipelineState!
    var gameOfLifeFunction:MTLFunction?
    var gameOfLifePipeline: MTLComputePipelineState!
    var blankTexture: MTLTexture!
    var threadsPerThreadgroup:MTLSize!
    var threadgroupsPerGrid: MTLSize!
    
    init(view: MTKView, device: MTLDevice) {
        self.mtkView = view
        self.device = device
        
        defaultLibrary = device.makeDefaultLibrary()!
        commandQueue = device.makeCommandQueue()
        
        gameOfLifeFunction = defaultLibrary.makeFunction(name: "GameOfLife")
        seedLifeFunction = defaultLibrary.makeFunction(name: "SeedLife")
        do {
            gameOfLifePipeline = try device.makeComputePipelineState(function: gameOfLifeFunction!)
            seedLifePipeline = try device.makeComputePipelineState(function: seedLifeFunction!)
        }
        catch {
            fatalError("Unable to create game of life pipeline state")
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: mtkView.currentDrawable!.texture.width,
            height: mtkView.currentDrawable!.texture.height,
            mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        blankTexture = self.device.makeTexture(descriptor: textureDescriptor)
        
        
        
        threadsPerThreadgroup = MTLSizeMake(1, 1, 1);
        threadgroupsPerGrid = MTLSizeMake(mtkView.currentDrawable!.texture.width / threadsPerThreadgroup.width,
                                          mtkView.currentDrawable!.texture.height / threadsPerThreadgroup.height,
                                          1);
        
        
        
        super.init()
        
        seedLife()
    }
    
    func seedLife() {
        
        var rand: Int32 = Int32.random(in: 1..<100)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(seedLifePipeline)
        commandEncoder.setTexture(blankTexture, index: 0)
        commandEncoder.setBytes(&rand, length: MemoryLayout<Int32>.stride, index: 0)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(gameOfLifePipeline)
        commandEncoder.setTexture(blankTexture, index: 0)
        commandEncoder.setTexture(mtkView.currentDrawable!.texture, index: 1)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder.endEncoding()
        commandBuffer.present(mtkView.currentDrawable!)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Swap texture
        blankTexture = mtkView.currentDrawable!.texture

    }
}

extension Renderer {
    
    //func debugGlider() {
        //        let commandBuffer1 = commandQueue.makeCommandBuffer()!
        //        let commandEncoder1 = commandBuffer1.makeComputeCommandEncoder()!
        //        commandEncoder1.setComputePipelineState(gameOfLifePipeline)
        //        commandEncoder1.setTexture(blankTexture, index: 0)
        //        commandEncoder1.setTexture(mtkView.currentDrawable!.texture, index: 1)
        //        commandEncoder1.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        //        commandEncoder1.endEncoding()
        //        commandBuffer1.present(mtkView.currentDrawable!)
        //        commandBuffer1.commit()
        //        commandBuffer1.waitUntilCompleted()
        //
        //        // Swap texture
        //        blankTexture = mtkView.currentDrawable!.texture
        //
        //        let commandBuffer11 = commandQueue.makeCommandBuffer()!
        //        let commandEncoder11 = commandBuffer11.makeComputeCommandEncoder()!
        //        commandEncoder11.setComputePipelineState(gameOfLifePipeline)
        //        commandEncoder11.setTexture(blankTexture, index: 0)
        //        commandEncoder11.setTexture(mtkView.currentDrawable!.texture, index: 1)
        //        commandEncoder11.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        //        commandEncoder11.endEncoding()
        //        commandBuffer11.present(mtkView.currentDrawable!)
        //        commandBuffer11.commit()
        //        commandBuffer11.waitUntilCompleted()
        //
        //        // Swap texture
        //        blankTexture = mtkView.currentDrawable!.texture
        //
        //
        //        let commandBuffer111 = commandQueue.makeCommandBuffer()!
        //        let commandEncoder111 = commandBuffer111.makeComputeCommandEncoder()!
        //        commandEncoder111.setComputePipelineState(gameOfLifePipeline)
        //        commandEncoder111.setTexture(blankTexture, index: 0)
        //        commandEncoder111.setTexture(mtkView.currentDrawable!.texture, index: 1)
        //        commandEncoder111.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        //        commandEncoder111.endEncoding()
        //        commandBuffer111.present(mtkView.currentDrawable!)
        //        commandBuffer111.commit()
        //        commandBuffer111.waitUntilCompleted()
        //
        //        // Swap texture
        //        blankTexture = mtkView.currentDrawable!.texture
        //
        //
        //        let commandBuffer1111 = commandQueue.makeCommandBuffer()!
        //        let commandEncoder1111 = commandBuffer1111.makeComputeCommandEncoder()!
        //        commandEncoder1111.setComputePipelineState(gameOfLifePipeline)
        //        commandEncoder1111.setTexture(blankTexture, index: 0)
        //        commandEncoder1111.setTexture(mtkView.currentDrawable!.texture, index: 1)
        //        commandEncoder1111.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        //        commandEncoder1111.endEncoding()
        //        commandBuffer1111.present(mtkView.currentDrawable!)
        //        commandBuffer1111.commit()
        //        commandBuffer1111.waitUntilCompleted()
        //
        //        // Swap texture
        //        blankTexture = mtkView.currentDrawable!.texture
    //}
    
}
