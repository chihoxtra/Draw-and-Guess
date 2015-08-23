//
//  GuessViewController.swift
//  DrawAndGuess
//
//  Created by pun samuel on 22/8/15.
//  Copyright © 2015 Samuel Pun. All rights reserved.
//

import UIKit

class GuessViewController: UIViewController {

    @IBOutlet var myGuess: UITextField!
    
    @IBAction func sumitButton(sender: AnyObject) {
        submitNewGuess(myGuess.text!)
    }
    @IBOutlet var guessList: UITextView!
    
    @IBOutlet var broadcastedImageView: UIImageView!
    
    func submitNewGuess(ans: String) {
        if ans != "" {
            guessList.text = guessList.text + "\n" + ans
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
