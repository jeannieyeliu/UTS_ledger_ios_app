//
//  AnimSegue.swift
//  MoMo
//
//  Created by 刘烨 on 27/5/19.
//  Copyright © 2019 Clima. All rights reserved.
//

import UIKit

class AnimSegue: UIStoryboardSegue {
    override func perform() {
        scale()
    }
    
    func scale()  {
        let toViewController = self.destination
        let fromViewController = self.source
        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center
        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        containerView?.addSubview(toViewController.view)
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
            toViewController.view.transform = CGAffineTransform.identity
            }, completion: {
                success in
                fromViewController.present(toViewController, animated: false, completion: nil)
        })
    }
}

class BackSegue: UIStoryboardSegue {
    override func perform() {
        scale()
    }
    
    func scale()  {
        let toViewController = self.destination
        let fromViewController = self.source
//        let containerView = fromViewController.view.superview
//        let originalCenter = fromViewController.view.center
//        toViewController.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
//        containerView?.addSubview(toViewController.view)
        
        fromViewController.view.superview?.insertSubview(toViewController.view, at: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
            toViewController.view.transform =  CGAffineTransform(translationX: 0.05, y: 0.05)
            //CGAffineTransform(scaleX: 0.05, y: 0.05)
        }, completion: {
            success in
            fromViewController.dismiss(animated: false, completion: nil)
        })
    }
}
