//
//  AppLoader.swift
//  3x3Connect
//
//  Created by abhinay varma on 02/02/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import Foundation
import UIKit

/// Used for ViewControllers that need to present an activity indicator when loading data.
public protocol AppLoaderPresenter {
    var bgIndicatorView:UIView { get }
    
    /// The activity indicator
    var activityIndicator: UIActivityIndicatorView { get }
    
    /// Show the activity indicator in the view
    func showActivityIndicator()
    
    /// Hide the activity indicator in the view
    func hideActivityIndicator()
}

public extension AppLoaderPresenter where Self: UIViewController {
    
    func showActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.view.addSubview((self?.bgIndicatorView)!)
            self?.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
                self?.activityIndicator.center = CGPoint(x: (self?.view.bounds.size.width)! / 2, y: (self?.view.bounds.height)! / 2)
            self?.bgIndicatorView.addSubview((self?.activityIndicator)!)
            self?.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.removeFromSuperview()
            self?.bgIndicatorView.removeFromSuperview()
        }
    }
}

