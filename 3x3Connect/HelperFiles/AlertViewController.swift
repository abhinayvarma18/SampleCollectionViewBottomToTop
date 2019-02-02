//
//  AlertViewController.swift
//  3x3Connect
//
//  Created by abhinay varma on 02/02/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import Foundation
import UIKit

class AlertViewController:UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func okClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var textValue:String?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorLabel.text = textValue ?? "Error"
    }
    
}
