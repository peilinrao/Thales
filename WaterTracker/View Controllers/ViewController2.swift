//
//  ViewController2.swift
//  WaterTracker
//
//  Created by Peilin Rao on 8/9/19.
//  Copyright © 2019 Peilin. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
    @IBOutlet weak var main_title: UILabel!
    @IBOutlet weak var second_title: UILabel!
    @IBOutlet weak var button_text: UILabel!
    @IBOutlet weak var imageButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.main_title.center.x = self.view.center.x
        self.second_title.center.x = self.view.center.x
        self.button_text.center.x = self.view.center.x
        
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = #colorLiteral(red: 0.04537009448, green: 0.1424690783, blue: 0.2587065697, alpha: 1)
        self.imageButton.frame = CGRect(x: 40, y: 520, width: 100, height: 100)
        self.imageButton.center.x = self.view.center.x
        self.imageButton.layer.cornerRadius = 0.5 * self.imageButton.bounds.size.width
        self.imageButton.layer.borderColor = UIColor.lightGray.cgColor
        self.imageButton.layer.borderWidth = 1.0
        self.imageButton.clipsToBounds = true
        self.imageButton.setBackgroundImage(#imageLiteral(resourceName: "water logo.jpg"), for: .normal)
        self.view.addSubview(self.imageButton)
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
