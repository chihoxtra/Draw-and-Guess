//
//  MainMenuViewController.swift
//  DrawAndGuess
//
//  Created by pun samuel on 22/8/15.
//  Copyright © 2015 Samuel Pun. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBAction func redButton(sender: AnyObject) {
    }
    
    @IBAction func greenButton(sender: AnyObject) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if (segue.identifier == "showDrawControllerMultiPlayer") {
            
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            
            let finalViewController = segue.destinationViewController as! GameViewController;
            finalViewController.gMultiPlayerMode = true
        } else if (segue.identifier == "showGuessControllerMultiPlayer") {
            _ = segue.destinationViewController as! GuessViewController;
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
