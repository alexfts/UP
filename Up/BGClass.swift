//
//  BGClass.swift
//  B-Popper
//
//  Created by Alex Fetisova and Reza Asad on 5/29/17.
//  Copyright © 2017 Alex Fetisova. All rights reserved.
//

import SpriteKit

class BGClass: SKSpriteNode
{
    func moveBG(camera : SKCameraNode)
    {
        if self.position.y + self.size.height < camera.position.y {
            self.position.y += self.size.height * 3
        }
    }
} // class

