//
//  PartyMode.swift
//  Tipple
//
//  Created by Adrian Sanchez on 11/29/23.
//

import UIKit

class PartyModeAnimationView: UIView {

    func startAnimation() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: bounds.size.width, height: 1)

        emitter.emitterCells = []
        emitter.emitterCells?.append(generateParticle(imageName: "Confetti"))
        emitter.emitterCells?.append(generateParticle(imageName: "PartyFace"))
        emitter.emitterCells?.append(generateParticle(imageName: "Champagne"))
        emitter.emitterCells?.append(generateParticle(imageName: "ClinkingGlasses"))

        layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emitter.removeFromSuperlayer()
            self.removeFromSuperview()
        }
    }
    
    func stopPartyMode() {
        layer.sublayers?.filter { $0 is CAEmitterLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    func generateParticle(imageName: String) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 7
        cell.lifetime = 20.0
        cell.velocity = 300
        cell.velocityRange = 100
        cell.emissionLongitude = CGFloat.pi
        cell.spinRange = 5
        cell.scale = 0.05
        cell.scaleRange = 0.1
        cell.contents = UIImage(named: imageName)?.cgImage
        return cell
    }
}

